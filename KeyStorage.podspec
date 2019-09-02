
Pod::Spec.new do |s|
  s.name             = 'KeyStorage'
  s.version          = '0.2.7'
  s.summary          = 'KeyStorage is a simple secure key persistance library written in Swift.'

  s.description  = <<-DESC
	Persist passwords, preferences, and other key information quickly, easily and securely using the Keychain or NSUserDefaults.
  DESC

  s.homepage         = 'https://github.com/benbahrenburg/KeyStorage'
  s.license          = 'MIT'
  s.authors          = { 'Ben Bahrenburg' => 'hello@bencoding.com' }
  s.source           = { :git => 'https://github.com/benbahrenburg/KeyStorage.git', :tag => s.version }
  s.social_media_url = 'https://twitter.com/bencoding'
  s.swift_version = "5.0"
  s.ios.deployment_target = '11.0'
  s.watchos.deployment_target = '4.0'
  s.source_files = 'KeyStorage/Classes/**/*'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
end
