Pod::Spec.new do |s|
  s.name             = 'ThinkingSDK'
  s.version          = '2.6.0'
  s.summary          = 'Official ThinkingData SDK for iOS.'

  s.homepage         = 'https://github.com/ThinkingDataAnalytics/ios-sdk'
  s.license          = 'Apache License, Version 2.0'
  s.author           = { 'ThinkingData, Inc' => 'sunyujuan@thinkingdata.cn' }
  s.source           = { :git => 'https://github.com/ThinkingDataAnalytics/ios-sdk.git', :tag => "v#{s.version}" }
  s.requires_arc     = true
  s.platform         = :ios, "8.0"

  s.frameworks       = 'UIKit', 'Foundation', 'CoreTelephony', 'SystemConfiguration', 'CoreGraphics', 'Security'
  s.libraries        = 'sqlite3', 'z'

  s.default_subspec  = 'Core'
    
  s.subspec 'Core' do |core|
     core.source_files        = 'ThinkingSDK/Source/*.{m,h}', 'ThinkingSDK/Source/autotrack/*.{m,h}', 'ThinkingSDK/Source/CalibratedTime/*.{c,m,h}', 'ThinkingSDK/Source/EventModel/*.{m,h}'
     core.public_header_files = 'ThinkingSDK/Source/ThinkingAnalyticsSDK.h', 'ThinkingSDK/Source/ThinkingSDK.h', 'ThinkingSDK/Source/EventModel/TDEventModel.h', 'ThinkingSDK/Source/EventModel/TDFirstEventModel.h', 'ThinkingSDK/Source/EventModel/TDEditableEventModel.h'
     core.resources           = ['ThinkingSDK/TDAnalyticsSDK.bundle']
  end
end
