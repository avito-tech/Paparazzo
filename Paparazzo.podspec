Pod::Spec.new do |s|
  s.name                   = 'Paparazzo'
  s.module_name            = 'Paparazzo'
  s.version                = '3.0.0'
  s.summary                = "iOS component for picking and editing photos from camera and user's photo library"
  s.homepage               = 'https://github.com/avito-tech/Paparazzo'
  s.license                = 'MIT'
  s.author                 = { 'Andrey Yutkin' => 'ayutkin@avito.ru' }
  s.source                 = { :git => 'https://github.com/avito-tech/Paparazzo.git', :tag => "Paparazzo-#{s.version}" }
  s.platform               = :ios, '8.0'
  s.ios.deployment_target = "8.0"
  s.requires_arc = true

  s.frameworks = 'UIKit', 'Photos', 'ImageIO', 'MobileCoreServices', 'GLKit', 'OpenGLES', 'CoreMedia', 'CoreVideo', 'AVFoundation', 'QuartzCore'
  
  s.dependency 'JNWSpringAnimation'
  
  s.dependency 'ImageSource/Core', '~> 2.0'
  s.dependency 'ImageSource/PHAsset', '~> 2.0'
  s.dependency 'ImageSource/Local', '~> 2.0'
  s.dependency 'ImageSource/Remote', '~> 2.0'

  s.default_subspec = 'Core', 'Marshroute', 'AlamofireImage'

  s.subspec 'AlamofireImage' do |ai|
    ai.dependency 'Paparazzo/Core'
    ai.dependency 'ImageSource/AlamofireImage', '~> 2.0'
  end

  s.subspec 'SDWebImage' do |sd|
    sd.dependency 'Paparazzo/Core'
    sd.dependency 'ImageSource/SDWebImage', '~> 2.0'
  end
  
  s.subspec 'Core' do |cs|
    cs.source_files = 'Paparazzo/Core/**/*'
  
    cs.ios.resource_bundle = {
      'Paparazzo' => [
        'Paparazzo/Shader/CameraShader.metallib',
        'Paparazzo/Localization/*.lproj',
        'Paparazzo/Assets/Assets.xcassets'
      ]
    }
  end
  
  s.subspec 'Marshroute' do |ms|
    ms.dependency 'Paparazzo/Core'
    ms.dependency 'Marshroute'
    ms.source_files = 'Paparazzo/Marshroute/**/*'
  end
end