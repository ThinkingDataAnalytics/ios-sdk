Pod::Spec.new do |s|
  s.name             = 'ThinkingSDK'
  s.version          = '2.0.0'
  s.summary          = 'Official ThinkingDara SDK for iOS.'

  s.homepage         = 'https://www.thinkingdata.cn'
  s.license          = 'Apache License, Version 2.0'
  s.author           = { 'ThinkingData, Inc' => 'sunyujuan@thinkingdata.cn' }
  s.source           = { :git => 'http://10.27.249.150:8888/thinking-analytics/data-collector/client-sdk/ios-sdk.git', :tag => s.version.to_s }
  s.requires_arc     = true
  s.platform         = :ios, "8.0"

  s.source_files        = 'ThinkingSDK/Source/*.{m,h}','ThinkingSDK/Source/autotrack/*.{m,h}'
  s.frameworks          = 'UIKit', 'Foundation', 'CoreTelephony', 'SystemConfiguration', 'CoreGraphics', 'Security'
  s.libraries           = 'sqlite3', 'z'
  s.public_header_files = 'ThinkingSDK/Source/ThinkingAnalyticsSDK.h', 'ThinkingSDK/Source/TDConfig.h'
  s.resources           = ['ThinkingSDK/TDAnalyticsSDK.bundle']
  
end