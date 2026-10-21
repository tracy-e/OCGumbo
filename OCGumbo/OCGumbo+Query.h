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

#import "OCGumbo.h"

@class OCQueryObject;

/** Block returned by the Query property of OCGumboNode. */
typedef OCQueryObject * (^OCGumboQueryBlockAS)(NSString *);
/** Block returned by the attr property of OCGumboNode. */
typedef NSString * (^OCGumboQueryBlockSS)(NSString *);
/** Block returned by the text and html properties of OCGumboNode. */
typedef NSString * (^OCGumboQueryBlockSV)(void);

/**
 * @category OCGumboNode(Query)
 * @abstract CSS-like querying of the parse tree.
 * @discussion The properties in this category are convenience accessors that
 * return blocks; the actual work happens when the returned block is invoked,
 * for example `document.Query(@"div").first().text()`. Selectors accept an
 * element ID (`#id`), a tag name (`div`), a class selector (`.cls`), a tag
 * with a class (`div.cls`) or a tag with an ID (`div#id`). Attribute and ID
 * matching is case-insensitive, as in HTML.
 */
@interface OCGumboNode (Query)

/**
 * @property Query
 * @abstract Query descendant elements of the receiver by selector.
 * @discussion The returned block takes a selector and returns an OCQueryObject
 * with every matching descendant in document order. Passing nil selects all
 * descendant nodes, including text and comment nodes.
 * @param selector An element ID, tag name, class selector, tag.class selector
 * or tag#id selector.
 * @result A block that performs the query and returns an OCQueryObject.
 */
@property (nonatomic, weak, readonly) OCGumboQueryBlockAS Query;

/**
 * @property attr
 * @abstract Read an attribute of the receiver.
 * @discussion The returned block takes an attribute name and returns its value.
 * It returns nil for non-element nodes or when the attribute is absent.
 * @param attributeName The name of the attribute to read.
 * @result A block that returns the attribute value or nil.
 */
@property (nonatomic, weak, readonly) OCGumboQueryBlockSS attr;

/**
 * @property text
 * @abstract Get the combined text contents of the receiver.
 * @discussion The returned block concatenates the text of all descendant text
 * nodes, in document order. For a text node it returns its own value.
 * @result A block that returns the combined text contents.
 */
@property (nonatomic, weak, readonly) OCGumboQueryBlockSV text;

/**
 * @property html
 * @abstract Get the inner HTML of the receiver.
 * @discussion The returned block returns the raw markup between the element's
 * start and end tags. The implementation is not fully reliable for all inputs;
 * it returns nil for non-element nodes.
 * @result A block that returns the raw inner contents of the element.
 */
@property (nonatomic, weak, readonly) OCGumboQueryBlockSV html;

@end

#pragma mark -
/** Block returned by first and last. */
typedef OCGumboNode * (^NSArrayQueryBlockNV)(void);
/** Block returned by get. */
typedef OCGumboNode * (^NSArrayQueryBlockNI)(NSUInteger);
/** Block returned by hasClass. */
typedef BOOL (^NSArrayQueryBlockBS)(NSString *);
/** Block returned by index. */
typedef NSUInteger (^NSArrayQueryBlockIN)(OCGumboNode *);
/** Block returned by find, children, parent and parents. */
typedef OCQueryObject * (^NSArrayQueryBlockAS)(NSString *);
/** Block returned by textArray. */
typedef OCQueryObject * (^NSArrayQueryBlockSA)(void);
/** Block returned by text. */
typedef NSString * (^NSArrayQueryBlockSV)(void);

/**
 * @class OCQueryObject
 * @abstract An array of OCGumboNode objects with chainable query helpers.
 * @discussion OCQueryObject is the result type of the query API. Like the
 * category on OCGumboNode, most properties return blocks that are invoked to
 * obtain a value. Because the object is an NSArray subclass, it can be used
 * directly in fast enumeration and indexed subscripting.
 */
@interface OCQueryObject : NSArray

/**
 * @property text
 * @abstract Get the combined text contents of every node in the collection.
 * @result A block that returns the concatenated text contents.
 */
@property (nonatomic, weak, readonly) NSArrayQueryBlockSV text;

/**
 * @property textArray
 * @abstract Get the text contents of every node in the collection.
 * @result A block that returns an OCQueryObject containing one string per text
 * node.
 */
@property (nonatomic, weak, readonly) NSArrayQueryBlockSA textArray;

/**
 * @property first
 * @abstract Get the first node of the collection.
 * @result A block that returns the first OCGumboNode, or nil if the collection
 * is empty.
 */
@property (nonatomic, weak, readonly) NSArrayQueryBlockNV first;

/**
 * @property last
 * @abstract Get the last node of the collection.
 * @result A block that returns the last OCGumboNode, or nil if the collection
 * is empty.
 */
@property (nonatomic, weak, readonly) NSArrayQueryBlockNV last;

/**
 * @property get
 * @abstract Get the node at a given index of the collection.
 * @param index The zero-based index of the node to return.
 * @result A block that returns the node at index, or nil if index is out of
 * bounds.
 */
@property (nonatomic, weak, readonly) NSArrayQueryBlockNI get;

/**
 * @property hasClass
 * @abstract Check whether the collection contains an element with a class.
 * @discussion This API is declared for compatibility with the original
 * JavaScript-inspired interface but is not implemented yet; it always returns
 * NO. Use the `.class` selector with Query or find instead.
 * @param name The class name to look for.
 * @result A block that currently always returns NO.
 */
@property (nonatomic, weak, readonly) NSArrayQueryBlockBS hasClass;

/**
 * @property index
 * @abstract Get the position of a node in the collection.
 * @param element The node whose index should be returned.
 * @result A block that returns the index of element, or NSNotFound if the node
 * is not in the collection.
 */
@property (nonatomic, weak, readonly) NSArrayQueryBlockIN index;

/**
 * @property find
 * @abstract Find descendants of each node in the collection matching a selector.
 * @param selector An element ID, tag name, class selector, tag.class selector
 * or tag#id selector.
 * @result A block that returns an OCQueryObject with all matching descendants.
 */
@property (nonatomic, weak, readonly) NSArrayQueryBlockAS find;

/**
 * @property children
 * @abstract Get the immediate children of each node matching a selector.
 * @param selector An element ID, tag name, class selector, tag.class selector
 * or tag#id selector.
 * @result A block that returns an OCQueryObject with the matching children.
 */
@property (nonatomic, weak, readonly) NSArrayQueryBlockAS children;

/**
 * @property parent
 * @abstract Get the immediate parent of each node matching a selector.
 * @discussion Only the direct parent is considered, so an empty result means
 * that no parent matched the selector.
 * @param selector An element ID, tag name, class selector, tag.class selector
 * or tag#id selector.
 * @result A block that returns an OCQueryObject with the matching parents,
 * without duplicates.
 */
@property (nonatomic, weak, readonly) NSArrayQueryBlockAS parent;

/**
 * @property parents
 * @abstract Get all ancestors of each node matching a selector.
 * @discussion Every ancestor up to the document node is considered.
 * @param selector An element ID, tag name, class selector, tag.class selector
 * or tag#id selector.
 * @result A block that returns an OCQueryObject with the matching ancestors,
 * without duplicates.
 */
@property (nonatomic, weak, readonly) NSArrayQueryBlockAS parents;

@end
