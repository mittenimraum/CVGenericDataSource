Pod::Spec.new do |s|
  s.name             = 'CVGenericDataSource'
  s.version          = '1.0.0'
  s.license          = 'MIT'
  s.summary          = 'A generic data source for UICollectionView.'
  s.homepage         = 'https://github.com/mittenimraum/CVGenericDataSource'
  s.social_media_url = 'https://twitter.com/mittenimraum'
  s.authors          = { "Stephan Schulz"          => "kontakt@stephanschulz.com" }
  s.source           = { :git  => 'https://github.com/mittenimraum/CVGenericDataSource.git', :tag => s.version }
  s.ios.frameworks   = 'UIKit'

  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/*.swift'
  s.frameworks = 'UIKit'
  s.requires_arc = true
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3' }
end