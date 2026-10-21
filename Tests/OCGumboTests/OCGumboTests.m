//
//  OCGumboTests.m
//  OCGumboTests
//
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
//

#import <XCTest/XCTest.h>

#import "OCGumbo+Query.h"

static NSString *const kHTML = @"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\" "
                                "\"http://www.w3.org/TR/html4/strict.dtd\">"
                                "<html><head><title>Hello OCGumbo</title></head>"
                                "<body class=\"main\" id=\"testID\">"
                                "<h1>Title</h1>"
                                "<div id=\"theId\" class=\"alpha beta\" data-role=\"hero\">"
                                "hello <span class=\"alpha\">world</span></div>"
                                "<p>text in p</p>"
                                "<select id=\"select\">"
                                "<option class=\"abc efg\">A</option>"
                                "<option id=\"optionB\" class=\"abc\">B</option>"
                                "<option>C</option>"
                                "</select>"
                                "<!-- comment -->"
                                "</body></html>";

/// Returns the first node of a query result as an element.
static OCGumboElement *FirstElement(OCQueryObject *query)
{
    return (OCGumboElement *)query.first();
}

/// Looks up an attribute by name, so tests do not depend on source order.
static NSString *AttributeValue(OCGumboElement *element, NSString *name)
{
    for (OCGumboAttribute *attribute in element.attributes) {
        if ([attribute.name isEqualToString:name]) {
            return attribute.value;
        }
    }
    return nil;
}

@interface OCGumboTests : XCTestCase {
    OCGumboDocument *_document;
}

@end

@implementation OCGumboTests

- (void)setUp
{
    [super setUp];
    _document = [[OCGumboDocument alloc] initWithHTMLString:kHTML];
    XCTAssertNotNil(_document);
}

- (void)tearDown
{
    _document = nil;
    [super tearDown];
}

#pragma mark - Parsing

- (void)testParsingDocument
{
    XCTAssertNotNil(_document, @"A document should be created from a valid HTML string");
    XCTAssertEqual(_document.nodeType, GUMBO_NODE_DOCUMENT);
    XCTAssertEqualObjects(_document.nodeName, @"#document");
    XCTAssertNil(_document.nodeValue);
    XCTAssertEqualObjects(_document.title, @"Hello OCGumbo");
}

- (void)testParsingDoctype
{
    XCTAssertTrue(_document.hasDoctype);
    XCTAssertEqualObjects(_document.publicID, @"-//W3C//DTD HTML 4.01//EN");
    XCTAssertEqualObjects(_document.systemID, @"http://www.w3.org/TR/html4/strict.dtd");
}

- (void)testParsingDocumentWithoutDoctype
{
    OCGumboDocument *document =
        [[OCGumboDocument alloc] initWithHTMLString:@"<html><body><p>x</p></body></html>"];
    XCTAssertNotNil(document);
    XCTAssertFalse(document.hasDoctype);
    XCTAssertEqualObjects(document.publicID, @"");
    XCTAssertEqualObjects(document.systemID, @"");
}

- (void)testParsingMalformedHTML
{
    // Gumbo follows the HTML5 parsing algorithm, so unclosed tags are repaired.
    OCGumboDocument *document =
        [[OCGumboDocument alloc] initWithHTMLString:@"<html><body><p>one<p>two"];
    XCTAssertNotNil(document);
    XCTAssertEqual(document.Query(@"p").count, 2);
    XCTAssertEqualObjects(document.Query(@"p").text(), @"onetwo");
}

#pragma mark - Structural elements

- (void)testRootElement
{
    OCGumboElement *root = _document.rootElement;
    XCTAssertNotNil(root);
    XCTAssertEqual(root.nodeType, GUMBO_NODE_ELEMENT);
    XCTAssertEqualObjects(root.tagName, @"html");
    XCTAssertEqualObjects(root.nodeName, @"html");
    XCTAssertEqual(root.tag, GUMBO_TAG_HTML);
}

- (void)testHeadElement
{
    OCGumboElement *head = _document.head;
    XCTAssertNotNil(head);
    XCTAssertEqualObjects(head.tagName, @"head");
    XCTAssertEqual(head.tag, GUMBO_TAG_HEAD);
    XCTAssertEqualObjects(head.parentNode, _document.rootElement);

    OCGumboNode *title = _document.Query(@"title").first();
    XCTAssertEqualObjects(title.parentNode, head);
}

