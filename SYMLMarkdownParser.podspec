Pod::Spec.new do |s|
  s.name         = "SYMLMarkdownParser"
  s.version      = "1.0.1"
  s.summary      = "SYMLMarkdownParser is a streamlined markdown parser written in Objective-C"
  s.description  = <<-DESC
		SYMLMarkdownParser is a markdown parser that detects the semantics of the input text as well as generating attributed strings
                   DESC

  s.homepage     = "https://github.com/inquisitivesoft/SYMLMarkdownParser"
  s.license      = "MIT"
  s.author       = { "Harry Jordan" => "harry@inquisitivesoftware.com" }
	
  s.ios.deployment_target = "5.0"
  s.osx.deployment_target = "10.7"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
	
  s.source       = { :git => "https://github.com/inquisitivesoft/SYMLMarkdownParser.git", :tag => "1.0.1" }
  s.source_files  = "Source"
	s.framework = 'Foundation'
  s.requires_arc = true
	
  s.dependency "RegexKitLite", "~> 4.0.6"
end
