platform :ios, '10.0'

target 'PinterestLibrary' do
use_frameworks!

pod 'MVImageDownloader', :git => 'https://github.com/leeweisern/MVImageDownloader.git', :tag => '1.0.0'

end

# Workaround for Cocoapods issue #7606
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
