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
=========

OCGumbo new support JQuery liked query.

examples:

```objective-c
OCGumboNode *findNode = document.Query(@"#someId");
NSString *attributeValue = findNode.attr(@"attributeName");
```

```objective-c
NSArray *options = document.Query(@"option");
GumboElement *first = options.first();
//...
NSArray *array = element.find(@".clsname");
```
