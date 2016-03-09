Pod::Spec.new do |s|
  s.name                  = "SJURLSessionOperation"
  s.version               = "1.2.0"
  s.summary               = "NSOperation solution for NSURLSession."
  s.description  = <<-DESC
SJURLSessionOperation creates and manages an NSURLSessionDownloadTask object based on a specified request and download location. SJURLSessionOperation is a subclass of NSOperation which then can be used with a NSOperationQueue. In addition, it uses AFURLSessionManager so, it requires AFNetworking.
DESC
  s.homepage              = "https://github.com/SoneeJohn/SJURLSessionOperation"
  s.license               = { :type => "MIT", :file => "LICENSE" }
  s.author                = { "Soneé John" => "sonee@alphasoftware.co" }
  s.social_media_url      = "https://twitter.com/Sonee_John"
  s.source                = { :git => "https://github.com/SoneeJohn/SJURLSessionOperation.git", :tag => s.version.to_s }
  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"
   s.dependency 'AFNetworking', '~> 3.0'
  s.source_files  = "Source Files/*.{h,m}"
  s.requires_arc          = true
end
