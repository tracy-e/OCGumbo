OCGumbo - An Objective-C HTML5 parser.
=====================================

OCGumbo is an Objective-C wrapper of the Google [Gumbo](https://github.com/google/gumbo-parser).

Basic Usage
===========

 1. Add [Gumbo](https://github.com/google/gumbo-parser/tree/master/src) sources or lib to your project.
 2. Add [OCGumbo](https://github.com/tracy-e/OCGumbo/tree/master/OCGumbo) file and import "OCGumbo.h", then use OCGumboDocument to parse an html string.

####Objects####

<table>
<tr><th>Class</th><th>Description</th></tr>
<tr><td>OCGumboDocument</td><td>the root of a document tree</td></tr>
<tr><td>OCGumboElement</td><td>an element in an HTML document</td></tr>
<tr><td>OCGumboText</td><td>the textual content of an element</td></tr>
<tr><td>OCGumboNode	</td><td>a single node in the document tree</td></tr>
<tr><td>OCGumboAttribute</td><td>an attribute of an Element object</td></tr>
</table>

####Examples####

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

<table>
<tr><th width="100">Method</th><th>Description</th></tr>
<tr><td>.Query( )</td><td>Query children elements from current node by selector</td></tr>
<tr><td>.text( )</td><td>Get the combined text contents of current object</td></tr>
<tr><td>.html( )</td><td>Get the raw contents of current element</td></tr>
<tr><td>.attr( )</td><td>Get the attribute value of the element by attributeName</td></tr>
<tr><td>.find( )</td><td>Find elements that match the selector in the current collection</td></tr>
<tr><td>.children( )</td><td>Get immediate children of each element in the current collection matching the selector</td></tr>
<tr><td>.parent( )</td><td>Get immediate parents of each element in the collection matching the selector</td></tr>
<tr><td>.parents( )</td><td>Get all ancestors of each element in the collection matching the selector</td></tr>
<tr><td>.first( )</td><td>Get the first element of the current collection</td></tr>
<tr><td>.last( )</td><td>Get the last element of the current collection</td></tr>
<tr><td>.get ( )</td><td>Get the element by index from current collection</td></tr>
<tr><td>.index( )</td><td>Get the position of an element in current collection</td></tr>
<tr><td>.hasClass( )</td><td>Check if any elements in the collection have the specified class</td></tr>
</table>

####Examples####

```objective-c
NSLog(@"options: %@", document.Query(@"body").find(@"#select").find(@"option"));
NSLog(@"title: %@", document.Query(@"title").text());
NSLog(@"attribute: %@", document.Query(@"select").first().attr(@"id"));
NSLog(@"class: %@", document.Query(@"#select").parents(@".main"));
NSLog(@"tag.class: %@", document.Query(@"div.theCls"));
NSLog(@"tag#id : %@", document.Query(@"div#theId"));
```

Contact
=======

Weibo: [@TracyYih](http://weibo.com/534072785)

Email: tracy.cpp@gmail.com


License
=======

[Apache License](http://www.apache.org/licenses/)
