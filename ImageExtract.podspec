Pod::Spec.new do |s|

  s.name                   = "ImageExtract"
  s.version                = "1.0.0"
  s.summary                = "A Swift library to allows you to extract the size of an image without downloading."
  s.homepage               = "https://github.com/gumob/ImageExtract"
  s.license                = { :type => "MIT", :file => "LICENSE" }
  s.author                 = { "gumob" => "hello@gumob.com" }
  s.requires_arc           = true
  s.source                 = { :git => "https://github.com/gumob/ImageExtract.git", :tag => "#{s.version}" }
  s.source_files           = "Source/*.{swift}"
  s.ios.deployment_target  = "9.0"
  s.tvos.deployment_target = "10.0"
  s.watchos.deployment_target = "3.0"
  s.osx.deployment_target  = "10.11"
  s.swift_version          = '4.2'

end
