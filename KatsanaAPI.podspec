Pod::Spec.new do |s|
s.name         = "KatsanaAPI"
s.version      = "0.0.1"
s.summary      = "Katsana sdk to access Katsana API"

s.description  = <<-DESC
Provide easier access to Katsana API using iOS sdk
DESC

s.homepage     = "https://github.com/katsana/katsana-sdk-ios"
s.license      = {:type => 'apache'}
s.author       = { "Wan Ahmad Lutfi" => "lutfime_2000@yahoo.com" }
s.platform     = :ios, '7.0'
s.source_files  = 'KatsanaAPI', 'KatsanaAPI/**/*.{h,m}'
s.public_header_files = 'KatsanaAPI/**/*.h'
#s.resources    = "KatsanaAPI/*.png"
s.framework    = 'CoreLocation'
s.requires_arc = true
s.source       = { :git => "https://github.com/katsana/katsana-sdk-ios.git", :tag => "#{s.version}" }

s.dependency 'RestKit'
s.dependency 'FastCoding'
s.dependency 'CocoaLumberjack'

end

