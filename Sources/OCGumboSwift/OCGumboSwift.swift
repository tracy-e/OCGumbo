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

import Foundation

// Re-export the Objective-C module so that depending on OCGumboSwift is enough
// at the call site: `import OCGumboSwift` brings in the whole OCGumbo API as
// well as the conveniences below.
@_exported import OCGumbo

// MARK: - Traversal

/// Every node is a collection of its direct children, so walking the tree reads
/// like ordinary Swift collection code:
///
/// ```swift
/// for child in document.body! where child is OCGumboElement {
///     print(child.nodeName ?? "")
/// }
/// print(document.body!.count)           // number of child nodes
/// print(document.body!.first?.nodeName)
/// ```
///
/// The children are re-read from the (already immutable) parse tree on every
/// access, so the conformance is `Collection` rather than
/// `RandomAccessCollection`: addressing a child costs time proportional to its
/// position.
extension OCGumboNode: Collection {
    /// The type produced while iterating over a node's children.
    public typealias Element = OCGumboNode
    /// The index type used to address children.
    public typealias Index = Int

    /// The position of the first child, or 0 for a childless node.
    public var startIndex: Index {
        return 0
    }

    /// The position one past the last child.
    public var endIndex: Index {
        return childNodes.count
    }

    /// Returns the position immediately after `i`.
    public func index(after i: Index) -> Index {
        return i + 1
    }

    /// Returns the child at `position`.
    public subscript(position: Index) -> Element {
        return childNodes[position]
    }
}

extension OCGumboNode {
    /// The direct children of the receiver that are elements.
    ///
    /// Text, comment and whitespace children are skipped, which makes this the
    /// convenient way to walk the element tree.
    public var childElements: [OCGumboElement] {
        return childNodes.compactMap { $0 as? OCGumboElement }
    }

    /// Every descendant of the receiver in document (depth-first) order.
    ///
    /// The receiver itself is not included.
    public var descendants: [OCGumboNode] {
        var result: [OCGumboNode] = []
        for child in childNodes {
            result.append(child)
            result.append(contentsOf: child.descendants)
        }
        return result
    }

    /// Every descendant element of the receiver in document order.
    public var descendantElements: [OCGumboElement] {
        return descendants.compactMap { $0 as? OCGumboElement }
    }

    /// The combined text contents of the receiver and its descendants.
    ///
    /// A typed property wrapping the `text` query block, so it can be used in
    /// string interpolation and collection operations directly.
    public var textContent: String {
        return text()
    }

    /// Returns the descendants of the receiver matching a selector.
    ///
    /// Selectors are the ones understood by `query`: `#id`, `tag`, `.class`,
    /// `tag.class` and `tag#id`.
    public func select(_ selector: String) -> [OCGumboNode] {
        return query(selector).nodes
    }

    /// Returns the descendant elements matching a selector.
    public func selectElements(_ selector: String) -> [OCGumboElement] {
        return select(selector).compactMap { $0 as? OCGumboElement }
    }

    /// Returns the first descendant element matching a selector, if any.
    public func firstElement(matching selector: String) -> OCGumboElement? {
        return selectElements(selector).first
    }
}

// MARK: - Attributes

extension OCGumboElement {
    /// Reads an attribute by name using subscript syntax.
    ///
    /// Names are matched case-insensitively, as in HTML, and the result is
    /// `nil` when the element has no such attribute:
    ///
    /// ```swift
    /// if let href = link["href"] { ... }
    /// ```
    public subscript(name: String) -> String? {
        return self.attribute(named: name)
    }

    /// The value of the element's `id` attribute, if any.
    public var id: String? {
        return attribute(named: "id")
    }

    /// The element's class list, in source order.
    ///
    /// Class names are split on whitespace; an element without a `class`
    /// attribute has an empty list.
    public var classNames: [String] {
        guard let value = attribute(named: "class") else {
            return []
        }
        return value.split(whereSeparator: { $0.isWhitespace }).map(String.init)
    }

    /// All attributes of the element, keyed by name.
    public var attributeMap: [String: String] {
        var result: [String: String] = [:]
        for attribute in attributes {
            result[attribute.name] = attribute.value
        }
        return result
    }

    /// Returns whether the element's class list contains `name`.
    ///
    /// A working Swift alternative to the unimplemented `hasClass` query block.
    public func hasClass(_ name: String) -> Bool {
        return classNames.contains(name)
    }
}

// MARK: - Query results

extension OCQueryObject where ObjectType == OCGumboNode {
    /// The query result as a strongly typed array of nodes.
    public var nodes: [OCGumboNode] {
        var result: [OCGumboNode] = []
        result.reserveCapacity(count)
        for index in 0..<count {
            result.append(self[index])
        }
        return result
    }

    /// The query result as an array of elements, skipping non-element nodes.
    public var elements: [OCGumboElement] {
        return nodes.compactMap { $0 as? OCGumboElement }
    }

    /// The first element of the query result, if any.
    public var firstElement: OCGumboElement? {
        return elements.first
    }
}

extension OCQueryObject where ObjectType == NSString {
    /// The query result as a strongly typed array of strings.
    public var strings: [String] {
        var result: [String] = []
        result.reserveCapacity(count)
        for index in 0..<count {
            result.append(self[index] as String)
        }
        return result
    }
}

// MARK: - Parsing

extension OCGumboDocument {
    /// Parses an HTML string and returns the resulting document.
    ///
    /// A spelling of `init(html:)` that reads well at the call site:
    ///
    /// ```swift
    /// let document = OCGumboDocument.parse("<p>Hello</p>")
    /// ```
    public static func parse(_ html: String) -> OCGumboDocument {
        return OCGumboDocument(html: html)
    }
}
