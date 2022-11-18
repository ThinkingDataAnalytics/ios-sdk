Pod::Spec.new do |s|
  s.name             = 'ThinkingSDK'
  s.version          = '2.8.1.7-daofeng1'
  s.summary          = 'Official ThinkingData SDK for iOS.'
  s.homepage         = 'https://github.com/ThinkingDataAnalytics/ios-sdk'
  s.license          = 'Apache License, Version 2.0'
  s.author           = { 'ThinkingData, Inc' => 'sdk@thinkingdata.cn' }
  s.source           = { :git => 'https://github.com/ThinkingDataAnalytics/ios-sdk.git', :tag => "v#{s.version}" }
  s.requires_arc     = true
  s.platform         = :ios, "8.0"
  s.frameworks       = 'UIKit', 'Foundation', 'CoreTelephony', 'SystemConfiguration', 'CoreGraphics', 'Security'
  s.libraries        = 'sqlite3', 'z'
  s.source_files     = 'ThinkingSDK/Source/**/*.{h,m,c}' 

  s.subspec 'Core' do |c|
    c.source_files = 'ThinkingSDK/Source/Logger/**/*.{h,m}', 'ThinkingSDK/Source/CalibratedTime/**/*.{h,m,c}', 'ThinkingSDK/Source/Config/TDConstant.h'

  end

  s.subspec 'Extension' do |e|
    e.source_files = 'ThinkingSDK/Source/Extension/**/*.{h,m}' 
    e.dependency 'ThinkingSDK/Core'
  end

end
