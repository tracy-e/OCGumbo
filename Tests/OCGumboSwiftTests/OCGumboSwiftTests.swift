//
//  OCGumboSwiftTests.swift
//  OCGumboSwiftTests
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

import XCTest

import OCGumbo
@testable import OCGumboSwift

// Kept on a single line, like the Objective-C fixtures, so that the whitespace
// text nodes between the tags do not change the expected child counts.
private let kHTML = "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\" "
    + "\"http://www.w3.org/TR/html4/strict.dtd\">"
    + "<html><head><title>Hello OCGumbo</title></head>"
    + "<body class=\"main\" id=\"testID\">"
    + "<h1>Title</h1>"
    + "<div id=\"theId\" class=\"alpha beta\" data-role=\"hero\">"
    + "hello <span class=\"alpha\">world</span></div>"
    + "<p>text in p</p>"
    + "<select id=\"select\">"
    + "<option class=\"abc efg\">A</option>"
    + "<option id=\"optionB\" class=\"abc\">B</option>"
    + "<option>C</option>"
    + "</select>"
    + "<!-- comment -->"
    + "</body></html>"

final class OCGumboSwiftTests: XCTestCase {
    private var document: OCGumboDocument!

    override func setUp() {
        super.setUp()
        document = OCGumboDocument(html: kHTML)
        XCTAssertNotNil(document)
    }

    override func tearDown() {
        document = nil
        super.tearDown()
    }

    // MARK: - Parsing through the overlay

    func testParseHelperMatchesInitializer() {
        let parsed = OCGumboDocument.parse("<html><body><p>Hi</p></body></html>")
        XCTAssertEqual(parsed.nodeType, GUMBO_NODE_DOCUMENT)
        XCTAssertEqual(parsed.firstElement(matching: "p")?.textContent, "Hi")
        XCTAssertEqual(document.title, "Hello OCGumbo")
    }

    func testSwiftRefinedNames() {
        // initWithHTMLString: -> init(html:), getAttribute: -> attribute(named:)
        let body = document.body!
        XCTAssertEqual(body.attribute(named: "id"), "testID")
        XCTAssertEqual(body.attributeNode(named: "class")?.value, "main")
        XCTAssertTrue(body.hasAttribute("ID"))
        XCTAssertFalse(body.hasAttribute("missing"))

        // get: -> nodeAtIndex, first -> firstNode, last -> lastNode, index -> indexOf
        let options = document.query("option")
        XCTAssertEqual(options.count, 3)
        XCTAssertEqual(options.firstNode()?.text(), "A")
        XCTAssertEqual(options.lastNode()?.text(), "C")
        XCTAssertEqual(options.nodeAtIndex(1)?.text(), "B")
        XCTAssertNil(options.nodeAtIndex(3))
        XCTAssertEqual(options.indexOf(options.nodeAtIndex(2)!), 2)

        // Query -> query, attr -> attributeValue, html -> innerHTML
        let select = document.query("select").firstNode() as? OCGumboElement
        XCTAssertEqual(select?.attributeValue("id"), "select")
        XCTAssertEqual(document.query("p").firstNode()?.innerHTML(), "text in p")
    }

    // MARK: - Sequence / Collection conformance

    func testNodeIsACollectionOfItsChildren() {
        let body = document.body!
        XCTAssertEqual(body.count, 5)
        XCTAssertEqual(body.startIndex, 0)
        XCTAssertEqual(body.endIndex, 5)
        XCTAssertNil(body.first?.nodeValue)

        let names = body.map { $0.nodeName ?? "#comment" }
        XCTAssertEqual(names, ["h1", "div", "p", "select", "#comment"])

        // Indexed access mirrors childNodes.
        XCTAssertEqual(body[0].nodeName, "h1")
        XCTAssertEqual(body[4].nodeType, GUMBO_NODE_COMMENT)
        XCTAssertEqual(body[3].nodeName, "select")

        // The document node yields its one child, the root element.
        var iterator = Array(document).makeIterator()
        XCTAssertEqual(iterator.next()?.nodeName, "html")
        XCTAssertNil(iterator.next())
    }

    func testIterationOverTextNodeIsEmpty() {
        let paragraph = document.query("p").firstNode()!
        let text = paragraph.first!
        XCTAssertEqual(text.nodeType, GUMBO_NODE_TEXT)
        XCTAssertEqual(text.count, 0)
        XCTAssertTrue(Array(text).isEmpty)
    }

