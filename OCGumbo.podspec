Pod::Spec.new do |spec|
  spec.name = 'OCGumbo'
  spec.version = '1.1.0'
  spec.license = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  spec.summary = "A fast HTML5 parser for Swift and Objective-C, built on Google Gumbo."
  spec.description = <<-DESC
    OCGumbo is an HTML5 parser for Swift and Objective-C, built on Google's
    Gumbo. It exposes the parsed document as Foundation objects (documents,
    elements, text nodes and attributes), annotated for idiomatic use from
    Swift, and adds a CSS-like query API for selecting nodes by tag name,
    class and id.
  DESC
  spec.homepage = 'https://github.com/tracy-e/OCGumbo'
  spec.authors = { 'Tracy Yih' => 'tracy.cpp@gmail.com' }
  spec.source = {
    :git => 'https://github.com/tracy-e/OCGumbo.git',
    :tag => spec.version.to_s,
    :submodules => true
  }
  spec.documentation_url = 'https://github.com/tracy-e/OCGumbo/blob/master/README.md'

  spec.requires_arc = true
  spec.ios.deployment_target = '12.0'
  spec.osx.deployment_target = '10.13'
  spec.frameworks = 'Foundation'

  # Gumbo is vendored as the OCGumbo/gumbo git submodule (:submodules above),
  # so its C sources are compiled directly into the pod. Only the wrapper's
  # headers are public.
  spec.source_files = 'OCGumbo/*.{h,m}', 'OCGumbo/gumbo/src/*.{c,h}'
  # Only the wrapper headers are public; Gumbo's headers stay private to the pod.
  spec.public_header_files = 'OCGumbo/OCGumbo.h', 'OCGumbo/OCGumbo+Query.h'
  spec.preserve_paths = 'LICENSE', 'README.md', 'CHANGELOG.md', 'CONTRIBUTING.md'
end
