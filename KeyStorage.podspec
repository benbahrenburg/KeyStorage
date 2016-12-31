#
# Be sure to run `pod lib lint KeyStorage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KeyStorage'
  s.version          = '0.1.4'
  s.summary          = 'Simplifying securely working with key information'
  s.description      = <<-DESC
KeyStorage makes working with key information (passwords, preferences, etc) quick, easily and secure. KeyStorage is a type safe persistance layer built on top of the iOS KeyChain and NSUserDefaults.
                       DESC

  s.homepage         = 'https://github.com/benbahrenburg/KeyStorage'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ben Bahrenburg' => '@bencoding' }
  s.source           = { :git => 'https://github.com/benbahrenburg/KeyStorage.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bencoding'

  s.ios.deployment_target = '9.0'

  s.source_files = 'KeyStorage/Classes/**/*'

end
