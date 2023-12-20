#
# Be sure to run `pod lib lint HuntingZombiesTool.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HuntingZombiesTool'
  s.version          = '0.1.0'
  s.summary          = '野指针探测工具'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
野指针探测工具，方便业务集成
                       DESC

  s.homepage         = 'https://github.com/葛高召/HuntingZombiesTool'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '葛高召' => 'gegaozhao1126@gmail.com' }
  s.source           = { :git => 'git@github.com:GE-GAO-ZHAO/HuntingZombiesTool.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'HuntingZombiesTool/Classes/**/*'
  
  s.subspec 'ZombieObject' do |sp|
    sp.source_files = ['HuntingZombiesTool/Classes/ZombieObject/*.{h,m}']
    sp.requires_arc = false
  end
  
  # s.resource_bundles = {
  #   'HuntingZombiesTool' => ['HuntingZombiesTool/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
