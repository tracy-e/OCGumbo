//  Copyright [2013] tracy.cpp@gmail.com (TracyYih)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#if !__has_feature(objc_arc)
#error OCGumbo must be built with ARC.
#endif

// Please add the gumbo sources (https://github.com/google/gumbo-parser/tree/master/src)
// or link a prebuilt libgumbo before compiling OCGumbo.
#include "gumbo.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OCGumboNode;
@class OCGumboAttribute;

/**
 @function OCGumboNodeCast
 @abstract Wraps a raw Gumbo parse-tree node in the matching OCGumboNode subclass.
 @discussion The concrete class is chosen from the node type: documents become
 OCGumboDocument, elements become OCGumboElement, and everything else (text,
 CDATA, comments and whitespace) becomes OCGumboText. The returned wrapper does
 not own the underlying node; it stays valid only for as long as the owning
 OCGumboDocument is alive.
 @param node The Gumbo node to wrap. May be NULL, in which case nil is returned.
 @result An OCGumboNode (or subclass) instance, or nil.
 */
id _Nullable OCGumboNodeCast(GumboNode * _Nullable node);

/**
 @function OCGumboAttributeCast
 @abstract Wraps a raw Gumbo attribute in an OCGumboAttribute object.
 @discussion The returned wrapper does not own the underlying attribute; it
 stays valid only for as long as the owning OCGumboDocument is alive.
 @param attribute The Gumbo attribute to wrap. May be NULL, in which case nil
 is returned.
 @result An OCGumboAttribute instance, or nil.
 */
id _Nullable OCGumboAttributeCast(GumboAttribute * _Nullable attribute);

#pragma mark -
/**
 @class OCGumboNode
 @abstract A single node in an HTML document tree.
 @discussion OCGumboNode is the abstract base class for every node type exposed
 by OCGumbo. Instances wrap a node from the Gumbo parse tree and are vended by
 OCGumboDocument, by the childNodes and parentNode properties, and by the query
 API. All node objects are immutable and share storage with the document that
 created them.
 */
@interface OCGumboNode : NSObject {
@public
    /** The underlying Gumbo node. Public for use by OCGumbo+Query. */
    GumboNode *_gumboNode;
}

/**
 @property nodeName
 @abstract The name of the node.
 @discussion "#document" for the document node, "#text" for text nodes, and the
 normalized lowercase tag name for elements. nil for other node types.
 */
@property (nonatomic, copy, readonly, nullable) NSString *nodeName;

/**
 @property nodeValue
 @abstract The value of the node.
 @discussion The text contents for text, CDATA, comment and whitespace nodes;
 nil for document and element nodes.
 */
@property (nonatomic, copy, readonly, nullable) NSString *nodeValue;

/**
 @property nodeType
 @abstract The Gumbo type of the underlying node.
 @discussion One of GUMBO_NODE_DOCUMENT, GUMBO_NODE_ELEMENT, GUMBO_NODE_TEXT,
 GUMBO_NODE_CDATA, GUMBO_NODE_COMMENT or GUMBO_NODE_WHITESPACE.
 */
@property (nonatomic, readonly) GumboNodeType nodeType;

/**
 @property childNodes
 @abstract The direct children of the receiver.
 @discussion An array of OCGumboNode (or subclass) objects in document order.
 Empty for nodes that cannot have children, such as text nodes.
 */
@property (nonatomic, readonly) NSArray<OCGumboNode *> *childNodes;

/**
 @property parentNode
 @abstract The parent of the receiver, or nil if it has none.
 @result An OCGumboNode (or subclass) instance, or nil for the document node.
 */
@property (nonatomic, readonly, nullable) OCGumboNode *parentNode;

@end

#pragma mark -
@class OCGumboAttribute;

/**
 @class OCGumboElement
 @abstract An HTML element in a document tree.
 @discussion Element nodes expose their tag name, their Gumbo tag constant, and
 their attributes. Use hasAttribute:, getAttribute: and getAttributeNode: to
 inspect individual attributes, or the attributes property to enumerate them.
 */
@interface OCGumboElement : OCGumboNode

/**
 @property tagName
 @abstract The normalized lowercase tag name of the element, such as "div".
 @discussion Equivalent to nodeName for element nodes.
 */
@property (nonatomic, copy, readonly) NSString *tagName;

/**
 @property tag
 @abstract The Gumbo tag constant for the element, such as GUMBO_TAG_DIV.
 @discussion Unknown or custom tags map to GUMBO_TAG_UNKNOWN.
 */
@property (nonatomic, readonly) GumboTag tag;

/**
 @property attributes
 @abstract The attributes of the element.
 @discussion An array of OCGumboAttribute objects. Empty when the element has
 no attributes.
 */
