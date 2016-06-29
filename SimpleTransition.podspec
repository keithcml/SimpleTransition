#
# Be sure to run `pod lib lint SimpleTransition.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SimpleTransition"
  s.version          = "1.1.2"
  s.summary          = "A simple way to create custom presentation transition."
  s.description      = "iOS Custom Animated Transitioning for view controller presentation"
  s.homepage         = "https://github.com/MingLoan/SimpleTranistion"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Mingloan" => "mingloanchan@gmail.com" }
  s.source           = { :git => "https://github.com/MingLoan/SimpleTranistion.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
#s.resource_bundles = {
#    'SimpleTransition' => ['Pod/Assets/*.png']
#  }

end
