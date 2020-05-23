---
layout: post
cover: 'assets/images/yellow-trees-and-brown-roof-3210189.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2020-05-23 00:00:00+00:00
title: Simple SMTP Client
categories: jyeary
tags: java
subclass: 'post tag-java'
---
## Introduction
I was cleaning up my hard drive when I came across another simple and easy to use SMTP client using plain Java (no frameworks required). This was written originally written in 2004 with just some minor updates prior to publishing here.

## Code

```java
/*
 * SimpleTextMessage.java
 *
 * Created on August 7, 2004, 7:46 PM
 */

/*
 * Copyright (C) 2004 JavaNetwork, LLC. All Rights Reserved.
 * Copyright (C) 2004-2020 Blue Lotus Holdings, LLC. All Rights Reserved.
 *
 * This software is provided "AS IS," without a warranty of any kind. ALL
 * EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES,
 * INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. Blue Lotus Software AND
 * ITS LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES OR LIABILITIES
 * SUFFERED BY LICENSEE AS A RESULT OF  OR RELATING TO USE, MODIFICATION
 * OR DISTRIBUTION OF THE SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL
 * Blue Lotus Software OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR
 * FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE
 * DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY,
 * ARISING OUT OF THE USE OF OR INABILITY TO USE SOFTWARE, EVEN IF Blue Lotus Software HAS
 * BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
 *
 * You acknowledge that Software is not designed, licensed or intended
 * for use in the design, construction, operation or maintenance of any
 * nuclear facility.
 */

package net.javanetwork.mail.smtp;

import com.sun.mail.smtp.SMTPAddressSucceededException;
import com.sun.mail.smtp.SMTPMessage;
import com.sun.mail.smtp.SMTPSendFailedException;
import com.sun.mail.smtp.SMTPTransport;
import java.io.IOException;
import java.util.Date;
import java.util.Properties;
import javax.activation.DataHandler;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.internet.InternetAddress;

/**
 * @author John Yeary
 * @version 0.1
 */

/**
 * Creates a simple single part RFC822 text message.
 */
public class SimpleTextMessage {

    private boolean auth = false;
    private String user = null;
    private String password = null;
    private String smtphost = null;
    private InternetAddress from = null;
    private InternetAddress[] to = null;
    private InternetAddress[] cc = null;
    private InternetAddress[] bcc = null;
    private String subject = null;
    private String message = null;
    private Properties props = null;
    private SMTPMessage msg = null;
    private SMTPTransport t = null;
    private DataHandler dh = null;
    private boolean verbose = false;

    /**
     * Constructs a new instance of SimpleTextMessage with the specified SMTP
     * mail server that requires user authorization. It also has a flag to turn
     * on verbose output (default is false).
     *
     * @param smtphost SMTP mail host
     * @param user user name for authorization
     * @param password password
     * @param from sender
     * @param to recipient addresses
     * @param subject subject
     * @param message text of the message
     * @param verbose boolean flag to turn on verbose output
     */
    public SimpleTextMessage(String smtphost, String user, String password, InternetAddress from,
            InternetAddress[] to, String subject, String message, boolean verbose) {
        this.smtphost = smtphost;
        this.user = user;
        this.password = password;
        this.from = from;
        this.to = to;
        this.subject = subject;
        this.message = message;
        this.verbose = verbose;

        auth = true;

        props = System.getProperties();
        props.put("mail.smtp.host", smtphost);
        props.put("mail.smtp.sendpartial", Boolean.TRUE);
        props.put("mail.smtp.dsn.notify", "SUCCESS,FAILURE");
        props.put("mail.smtp.dsn.ret", "FULL");
        props.put("mail.smtp.reportsuccess", Boolean.TRUE);
    }

    /**
     * Constructs a new instance of SimpleTextMessage with the specified SMTP
     * mail server that requires user authorization. It also has a flag to turn
     * on verbose output (default is false).
     *
     * @param smtphost SMTP mail host
     * @param user user name for authorization
     * @param password password
     * @param from sender
     * @param to recipient addresses
     * @param cc carbon copy recipient addresses
     * @param subject subject
     * @param message text of the message
     * @param verbose boolean flag to turn on verbose output
     */
    public SimpleTextMessage(String smtphost, String user, String password, InternetAddress from,
            InternetAddress[] to, InternetAddress[] cc, String subject, String message, boolean verbose) {
        this(smtphost, user, password, from, to, subject, message, verbose);
        this.cc = cc;
    }

    /**
     * Constructs a new instance of SimpleTextMessage with the specified SMTP
     * mail server that requires user authorization. It also has a flag to turn
     * on verbose output (default is false).
     *
     * @param smtphost SMTP mail host
     * @param user user name for authorization
     * @param password password
     * @param from sender
     * @param to recipient addresses
     * @param cc carbon copy recipient addresses
     * @param bcc blind carbon copy recipient addresses
     * @param subject subject
     * @param message text of the message
     * @param auth
     * @param verbose boolean flag to turn on verbose output
     */
    public SimpleTextMessage(String smtphost, String user, String password, InternetAddress from,
            InternetAddress[] to, InternetAddress[] cc, InternetAddress[] bcc, String subject, String message,
            boolean auth, boolean verbose) {
        this(smtphost, user, password, from, to, cc, subject, message, verbose);
        this.bcc = bcc;
    }

    /**
     * Constructs a new instance of SimpleTextMessage with the specified SMTP
     * mail server that requires user authorization. It also has a flag to turn
     * on verbose output (default is false).
     *
     * @param smtphost SMTP mail host
     * @param user user name for authorization
     * @param password password
     * @param from sender
     * @param to recipient addresses
     * @param bcc blind carbon copy recipient addresses
     * @param subject subject
     * @param message text of the message
     * @param auth
     * @param verbose boolean flag to turn on verbose output
     */
    public SimpleTextMessage(String smtphost, String user, String password, InternetAddress from,
            InternetAddress[] to, InternetAddress[] bcc, String subject, String message,
            boolean auth, boolean verbose) {
        this(smtphost, user, password, from, to, subject, message, verbose);
        this.bcc = bcc;
    }

    /**
     * Constructs a new instance of SimpleTextMessage with the specified SMTP
     * mail server that does not require user authorization. It also has a flag
     * to turn on verbose output (default is false).
     *
     * @param smtphost SMTP mail host
     * @param from sender
     * @param to recipient addresses
     * @param subject subject
     * @param message text of the message
     * @param verbose boolean flag to turn on verbose output
     */
    public SimpleTextMessage(String smtphost, InternetAddress from,
            InternetAddress[] to, String subject, String message, boolean verbose) {
        this(smtphost, null, null, from, to, subject, message, verbose);
    }

    /**
     * Constructs a new instance of SimpleTextMessage with the specified SMTP
     * mail server that does not require user authorization. It also has a flag
     * to turn on verbose output (default is false).
     *
     * @param smtphost SMTP mail host
     * @param from sender
     * @param to recipient addresses
     * @param cc carbon copy recipient addresses
     * @param subject subject
     * @param message text of the message
     * @param verbose boolean flag to turn on verbose output
     */
    public SimpleTextMessage(String smtphost, InternetAddress from,
            InternetAddress[] to, InternetAddress[] cc, String subject, String message, boolean verbose) {
        this(smtphost, from, to, subject, message, verbose);
        this.cc = cc;
    }

    /**
     * Constructs a new instance of SimpleTextMessage with the specified SMTP
     * mail server that does not require user authorization. It also has a flag
     * to turn on verbose output (default is false).
     *
     * @param smtphost SMTP mail host
     * @param from sender
     * @param to recipient addresses
     * @param cc carbon copy recipient addresses
     * @param bcc blind carbon copy recipient addresses
     * @param subject subject
     * @param message text of the message
     * @param verbose boolean flag to turn on verbose output
     */
    public SimpleTextMessage(String smtphost, InternetAddress from,
            InternetAddress[] to, InternetAddress[] cc, InternetAddress[] bcc, String subject, String message, boolean verbose) {
        this(smtphost, from, to, cc, subject, message, verbose);
        this.bcc = bcc;
    }

    /**
     * Constructs a new instance of SimpleTextMessage with the specified SMTP
     * mail server that does not require user authorization. It also has a flag
     * to turn on verbose output (default is false).
     *
     * @param smtphost SMTP mail host
     * @param from sender
     * @param to recipient addresses
     * @param bcc blind carbon copy recipient addresses
     * @param subject subject
     * @param message text of the message
     * @param verbose boolean flag to turn on verbose output
     */
    public SimpleTextMessage(String smtphost, InternetAddress from, InternetAddress[] to, String subject,
            String message, InternetAddress[] bcc, boolean verbose) {
        this(smtphost, from, to, null, bcc, subject, message, verbose);
    }

    /**
     * Constructs a new instance of SimpleTextMessage with the specified SMTP
     * mail server that does not require user authorization. verbose output is
     * disabled.
     *
     * @param smtphost SMTP mail host
     * @param from sender
     * @param to recipient addresses
     * @param subject subject
     * @param message text of the message
     *
     */
    public SimpleTextMessage(String smtphost, InternetAddress from,
            InternetAddress[] to, String subject, String message) {
        this(smtphost, from, to, subject, message, false);
    }

    /**
     * Create a simple SMTP text/plain message and send it.
     */
    public void create() {
        Session session = Session.getDefaultInstance(props, null);

        try {
            msg = new SMTPMessage(session);
            msg.setHeader("X-Mailer", "JavaNetwork SimpleTextMessage MUA 0.1");
            msg.setFrom(from);
            msg.setRecipients(Message.RecipientType.TO, to);

            if (cc != null && cc.length > 0) {
                msg.setRecipients(Message.RecipientType.CC, cc);
            }

            if (bcc != null && bcc.length > 0) {
                msg.setRecipients(Message.RecipientType.BCC, bcc);
            }

            if (subject != null && subject.length() > 0) {
                msg.setSubject(subject);
            }

            msg.setSentDate(new Date());
            dh = new DataHandler(message, "text/plain");
            msg.setDataHandler(dh);

            // Set the SMTP transport to use the current session
            t = (SMTPTransport) session.getTransport("smtp");
            t.setReportSuccess(false); // report successfully sent message as SMTPSendSucceededException

            // Check for SMTP server authorization requirements
            if (auth) {
                t.connect(smtphost, user, password);
            } else {
                t.connect();
            }
            // Extract all of the recipients from the message and send
            SMTPTransport.send(msg, msg.getAllRecipients());
            System.out.println("All Messages Sent");

        /* It appears that the SMTPSendSuccededException and SMTPSendFailedExceptions are never
         * returned from the SMTP host. Further investigation is necessary as to why this does not
         * happen. The code is left "as is" until a solution is determined. The order of the exceptions
         * may need to be changed to chain the SMTPSendSuccededException from the SMTPSendFailedException.
         */
        } catch (SMTPAddressSucceededException sse) {
            while (sse.getNextException() != null) {
                System.out.println(sse.toString());
                System.out.println("SUCCEEDED");

                if (verbose) {
                    System.out.println("Address: " + sse.getAddress());
                    System.out.println("Command: " + sse.getCommand());
                    System.out.println("Return Code: " + sse.getReturnCode());
                    System.out.println("Response: " + sse.getMessage());
                    System.out.println("Message:");
                    try {
                        msg.writeTo(System.out);
                    } catch (IOException | MessagingException ignored) {
                    }
                }
            }

        } catch (SMTPSendFailedException sfe) {
            while (sfe.getNextException() != null) {
                System.out.println(sfe.toString());
                System.out.println("FAILED");

                if (verbose) {
                    System.out.println("Command: " + sfe.getCommand());
                    System.out.println("Return Code: " + sfe.getReturnCode());
                    System.out.println("Response: " + sfe.getMessage());
                }
            }

        } catch (MessagingException me) {
            System.out.println("Messaging exception!");
            me.printStackTrace(System.out);

        } finally {
            try {
                // Close connection
                t.close();
            } catch (MessagingException ignored) {
            } //Already Closed
        }
    }
}
```