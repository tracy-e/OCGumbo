# Contributing to OCGumbo

Thanks for taking the time to contribute! This document describes how to report
bugs, propose features and get a pull request merged.

## Reporting issues

Before opening an issue, please search the existing issues to avoid duplicates.
A good bug report includes:

- The OCGumbo version (or commit) you are using.
- The platform and toolchain (iOS/macOS version, Xcode and Swift version).
- A minimal HTML input that reproduces the problem.
- What you expected to happen and what actually happened, including any crash
  log or console output.

If the problem is in the HTML5 parsing algorithm itself rather than in the
Objective-C wrapper, please check whether it also reproduces with
[Gumbo](https://github.com/google/gumbo-parser) directly, and report it upstream
if it does.

## Feature requests

Feature requests are welcome. Please describe the use case and the API you have
in mind. Keep in mind that OCGumbo aims to stay a thin wrapper: changes to the
public API should be small, additive and consistent with the existing object
model and query style.

## Working on the code

1. Clone the repository including the Gumbo submodule:

   ```sh
   git clone --recursive https://github.com/tracy-e/OCGumbo.git
   ```

   If you already cloned it, run `git submodule update --init --recursive`.

2. Create a topic branch for your change:

   ```sh
   git checkout -b fix-my-bug
   ```

3. Build and test with Swift Package Manager:

   ```sh
   swift build
   swift test
   ```

   You can also add `OCGumbo/*.{h,m}` and `OCGumbo/gumbo/src` to an Xcode
   target, as described in the README.

4. Format the files you touched:

   ```sh
   clang-format -i OCGumbo/*.h OCGumbo/*.m Tests/OCGumboTests/*.m
   ```

   The formatting rules live in `.clang-format` and are based on the WebKit
   style with a 4-space indent.

## Submodule policy

`OCGumbo/gumbo` is an unmodified git submodule of
[google/gumbo-parser](https://github.com/google/gumbo-parser). Do not edit files
inside it. If a fix is needed in Gumbo, send it upstream and update the
submodule pointer once it is merged (or propose a patch that keeps the
submodule clean, such as a workaround in the Objective-C wrapper).

## Pull requests

- Keep each pull request focused on a single logical change.
- Add or update tests for behaviour changes.
- Update `CHANGELOG.md` under the `Unreleased` heading.
- Document any new public API with HeaderDoc comments (`/** ... */`) in the
  header, following the existing style.
- Make sure `swift build` and `swift test` pass; CI runs them on macOS.
- Do not include unrelated reformatting in a functional change.

By contributing you agree that your contributions are licensed under the
[Apache License 2.0](LICENSE), the same license as the project.
