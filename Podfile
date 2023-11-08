# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'JioMeetHealthCareTemplateDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

   pod 'JioMeetHealthCareTemplate_iOS', '1.0.0-alpha.1'

  # Pods for JioMeetHealthCareTemplateDemo

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
