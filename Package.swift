// swift-tools-version:5.7
//
// Package.swift
// OCGumbo
//
// Swift Package Manager manifest for OCGumbo, an HTML5 parser for Swift and
// Objective-C, built on Google's Gumbo.
//
// Gumbo itself is vendored, unmodified, in OCGumbo/gumbo.

import PackageDescription

let package = Package(
    name: "OCGumbo",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "OCGumbo",
            targets: ["OCGumbo"]
        ),
        .library(
            name: "OCGumboSwift",
            targets: ["OCGumboSwift"]
        )
    ],
    targets: [
        // The Gumbo HTML5 parser, compiled straight from the vendored sources.  Its
        // sources sit outside this target's own path (paths cannot contain
        // ".."), so the target is rooted at the package root and `exclude`
        // keeps everything except the Gumbo sources out of it.  The module's
        // public header is the shim in Sources/CGumbo/include, which in turn
        // includes the real vendored gumbo.h.
        .target(
            name: "CGumbo",
            path: ".",
            exclude: [
                "Tests",
                "Sources/OCGumboSwift",
                "OCGumbo/OCGumbo.h",
                "OCGumbo/OCGumbo.m",
                "OCGumbo/OCGumbo+Query.h",
                "OCGumbo/OCGumbo+Query.m",
                "OCGumbo/module.modulemap"
            ],
            sources: ["OCGumbo/gumbo/src"],
            publicHeadersPath: "Sources/CGumbo/include",
            cSettings: [
                .headerSearchPath("OCGumbo/gumbo/src")
            ]
        ),

        // The Objective-C wrapper.  OCGumbo/module.modulemap pins the two
        // public headers so the vendored Gumbo sources beside them are not
        // swept into the module.
        .target(
            name: "OCGumbo",
            dependencies: ["CGumbo"],
            path: "OCGumbo",
            exclude: ["gumbo"],
            sources: [
                "OCGumbo.m",
                "OCGumbo+Query.m"
            ],
            publicHeadersPath: "."
        ),

        // The Swift overlay.  It depends on the Objective-C target and adds
        // Swift-only conveniences (Sequence/Collection conformance, attribute
        // subscripts and typed query helpers) without touching the Objective-C
        // API or its selectors.
        .target(
            name: "OCGumboSwift",
            dependencies: ["OCGumbo"],
            path: "Sources/OCGumboSwift"
        ),

        .testTarget(
            name: "OCGumboTests",
            dependencies: ["OCGumbo"],
            path: "Tests/OCGumboTests"
        ),

        // Swift overlay tests.  They exercise the Swift-only conveniences and
        // basic parsing through the overlay's entry point.
        .testTarget(
            name: "OCGumboSwiftTests",
            dependencies: ["OCGumboSwift"],
            path: "Tests/OCGumboSwiftTests"
        )
    ]
)
