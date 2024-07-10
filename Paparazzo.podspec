Pod::Spec.new do |s|
  s.name                   = 'Paparazzo'
  s.module_name            = 'Paparazzo'
  s.version                = '8.0.0'
  s.summary                = "iOS component for picking and editing photos from camera and user's photo library"
  s.homepage               = 'https://github.com/avito-tech/Paparazzo'
  s.license                = 'MIT'
  s.author                 = { 'Andrey Yutkin' => 'ayutkin@avito.ru' }
  s.source                 = { :git => 'https://github.com/avito-tech/Paparazzo.git', :tag => "#{s.version}" }
  s.platform               = :ios, '13.0'
  s.ios.deployment_target  = '13.0'
  s.swift_version          = '5.0'
  s.requires_arc           = true

  s.frameworks = 'UIKit', 'Photos', 'ImageIO', 'CoreServices', 'GLKit', 'OpenGLES', 'CoreMedia', 'CoreVideo', 'AVFoundation', 'QuartzCore'
  
  s.dependency 'ImageSource/Core', '~> 4.0'
  s.dependency 'ImageSource/PHAsset', '~> 4.0'
  s.dependency 'ImageSource/Local', '~> 4.0'
  s.dependency 'ImageSource/Remote', '~> 4.0'

  s.default_subspec = 'Core', 'AlamofireImage'

  s.subspec 'AlamofireImage' do |ss|
    ss.dependency 'Paparazzo/Core'
    ss.dependency 'ImageSource/AlamofireImage', '~> 4.0'
  end
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/PaparazzoCore/**/*.swift', 'Sources/ObjCExceptionCatcherHelper/**/*', 'Sources/JNWSpringAnimation/**/*'

    ss.ios.resource_bundle = {
      'Paparazzo' => [
        'Sources/PaparazzoCore/Resources/CameraShader.metallib',
        'Sources/PaparazzoCore/Resources/Localization/*.lproj',
        'Sources/PaparazzoCore/Resources/Assets.xcassets'
      ]
    }
  end
  
  s.subspec 'Marshroute' do |ss|
    ss.dependency 'Paparazzo/Core'
    ss.dependency 'Marshroute'
    ss.source_files = 'Sources/PaparazzoMarshroute/**/*.swift', 'Sources/ObjCExceptionCatcherHelper/**/*', 'Sources/JNWSpringAnimation/**/*'

    ss.ios.resource_bundle = {
      'Paparazzo' => [
        'Sources/PaparazzoCore/Resources/CameraShader.metallib',
        'Sources/PaparazzoCore/Resources/Localization/*.lproj',
        'Sources/PaparazzoCore/Resources/Assets.xcassets'
      ]
    }
  end
end
