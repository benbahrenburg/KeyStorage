
Pod::Spec.new do |s|
  s.name             = 'KeyStorage'
  s.version          = '0.1.6'
  s.summary          = 'Simplifying securely working with key information'
  s.homepage         = 'https://github.com/benbahrenburg/KeyStorage'
  s.license          = 'MIT'
  s.authors          = { 'Ben Bahrenburg' => 'hello@bencoding.com' }
  s.source           = { :git => 'https://github.com/benbahrenburg/KeyStorage.git', :tag => s.version }
  s.social_media_url = 'https://twitter.com/bencoding'

  s.ios.deployment_target = '9.0'

  s.source_files = 'KeyStorage/Classes/**/*'

end
