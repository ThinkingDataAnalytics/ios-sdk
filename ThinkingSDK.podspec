Pod::Spec.new do |s|
  s.name             = 'ThinkingSDK'
  s.version          = '2.8.4-beta.4'
  s.summary          = 'Official ThinkingData SDK for iOS.'
  s.homepage         = 'https://github.com/ThinkingDataAnalytics/ios-sdk'
  s.license          = 'Apache License, Version 2.0'
  s.author           = { 'ThinkingData, Inc' => 'sdk@thinkingdata.cn' }
  s.source           = { :git => 'https://github.com/ThinkingDataAnalytics/ios-sdk.git', :tag => "v#{s.version}" }
  s.requires_arc     = true
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.frameworks       = 'Foundation', 'SystemConfiguration', 'CoreGraphics', 'Security'
  s.libraries        = 'sqlite3', 'z'
  s.default_subspec = 'Main'

  s.subspec 'OSX' do |s|
    path = "ThinkingSDK/Source"
    s.osx.deployment_target = '10.10'
    s.source_files = path + '/EventTracker/**/*.{h,m}', path + '/TDRuntime/**/*.{h,m}', path + '/Config/**/*.{h,m}', path + '/DeviceInfo/**/*.{h,m}', path + '/main/**/*.{h,m}',  path + '/Store/*.{h,m}', path + '/Network/**/*.{h,m}','ThinkingSDK/Source/Core/**/*.{h,m,c}', 'ThinkingSDK/Source/AppLifeCycle/**/*.{h,m}', 'ThinkingSDK/Source/Util/**/*.{h,m}', 'ThinkingSDK/Source/Extension/**/*.{h,m}'
    s.osx.exclude_files = path + '/DeviceInfo/TDFPSMonitor.{h,m}', path + '/DeviceInfo/TDPerformance.{h,m}', 'ThinkingSDK/Source/Util/Toast/*.{h,m}'

  end

  s.subspec 'iOS' do |i|
    path = "ThinkingSDK/Source"
    i.ios.deployment_target = '9.0'
    i.source_files = path + '/EventTracker/**/**/*.{h,m}', path + '/TDRuntime/**/*.{h,m}', path + '/Config/**/*.{h,m}', path + '/DeviceInfo/**/*.{h,m}', path + '/Router/*.{h,m}', path + '/main/**/*.{h,m}',  path + '/Store/**/*.{h,m}', path + '/Network/**/*.{h,m}', path + '/AppLaunch/**/*.{h,m}', path + '/AutoTrack/**/*.{h,m}', path + '/Encrypt/**/*.{h,m}', path + '/Exception/**/*.{h,m}',  'ThinkingSDK/Source/AppLifeCycle/**/*.{h,m}', 'ThinkingSDK/Source/Core/**/*.{h,m,c}', 'ThinkingSDK/Source/Util/**/*.{h,m}', 'ThinkingSDK/Source/Util/Toast/*.{h,m}', 'ThinkingSDK/Source/Extension/**/*.{h,m}'
    i.ios.frameworks = 'CoreTelephony', 'UIKit'
  end


  s.subspec 'Main' do |m|
    m.ios.dependency 'ThinkingSDK/iOS'
    m.osx.dependency 'ThinkingSDK/OSX'
  end

end
