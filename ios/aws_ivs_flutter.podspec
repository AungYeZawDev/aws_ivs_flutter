Pod::Spec.new do |s|
  s.name             = 'aws_ivs_flutter'
  s.version          = '1.0.0'
  s.summary          = 'AWS IVS Player plugin for Flutter'
  s.description      = <<-DESC
A Flutter plugin that provides AWS Interactive Video Service (IVS) player functionality for both Android and iOS platforms. 
Supports live video streaming with comprehensive playback controls.
                       DESC
  s.homepage         = 'https://github.com/AungYeZawDev/aws_ivs_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'AmazonIVSPlayer', '~> 1.41.0'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'SWIFT_VERSION' => '5.0'
  }
  s.swift_version = '5.0'

  # Required frameworks for AWS IVS Player
  s.frameworks = 'UIKit', 'AVFoundation', 'VideoToolbox', 'CoreMedia', 'CoreVideo'
  
  # Link with required libraries
  s.libraries = 'c++', 'z'
end