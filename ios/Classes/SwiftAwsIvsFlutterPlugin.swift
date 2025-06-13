import Flutter
import UIKit

public class SwiftAwsIvsFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    AwsIvsFlutterPlugin.register(with: registrar)
  }
}