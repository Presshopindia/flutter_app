import UIKit
import Flutter
import GoogleMaps
import flutter_local_notifications
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyAzccAqyrfD-V43gI9eBXqLf0qpqlm0Gu0")
    GeneratedPluginRegistrant.register(with: self)
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
