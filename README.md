OCGumbo - An Objective-C HTML5 parser.
=====================================

OCGumbo is an Objective-C wrapper of the Google [Gumbo](https://github.com/google/gumbo-parser).

Basic Usage
===========

 1. Add [Gumbo](https://github.com/google/gumbo-parser/tree/master/src) sources or lib to your project.
 2. Add [OCGumbo](https://github.com/tracy-e/OCGumbo/tree/master/OCGumbo) file and import "OCGumbo.h", then use OCGumboDocument to parse an html string.

```objective-c
OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
OCGumboElement *root = document.rootElement;
//document: do something with the document.
//rootElement: do something with the html tree.
```

Extension
========

Now, OCGumbo add more Query support, add "OCGumbo+Query.h" and enjoy it.

####Query APIs####

```
.Query(); 
.attr(); .text(); .find(); .children(); .parent(); .parents(); .first(); .last(); .get(); .index(); .hasClass();
```

####Examples:####

```objective-c
NSLog(@"options: %@", document.Query(@"body").find(@"#select").find(@"option"));
NSLog(@"title: %@", document.Query(@"title").text());
NSLog(@"attribute: %@", document.Query(@"select").first().attr(@"id"));
NSLog(@"class: %@", document.Query(@"#select").parents(@".main"));
```
