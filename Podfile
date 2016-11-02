platform :ios, '8.0'
use_frameworks!
inhibit_all_warnings!

def shared_pods
	pod 'Kingfisher', '~> 3.0'
	pod 'ObjectMapper', '~> 2.0'
	pod 'XCGLogger', '~> 4.0.0'
	pod 'BrightFutures'
	pod 'SDVersion'
	pod 'Fabric'
	pod 'Crashlytics'
end

target 'kllect' do
	shared_pods
end

target 'kllectTests' do
	shared_pods
	pod 'OHHTTPStubs'
	pod 'OHHTTPStubs/Swift'
end

target 'kllectUITests' do
	shared_pods
end