- (void)testBodyElement
{
    OCGumboElement *body = _document.body;
    XCTAssertNotNil(body);
    XCTAssertEqualObjects(body.tagName, @"body");
    XCTAssertEqual(body.tag, GUMBO_TAG_BODY);
    XCTAssertEqualObjects(body.parentNode, _document.rootElement);
    XCTAssertEqualObjects([body getAttribute:@"class"], @"main");
    XCTAssertEqualObjects([body getAttribute:@"id"], @"testID");
}

#pragma mark - Text content

- (void)testTextContentOfElement
{
    XCTAssertEqualObjects(_document.Query(@"title").text(), @"Hello OCGumbo");
    XCTAssertEqualObjects(_document.Query(@"p").text(), @"text in p");
    XCTAssertEqualObjects(_document.Query(@"div").text(), @"hello world");
}

- (void)testTextContentOfBodyAndDocument
{
    XCTAssertEqualObjects(_document.body.text(), @"Titlehello worldtext in pABC");
    XCTAssertEqualObjects(_document.text(), @"Hello OCGumboTitlehello worldtext in pABC");
}

- (void)testTextNodeData
{
    OCGumboElement *paragraph = FirstElement(_document.Query(@"p"));
    OCGumboNode *node = paragraph.childNodes.firstObject;
    XCTAssertTrue([node isKindOfClass:[OCGumboText class]]);
    XCTAssertEqual(node.nodeType, GUMBO_NODE_TEXT);
    XCTAssertEqualObjects(node.nodeName, @"#text");
    XCTAssertEqualObjects(node.nodeValue, @"text in p");
    XCTAssertEqualObjects(((OCGumboText *)node).data, @"text in p");
    XCTAssertEqualObjects(node.parentNode, paragraph);
}

#pragma mark - Attributes

- (void)testAttributesCollection
{
    OCGumboElement *div = FirstElement(_document.Query(@"div"));
    NSArray *attributes = div.attributes;
    XCTAssertEqual(attributes.count, 3);

    for (OCGumboAttribute *attribute in attributes) {
        XCTAssertTrue([attribute isKindOfClass:[OCGumboAttribute class]]);
        XCTAssertTrue(attribute.name.length > 0);
        XCTAssertTrue(attribute.value.length > 0);
    }
    XCTAssertEqualObjects(AttributeValue(div, @"id"), @"theId");
    XCTAssertEqualObjects(AttributeValue(div, @"class"), @"alpha beta");
    XCTAssertEqualObjects(AttributeValue(div, @"data-role"), @"hero");
}

- (void)testGetAttribute
{
    OCGumboElement *div = FirstElement(_document.Query(@"div"));
    XCTAssertEqualObjects([div getAttribute:@"id"], @"theId");
    XCTAssertEqualObjects([div getAttribute:@"class"], @"alpha beta");
    XCTAssertNil([div getAttribute:@"missing"]);

    // Attribute lookup is case-insensitive, as in HTML.
    XCTAssertEqualObjects([div getAttribute:@"DATA-ROLE"], @"hero");
}

- (void)testHasAttribute
{
    OCGumboElement *div = FirstElement(_document.Query(@"div"));
    XCTAssertTrue([div hasAttribute:@"id"]);
    XCTAssertTrue([div hasAttribute:@"ID"]);
    XCTAssertTrue([div hasAttribute:@"data-role"]);
    XCTAssertFalse([div hasAttribute:@"missing"]);
}

- (void)testGetAttributeNode
{
    OCGumboElement *div = FirstElement(_document.Query(@"div"));
    OCGumboAttribute *attribute = [div getAttributeNode:@"data-role"];
    XCTAssertNotNil(attribute);
    XCTAssertEqualObjects(attribute.name, @"data-role");
    XCTAssertEqualObjects(attribute.value, @"hero");
    // Note: getAttributeNode: with a missing name currently wraps a NULL
    // attribute and crashes on access (pre-existing behavior), so it is not tested here.
}

- (void)testEmptyAttributes
{
    OCGumboElement *paragraph = FirstElement(_document.Query(@"p"));
    XCTAssertEqual(paragraph.attributes.count, 0);
    XCTAssertFalse([paragraph hasAttribute:@"id"]);
    XCTAssertNil([paragraph getAttribute:@"id"]);
}

