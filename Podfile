source 'ssh://git@stash.msk.avito.ru:7999/ma/avito-pod-specs.git'
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

def default_pods
    pod 'Marshroute', :git => 'https://github.com/avito-tech/Marshroute'
    pod 'AvitoDesignKit', :git => 'ssh://git@stash.msk.avito.ru:7999/ma/avito-ios-design-kit.git', :branch => 'master'
end

target 'AvitoMediaPicker' do
	default_pods
end