@property (nonatomic, readonly) NSArray<OCGumboAttribute *> *attributes;

/**
 @method hasAttribute:
 @abstract Returns whether the element has an attribute with the given name.
 @param name The attribute name, matched case-insensitively as in HTML.
 @result YES if the attribute is present, otherwise NO.
 */
- (BOOL)hasAttribute:(NSString *)name NS_SWIFT_NAME(hasAttribute(_:));

/**
 @method getAttribute:
 @abstract Returns the value of the named attribute.
 @param name The attribute name, matched case-insensitively as in HTML.
 @result The attribute value, or nil if the element has no such attribute.
 */
- (nullable NSString *)getAttribute:(NSString *)name NS_SWIFT_NAME(attribute(named:));

/**
 @method getAttributeNode:
 @abstract Returns the named attribute as an OCGumboAttribute object.
 @param name The attribute name, matched case-insensitively as in HTML.
 @result The matching OCGumboAttribute, or nil if the element has no such
 attribute.
 */
- (nullable OCGumboAttribute *)getAttributeNode:(NSString *)name NS_SWIFT_NAME(attributeNode(named:));

@end

#pragma mark -
/**
 @class OCGumboText
 @abstract A textual node in a document tree.
 @discussion OCGumboText represents text, CDATA, comment and whitespace nodes.
 Use the data property to read the node's contents.
 */
@interface OCGumboText : OCGumboNode

/**
 @property data
 @abstract The textual contents of the node.
 */
@property (nonatomic, copy, readonly) NSString *data;

@end

#pragma mark -
/**
 @class OCGumboDocument
 @abstract The root of an HTML document tree and entry point of the library.
 @discussion Create a document with initWithHTMLString: to parse an HTML string
 with Gumbo. The document owns the parse tree, so all nodes, elements,
 attributes and query results obtained from it remain valid only while the
 document is alive. Use rootElement, head and body for quick access to the
 structural elements, or the query API in OCGumbo+Query.h for CSS-like
 selection.
 */
@interface OCGumboDocument : OCGumboNode

/**
 @property title
 @abstract The text of the document's title element.
 @result The title text, or nil if the document has no title element.
 */
@property (nonatomic, copy, readonly, nullable) NSString *title;

/**
 @property hasDoctype
 @abstract Whether the document contains a doctype declaration.
 */
@property (nonatomic, readonly) BOOL hasDoctype;

/**
 @property publicID
 @abstract The public identifier of the document type declaration.
 @discussion Only meaningful when hasDoctype is YES; Gumbo leaves the
 identifier unset when the declaration does not provide one.
 */
@property (nonatomic, copy, readonly, nullable) NSString *publicID;

/**
 @property systemID
 @abstract The system identifier of the document type declaration.
 @discussion Only meaningful when hasDoctype is YES; Gumbo leaves the
 identifier unset when the declaration does not provide one.
 */
@property (nonatomic, copy, readonly, nullable) NSString *systemID;

/**
 @property rootElement
 @abstract The root html element of the document.
 */
@property (nonatomic, readonly) OCGumboElement *rootElement;

/**
 @property head
 @abstract The head element of the document.
 @result The head element, or nil if the parsed document has none.
 */
@property (nonatomic, readonly, nullable) OCGumboElement *head;

/**
 @property body
 @abstract The body element of the document.
 @result The body element, or nil if the parsed document has none.
 */
@property (nonatomic, readonly, nullable) OCGumboElement *body;

/**
 @method initWithHTMLString:
 @abstract Creates a document by parsing the given HTML string.
 @discussion The input is parsed as UTF-8 using Gumbo's default options. Gumbo
 applies the HTML5 parsing algorithm, so malformed markup is repaired rather
 than rejected. The document keeps the resulting parse tree until it is
 deallocated.
 @param htmlString The HTML source to parse.
 @result An initialized document, or nil if allocation failed.
 */
- (instancetype)initWithHTMLString:(NSString *)htmlString NS_SWIFT_NAME(init(html:));

@end

#pragma mark -
/**
 @class OCGumboAttribute
 @abstract An attribute of an OCGumboElement.
 @discussion Attribute objects are vended by OCGumboElement and do not own the
 underlying Gumbo attribute; they remain valid only while the document that
 produced them is alive.
 */
@interface OCGumboAttribute : NSObject

/**
 @property name
 @abstract The name of the attribute, lowercased as normalized by Gumbo.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 @property value
 @abstract The value of the attribute as a string.
 */
@property (nonatomic, copy, readonly) NSString *value;

@end

NS_ASSUME_NONNULL_END
