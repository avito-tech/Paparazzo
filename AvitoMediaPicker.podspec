Pod::Spec.new do |s|
  s.name                   = 'AvitoMediaPicker'
  s.module_name            = 'AvitoMediaPicker'
  s.version                = '0.0.0'
  s.summary                = 'Avito Media Picker by Avito'
  s.homepage               = 'http://stash.msk.avito.ru/projects/MA/repos/avito-ios-media-picker'
  s.license                = 'Avito'
  s.author                 = { 'Andrey Yutkin' => 'ayutkin@avito.ru' }
  s.source                 = { :git => 'ssh://git@stash.msk.avito.ru:7999/ma/avito-ios-media-picker.git', :tag => "#{s.version}" }
  s.platform               = :ios, '8.0'
  s.ios.deployment_target = "8.0"
  s.requires_arc = true
  s.source_files = 'AvitoMediaPicker/Classes/**/*'
  s.resources = ['AvitoMediaPicker/Assets/Assets.xcassets']

  s.frameworks = 'UIKit', 'Photos', 'ImageIO', 'MobileCoreServices', 'GLKit', 'OpenGLES'
  s.dependency 'AvitoDesignKit', '0.0.6'
  s.dependency 'Marshroute'
  s.dependency 'JNWSpringAnimation'
end