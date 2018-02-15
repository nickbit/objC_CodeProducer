# Uncomment this line to define a global platform for your project
platform :osx, '10.12'
use_frameworks!
workspace './CodeProducerWorkspace'

def common_pods
	pod 'ObjectiveSugar', :git => 'https://github.com/supermarin/ObjectiveSugar.git'
end

target 'CodeProducer' do

	common_pods

end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.12'
		end
	end
end
