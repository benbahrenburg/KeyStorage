#
# Be sure to run `pod lib lint KeyStorage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KeyStorage'
  s.version          = '0.1.1'
  s.summary          = 'Simplifying securely saving key information'
  s.description      = <<-DESC
Simplifying securely saving key information.  An easy lite key persistance framework for the iOS KeyChain and NSUserDefaults.
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
