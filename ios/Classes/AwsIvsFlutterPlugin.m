#import "AwsIvsFlutterPlugin.h"
#if __has_include(<aws_ivs_flutter/aws_ivs_flutter-Swift.h>)
#import <aws_ivs_flutter/aws_ivs_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "aws_ivs_flutter-Swift.h"
#endif

@implementation AwsIvsFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwsIvsFlutterPlugin registerWithRegistrar:registrar];
}
@end