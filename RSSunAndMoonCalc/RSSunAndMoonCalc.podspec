Pod::Spec.new do |s|
  s.name             = 'RSSunAndMoonCalc'
  s.version          = '0.2.0'
  s.summary          = 'Sun and Moon calculations in Swift 4.'
 
  s.description      = <<-DESC
Sunrise, sunset, Moon rise and set ; Sun position : Moon position and more!
                       DESC
 
  s.homepage         = 'https://github.com/iLandes/RSSunAndMoonCalc'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sebastien REMY' => 'seb.remy@me.com' }
  s.source           = { :git => 'https://github.com/iLandes/RSSunAndMoonCalc.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '10.0'
  s.source_files = 'RSSunAndMoonCalc/RSSunAndMoonCalc.swift'
 
end
