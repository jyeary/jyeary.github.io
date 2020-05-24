---
layout: post
cover: 'assets/images/brown-landscape-under-grey-sky-3244513.jpg'
logo: 'assets/images/logo.jpg'
navigation: true
author: jyeary
disqus: true
date: 2010-01-13 22:08:00+00:00
title: 'Tip: How to Use a Sequence as the Default Value on a Coumn (Oracle)'
categories: jyeary
tags: life
subclass: 'post tag-life'
---
You first must create the sequence you want to use to add the identity value for the column. Then replace the values in highlighted below appropriately for your environment.

```
CREATE OR REPLACE TRIGGER {SCHEMA.TRIGGER_NAME}
BEFORE INSERT ON {SCHEMA.TABLE_NAME} FOR EACH ROW
BEGIN
IF :NEW.{COLUMN_NAME} IS NULL
THEN
SELECT {SCHEMA.SEQUENCE_NAME}.NEXTVAL INTO :NEW.{COLUMN_NAME} FROM DUAL;
END IF;
END;
```