---
layout: post
cover: 'assets/images/abstract-abstract-art-abstract-expressionism-3057821.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2020-05-22 00:00:00+00:00
title: Apache FTP Client... A Found Surprise
categories: jyeary
tags: java
subclass: 'post tag-java'
---

## Introduction
I was cleaning up my hard drive this Memorial Day weekend when I found a bunch of code I wrote many years ago. It is funny how hindsight is 20/20. The old code examples I found were in some cases awful by today's standards. At the time, I thought it looked pretty good. I guess as we celebrate 25 years of Java and me coding it, we should look at some code from dusty days past.

## Code

The code was originally written for Apache `commons-net-1.3.0`, but it still works and not a lot has changed with Apache... or FTP for decades. Let's look at some code. I did update some of it from its original state. I couldn't let it pass. It may have a little Java 8+ "enhancements".

```java
/*
 * FTPTransfer.java
 *
 * Created on January 23, 2004, 8:20 AM
 */

 /*
 * Copyright (C) 2004 John Yeary. All Rights Reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS," WITHOUT A WARRANTY OF ANY KIND. ALL
 * EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES,
 * INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. JOHN YEARY AND
 * ITS LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES OR LIABILITIES
 * SUFFERED BY LICENSEE AS A RESULT OF  OR RELATING TO USE, MODIFICATION
 * OR DISTRIBUTION OF THE SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL
 * JOHN YEARY OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR
 * FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE
 * DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY,
 * ARISING OUT OF THE USE OF OR INABILITY TO USE SOFTWARE, EVEN IF JOHN YEARY HAS
 * BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
 *
 * You acknowledge that Software is not designed, licensed or intended
 * for use in the design, construction, operation or maintenance of any
 * nuclear facility.
 */

package net.javanetwork.net;

/**
 *
 * @author John Yeary
 * @version $Revision$
 *
 * <p>
 * This class is designed to transfer files via FTP using the org.apache.commons.net framework.</p>
 */
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.SocketException;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.PatternSyntaxException;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPConnectionClosedException;
import org.apache.commons.net.ftp.FTPReply;

@NoArgsConstructor
@Data
public class FTPTransfer {

    private FTPClient ftp;
    private static final Logger log = Logger.getLogger(FTPTransfer.class.getCanonicalName());

    /**
     * The username to use to login to FTP server.
     */
    private String username;

    /**
     * The target FTP server hostname.
     */
    private String hostname;

    /**
     * Password for username.
     */
    private String password;

    /**
     * The target directory for where the files are to be placed.
     */
    private String targetDirectory;

    /**
     * File transfer type. It is usually {@link FTP#ASCII_FILE_TYPE}, or {@link FTP#BINARY_FILE_TYPE}. The default file
     * transfer type is ASCII.
     */
    private int fileType = FTP.ASCII_FILE_TYPE;

    /**
     * Logging level. The default logging level is INFO.
     */
    private Level logLevel = Level.INFO;

    /**
     * An array of files to be transferred.
     */
    private java.io.File[] files;

    /**
     * Indicates if the directory should be created on the remote FTP server if they do not exist.
     */
    private boolean createDirectories;

    /**
     * Connect to FTP server based on the hostname, username, and password set. If it encounters any issues connecting,
     * it will call the <code>disconnect()</code> method. This method also starts the default logging.
     */
    private void connect() {
        int replyCode;

        ftp = new FTPClient();

        try {

            if (hostname != null) {
                log.log(Level.INFO, "Connecting to {0}.", hostname);
                ftp.connect(hostname);
                log.log(Level.INFO, "User: {0}", username);
                ftp.login(username, password);
                log.log(Level.INFO, ftp.getReplyString());

                // Check to make sure we have a usable connection
                replyCode = ftp.getReplyCode();

                if (!FTPReply.isPositiveCompletion(replyCode)) {
                    log.log(Level.SEVERE, "FTP failed to connect with reply code: {0}", replyCode);
                    disconnect();
                }
            } else {
                log.log(Level.SEVERE, "No hostname set. Exiting application.");
                System.exit(1);
            }

        } catch (SocketException e) {
            log.log(Level.SEVERE, "SocketException on Connection");
            log.log(Level.SEVERE, e.getMessage());
        } catch (IOException e) {
            log.log(Level.SEVERE, "IOException on Connection");
            log.log(Level.SEVERE, e.getMessage());
        }
    }

    /**
     * Disconnect from connected FTP server.
     */
    private void disconnect() {
        try {
            log.log(Level.INFO, "Logging out.");
            ftp.logout();
        } catch (IOException ignored) {
        } finally {
            try {
                if (ftp.isConnected()) {
                    log.log(Level.INFO, "Disconnecting.");
                    ftp.disconnect();
                    log.log(Level.INFO, "Disconnected.");
                }
            } catch (IOException e) {
                log.log(Level.WARNING, "IOException on disconnect.");
                log.log(Level.WARNING, e.getMessage());
            }
        }
    }

    /**
     * Transfers a single file in ASCII or BINARY depending on the file type set using <code>setFileType</code>. The
     * default file transfer type is ASCII.
     *
     * @return
     */
    public boolean transferFiles() {
        int reply = 0;
        FileInputStream in;
        String[] targetDirectorySplit;

        // Connect to server.
        connect();

        // Check to see if we are connected before continuing
        if (ftp.isConnected()) {

            try {
                // Change to the requested directory
                reply = ftp.cwd(targetDirectory);
                log.log(Level.INFO, ftp.getReplyString());

                if (FTPReply.isNegativePermanent(reply) && reply == FTPReply.CODE_553) {
                    // Permission denied to target directory

                    log.log(Level.SEVERE, "{0} - Permission denied to target directory.", ftp.getReplyString());

                } else if (FTPReply.isNegativePermanent(reply) && reply == FTPReply.CODE_550) {
                    log.log(Level.INFO, "Directory: {0} does not not exist.", targetDirectory);
                    if (createDirectories) {

                        log.log(Level.INFO, "Attempting to create {0}.", targetDirectory);

                        //Split the target directory into tokens to create the directory and sub-directories
                        targetDirectorySplit = targetDirectory.split("/");

                        //Create the directory and sub-directories
                        for (String directory : targetDirectorySplit) {
                            log.log(Level.INFO, "Creating: {0}", directory);
                            reply = ftp.mkd(directory);
                            ftp.cwd(directory);
                            log.log(Level.INFO, ftp.getReplyString());
                        }
                        // Check the final response from server to decide if we should continue.
                        if (FTPReply.isNegativePermanent(reply)) {
                            disconnect();
                            return false;
                        }
                    } else {
                        log.log(Level.SEVERE, "Directory: {0} does not not exist, and the application is not set to create directories.", targetDirectory);
                        disconnect();
                        return false;
                    }
                }
            } catch (PatternSyntaxException e) {
                log.log(Level.SEVERE,
                        "The target directory format was not in typical UNIX style: /directory/subdirectory");
            } catch (IOException e) {
                log.log(Level.SEVERE, "Can not create directory {0}.", targetDirectory);
                log.log(Level.SEVERE, ftp.getReplyString());
                log.log(Level.SEVERE, e.getMessage());
            }
        }
        try {
            // Set the file type for data transfer
            ftp.setFileType(fileType);
            log.log(Level.INFO, ftp.getReplyString());

            //Start transferring the files.
            for (File file : files) {
                if (file != null) {
                    log.log(Level.INFO, "Opening FileInputStream to: {0}", file.getName());
                    in = new FileInputStream(file);
                    log.log(Level.INFO, "Transferring {0} to server.", file.getName());
                    ftp.storeFile(file.getName(), in);
                    reply = ftp.getReplyCode();
                    log.log(Level.INFO, ftp.getReplyString());
                    // close the FileInputStream
                    in.close();
                    log.log(Level.INFO, "FileInputStream closed.");
                }
            }

        } catch (FTPConnectionClosedException e) {
            log.log(Level.SEVERE, e.getMessage());
        } catch (FileNotFoundException e) {
            log.log(Level.SEVERE, e.getMessage());
        } catch (IOException e) {
            log.log(Level.SEVERE, e.getMessage());
        } finally {
            try {
                if (ftp.isConnected()) {
                    log.log(Level.INFO, "Disconnecting.");
                    ftp.disconnect();
                    log.log(Level.INFO, "Disconnected.");
                }
            } catch (IOException e) {
                log.log(Level.WARNING, "IOException on disconnect.");
                log.log(Level.WARNING, e.getMessage());
            }
        }
        return reply == 226;
    }
}
```

Here is an example of how to use it.

```java
package net.javanetwork.net;

import java.io.File;
import lombok.NoArgsConstructor;
import org.apache.commons.net.ftp.FTP;

@NoArgsConstructor
public class FTPExample {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        FTPTransfer ft = new FTPTransfer();
        File[] nf = new File[1];
        nf[0] = new File("java.png");
        ft.setFiles(nf);
        ft.setFileType(FTP.BINARY_FILE_TYPE); // The Default is FTP.ASCII
        ft.setHostname("speedtest.tele2.net");
        ft.setUsername("anonymous");
        ft.setPassword("anonymous");
        ft.setTargetDirectory("/upload");
        System.out.println(ft.transferFiles());
    }
}
```

It is interesting that this code is originally from 2004. The FTP host http://speedtest.tele2.net allows anonymous connections for testing upload and download speeds. A great feature is that it has downloadable files of various sizes for testing.
