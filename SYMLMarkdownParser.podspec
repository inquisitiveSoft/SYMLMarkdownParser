Pod::Spec.new do |s|
  s.name         = "SYMLMarkdownParser"
  s.version      = "0.0.1"
  s.summary      = "SYMLMarkdownParser is a markdown parser that generates attributed strings"
  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/inquisitivesoft/SYMLMarkdownParser"
  s.license      = "MIT"
  s.author       = { "Harry Jordan" => "harry@inquisitivesoftware.com" }
	
  s.ios.deployment_target = "5.0"
  s.osx.deployment_target = "10.7"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
	
  s.source       = { :git => "https://github.com/inquisitivesoft/SYMLMarkdownParser.git", :tag => "1.0" }
  s.source_files  = "Source"
	s.framework = 'Foundation'
  s.requires_arc = true
	
  s.dependency "RegexKitLite", "~> 4.0.1"
end
