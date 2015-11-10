Pod::Spec.new do |s|

# ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.name         = "SJURLSessionOperation"
s.version      = "1.0.1"
s.summary      = "NSOperation solution for NSURLSession."

s.description  = <<-DESC
SJURLSessionOperation creates and manages an NSURLSessionDownloadTask object based on a specified request and download location. SJURLSessionOperation is a subclass of NSOperation which then can be used with a NSOperationQueue. In addition, it uses AFURLSessionManager so, it requires AFNetworking.
DESC

s.homepage     = "https://github.com/SoneeJohn/SJURLSessionOperation"

# ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.license      = "MIT"

# ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
 s.authors          = { "Soneé John" => "sonee@alphasoftware.co" }

# ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

s.platform = :osx, "10.9"
s.dependency 'AFNetworking', '~> 2.0'

# ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.source = { :git => "https://github.com/SoneeJohn/SJURLSessionOperation.git", :tag => "#{s.version}"}


# ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.source_files  = "Source Files/*.{h,m}"

# ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

# ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

# ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.requires_arc = true
end
