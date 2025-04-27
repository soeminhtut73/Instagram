  # Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Instagram' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "13.0"
        end
    end
  end

  # Pods for Instagram

  target 'InstagramTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'InstagramUITests' do
    # Pods for testing
  end
  
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  pod 'Firebase/Auth'
  pod 'ActiveLabel'
  pod 'SDWebImage'
  pod 'JGProgressHUD'
  pod 'YPImagePicker'
  pod 'SkeletonView'

end
