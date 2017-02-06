Pod::Spec.new do |s|
s.name         = "katsana-sdk-ios"
s.version      = "0.9.1"
s.summary      = "Access Katsana platform"

s.description  = <<-DESC
SDK for accessing Katsana platform data
DESC

s.homepage     = "https://github.com/katsana/katsana-sdk-ios"
s.license      = {:type => 'apache'}
s.author       = { "Wan Ahmad Lutfi" => "lutfime_2000@yahoo.com" }
s.ios.deployment_target = "8.0"
s.osx.deployment_target = "10.11"
s.source_files  = 'KatsanaSDK', 'KatsanaSDK/**/*.{swift,h,m}'
s.public_header_files = 'KatsanaSDK/**/*.h'
#s.resources    = "KatsanaSDK/*.png"
s.framework    = 'CoreLocation'
s.requires_arc = true
s.source       = { :git => "https://github.com/katsana/katsana-sdk-ios.git", :tag => "#{s.version}" }

s.dependency 'Siesta'
s.dependency 'XCGLogger'

end

