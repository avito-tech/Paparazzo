Pod::Spec.new do |s|
  s.name                   = 'AvitoMediaPicker'
  s.module_name            = 'AvitoMediaPicker'
  s.version                = '1.0.0'
  s.summary                = 'Avito Media Picker by Avito'
  s.homepage               = 'http://stash.msk.avito.ru/projects/MA/repos/avito-ios-media-picker'
  s.license                = 'Avito'
  s.author                 = { 'Andrey Yutkin' => 'ayutkin@avito.ru' }
  s.source                 = { :git => 'ssh://git@stash.msk.avito.ru:7999/ma/avito-ios-media-picker.git', :tag => "#{s.version}" }
  s.platform               = :ios, '8.0'
  s.ios.deployment_target = "8.0"
  s.requires_arc = true

  s.frameworks = 'UIKit', 'Photos', 'ImageIO', 'MobileCoreServices', 'GLKit', 'OpenGLES', 'CoreMedia', 'CoreVideo', 'AVFoundation', 'QuartzCore'
  s.dependency 'JNWSpringAnimation'
  s.dependency 'SDWebImage', '~> 3.8'
  s.dependency 'ImageSource'
  
  s.subspec 'Core' do |cs|
    cs.source_files = 'AvitoMediaPicker/Core/**/*'
    cs.resources = ['AvitoMediaPicker/Assets/Assets.xcassets']
  end
  
  s.subspec 'Marshroute' do |ms|
    ms.dependency 'AvitoMediaPicker/Core'
    ms.dependency 'Marshroute'
    ms.source_files = 'AvitoMediaPicker/Marshroute/**/*'
  end
end