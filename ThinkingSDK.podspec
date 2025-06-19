Pod::Spec.new do |s|
  s.name             = 'ThinkingSDK'
  s.version          = '3.3.0-beta.1'
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
    s.source_files = path + '/EventTracker/**/*.{h,m}', path + '/Config/**/*.{h,m}', path + '/DeviceInfo/**/*.{h,m}', path + '/main/**/*.{h,m}', path + '/Store/**/*.{h,m}', path + '/Network/**/*.{h,m}', path + '/AppLifeCycle/**/*.{h,m}', path + '/Util/**/*.{h,m}', path + '/PresetProperty/**/*.{h,m}', path + '/Logger/**/*.{h,m}', path + '/AutoTrack/TDAutoTrackConst.h'
    s.dependency 'ThinkingDataCore', '1.3.1'
  end

  s.subspec 'iOS' do |i|
    path = "ThinkingSDK/Source"
    i.ios.deployment_target = '9.0'
    i.source_files = path + '/EventTracker/**/*.{h,m}', path + '/Config/**/*.{h,m}', path + '/DeviceInfo/**/*.{h,m}', path + '/main/**/*.{h,m}', path + '/Store/**/*.{h,m}', path + '/Network/**/*.{h,m}', path + '/AppLifeCycle/**/*.{h,m}', path + '/Util/**/*.{h,m}', path + '/PresetProperty/**/*.{h,m}', path + '/Logger/**/*.{h,m}', path + '/AutoTrack/**/*.{h,m}', path + '/Toast/**/*.{h,m}', path + '/Hook/**/*.{h,m}',path + '/AppLaunch/**/*.{h,m}', path + '/Encrypt/**/*.{h,m}', path + '/Exception/**/*.{h,m}'
    i.ios.frameworks = 'CoreTelephony', 'UIKit'
    i.dependency 'ThinkingDataCore', '1.3.1'
  end

  s.subspec 'Main' do |m|
    m.ios.dependency 'ThinkingSDK/iOS'
    m.osx.dependency 'ThinkingSDK/OSX'
  end

  s.resource_bundles = {'ThinkingSDK' => ['ThinkingSDK/Resources/**/*']}

end
