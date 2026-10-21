# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `.clang-format` configuration (WebKit-derived Objective-C style, 4-space
  indent) and consistently formatted `OCGumbo/*.h` and `OCGumbo/*.m`.
- HeaderDoc documentation comments on every public class, property, method and
  function in `OCGumbo.h` and `OCGumbo+Query.h`.
- `Package.swift` (swift-tools-version 5.7) with a `CGumbo` C target for the
  vendored Gumbo parser, an `OCGumbo` Objective-C target and an
  `OCGumboTests` test target. Supported platforms are iOS 12 and macOS 10.13.
- XCTest suite in `Tests/OCGumboTests` covering document parsing, root/head/body
  elements, text content, attributes, child nodes and the query API.
- GitHub Actions workflow that builds and tests the package with SwiftPM on
  macOS, checking out submodules recursively.
- `OCGumbo.podspec` (1.1.0) so the library can be installed with CocoaPods.
- `CHANGELOG.md` and `CONTRIBUTING.md`.

### Changed

- Rewrote `README.md` with badges, a feature summary, installation instructions
  for Swift Package Manager, CocoaPods and manual integration, Objective-C and
  Swift usage examples, and links to the contributing guide and license.
- `.gitignore` now also ignores SwiftPM build products.

### Fixed

- Nothing yet.

## [1.1.0] - 2026-10-21

First tagged release since 1.0. It contains no public API changes; the work is
project maintenance and packaging:

- Formatting and documentation cleanup of the public headers and sources.
- Swift Package Manager support, including the `CGumbo` C target.
- XCTest coverage for parsing and the query API.
- Continuous integration on GitHub Actions.
- CocoaPods support and a rewritten README.

## [1.0.0] - 2013-08-16

Initial public release: an Objective-C wrapper around Google's Gumbo HTML5
parser, with the `OCGumboNode`, `OCGumboElement`, `OCGumboText`,
`OCGumboDocument` and `OCGumboAttribute` object model.

[Unreleased]: https://github.com/tracy-e/OCGumbo/compare/1.1.0...HEAD
[1.1.0]: https://github.com/tracy-e/OCGumbo/releases/tag/1.1.0
[1.0.0]: https://github.com/tracy-e/OCGumbo/releases/tag/1.0
