Pod::Spec.new do |s|
  s.name         = "TextInputFilter"
  s.version      = "0.1.0"
  s.summary      = "Write your own reusable input filters for UITextField and UITextView"
  s.description  = <<-DESC
  TextInputFilter allows you to write contained and reusable input filters, that can filter and/or
  transform input as it's typed. The same filters can be used for UITextField or UITextView.
  DESC
  s.homepage     = "https://github.com/fabiorodella/TextInputFilter"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Fabio Rodella" => "fabiorodella@gmail.com" }
  s.ios.deployment_target = "9.0"
  s.source = { :git => "https://github.com/fabiorodella/TextInputFilter.git", :tag => s.version }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation", "UIKit"
  s.swift_version = '4.0'
end
