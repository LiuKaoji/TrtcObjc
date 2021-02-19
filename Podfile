# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'TrtcObjc' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TrtcOjc
pod 'GPUImage'
pod 'Masonry'
pod 'ReactiveObjC'
pod 'StepSlider'

#指定最新实时音视频精简版SDK
pod 'TXLiteAVSDK_TRTC', :podspec => 'http://pod-1252463788.cosgz.myqcloud.com/liteavsdkspec/TXLiteAVSDK_TRTC.podspec'

#指定最新专业版SDK
#pod 'TXLiteAVSDK_Professional', :podspec => 'http://pod-1252463788.cosgz.myqcloud.com/liteavsdkspec/TXLiteAVSDK_Professional.podspec'

#指定版本:旧版可能需要屏蔽一些代码
#pod 'TXLiteAVSDK_TRTC',  '<= 8.2'
#pod 'TXLiteAVSDK_Professional',  '<= 8.2'

end

#M1芯片模拟器适配
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
