---
layout: post
cover: 'assets/images/pexels-industrial-gears-39277869.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2026-08-31 09:00:00+00:00
title: "Apache Camel: SFTP Content-Aware and Batch-Completion Route Policy"
categories: [jyeary]
tags: [java, camel, spring-boot, sftp, integration, ai-assisted]
subclass: 'post tag-java tag-camel tag-spring-boot tag-sftp tag-integration tag-ai-assisted'
---

Most Camel polling examples answer one question: *when does the poller run?* A cron on the
endpoint, a `repeatCount`, a timer, an empty-poll check. They are all **time-driven** — the schedule
decides when to start and something mechanical decides when to stop.

A lot of real integrations have a different shape. An upstream system drops a known *set* of files
every night — `REPORT_A.csv` and `REPORT_B.csv`, say — but not necessarily at the same moment. You
want the poller to wake on a schedule, stay awake and keep polling until the whole expected batch
has landed, and then get out of the way until tomorrow. The thing that decides "we're done" is not
the clock — it's the **content** that has arrived.

This post is one clean way to build that with stock Camel primitives: a `RoutePolicy` that watches
for a named batch and suspends the consumer once it's complete, paired with a
`CronScheduledRoutePolicy` that wakes it again. It comes out of a small reference project,
`camel-sftp-rest`, that puts four SFTP polling patterns side by side; this is the fourth.

## The pattern in one sentence

Separate *when to look* from *when to stop*: a cron route policy owns wake-up, a content-aware route
policy owns shut-down, and the SFTP endpoint itself has no scheduler at all.

## The route policy

`SFTPRoutePolicy` extends `RoutePolicySupport`. It is constructed with the file names it expects,
records each one as it is processed, and — the first moment every expected name has been seen —
suspends the route's consumer and resets for the next batch.

```java
// Apache 2.0 license header omitted
package com.bluelotussoftware.camel.sftp.route.policy;

import lombok.extern.slf4j.Slf4j;
import org.apache.camel.Exchange;
import org.apache.camel.Route;
import org.apache.camel.support.RoutePolicySupport;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.locks.ReentrantLock;

/**
 * A route policy that watches an SFTP consumer route for a known set of file names
 * ({@code sftp.expected-files}) and, once every one of them has been received, suspends the
 * route's consumer - parking the poller until something resumes it. For the {@code sftp-policy}
 * route that "something" is a {@link org.apache.camel.routepolicy.quartz.CronScheduledRoutePolicy}
 * firing on {@code sftp.policyCron}.
 *
 * <p>Progress is tracked in a single {@code received} set, so this policy must be attached to
 * exactly one route.</p>
 */
@Slf4j
@Component
public class SFTPRoutePolicy extends RoutePolicySupport {

    private final ReentrantLock lock = new ReentrantLock();
    private final Set<String> expected;
    private final Set<String> received = new HashSet<>();

    public SFTPRoutePolicy(@Value("${sftp.expected-files}") final List<String> expected) {
        this.expected = Set.copyOf(expected);
    }

    /**
     * Records each processed file and, when the full expected batch has been received, suspends
     * the route's consumer and resets for the next batch.
     */
    @Override
    public void onExchangeDone(final Route route, final Exchange exchange) {
        final String file = exchange.getIn().getHeader(Exchange.FILE_NAME_ONLY, String.class);
        if (file == null || !expected.contains(file)) {
            return;
        }

        lock.lock();
        try {
            received.add(file);
            log.info("{}: received {}/{} expected files {}", route.getId(), received.size(), expected.size(), received);

            if (received.containsAll(expected)) {
                log.info("{}: expected batch complete - suspending consumer until the next scheduled wake",
                        route.getId());
                received.clear();
                suspendOrStopConsumer(route.getConsumer());
            }
        } catch (Exception e) {
            handleException(e);
        } finally {
            lock.unlock();
        }
    }

    @Override
    public void onStop(final Route route) {
        lock.lock();
        try {
            received.clear();
        } finally {
            lock.unlock();
        }
    }

    @Override
    public void onSuspend(final Route route) {
        log.info("{}: route suspended", route.getId());
    }

    @Override
    public void onResume(final Route route) {
        log.info("{}: route resumed", route.getId());
    }
}
```

