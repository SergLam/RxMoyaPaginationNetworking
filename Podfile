source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "9.0"
use_frameworks!

abstract_target 'RxNetworkModelCommon' do

pod 'ObjectMapper', '~> 2.2'
pod 'RxSwift', '~> 3.1'
pod 'Moya/RxSwift'
pod 'Moya-ObjectMapper/RxSwift'
pod 'Moya-ModelMapper/RxSwift'
#pod 'NSObject+Rx'
pod 'RxOptional', '~> 3.1'
#pod 'Result'

target 'RxNetworkModel' do

pod 'RxCocoa', '~> 3.1'
#pod 'RxAlamofire'

  end

end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

