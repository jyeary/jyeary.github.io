---
layout: post
cover: 'assets/images/boats-canoes-daytime-2907206.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
comments: true
date: 2019-10-15 15:50:47+00:00
title: Multiple Java Persistence API (JPA) persistence.xml Merging
categories:
- Java
tags:
- java
subclass: 'post tag-Java'
---

## Introduction

Java Persistence API (JPA) is a great technology for combining the power of Java and data persistence. The specification goes a long way from the days of using EJB 1.0 for data management, but still comes with some limitations. One of them is using multiple jars that may contain _persistence.xml_ files. The current limitation is that the first _persistence.xml_ file that is found, is loaded by the `Classloader`, and the others are ignored. 

The code below is used to get around this limitation by proxying the `Classloader`, scanning the jars for _persistence.xml_ files and combining them into one file for the `Classloader` to load.

The original idea came from Fabrizio Giudici so I can not claim this as my own. The code below is based on his great work. My enhancements to his code are removal of duplicate classes that may be included in the multiple _persistence.xml_ files, and the use of a Random Access Memory (RAM) file system to merge the files.

# Code

The code will work on Java 8, but the changes in later versions of Java around class loading may prevent us from using this clever trick.
   ```java
    package com.bluelotussoftware.persistence;
    
    import java.io.IOException;
    import java.io.InputStream;
    import java.io.OutputStream;
    import java.io.StringWriter;
    import java.net.URL;
    import java.nio.charset.Charset;
    import java.text.MessageFormat;
    import java.util.Collection;
    import java.util.Collections;
    import java.util.Enumeration;
    import java.util.Iterator;
    import javax.xml.parsers.DocumentBuilder;
    import javax.xml.parsers.DocumentBuilderFactory;
    import javax.xml.parsers.ParserConfigurationException;
    import javax.xml.transform.Transformer;
    import javax.xml.transform.TransformerConfigurationException;
    import javax.xml.transform.TransformerException;
    import javax.xml.transform.TransformerFactory;
    import javax.xml.transform.dom.DOMSource;
    import javax.xml.transform.stream.StreamResult;
    import javax.xml.xpath.XPath;
    import javax.xml.xpath.XPathConstants;
    import javax.xml.xpath.XPathExpression;
    import javax.xml.xpath.XPathExpressionException;
    import javax.xml.xpath.XPathFactory;
    import org.apache.commons.io.IOUtils;
    import org.apache.commons.vfs2.FileObject;
    import org.apache.commons.vfs2.FileSystemException;
    import org.apache.commons.vfs2.FileSystemManager;
    import org.apache.commons.vfs2.VFS;
    import org.apache.log4j.Logger;
    import org.w3c.dom.Document;
    import org.w3c.dom.Node;
    import org.w3c.dom.NodeList;
    import org.xml.sax.SAXException;
    
    /**
     * @author Fabrizio Giudici
     * @author John Yeary <jyeary@bluelotussoftware.com>
     * @version 1.0.0
     */
    public class PersistenceClassLoader extends ClassLoader {
    
        private final ClassLoader parent;
        private static final Logger LOGGER = Logger.getLogger(PersistenceClassLoader.class);
        private static final DocumentBuilderFactory DOCUMENT_BUILDER_FACTORY = DocumentBuilderFactory.newInstance();
        private static final XPathFactory XPATH_FACTORY = XPathFactory.newInstance();
        private static final XPath XPATH = XPATH_FACTORY.newXPath();
        private static final XPathExpression XPATH_ENTITY_PU_NODE;
        private static final XPathExpression XPATH_PROPERTIES_NODE;
        private static final XPathExpression XPATH_ENTITY_CLASS_TEXT;
        private static final String PERSISTENCE_XML = "META-INF/persistence.xml";
        private URL mergedPersistenceXml;
    
        static {
            try {
                XPATH_ENTITY_PU_NODE = XPATH.compile("//persistence/persistence-unit");
                XPATH_PROPERTIES_NODE = XPATH.compile("//persistence/persistence-unit/properties");
                XPATH_ENTITY_CLASS_TEXT = XPATH.compile("//persistence/persistence-unit/class/text()");
            } catch (XPathExpressionException e) {
                throw new ExceptionInInitializerError(e);
            }
        }
    
        /**
         * Constructor that wraps the provided {@link ClassLoader}
         *
         * @param parent The parent {@link ClassLoader} to wrap.
         */
        public PersistenceClassLoader(final ClassLoader parent) {
            super(parent);
            this.parent = parent;
        }
    
        /**
         * {@inheritDoc}
         * <p>
         * This handles setting the {@literal persistence.xml} from multiple {@literal META-INF/persistence.xml} files using
         * the same persistence unit.</p>
         */
        @Override
        public Enumeration<URL> getResources(String name) throws IOException {
            if (PERSISTENCE_XML.equals(name)) {
                if (mergedPersistenceXml == null) {
                    try {
                        String merged = scanPersistenceXML();
                        LOGGER.trace(merged);
                        mergedPersistenceXml = getMergedURL(merged);
                        LOGGER.trace(MessageFormat.format("Merged persistence.xml URL: {0}", mergedPersistenceXml));
                    } catch (IOException | ParserConfigurationException | SAXException | XPathExpressionException | TransformerException ex) {
                        //TODO Need to return the first persistence.xml file, or throw a new exception. This should be fatal.
                        LOGGER.fatal("Could not merge persistence.xml files", ex);
                        return parent.getResources(name);
                    }
                }
                return new Enumeration<URL>() {
                    URL url = mergedPersistenceXml;
    
                    @Override
                    public boolean hasMoreElements() {
                        return url != null;
                    }
    
                    @Override
                    public URL nextElement() {
                        final URL url2 = url;
                        url = null;
                        return url2;
                    }
                };
            } else {
                return super.getResources(name);
            }
        }
    
        /**
         * Scans the {@link ClassLoader#getResources(java.lang.String)} for {@literal persistence.xml} files.
         *
         * @return A {@code Collection<URL} of {@literal persistence.xml} URLs.
         * @throws IOException If an exception occurs during processing.
         */
        public Collection<URL> findPersistenceXMLs() throws IOException {
            final Enumeration<URL> e = super.getResources(PERSISTENCE_XML);
            return Collections.list(e);
        }
    
        /**
         * Converts a {@link Document} to a {@code String}.
         *
         * @param document The document to convert.
         * @return A {@code String} representation of the document if the conversion was successful, and {@literal null}
         * otherwise.
         */
        private String documentToString(final Document document) {
            try {
                DOMSource source = new DOMSource(document);
                StringWriter writer = new StringWriter();
                StreamResult result = new StreamResult(writer);
                TransformerFactory tf = TransformerFactory.newInstance();
                Transformer transformer = tf.newTransformer();
                transformer.transform(source, result);
                return writer.toString();
            } catch (TransformerException ex) {
                LOGGER.error("Could not convert Document to String", ex);
                return null;
            }
        }
    
        /**
         * This method creates the merged {@literal persistence.xml} file from all of {@literal persistence.xml} files found
         * by the {@link ClassLoader} during its scan and constructs a {@link Document} containing the merged
         * {@literal <class>} elements.
         *
         * @return A {@code String} representation of the {@link Document} that was generated.
         */
        private String scanPersistenceXML()
                throws IOException,
                ParserConfigurationException,
                SAXException,
                XPathExpressionException,
                TransformerConfigurationException,
                TransformerException {
            LOGGER.info("scanPersistenceXML()");
            final DocumentBuilder builder = DOCUMENT_BUILDER_FACTORY.newDocumentBuilder();
            DOCUMENT_BUILDER_FACTORY.setNamespaceAware(true);
            Collection<URL> persistenceXMlUrls = findPersistenceXMLs();
    
            Iterator<URL> it = persistenceXMlUrls.iterator();
            final URL masterURL = it.next();
            it.remove();
    
            LOGGER.trace(String.format(">>>> master persistence.xml: %s", masterURL));
            final Document masterDocument = builder.parse(masterURL.toExternalForm());
            final Node puNode = (Node) XPATH_ENTITY_PU_NODE.evaluate(masterDocument, XPathConstants.NODE);
            final Node propertiesNode = (Node) XPATH_PROPERTIES_NODE.evaluate(masterDocument, XPathConstants.NODE);
    
            for (final URL url : persistenceXMlUrls) {
                LOGGER.info(String.format(">>>> other persistence.xml: %s", url));
                final Document document = builder.parse(url.toExternalForm());
                final NodeList nodes = (NodeList) XPATH_ENTITY_CLASS_TEXT.evaluate(document, XPathConstants.NODESET);
    
                for (int i = 0; i < nodes.getLength(); i++) {
                    final String entityClassName = nodes.item(i).getNodeValue();
    
                    /*
                     * Check for duplicates and only add new classes.
                     */
                    if (!classNodeExists(masterDocument, entityClassName)) {
                        LOGGER.info(String.format(">>>>>>>> entity class: %s found. Adding to persistence.xml", entityClassName));
    
                        if (i == 0) {
                            puNode.insertBefore(masterDocument.createComment(" from " + url.toExternalForm() + " "), propertiesNode);
                            puNode.insertBefore(masterDocument.createTextNode("\n"), propertiesNode);
                        }
                        final Node child = masterDocument.createElement("class");
                        child.appendChild(masterDocument.createTextNode(entityClassName));
                        // The entity classes must be appended before the properties to successfully validate.
                        puNode.insertBefore(child, propertiesNode);
                        puNode.insertBefore(masterDocument.createTextNode("\n"), propertiesNode);
                    }
                }
            }
    
            return documentToString(masterDocument);
        }
    
        /**
         * <p>
         * This method will provide a {@link URL} to a virtual file stored in Random Access Memory (RAM) using
         * {@link FileSystemManager}.The method is sufficiently abstract to store any {@code String} data.</p>
         * <p>
         * The implementation in this class will be used to store our merged persistence.xml files. This way we can avoid
         * storing the merged file on the operating system.</p>
         *
         * @param data The data to be stored to a virtual file in RAM.
         * @return The {@link URL} to the virtual file in RAM.
         */
        private URL getMergedURL(final String data) {
            try {
                FileSystemManager manager = VFS.getManager();
                // The EntityManagerFactory will scan a pattern like PROJECT_NAME/META-INF/ for persistence.xml file.
                FileObject pxml = manager.resolveFile("ram://RAM_MERGED_PERSISTENCE/META-INF/persistence.xml");
                pxml.createFile();
                try (OutputStream os = pxml.getContent().getOutputStream()) {
                    IOUtils.write(data, os, Charset.forName("UTF-8"));
                }
                try (InputStream is = pxml.getContent().getInputStream()) {
                    LOGGER.info(IOUtils.toString(is, Charset.forName("UTF-8")));
                }
                return pxml.getURL();
            } catch (FileSystemException ex) {
                LOGGER.error("Could not create RAM filesystem.", ex);
                return null;
            } catch (IOException ex) {
                LOGGER.error("An exception occurred while trying to generate merged URL", ex);
                return null;
            }
        }
    
        /**
         * This checks the provided master {@literal persistence.xml} {@link Document} for the existence of a class node.
         *
         * @param masterDocument The document to evaluate.
         * @param className The name of class to check to see if it already exists.
         * @return {@literal true} if the class already exists and {@literal false} otherwise.
         */
        private boolean classNodeExists(Document masterDocument, String className) {
            boolean result = false;
            final NodeList nodeList;
    
            try {
                nodeList = (NodeList) XPATH_ENTITY_CLASS_TEXT.evaluate(masterDocument, XPathConstants.NODESET);
            } catch (XPathExpressionException ex) {
                LOGGER.warn("The provided persistence.xml contains no class entries", ex);
                return false;
            }
    
            String masterEntityClassName;
    
            for (int j = 0; j < nodeList.getLength(); j++) {
                masterEntityClassName = nodeList.item(j).getNodeValue();
                if (masterEntityClassName.equals(className)) {
                    result = true;
                    break;
                }
            }
            return result;
        }
    
    }
```

The implementation is simply a matter of doing a switch on the ``ClassLoader`` as shown below.

```java
    public static void main(String[] args) {
    
            ClassLoader contextClassLoader = Thread.currentThread().getContextClassLoader();
            PersistenceClassLoader cl = new PersistenceClassLoader(contextClassLoader);
    
            // We must set the Classloader to use our loader BEFORE calling Persistence.Persistence.createEntityManagerFactory()
            Thread.currentThread().setContextClassLoader(cl);
    
            EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("emample-pu");
    
            //Reset the classloader
            Thread.currentThread().setContextClassLoader(contextClassLoader);
    
            EntityManager em = entityManagerFactory.createEntityManager();
    
            ...
        }
```
# Conclusion

The Java Persistence API (JPA) is a great technology, but has some limitations with regards to loading multiple _persistence.xml_ files. We can use `Classloader` magic to accomplish loading multiple _persistence.xml_ files.

This code may not work as expected on later versions of Java. At the time of this writing, Java 8 is still used by most of the enterprise clients I work with.