abstract_target 'MathPix-API' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  swift_version = '5.0'
  platform :ios, '12'
  
  pod 'PureLayout'
  
  target 'MathPix-API-Sample' do
  end
  
end


post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