A few things worth pointing at:

- **`onExchangeDone` is the hook.** `RoutePolicySupport` gives you lifecycle callbacks
  (`onStart`, `onStop`, `onSuspend`, `onResume`) *and* per-exchange callbacks (`onExchangeBegin`,
  `onExchangeDone`). The per-exchange one is what lets a policy react to traffic content rather than
  just to route state.
- **`suspendOrStopConsumer(route.getConsumer())`** is a protected helper on `RoutePolicySupport`.
  It suspends the consumer if it is suspendable and stops it otherwise. Suspending is the good case
  here: the route definition stays live, JMX still reports it, and a resume is cheap.
- **The `received` set is instance state**, guarded by a `ReentrantLock` because the SFTP consumer
  and a control-bus / management thread can touch the policy concurrently. Because that state is a
  single field, one instance of this policy belongs to exactly one route. If you need it on several
  routes, make it prototype-scoped or key the progress by `route.getId()`.
- **It resets itself.** `received.clear()` runs both when the batch completes and in `onStop`, so
  the next wake starts from an empty batch. Unexpected file names and a missing `CamelFileNameOnly`
  header are simply ignored, and a repeated expected file doesn't advance the count (a `Set`).

## The route that wires it together

`SFTPPolicyRoute` is the interesting half. Note what is *missing* from the `from(...)` URI: there is
no `scheduler=quartz`. The endpoint does not schedule itself. Two route policies drive the entire
lifecycle.

```java
// Apache 2.0 license header omitted
package com.bluelotussoftware.camel.sftp.route;

import com.bluelotussoftware.camel.sftp.route.policy.SFTPRoutePolicy;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.camel.LoggingLevel;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.routepolicy.quartz.CronScheduledRoutePolicy;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.net.ConnectException;

/**
 * A schedule-driven, batch-aware SFTP poller. Its lifecycle is driven entirely by two route
 * policies: a {@link CronScheduledRoutePolicy} that wakes the consumer on {@code sftp.policyCron},
 * and {@link SFTPRoutePolicy}, which suspends the consumer again as soon as every file listed in
 * {@code sftp.expected-files} has been received.
 */
@Component
@Slf4j
@RequiredArgsConstructor
public class SFTPPolicyRoute extends RouteBuilder {

    private final SFTPRoutePolicy batchPolicy;

    @Value("${sftp.policyCron}")
    private String policyCron;

    @Override
    public void configure() throws Exception {

        CronScheduledRoutePolicy schedule = new CronScheduledRoutePolicy();
        // Action.START starts a stopped route and also resumes one whose consumer
        // batchPolicy has suspended, so a single cron is enough here.
        schedule.setRouteStartTime(policyCron);

        onException(ConnectException.class)
                .handled(true)
                .log(LoggingLevel.WARN, "sftp-policy: SFTP not reachable, will retry on the next scheduled wake");

        from("sftp:{{sftp.host}}:{{sftp.port}}{{sftp.directory}}"
                + "?username={{sftp.username}}"
                + "&password={{sftp.password}}"
                + "&noop=true"
                + "&idempotent=true"
                + "&idempotentKey=${file:name}-${file:size}-${file:modified}"
                + "&include={{sftp.include}}"
                // while awake, poll this often until the expected batch is complete
                + "&delay={{sftp.policyPollDelay}}"
                + "&throwExceptionOnConnectFailed=true"
                + "&bridgeErrorHandler=true"
                + "&connectTimeout={{sftp.connectTimeout}}"
                + "&timeout={{sftp.timeout}}"
                + "&disconnect=true"
                // deliberately no scheduler=quartz - the route policies drive the lifecycle
            )
                .routeId("sftp-policy")
                .routePolicy(schedule, batchPolicy)
                .log("Received file ${header.CamelFileName} (${header.CamelFileLength} bytes)")
                .to("file://{{file.output.uri}}")
                .log("Saved ${header.CamelFileNameOnly} to: {{file.output.uri}}");
    }
}
```

The one subtlety that makes this compact: `CronScheduledRoutePolicy.setRouteStartTime(...)` fires
`Action.START`, and in Camel that action both *starts* a stopped route **and** *resumes* one whose
consumer has been suspended. So a single cron expression covers both "begin the day's run" and
"come back from a park." You do not need a separate resume trigger.

