platform :ios, "10.0"
use_frameworks!

target 'Application' do
    
    pod 'MagicalRecord'
    pod 'AFNetworking'
    pod 'ActionSheetPicker-3.0'
    pod 'JFMinimalNotifications'
    pod 'IQKeyboardManagerSwift'
    pod 'DZNEmptyDataSet'
    pod 'M13ProgressSuite'
    pod 'GBDeviceInfo'
    pod 'ZCAnimatedLabel'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'iVersion'
    pod 'CTFeedback'
    pod 'UIView+AnimationExtensions'
    pod 'RESideMenu'
    pod 'REMenu'
    pod 'XCDYouTubeKit'
    pod 'UIView+draggable'
    pod 'SwiftMessages'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
