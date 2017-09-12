Pod::Spec.new do |s|
  s.name                   = 'Paparazzo'
  s.module_name            = 'Paparazzo'
  s.version                = '2.0.0'
  s.summary                = "iOS component for picking and editing photos from camera and user's photo library"
  s.homepage               = 'https://github.com/avito-tech/Paparazzo'
  s.license                = 'MIT'
  s.author                 = { 'Andrey Yutkin' => 'ayutkin@avito.ru' }
  s.source                 = { :git => 'https://github.com/avito-tech/Paparazzo.git', :tag => "#{s.version}" }
  s.platform               = :ios, '8.0'
  s.ios.deployment_target = "8.0"
  s.requires_arc = true

  s.frameworks = 'UIKit', 'Photos', 'ImageIO', 'MobileCoreServices', 'GLKit', 'OpenGLES', 'CoreMedia', 'CoreVideo', 'AVFoundation', 'QuartzCore'
  
  s.dependency 'JNWSpringAnimation'
  
  s.dependency 'ImageSource/Core'
  s.dependency 'ImageSource/PHAsset'
  s.dependency 'ImageSource/Local'
  s.dependency 'ImageSource/Remote'

  s.default_subspec = 'Core', 'Marshroute', 'AlamofireImage'

  s.subspec 'AlamofireImage' do |ai|
    ai.dependency 'Paparazzo/Core'
    ai.dependency 'ImageSource/AlamofireImage'
  end

  s.subspec 'SDWebImage' do |sd|
    sd.dependency 'Paparazzo/Core'
    sd.dependency 'ImageSource/SDWebImage'
  end
  
  s.subspec 'Core' do |cs|
    cs.source_files = 'Paparazzo/Core/**/*'
    cs.resources = ['Paparazzo/Assets/Assets.xcassets']
  end
  
  s.subspec 'Marshroute' do |ms|
    ms.dependency 'Paparazzo/Core'
    ms.dependency 'Marshroute'
    ms.source_files = 'Paparazzo/Marshroute/**/*'
  end
end