Pod::Spec.new do |s|
  s.name             = 'ThinkingSDK'
  s.version          = '2.7.3'
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
end