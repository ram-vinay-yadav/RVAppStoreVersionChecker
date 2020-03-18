Pod::Spec.new do |s|
  s.name             = 'RVAppStoreVersionChecker'
  s.version          = '1.0'
  s.summary          = 'To update new version of App'
 
  s.description      = <<-DESC
Update new version of App from App store.
                       DESC
 
  s.homepage         = 'https://github.com/ram-vinay-yadav/RVAppStoreVersionChecker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ram Vinay Yadav' => 'ramvinay093@gmail.com' }
  s.source           = { :git => 'https://github.com/ram-vinay-yadav/RVAppStoreVersionChecker.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '10.0'
  s.swift_version = '4.0'
  s.source_files = 'RVAppStoreVersionChecker/RVAppStoreVersionChecker/**/*.{swift,h,xib}'
 
end
