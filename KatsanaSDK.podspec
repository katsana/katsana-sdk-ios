Pod::Spec.new do |s|
s.name         = "KatsanaSDK"
s.version      = "0.9.3"
s.summary      = "Access Katsana platform"

s.description  = <<-DESC
SDK for accessing Katsana platform data
DESC

s.homepage     = "https://github.com/katsana/katsana-sdk-ios"
s.license      = 'apache'
s.author       = { "Wan Ahmad Lutfi" => "lutfime_2000@yahoo.com" }
s.platform = :ios, '8.0'
s.platform = :osx, '10.11'
s.ios.deployment_target = "8.0"
s.osx.deployment_target = "10.11"
s.source_files  = 'KatsanaSDK/**/*.{swift,h,m}'
s.public_header_files = 'KatsanaSDK/**/*.h'
s.ios.exclude_files = 'KatsanaSDK/macOS'
s.osx.exclude_files = 'KatsanaSDK/iOS'
s.framework    = 'CoreLocation'
s.ios.framework  = 'UIKit'
s.osx.framework  = 'AppKit'
s.requires_arc = true
s.source       = { :git => "https://github.com/katsana/katsana-sdk-ios.git", :tag => "#{s.version}" }

s.dependency 'Siesta', '~>1.3.0'
s.dependency 'XCGLogger'
s.dependency 'FastCoding'

end

