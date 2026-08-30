---
layout: post
cover: 'assets/images/pexels-fecundap6-347226.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2026-08-30 09:00:00+00:00
title: "Working Smarter with Claude AI to Update Projects"
categories: [jyeary]
tags: [web, github-pages, dns, ai-assisted]
subclass: 'post tag-web tag-github-pages tag-dns tag-ai-assisted'
---

The landing page for my company domain, `bluelotussoftware.com`, had quietly stopped being correct. It's a small separate repository — a static Foundation 5 page served by GitHub Pages — and I went in meaning to do nothing more than fix a few broken links. I came out having repaired the DNS, restored HTTPS, recovered a lost image from the Internet Archive, and rewritten three metadata files that had been wrong for years. I did it as a working session with Claude Code, the same as the last couple of blog-plumbing posts here.

## The site was up — but only over HTTP

The page loaded fine at `http://bluelotussoftware.com`. Visiting `https://` threw a certificate error, and the GitHub Pages settings explained why: *"DNS check unsuccessful — your domain is pointed at an outdated IP address (DeprecatedIPError)."*

The apex `A` records still pointed at `192.30.252.153` and `192.30.252.154` — GitHub Pages addresses that were retired years ago. GitHub still answers plain HTTP on them out of inertia, but it will not issue a TLS certificate for a domain sitting on deprecated IPs. So the site had been HTTP-only for a long time and nobody noticed, because it *looked* fine.

## Fixing the DNS

The domain is on Squarespace now — it came over from Google Domains, nameservers and all. The changes:

- Replaced the apex `A` records with the current GitHub Pages set: `185.199.108.153` through `185.199.111.153`.
- Added the matching `AAAA` records (`2606:50c0:8000::153` through `8003::153`) so IPv6 clients resolve too.
- Left the `www` `CNAME` pointing at `bluelotussoftware.github.io`, which was already right.

Then a GitHub quirk: even after the new records had propagated worldwide, the Pages settings kept showing the old `DeprecatedIPError`. GitHub caches the result of its DNS check, and the **Check again** button is what forces a re-run. Two clicks later it flipped to "DNS check successful," GitHub requested a Let's Encrypt certificate, and a few minutes after that the **Enforce HTTPS** checkbox unlocked. Ticked it; `http://` now redirects to `https://`.

### A "not secure" warning that wasn't

Right after enabling HTTPS, my browser still showed "Not secure." A full browser restart cleared it.

Worth remembering that "the site is broken" and "my own machine is lying to me" look identical from the address bar. The tell here was that `openssl` and `curl` from the same machine failed the same way the browser did, while an external SSL test graded the site an A. When the local tools and the remote checks disagree, believe the remote checks.

## The missing logo, and the Internet's time machine

The page's logo was an `<img>` pointing at a Google Cloud Storage bucket:

```
https://storage.googleapis.com/bluelotussoftware/logos/Logo_500.gif
```

That URL now returns `403 Forbidden` — the bucket is no longer public, and I no longer had the original file anywhere. Hotlinking an asset from a service you've stopped paying attention to is exactly the kind of dependency that rots without a sound.

The Wayback Machine had it. Their availability API takes a URL and returns the closest snapshot:

```
http://archive.org/wayback/available?url=storage.googleapis.com/bluelotussoftware/logos/Logo_500.gif
```

That pointed at an April 2022 capture. Fetching it with the `im_` ("identity") modifier on the timestamp returns the raw bytes rather than the archive's wrapped viewer page:

```
https://web.archive.org/web/20220415222812im_/https://storage.googleapis.com/bluelotussoftware/logos/Logo_500.gif
```

Out came the original GIF, byte for byte. I committed it into the repo under `img/` and repointed both the `<img>` tag and a stray `background-image` rule in the CSS at the local copy. Now it cannot disappear again without me noticing, because it is version-controlled next to the page that uses it.

## Housekeeping: CNAME, robots.txt, sitemap.xml, humans.txt

While I was in there, a few small files had drifted out of correctness.

**`CNAME`** held three lines — the apex, `www`, and an old `code.` subdomain. GitHub Pages honors only one custom domain per repository; the extras did nothing. Trimmed to just `bluelotussoftware.com`.

**`robots.txt`** advertised a sitemap that did not exist:

```
Sitemap: http://bluelotussoftware.com/sitemap.xml
```

There was no `sitemap.xml` in the repo, and the URL was `http://` on a site that should be entirely HTTPS.

**`sitemap.xml`** — created it. For a one-page site it is almost trivially small: a single `<url>` entry for the homepage with a `lastmod` date. It earns its place mainly as something to grow into later, and it lets `robots.txt` point at something real. I fixed that line to `https://` and aimed it at the new file.

**`humans.txt`** was still the stock ZURB Foundation template that ships with the framework. It credited "Orbit" and "Reveal," and listed Sass and Sublime Text as the build tools — none of which this site actually uses. The [humans.txt](https://humanstxt.org/) convention is a small plain-text credits file: who built the site and what it is built with. I rewrote it to reflect reality — me, and the actual stack.

### Should the AI be in humans.txt?

Which raised a question I had not considered before. Claude did a real share of this work. Does it belong in the credits?

I don't think so — at least not in the `TEAM` section. The file is called *humans*.txt on purpose; the project that started it was a small reaction against the web becoming nothing but machine-readable metadata, a place to say *people made this*. An AI assistant sits in the same conceptual bucket as the framework and the hosting provider: a tool that helped, creditable under a `THANKS` line or a `SITE` note if you like, but not a member of the team. I left it out of that file and wrote this post instead, which is the honest place to describe how the work actually got done. The tag on this post is `ai-assisted`, same as the last couple.

## Cleaning out DNS cruft

One last pass. The company had a Google Workspace subscription that got cancelled, and the DNS zone still carried its fingerprints: a `google._domainkey` DKIM record, an `include:_spf.google.com` term in the SPF record, and a `gv-…dv.googlehosted.com` domain-verification `CNAME`. All dead weight now, and the SPF include in particular slightly widens who is authorized to send mail as the domain. I removed those, along with a stale `_acme-challenge` `TXT` record left over from a manual certificate run and an `ftp.` `CNAME` from a hosting setup two moves ago.

I checked that DNSSEC was still intact on the way out — the zone is signed and the `DS` record is registered in `.com`, so the chain validates. If that domain ever moves to different nameservers, the `DS` record has to be pulled at the registrar *first*, or the domain goes dark for anyone whose resolver validates signatures. Not today's problem, but worth writing down.

## What "working smarter" actually meant

None of this was hard, exactly. It was *fiddly* — a dozen small tasks, each needing one specific fact (which IP range, which archive URL format, which GitHub setting) and a way to confirm it had actually taken effect.

The value of doing it with an agent was not that it knew all those facts cold. It was the loop: change a record, query it back from three resolvers, check what GitHub sees, read the certificate, move on. Every step verified against reality instead of "that should work." An afternoon or more, compressed into an hour — and a landing page that now serves over HTTPS, with its logo intact and its metadata telling the truth.
