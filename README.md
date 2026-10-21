# OCGumbo

[![CI](https://github.com/tracy-e/OCGumbo/actions/workflows/ci.yml/badge.svg)](https://github.com/tracy-e/OCGumbo/actions/workflows/ci.yml)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](#swift-package-manager)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-compatible-brightgreen.svg)](#cocoapods)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

OCGumbo is an Objective-C wrapper around Google's [Gumbo](https://github.com/google/gumbo-parser),
a pure-C implementation of the HTML5 parsing algorithm. Gumbo repairs malformed
markup exactly like a browser does and returns a full parse tree; OCGumbo exposes
that tree as ordinary Foundation objects and adds a small, chainable query API.

## Features

- **Spec-compliant parsing.** Uses Gumbo's implementation of the HTML5 parsing
  algorithm, so broken or partial markup is repaired rather than rejected.
- **Objective-C object model.** Documents, elements, text nodes and attributes
  are `OCGumboDocument`, `OCGumboElement`, `OCGumboText` and `OCGumboAttribute`.
- **Direct access to the tree.** `rootElement`, `head`, `body`, `title`,
  `childNodes`, `parentNode`, `attributes` and doctype information.
- **CSS-like queries.** Select by tag name, class, id, `tag.class` or `tag#id`,
  then filter with `find`, `children`, `parent` and `parents`.
- **Text helpers.** Read the combined text of a node or a whole collection with
  `text`, or the raw inner markup with `html`.
- **No dependencies of its own.** Everything is built from the sources in this
  repository; the Gumbo parser is vendored as a git submodule.

## Requirements

- iOS 12.0+ or macOS 10.13+
- ARC is required
- Xcode 11+ / Swift 5.7+ for Swift Package Manager

## Installation

### Swift Package Manager

Add OCGumbo to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tracy-e/OCGumbo.git", from: "1.1.0")
]
```

Then add `OCGumbo` to your target's dependencies:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "OCGumbo", package: "OCGumbo")
    ]
)
```

The Gumbo parser itself lives in the `OCGumbo/gumbo` git submodule. SwiftPM
does not check out submodules for you, so initialize it once in your checkout
before building:

```sh
git submodule update --init --recursive
swift build
```

When using OCGumbo as a remote SwiftPM dependency, prefer a fork or mirror that
has the Gumbo sources vendored, or check the submodule out manually in
`.build/checkouts/OCGumbo`.

### CocoaPods

Add the pod to your `Podfile`:

```ruby
platform :ios, '12.0'

target 'MyApp' do
  pod 'OCGumbo', '~> 1.1'
end
```

Then run `pod install`.

### Manual installation

1. Clone the repository with its submodule:

   ```sh
   git clone --recursive https://github.com/tracy-e/OCGumbo.git
   ```

   If you already cloned it without `--recursive`, run
   `git submodule update --init --recursive`.

2. Add `OCGumbo/OCGumbo.h`, `OCGumbo/OCGumbo.m`, `OCGumbo/OCGumbo+Query.h` and
   `OCGumbo/OCGumbo+Query.m` to your target.
3. Add every file in `OCGumbo/gumbo/src` (`*.c` and `*.h`) to the same target, or
   link against a prebuilt Gumbo library and add its headers to the header
   search path.
4. Import `"OCGumbo.h"` (and `"OCGumbo+Query.h"` for queries).

## Usage

### Objective-C

```objective-c
#import "OCGumbo+Query.h"

NSString *html = @"<html><body>"
                 @"<h1 id=\"heading\">Hello</h1>"
                 @"<p class=\"lead\">World</p>"
                 @"<a href=\"https://example.com\">link</a>"
                 @"</body></html>";

OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:html];

// Structural access.
OCGumboElement *root = document.rootElement;   // the <html> element
OCGumboElement *head = document.head;
OCGumboElement *body = document.body;
NSLog(@"title: %@", document.title);
NSLog(@"root tag: %@ (%@)", root.tagName, [root getAttribute:@"lang"]);

// Attributes and children.
OCGumboElement *heading = document.Query(@"h1").first();
NSLog(@"heading id: %@", [heading getAttribute:@"id"]);
NSLog(@"body children: %@", body.childNodes);

// CSS-like queries.
NSLog(@"paragraphs: %@", document.Query(@"p").text());          // World
NSLog(@"by class: %@", document.Query(@".lead").text());        // World
NSLog(@"by tag+class: %@", document.Query(@"p.lead").text());   // World
NSLog(@"by id: %@", document.Query(@"#heading").text());        // Hello
NSLog(@"links: %@", document.Query(@"a").first().attr(@"href"));

// Traversal.
NSLog(@"within body: %@", document.Query(@"body").find(@"a").text());
NSLog(@"direct children: %@", document.Query(@"body").children(@"p").text());
NSLog(@"ancestors: %@", document.Query(@".lead").parents(@"body").count);
```

### Swift

```swift
import OCGumbo

let html = "<html><body><h1>Hello</h1><p class=\"lead\">World</p></body></html>"
let document = OCGumboDocument(htmlString: html)

if let body = document.body {
    print(body.tagName)              // body
}

// Query returns an OCQueryObject, an NSArray subclass whose helpers are
// imported as closures, so they are called like methods.
let headings = document.Query("h1")
print(headings.text())               // Hello

let leads = document.Query(".lead")
if let first = leads.first() as? OCGumboElement {
    print(first.text())              // World
    print(first.getAttribute("class") ?? "")
}

// Attribute helpers are available through the query category as well.
let links = document.Query("a")
if let href = links.first()?.attr("href") {
    print(href)
}
```

> **Note:** the query API is built from Objective-C block properties (`Query`,
> `text`, `attr`, `html`, `find`, `children`, `parent`, `parents`, ...).
> Swift imports each of them as a property whose value is a closure, so you call
> them like methods: `document.Query("h1").text()`, `element.attr("id")`.

## API overview

| Class | Description |
| --- | --- |
| `OCGumboDocument` | The root of a document tree; parse entry point. |
| `OCGumboElement` | An element: tag name, `GumboTag`, attributes. |
| `OCGumboText` | Text, CDATA, comment and whitespace nodes. |
| `OCGumboNode` | Base class for all nodes. |
| `OCGumboAttribute` | A name/value pair on an element. |
| `OCQueryObject` | An array of nodes with chainable query helpers. |

Selectors accepted by `Query`, `find`, `children`, `parent` and `parents`:
`#id`, `tag`, `.class`, `tag.class` and `tag#id`. Tag and id matching is
case-insensitive, as in HTML.

## Contributing

Bug reports, feature requests and pull requests are welcome. Please read
[CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## License

OCGumbo is released under the [Apache License 2.0](LICENSE).
[Gumbo](https://github.com/google/gumbo-parser) is also licensed under the
Apache License 2.0; see `OCGumbo/gumbo/COPYING`.
