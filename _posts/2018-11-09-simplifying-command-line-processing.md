---
layout: post
cover: 'assets/images/pexels-photo-784261.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2018-11-09 19:59:47+00:00
title: Simplifying Command Line Processing
categories: jyeary
tags: java
subclass: 'post tag-java'
---

## Introduction

I like many of you have spent many hours using [Apache Commons CLI](https://commons.apache.org/proper/commons-cli/) to create command line options. It does a great job. As the number of options, or groups increases, the framework begins to show its rough edges. A tool called [JCommander](http://jcommander.org/) which I mentioned in my post [Useful Java Frameworks](https://blog.johnyeary.com/2018/09/useful-java-frameworks/) really begins to shine. I will present two versions of the same command line processing, and let you decide.

## CLI.java

```java
    package com.bluelotussoftware.cli;
    
    import java.util.logging.Level;
    import java.util.logging.Logger;
    import org.apache.commons.cli.AlreadySelectedException;
    import org.apache.commons.cli.CommandLine;
    import org.apache.commons.cli.CommandLineParser;
    import org.apache.commons.cli.DefaultParser;
    import org.apache.commons.cli.HelpFormatter;
    import org.apache.commons.cli.Option;
    import org.apache.commons.cli.OptionGroup;
    import org.apache.commons.cli.Options;
    import org.apache.commons.cli.ParseException;
    
    /**
     *
     * @author <a href="mailto:jyeary@bluelotussoftware.com">John Yeary</a>
     * @version 1.0.0
     */
    public class CLI {
    
        private static final Options OPTIONS;
    
        static {
            OPTIONS = CLI.createOptions();
        }
    
        public static void main(String[] args) {
    
            CommandLineParser commandLineParser = new DefaultParser();
    
            try {
                CommandLine cmd = commandLineParser.parse(OPTIONS, args);
    
                if (cmd.getOptions().length == 0) {
                    CLI.help();
                    return;
                }
    
                if (cmd.hasOption('v')) {
                    System.out.println("Product Version: 1.0.0");
                }
    
                if(cmd.hasOption('i')) {
                    System.out.println("Starting interactive mode.");
                }
    
                if(cmd.hasOption("start")) {
                    System.out.println("Starting application");
                }
    
                if(cmd.hasOption("stop")) {
                    System.out.println("Stopping application");
                }
    
    
            } catch (AlreadySelectedException e) {
                CLI.help();
                Logger.getLogger(CLI.class.getName()).log(Level.SEVERE, null, e);
            } catch (ParseException e) {
                CLI.help();
                Logger.getLogger(CLI.class.getName()).log(Level.SEVERE, null, e);
            }
        }
    
        private static void help() {
            HelpFormatter formatter = new HelpFormatter();
            formatter.printHelp("CLI", OPTIONS);
        }
    
        private static Options createOptions() {
            Options options = new Options();
    
            OptionGroup mode = new OptionGroup();
    
            Option help = new Option("help", "Help");
    
            Option interactive = Option.builder("i")
                    .longOpt("interactive")
                    .desc("Starts the processor in interactive mode.")
                    .build();
    
            Option start = Option.builder().longOpt("start")
                    .desc("Start the application.")
                    .build();
    
            Option stop = Option.builder().longOpt("stop")
                    .desc("Stop the application.")
                    .build();
    
            Option properties = Option.builder("p")
                    .longOpt("properties")
                    .desc("List all properties")
                    .build();
    
            Option quit = Option.builder("q")
                    .longOpt("quit")
                    .desc("Quit the application.")
                    .build();
    
            Option version = Option.builder("v")
                    .longOpt("version")
                    .desc("The current version of the application.")
                    .build();
    
            mode.addOption(interactive);
            mode.addOption(start);
            mode.addOption(stop);
    
            options.addOptionGroup(mode);
            options.addOption(help);
            options.addOption(properties);
            options.addOption(quit);
            options.addOption(version);
    
            return options;
        }
    }
```
 
    usage: CLI
     -help              Help
     -i,--interactive   Starts the processor in interactive mode.
     -p,--properties    List all properties
     -q,--quit          Quit the application.
        --start         Start the application.
        --stop          Stop the application.
     -v,--version       The current version of the application.


## JCommanderCLI.java

```java
    package com.bluelotussoftware.cli;
    
    import com.beust.jcommander.JCommander;
    import com.beust.jcommander.Parameter;
    
    /**
     *
     * @author <a href="mailto:jyeary@bluelotussoftware.com">John Yeary</a>
     * @version 1.0.0
     */
    public class JCommanderCLI {
    
        @Parameter(names = {"-v", "--version"}, description = "The current version of the application.")
        private boolean version;
        @Parameter(names = {"-h", "--help"}, description = "Provides help to the user.", help = true)
        private boolean help;
        @Parameter(names = {"-q", "--quit"}, description = "Quit the application.")
        private boolean quit;
        @Parameter(names = {"-i", "--interactive"}, description = "Starts the processor in interactive mode.")
        private boolean interactive;
        @Parameter(names = "--start", description = "Start the application.")
        private boolean start;
        @Parameter(names = "--stop", description = "Stop the application.")
        private boolean stop;
        @Parameter(names = {"-p", "--properties"}, description = "List all of the configured properties.")
        private boolean props;
    
        public static void main(String[] args) {
    
            JCommanderCLI clic = new JCommanderCLI();
            JCommander jc = JCommander.newBuilder()
                    .addObject(clic)
                    .build();
            jc.parse(args);
            jc.setProgramName(JCommanderCLI.class.getCanonicalName());
    
            if (args.length == 0) {
                jc.usage();
                return;
            }
    
            clic.run();
        }
    
        public void run() {
    
            if (version) {
                System.out.println("CLICommander version 1.0.0");
            }
    
            if (interactive) {
                System.out.println("Starting interactive mode.");
            }
    
            if (start) {
                System.out.println("Starting application");
            }
    
            if (stop) {
                System.out.println("Stopping application");
            }
        }
    }
```

    Usage: com.bluelotussoftware.cli.JCommanderCLI [options]
      Options:
        -h, --help
          Provides help to the user.
        -i, --interactive
          Starts the processor in interactive mode.
          Default: false
        -p, --properties
          List all of the configured properties.
          Default: false
        -q, --quit
          Quit the application.
          Default: false
        --start
          Start the application.
          Default: false
        --stop
          Stop the application.
          Default: false
        -v, --version
          The current version of the application.
          Default: false

## Results

If you have come to the same conclusion as me, then you may want to simply include JCommander in your next development project. If you are already invested in Commons CLI, you can spend the time to convert it, but don't waste time if you are not encountering issues.

The Maven dependency can be found here:

    <dependency>
      <groupId>com.beust</groupId>
      <artifactId>jcommander</artifactId>
      <version>1.72</version>
    </dependency>