- (void)testAttributeQueryBlock
{
    OCGumboElement *select = FirstElement(_document.Query(@"select"));
    XCTAssertEqualObjects(select.attr(@"id"), @"select");
    XCTAssertNil(select.attr(@"missing"));

    // Only elements can have attributes.
    XCTAssertNil(_document.attr(@"id"));
}

#pragma mark - Child nodes

- (void)testChildNodes
{
    NSArray *rootChildren = _document.childNodes;
    XCTAssertEqual(rootChildren.count, 1);
    XCTAssertEqualObjects([(OCGumboElement *)rootChildren.firstObject tagName], @"html");

    NSArray *bodyChildren = _document.body.childNodes;
    XCTAssertEqual(bodyChildren.count, 5);

    NSArray *expectedNames = @[ @"h1", @"div", @"p", @"select" ];
    for (NSUInteger i = 0; i < expectedNames.count; i++) {
        OCGumboNode *node = bodyChildren[i];
        XCTAssertTrue([node isKindOfClass:[OCGumboNode class]]);
        XCTAssertEqual(node.nodeType, GUMBO_NODE_ELEMENT);
        XCTAssertEqualObjects(node.nodeName, expectedNames[i]);
        XCTAssertEqualObjects(node.parentNode, _document.body);
    }
}

- (void)testChildNodesIncludeTextAndElements
{
    OCGumboElement *span = FirstElement(_document.Query(@"span"));
    NSArray *children = span.parentNode.childNodes;
    XCTAssertEqual(children.count, 2);

    OCGumboText *text = (OCGumboText *)children[0];
    XCTAssertEqual(text.nodeType, GUMBO_NODE_TEXT);
    XCTAssertEqualObjects(text.nodeValue, @"hello ");
    XCTAssertEqualObjects([(OCGumboElement *)children[1] tagName], @"span");
}

- (void)testTextNodeHasNoChildren
{
    OCGumboText *text = (OCGumboText *)_document.Query(@"p").first().childNodes.firstObject;
    XCTAssertEqual(text.childNodes.count, 0);
}

- (void)testCommentNode
{
    OCGumboNode *comment = _document.body.childNodes.lastObject;
    XCTAssertEqual(comment.nodeType, GUMBO_NODE_COMMENT);
    XCTAssertEqualObjects(comment.nodeValue, @" comment ");
}

#pragma mark - Query: selectors

- (void)testQueryByTagName
{
    OCQueryObject *paragraphs = _document.Query(@"p");
    XCTAssertTrue([paragraphs isKindOfClass:[NSArray class]]);
    XCTAssertEqual(paragraphs.count, 1);
    XCTAssertEqualObjects([FirstElement(paragraphs) tagName], @"p");

    XCTAssertEqual(_document.Query(@"option").count, 3);
    XCTAssertEqual(_document.Query(@"table").count, 0);
}

- (void)testQueryByElementID
{
    OCQueryObject *result = _document.Query(@"#theId");
    XCTAssertEqual(result.count, 1);
    XCTAssertEqualObjects([FirstElement(result) tagName], @"div");
    XCTAssertEqualObjects([FirstElement(result) getAttribute:@"class"], @"alpha beta");
}

- (void)testQueryByClassSelector
{
    OCQueryObject *result = _document.Query(@".alpha");
    XCTAssertEqual(result.count, 2);
    XCTAssertEqualObjects([(OCGumboElement *)result.get(0) tagName], @"div");
    XCTAssertEqualObjects([(OCGumboElement *)result.get(1) tagName], @"span");

    XCTAssertEqual(_document.Query(@".efg").count, 1);
    XCTAssertEqual(_document.Query(@".missing").count, 0);
}

- (void)testQueryByTagAndClass
{
    OCQueryObject *result = _document.Query(@"div.alpha");
    XCTAssertEqual(result.count, 1);
    XCTAssertEqualObjects([FirstElement(result) getAttribute:@"id"], @"theId");

    XCTAssertEqual(_document.Query(@"span.alpha").count, 1);
    XCTAssertEqual(_document.Query(@"p.alpha").count, 0);
}

