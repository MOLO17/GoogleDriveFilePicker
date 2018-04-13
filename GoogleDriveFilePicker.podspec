#
# Be sure to run `pod lib lint GoogleDriveFilePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GoogleDriveFilePicker'
  s.version          = '0.1.0'
  s.summary          = 'A short description of GoogleDriveFilePicker.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/fed933/GoogleDriveFilePicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fed933' => 'federico.monti@molo17.com' }
  s.source           = { :git => 'https://github.com/fed933/GoogleDriveFilePicker.git', :branch => "master", :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'GoogleDriveFilePicker/Classes/**/*'
  
  # s.resource_bundles = {
  #   'GoogleDriveFilePicker' => ['GoogleDriveFilePicker/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'GoogleAPIClientForREST/Drive', '~> 1.2.1'
  s.dependency 'GoogleSignIn'
  s.dependency 'SDWebImage', '~> 4.0'
  s.dependency 'PureLayout'
  
  s.static_framework = true

  s.swift_version = '4.0'
end
