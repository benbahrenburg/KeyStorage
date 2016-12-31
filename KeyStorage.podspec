
Pod::Spec.new do |s|
  s.name             = 'KeyStorage'
  s.version          = '0.2.0'
  s.summary          = 'KeyStorage is a simple secure key persistance library written in Swift.'

  s.description  = <<-DESC
	Persist passwords, preferences, and other key information quickly, easily and securely using the Keychain or NSUserDefaults.
  DESC

  s.homepage         = 'https://github.com/benbahrenburg/KeyStorage'
  s.license          = 'MIT'
  s.authors          = { 'Ben Bahrenburg' => 'hello@bencoding.com' }
  s.source           = { :git => 'https://github.com/benbahrenburg/KeyStorage.git', :tag => s.version }
  s.social_media_url = 'https://twitter.com/bencoding'

  s.ios.deployment_target = '9.0'

  s.source_files = 'KeyStorage/Classes/**/*'

end
