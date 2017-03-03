Pod::Spec.new do |s|
  s.name                   = 'ImageSource'
  s.module_name            = 'ImageSource'
  s.version                = '1.0.0'
  s.summary                = 'ImageSource by Avito'
  s.homepage               = 'https://github.com/avito-tech/Paparazzo'
  s.license                = 'MIT'
  s.author                 = { 'Andrey Yutkin' => 'ayutkin@avito.ru' }
  s.source                 = { :git => 'https://github.com/avito-tech/Paparazzo.git', :tag => "#{s.version}" }
  s.platform               = :ios, '8.0'
  s.ios.deployment_target = "8.0"
  s.requires_arc = true
  
  s.subspec 'Core' do |cs|
  	cs.frameworks = 'CoreGraphics'
    cs.source_files = 'ImageSource/Core/**/*'
  end
  
  s.subspec 'PHAsset' do |ps|
    ps.frameworks = 'Photos'
  	ps.dependency 'ImageSource/Core'
  	ps.source_files = 'ImageSource/PHAsset/*'
  end
  
  s.subspec 'Local' do |ls|
    ls.frameworks = 'ImageIO', 'MobileCoreServices'
  	ls.dependency 'ImageSource/Core'
  	ls.source_files = 'ImageSource/Local/*'
  end
  
  s.subspec 'Remote' do |rs|
    rs.frameworks = 'ImageIO', 'MobileCoreServices'
  	rs.dependency 'ImageSource/Core'
    rs.dependency 'ImageSource/UIKit'
  	rs.source_files = 'ImageSource/Remote/*'
	
    rs.subspec 'SDWebImage' do |sds|
	    sds.dependency 'SDWebImage', '~> 3.8'
  	  sds.source_files = 'ImageSource/Remote/*', 'ImageSource/Remote/SDWebImage/*'
    end
  end
  
  s.subspec 'UIKit' do |uis|
    uis.frameworks = 'UIKit'
	  uis.dependency 'ImageSource/Core'
	  uis.source_files = 'ImageSource/UIKit/*'
  end
end
