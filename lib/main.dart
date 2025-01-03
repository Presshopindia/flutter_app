import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/LocalNotificationService.dart';
import 'package:presshop/view/menuScreen/MyProfile.dart';
import 'package:presshop/view/splash/SplashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();
GoogleSignIn googleSignIn = GoogleSignIn();
bool rememberMe = false;
SharedPreferences? sharedPreferences;

const iOSLocalizedLabels = false;

//late List<CameraDescription> cameras;
List<CameraDescription> cameras = <CameraDescription>[];
LocalNotificationService localNotificationService = LocalNotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await localNotificationService.setup();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // cameras = await availableCameras();

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint("CameraException: $e");
  }

  getSharedPreferences().then((value) {
    sharedPreferences = value;
    if (sharedPreferences!.getBool(rememberKey) != null) {
      rememberMe = sharedPreferences!.getBool(rememberKey)!;
    }
    debugPrint("IsItRemember:::: $rememberMe");
    runApp(MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(fontFamily: "AirbnbCereal", scaffoldBackgroundColor: Colors.white),
      home: const SplashScreen(),
    ));
  });
}
