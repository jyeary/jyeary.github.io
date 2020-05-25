---
layout: post
cover: 'assets/images/pexels-photo-209137.jpeg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2018-06-29 15:45:23+00:00
title: Apache Commons IO Directory Copying
categories: jyeary
tags: java
subclass: 'post tag-java'
---
### Introduction
I was having an issue with some code in a very large project, and I wasn't sure if it was my approach, or if it was a code issue. I think we have all been there before. I decided to check my approach. Well it turns out the approach was correct, but an unrelated piece of code was the issue.

This code is a simple version of the approach I used to copy directories. It is nothing magical, and uses Apache Commons IO. A project with great code, but lacking great documentation. It is better than a lot of projects though. I decided to publish this example for your enjoyment.

#### pom.xml
```xml
<code class="xml"><?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.bluelotusssoftware</groupId>
    <artifactId>cp-utils</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>
    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
    </properties>
    <inceptionYear>2018</inceptionYear>
    <organization>
        <name>Blue Lotus Software, LLC.</name>
        <url>http://bluelotussoftware.com</url>
    </organization>
    <developers>
        <developer>
            <id>jyeary</id>
            <name>John Yeary</name>
            <email>jyeary@bluelotussoftware.com</email>
            <organization>Blue Lotus Software, LLC.</organization>
            <organizationUrl>http://www.bluelotussoftware.com</organizationUrl>
            <url>http://javaevangelist.blogspot.com</url>
            <timezone>-6</timezone>
            <roles>
                <role>Principal</role>
                <role>Architect</role>
                <role>Developer</role>
            </roles>
        </developer>
    </developers>
    <licenses>
        <license>
            <name>Apache License, Version 2.0</name>
            <url>https://www.apache.org/licenses/LICENSE-2.0.txt</url>
            <comments>A business-friendly OSS license.</comments>
        </license>
    </licenses>
    <dependencies>
        <dependency>
            <groupId>commons-io</groupId>
            <artifactId>commons-io</artifactId>
            <version>2.6</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.7.0</version>
                <inherited>true</inherited>
                <configuration>
                    <source>${maven.compiler.source}</source>
                    <target>${maven.compiler.target}</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <version>3.1.0</version>
                <configuration>
                    <archive>
                        <manifest>
                            <mainClass>com.bluelotussoftware.utils.FileCopy</mainClass>
                        </manifest>
                    </archive>
                    <descriptorRefs>
                        <descriptorRef>jar-with-dependencies</descriptorRef>
                    </descriptorRefs>
                </configuration>
            </plugin>
        </plugins>
    </build>
    <name>FileCopy</name>
    <description>This is a simple use of the Apache Commons IO FileUtils to copy
        directories. This can compile to a self-contained super jar
        executable.</description>
</project>
</code>
```
#### FileCopy.java
```java
package com.bluelotussoftware.utils;

import java.io.File;
import java.io.IOException;
import org.apache.commons.io.FileUtils;

/**
    * A simple utility to copy files.
    *
    * @author John Yeary <jyeary@bluelotussoftware.com>
    * @version 1.0
    */
public class FileCopy {

    private static boolean deleteTarget = false;

    public static void main(String[] args) throws IOException {

        if (args.length < 2) {
            System.out.println("Usage: com.bluelotussoftware.utils.FileCopy <source> <target>");
            System.out.println("Usage: com.bluelotussoftware.utils.FileCopy <source> <target> <deleteTargetDirectory:true>");
            System.exit(1);
        }

        File source = new File(args[0]);
        File target = new File(args[1]);
        if (args.length == 3 && !args[2].isEmpty()) {
            deleteTarget = Boolean.parseBoolean(args[2]);
        }

        if (deleteTarget) {
            FileUtils.deleteDirectory(target);
        }
        FileUtils.copyDirectoryToDirectory(source, target);
    }
}
```
### Project
The Git source code for the project can be found on BitBucket here: [cp-utils](https://bitbucket.org/bluelotussoftware/cp-utils)
