Pod::Spec.new do |s|
  s.name             = 'ThinkingSDK'
  s.version          = '2.1.0'
  s.summary          = 'Official ThinkingData SDK for iOS.'

  s.homepage         = 'https://github.com/ThinkingDataAnalytics/ios-sdk'
  s.license          = 'Apache License, Version 2.0'
  s.author           = { 'ThinkingData, Inc' => 'sunyujuan@thinkingdata.cn' }
  s.source           = { :git => 'https://github.com/ThinkingDataAnalytics/ios-sdk.git', :tag => s.version.to_s }
  s.requires_arc     = true
  s.platform         = :ios, "8.0"

  s.source_files        = 'ThinkingSDK/Source/*.{m,h}', 'ThinkingSDK/Source/AutoTrack/*.{m,h}'
  s.public_header_files = 'ThinkingSDK/Source/ThinkingAnalyticsSDK.h', 'ThinkingSDK/Source/ThinkingSDK.h'
  s.frameworks          = 'UIKit', 'Foundation', 'CoreTelephony', 'SystemConfiguration', 'CoreGraphics', 'Security'
  s.libraries           = 'sqlite3', 'z'
  s.resources           = ['ThinkingSDK/TDAnalyticsSDK.bundle']
  
end