    func testChildElementsSkipsTextAndComments() {
        XCTAssertEqual(document.body!.childElements.map(\.tagName),
                       ["h1", "div", "p", "select"])

        let div = document.firstElement(matching: "div")!
        XCTAssertEqual(div.childElements.map(\.tagName), ["span"])
        XCTAssertEqual(div.count, 2)
    }

    func testDescendants() {
        let body = document.body!
        let tags = body.descendantElements.map(\.tagName)
        XCTAssertEqual(tags, ["h1", "div", "span", "p", "select", "option", "option", "option"])

        // The receiver itself is not part of its own descendants, and every
        // direct child appears there. `OCGumboNode` implements `isEqual:` by
        // comparing the wrapped Gumbo nodes, so fresh wrappers compare equal.
        XCTAssertFalse(body.descendants.contains(body))
        XCTAssertTrue(Array(body).allSatisfy { body.descendants.contains($0) })
    }

    // MARK: - Attribute subscript

    func testAttributeSubscript() {
        let div = document.firstElement(matching: "div")!
        XCTAssertEqual(div["id"], "theId")
        XCTAssertEqual(div["class"], "alpha beta")
        XCTAssertEqual(div["data-role"], "hero")
        XCTAssertEqual(div["DATA-ROLE"], "hero", "HTML attribute names are case-insensitive")
        XCTAssertNil(div["missing"])
    }

    func testAttributeHelpers() {
        let div = document.firstElement(matching: "div")!
        XCTAssertEqual(div.id, "theId")
        XCTAssertEqual(div.classNames, ["alpha", "beta"])
        XCTAssertTrue(div.hasClass("alpha"))
        XCTAssertFalse(div.hasClass("gamma"))
        XCTAssertEqual(div.attributeMap,
                       ["id": "theId", "class": "alpha beta", "data-role": "hero"])

        let paragraph = document.firstElement(matching: "p")!
        XCTAssertNil(paragraph.id)
        XCTAssertEqual(paragraph.classNames, [])
        XCTAssertTrue(paragraph.attributeMap.isEmpty)
    }

    // MARK: - Query helpers

    func testSelectHelpers() {
        XCTAssertEqual(document.select("option").count, 3)
        XCTAssertEqual(document.selectElements("option").count, 3)
        XCTAssertEqual(document.selectElements(".alpha").map(\.tagName), ["div", "span"])

        XCTAssertEqual(document.firstElement(matching: "#theId")?.tagName, "div")
        XCTAssertNil(document.firstElement(matching: "table"))

        XCTAssertEqual(document.body!.firstElement(matching: "span")?.textContent, "world")
        XCTAssertEqual(document.body!.selectElements("option").count, 3)
    }

    func testQueryResultHelpers() {
        let paragraphs = document.query("p")
        XCTAssertEqual(paragraphs.nodes.count, 1)
        XCTAssertEqual(paragraphs.elements.map(\.tagName), ["p"])
        XCTAssertEqual(paragraphs.firstElement?.textContent, "text in p")

        // A nil selector returns the direct children of the document node.
        let everything = document.query(nil)
        XCTAssertEqual(everything.nodes.count, document.childNodes.count)

        let texts = document.query("select").children("option").textArray()
        XCTAssertEqual(texts.strings, ["A", "B", "C"])

        let empty = document.query("table")
        XCTAssertTrue(empty.nodes.isEmpty)
        XCTAssertNil(empty.firstElement)
    }

    // MARK: - Text content

    func testTextContent() {
        XCTAssertEqual(document.title, "Hello OCGumbo")
        XCTAssertEqual(document.firstElement(matching: "p")?.textContent, "text in p")
        XCTAssertEqual(document.body!.textContent, "Titlehello worldtext in pABC")
        XCTAssertEqual(document.textContent,
                       "Hello OCGumboTitlehello worldtext in pABC")
    }

    // MARK: - Malformed input

    func testMalformedHTMLIsRepaired() {
        let parsed = OCGumboDocument.parse("<html><body><p>one<p>two")
        XCTAssertEqual(parsed.selectElements("p").count, 2)
        XCTAssertEqual(parsed.query("p").text(), "onetwo")
    }
}
