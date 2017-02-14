Pod::Spec.new do |s|
  s.name = 'OCGumbo'
  s.version = '1.0'
  s.license = {:type => 'Apache', :file => 'LICENSE'}
  s.summary = 'An Objective-C HTML5 parser based on Google Gumbo.'
  s.homepage = 'https://github.com/tracy-e/OCGumbo'
  s.authors = {'Tracy Yih' => 'tracy.cpp@gmail.com'}
  s.source = {:git => 'https://github.com/tracy-e/OCGumbo.git', :tag => '1.0'}
  s.source_files = 'OCGumbo/**/*.{h,m,c}'
  s.requires_arc = true
  s.ios.deployment_target = '5.0'
end
