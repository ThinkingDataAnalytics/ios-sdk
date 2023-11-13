Pod::Spec.new do |s|
  s.name             = 'ThinkingSDK'
  s.version          = '3.0.1-beta.1'
  s.summary          = 'Official ThinkingData SDK for iOS.'
  s.homepage         = 'https://github.com/ThinkingDataAnalytics/ios-sdk'
  s.license          = 'Apache License, Version 2.0'
  s.author           = { 'ThinkingData, Inc' => 'sdk@thinkingdata.cn' }
  s.source           = { :git => 'https://github.com/ThinkingDataAnalytics/ios-sdk.git', :tag => "v#{s.version}" }
  s.requires_arc     = true
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.frameworks       = 'Foundation', 'SystemConfiguration', 'CoreGraphics', 'Security'
  s.libraries        = 'sqlite3', 'z'
  s.default_subspec = 'Main'

  s.subspec 'OSX' do |s|
    path = "ThinkingSDK/Source"
    s.osx.deployment_target = '10.11'
    s.source_files = path + '/EventTracker/**/*.{h,m}', path + '/TDRuntime/**/*.{h,m}', path + '/Config/**/*.{h,m}', path + '/DeviceInfo/**/*.{h,m}', path + '/main/**/*.{h,m}',  path + '/Store/*.{h,m}', path + '/Network/**/*.{h,m}', 'ThinkingSDK/Source/AppLifeCycle/**/*.{h,m}', 'ThinkingSDK/Source/Util/**/*.{h,m}', path + '/PresetProperty/**/*.{h,m}', path + '/Logger/**/*.{h,m}', path + '/Collections/**/*.{h,m}', path + '/CalibratedTime/**/*.{h,m,c}', path + '/ExtensionAnalyticsPlugin/**/*.{h,m}', path + '/AutoTrack/TDAutoTrackConst.h'
    s.osx.exclude_files = path + '/DeviceInfo/TDFPSMonitor.{h,m}', path + '/DeviceInfo/TDPerformance.{h,m}', 'ThinkingSDK/Source/Util/Toast/*.{h,m}'
    s.dependency 'ThinkingDataCore', '1.0.1'
  end

  s.subspec 'iOS' do |i|
    path = "ThinkingSDK/Source"
    i.ios.deployment_target = '9.0'
    i.source_files = path + '/EventTracker/**/**/*.{h,m}', path + '/Hook/**/*.{h,m}', path + '/Config/**/*.{h,m}', path + '/DeviceInfo/**/*.{h,m}', path + '/main/**/*.{h,m}', path + '/Store/**/*.{h,m}', path + '/Network/**/*.{h,m}', path + '/AppLaunch/**/*.{h,m}', path + '/AutoTrack/**/*.{h,m}', path + '/Encrypt/**/*.{h,m}', path + '/Exception/**/*.{h,m}',  path + '/AppLifeCycle/**/*.{h,m}',  path + '/ExtensionAnalyticsPlugin/**/*.{h,m}', path + '/PresetProperty/**/*.{h,m}', path + '/Util/**/*.{h,m}', path + '/Toast/**/*.{h,m}', path + '/Logger/**/*.{h,m}', path + '/Collections/**/*.{h,m}', path + '/CalibratedTime/**/*.{h,m,c}'
    i.ios.frameworks = 'CoreTelephony', 'UIKit'
    i.dependency 'ThinkingDataCore', '1.0.1'
  end

  s.subspec 'Main' do |m|
    m.ios.dependency 'ThinkingSDK/iOS'
    m.osx.dependency 'ThinkingSDK/OSX'
  end

end