`disconnect=true` matters more than it looks. While the consumer is suspended there are no polls, so
there is no idle SSH session sitting open between batches — the route costs nothing until the cron
wakes it.

## Configuration

```properties
# names the SFTPRoutePolicy waits for before it parks the route (must match sftp.include)
sftp.expected-files=REPORT_A.csv,REPORT_B.csv
sftp.include=^(REPORT_A|REPORT_B)\\.csv$

# plain (space-separated) Quartz cron for the CronScheduledRoutePolicy that wakes the route
sftp.policyCron=0 0/1 * 1/1 * ? *

# how often to poll *while awake*, until the expected batch is complete
sftp.policyPollDelay=5000
```

## What it does at runtime

```
cron fires  ──►  route starts / consumer resumes
                     │
                     ▼
              poll every policyPollDelay ms
                     │
        REPORT_A.csv arrives ─► received = {A}      (batch incomplete, keep polling)
                     │
        REPORT_B.csv arrives ─► received = {A, B}   (containsAll(expected) → true)
                     │
                     ▼
        SFTPRoutePolicy.suspendOrStopConsumer()  ──►  consumer parked, received cleared
                     │
                     ▼
              idle — no polls, no SSH session — until the next cron tick
```

An integration test with a Testcontainers `atmoz/sftp` server pins exactly that: drop only
`REPORT_A.csv` and the consumer keeps polling and is **not** suspended; drop `REPORT_B.csv` and
within a couple of seconds the consumer reports `isSuspended() == true`; wait one more cron tick and
it is running again.

## Why it's worth reusing

- **Content-driven lifecycle.** The decision to stop is "the expected artifacts are all here,"
  which is what the business actually cares about. Most polling idioms can only express "stop after
  N polls" or "stop on the first empty poll."
- **Separation of concerns.** Wake-up and shut-down are two small, independent objects. The cron
  policy has no idea what a batch is; the batch policy has no idea about schedules. Each is trivially
  unit-testable — the batch policy with plain Mockito (mock the `Route` and a suspendable
  `Consumer`), no Camel context required.
- **Cheap between batches.** A suspended consumer holds no connection and burns no poll cycles, but
  stays warm for an instant cron resume. That is materially cheaper than a stop/start cycle, and far
  cheaper than polling an SFTP server every few seconds around the clock to catch a nightly drop.
- **It composes.** `.routePolicy(schedule, batchPolicy)` takes a varargs list. You can stack a
  `ThrottlingRoutePolicy`, a metrics policy, or your own alongside these two without any of them
  knowing about the others.

## Caveats

- **Single route per policy instance.** The progress `Set` is a field. Attaching one instance to
  two routes will cross their batches. Scope it per-route if you need more than one.
- **In-memory progress.** If the JVM restarts mid-batch, `received` is empty again — the route will
  re-notice the already-downloaded files only if your idempotent repository is durable
  (the example's is in-memory, so on restart it would re-fetch). For an at-least-once file mover
  that is usually fine; if it isn't, back the idempotent repository with something persistent.
- **The batch definition is static.** `sftp.expected-files` is fixed config. A batch whose members
  vary by day (a date in the filename, a manifest file) needs the expected set computed at wake
  time rather than injected once — a good extension point: override `onStart`/`onResume` to
  recompute `expected`.
- **No timeout on an incomplete batch.** If `REPORT_B.csv` never shows up, the route stays awake
  polling until the *next* cron tick (which re-issues `Action.START` harmlessly). If you need an
  alert for "batch didn't complete by 02:00," that's a third policy or a scheduled check.

## Generalizing past SFTP

Nothing here is FTP-specific. `RoutePolicySupport.onExchangeDone` fires for any consumer, so the
same shape works for a File component draining a landing directory, an S3 poller, or a JMS queue
where a control message signals "end of batch." The reusable idea is the split: **let a schedule
decide when to start looking, and let the data decide when you're finished.**

---

*Cover photo: ["Close-up view of interlocking industrial gears"](https://www.pexels.com/photo/close-up-view-of-interlocking-industrial-gears-39277869/)
by [Rafael Minguet Delgado](https://www.pexels.com/@thales13/) on Pexels.*
