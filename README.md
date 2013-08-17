OCGumbo - An Objective-C HTML5 parser.
=====================================

OCGumbo is an Objective-C wrapper of the Google [Gumbo](https://github.com/google/gumbo-parser).

Basic Usage
===========

Within your program, you need to import "OCGumbo.h" and then use OCGumboDocument to parse an html string.

```objective-c
OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString URL:@"http://esoftmobile.com"];
OCGumboElement *root = document.documentElement;
//do something with the document.
//do something with the html tree.
```