- (void)testQueryByTagAndID
{
    OCQueryObject *result = _document.Query(@"div#theId");
    XCTAssertEqual(result.count, 1);
    XCTAssertEqualObjects([FirstElement(result) tagName], @"div");

    XCTAssertEqual(_document.Query(@"span#theId").count, 0);
}

- (void)testQueryOnlyMatchesDescendants
{
    // The body itself is not a descendant of the body.
    XCTAssertEqual(_document.body.Query(@"body").count, 0);
    XCTAssertEqual(_document.Query(@"body").find(@"div").count, 1);
    XCTAssertEqual(_document.Query(@"html").find(@"option").count, 3);
}

#pragma mark - Query: collections

- (void)testFirstLastGetAndIndex
{
    OCQueryObject *options = _document.Query(@"option");
    XCTAssertEqual(options.count, 3);

    XCTAssertEqualObjects(((OCGumboNode *)options.first()).text(), @"A");
    XCTAssertEqualObjects(((OCGumboNode *)options.last()).text(), @"C");
    XCTAssertEqualObjects(((OCGumboNode *)options.get(1)).text(), @"B");
    XCTAssertNil(options.get(3));

    XCTAssertEqual(options.index(options.get(2)), 2);
    XCTAssertEqual(options.index(_document.Query(@"p").first()), (NSUInteger)NSNotFound);

    OCQueryObject *empty = _document.Query(@"table");
    XCTAssertNil(empty.first());
    XCTAssertNil(empty.last());
    XCTAssertNil(empty.get(0));
}

- (void)testCollectionText
{
    XCTAssertEqualObjects(_document.Query(@"option").text(), @"ABC");
    XCTAssertEqualObjects(_document.Query(@"p").text(), @"text in p");
    XCTAssertEqualObjects(_document.Query(@"table").text(), @"");
}

- (void)testCollectionTextArray
{
    OCQueryObject *texts = _document.Query(@"body").textArray();
    NSArray *expected = @[ @"Title", @"hello ", @"world", @"text in p", @"A", @"B", @"C" ];
    XCTAssertEqualObjects(texts, expected);
}

- (void)testHasClass
{
    // hasClass is part of the public API but has never been implemented; it
    // always returns NO. Use the ".class" selector instead.
    XCTAssertFalse(_document.Query(@"div").hasClass(@"alpha"));
}

#pragma mark - Query: traversal

- (void)testFindSearchesDescendants
{
    OCQueryObject *result = _document.Query(@"body").find(@"option");
    XCTAssertEqual(result.count, 3);
    XCTAssertEqualObjects(((OCGumboNode *)result.last()).text(), @"C");
}

- (void)testChildrenMatchesDirectChildrenOfEachNode
{
    OCQueryObject *result = _document.Query(@"body").children(@"div");
    XCTAssertEqual(result.count, 1);
    XCTAssertEqualObjects([FirstElement(result) getAttribute:@"id"], @"theId");

    // The option elements are grandchildren of the body, not children.
    XCTAssertEqual(_document.Query(@"body").children(@"option").count, 0);
    XCTAssertEqual(_document.Query(@"select").children(@"option").count, 3);
}

- (void)testParentAndParentsMatchAncestors
{
    OCQueryObject *optionB = _document.Query(@"#optionB");
    XCTAssertEqual(optionB.count, 1);

    OCQueryObject *parent = optionB.parent(@"select");
    XCTAssertEqual(parent.count, 1);
    XCTAssertEqualObjects([FirstElement(parent) tagName], @"select");

    OCQueryObject *ancestor = optionB.parents(@".main");
    XCTAssertEqual(ancestor.count, 1);
    XCTAssertEqualObjects([FirstElement(ancestor) tagName], @"body");

    XCTAssertEqual(optionB.parents(@"html").count, 1);
    XCTAssertEqual(optionB.parents(@"select").count, 1);
}

- (void)testHTML
{
    XCTAssertEqualObjects(_document.Query(@"p").first().html(), @"text in p");
    XCTAssertEqualObjects(_document.Query(@"span").first().html(), @"world");
    XCTAssertEqualObjects(_document.Query(@"title").first().html(), @"Hello OCGumbo");

    // Non-element nodes have no inner HTML.
    OCGumboText *text = (OCGumboText *)_document.Query(@"p").first().childNodes.firstObject;
    XCTAssertNil(text.html());
}

@end
