OCGumbo - An Objective-C HTML5 parser.
=====================================

OCGumbo is an Objective-C wrapper of the Google [Gumbo](https://github.com/google/gumbo-parser).

Basic Usage
===========

 1. Add [Gumbo](https://github.com/google/gumbo-parser/tree/master/src) sources or lib to your project.
 2. Add [OCGumbo](https://github.com/tracy-e/OCGumbo/tree/master/OCGumbo) file and import "OCGumbo.h", then use OCGumboDocument to parse an html string.

####Objects####

Class 				| Description
-|-
OCGumboDocument		|  the root of a document tree
OCGumboElement 		|  an element in an HTML document
OCGumboText 		|  the textual content of an element
OCGumboNode			|  a single node in the document tree
OCGumboAttribute 	|  an attribute of an Element object

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

Method | Description
-|-
.Query( )		| Query children elements from current node by selector
.text( )		| Get the combined text contents of current object
.attr( )		| Get the attribute value of the element by attributeName
.find( )		| Find elements that match the selector in the current collection
.children( )	| Get immediate children of each element in the current collection matching the selector
.parent( )		| Get immediate parents of each element in the collection matching the selector
.parents( )		| Get all ancestors of each element in the collection matching the selector
.first( )		| Get the first element of the current collection
.last( )		| Get the last element of the current collection
.get ( )		| Get the element by index from current collection
.index( )		| Get the position of an element in current collection
.hasClass( )	| Check if any elements in the collection have the specified class

####Examples:####

```objective-c
NSLog(@"options: %@", document.Query(@"body").find(@"#select").find(@"option"));
NSLog(@"title: %@", document.Query(@"title").text());
NSLog(@"attribute: %@", document.Query(@"select").first().attr(@"id"));
NSLog(@"class: %@", document.Query(@"#select").parents(@".main"));
NSLog(@"tag.class: %@", document.Query(@"div.theCls"));
NSLog(@"tag#id : %@", document.Query(@"div#theId"));
```

License
=======

[Apache License](http://www.apache.org/licenses/)
