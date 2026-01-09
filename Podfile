use_frameworks!
target "KatsanaSDK" do
    platform :ios, '9.0'
    pod 'Siesta'
    pod 'XCGLogger'
    pod 'FastCoding'
end

target "KatsanaSDK macOS" do
platform :osx, '10.11'
    pod 'Siesta'
    pod 'XCGLogger'
    pod 'FastCoding'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if Gem::Version.new('9.0') > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end
