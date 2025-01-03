import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonModel.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/chatScreens/ChatListingScreen.dart';
import 'package:presshop/view/menuScreen/MenuScreen.dart';
import 'package:presshop/view/menuScreen/MyContentScreen.dart';
import 'package:presshop/view/menuScreen/MyTaskScreen.dart';
import 'package:uni_links/uni_links.dart';
import '../../main.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../cameraScreen/CameraScreen.dart';
import 'package:location/location.dart' as lc;
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

bool _initialUriIsHandled = false;

class Dashboard extends StatefulWidget {
  int initialPosition = 2;
  String? broadCastId;
  String? taskStatus = "";

  Dashboard(
      {super.key,
      required this.initialPosition,
      this.broadCastId,
      this.taskStatus});

  @override
  State<StatefulWidget> createState() {
    return DashboardState();
  }
}

class DashboardState extends State<Dashboard> implements NetworkResponse {
  int currentIndex = 2;
  String fcmToken = "";
  String deviceId = "";
  StreamSubscription? _sub;

  String mediaAddress = "", mediaDate = "", country = "", state = "", city = "";
  int totalEntitiesCount = 0;
  double x = 0, y = 0, latitude = 0, longitude = 0;

  final int _sizePerPage = 50;
  int page = 0;
  bool isGetLatLong = false;

  /// Prince
  lc.LocationData? locationData;
  lc.Location location = lc.Location();

  final bottomNavigationScreens = <Widget>[
    MyContentScreen(hideLeading: true),
    MyTaskScreen(hideLeading: true),
    const CameraScreen(picAgain: false),
    ChatListingScreen(hideLeading: true),
    MenuScreen()
  ];

  @override
  void initState() {
    /// Light statusBar mode-->
    debugPrint('taskStatus value=====> ${widget.taskStatus}');
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    currentIndex = widget.initialPosition;
    if (widget.taskStatus == 'rejected') {
    } else {
      if (widget.broadCastId != null) {
        callTaskDetailApi(widget.broadCastId!);
      }
      super.initState();
      getFcmToken();
      fireBaseMessaging();
    }
    isGetLatLong = true;
    requestLocationPermissions();
  }

  /// An implementation using a link Amit
  initPlatformStateForStringUniLinks() async {
    debugPrint("initPlatformStateForStringUniLinks=======>Enter");

    ///Attach a listener to the links stream
    _sub = linkStream.listen((String? link) {
      if (!mounted) return;
      debugPrint('initPlatformStateForStringUniLinks  $link');
    }, onError: (err) {
      if (!mounted) return;
      debugPrint('exception $err');
    });

    /// Attach a second listener to the stream Note:
    /// The jump here should be when the APP is opened and cut to the background process.
    linkStream.listen((String? link) {
      debugPrint('linkStream index got? link: $link');
      jump2Screen(link!);
    }, onError: (err) {
      debugPrint('got err: $err');
    });

    ///Get the latest link
    String? initialLink = "";

    ///Uri? initialUri;
    /// Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialLink = await getInitialLink();
      debugPrint('initial link: $initialLink');
      jump2Screen(initialLink!);

      ///if (initialLink != null) initialUri = Uri.parse(initialLink);
    } catch (e) {
      debugPrint('exception -----> $e');
    }

    if (!mounted) return;
    setState(() {});
  }

  /// Navigate other screen using share link
  void jump2Screen(String link) async {
    debugPrint("dashboardDeepLiking-->$link");
    debugPrint("dashboardDeepLiking-->${link.split("&").last}");

    if (link.isNotEmpty) {
      debugPrint("link Enter::::::::::>");
      if (link.contains("shareLinkforUserid")) {
        String id = link.substring(link.lastIndexOf("?") + 1, link.length);
        String type = link.substring(link.lastIndexOf("&") + 1, link.length);
        debugPrint("type:::::$type");
        debugPrint("commonID-->$id");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyContentScreen(hideLeading: false)),
        );
      } else if (link.split("&").last == "type=Group") {
        String groupId = link.substring(link.lastIndexOf("?") + 1, link.length);
        String id =
            groupId.replaceAll("group_id=", "").replaceAll("&type=Group", "");
        debugPrint(
            "groupId : ${groupId.replaceAll("group_id=", "").replaceAll("&type=Group", "")}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        unselectedItemColor: Colors.black,
        selectedItemColor: colorThemePink,
        elevation: 0,
        iconSize:size.width * numD05,
        selectedFontSize: size.width * numD03,
        unselectedFontSize: size.width * numD03,
        type: BottomNavigationBarType.fixed,
        onTap: _onBottomBarItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("${iconsPath}ic_content.png"),
              ),
              label: contentText),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("${iconsPath}ic_task.png"),
              ),
              label: taskText),
          BottomNavigationBarItem(

              icon: ImageIcon(
                AssetImage("${iconsPath}ic_camera.png",
                ),
              ),
              label: cameraText),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("${iconsPath}ic_chat.png"),
              ),
              label: chatText),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("${iconsPath}ic_menu.png"),
              ),
              label: menuText),
        ],
      ),
      body: isGetLatLong
          ? const Center(
              child: CircularProgressIndicator(
                color: colorThemePink,
              ),
            )
          : bottomNavigationScreens[currentIndex],
    );
  }

  /// FireBase Notification Initialize
  void fireBaseMessaging() async {
    debugPrint("InsideFirebase");
    FirebaseMessaging.instance.requestPermission(
      badge: true,
      alert: true,
    );
    /*await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );*/
    localNotificationService.flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((notificationDetail) async {
      await Future.delayed(const Duration(seconds: 1));
      if (notificationDetail != null &&
          notificationDetail.didNotificationLaunchApp &&
          context.mounted) {
        if (notificationDetail.notificationResponse != null &&
            notificationDetail.notificationResponse!.payload != null) {
          var taskDetail =
              jsonDecode(notificationDetail.notificationResponse!.payload!);
          if (taskDetail["notification_type"].toString() ==
              "media_house_tasks") {
            callTaskDetailApi(taskDetail["broadCast_id"]);
          }
        }
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        debugPrint("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          debugPrint("New Notification");
        }
      },
    );

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("Fi1rebaseMessage: ${message.data}");

      if (message.data.isNotEmpty &&
          message.data["notification_type"].toString() == "media_house_tasks") {
        debugPrint("Inside Task Assigned notification");
        localNotificationService.showFlutterNotificationWithSound(message);
        if (mounted) {
          callTaskDetailApi(message.data["broadCast_id"]);
        }
      } else {
        debugPrint("inside else------>");
        debugPrint(
            "desensitising------>${message.notification!.android}");
        localNotificationService.showFlutterNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        if (mounted) {
          setState(() {});
        }
        debugPrint("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.data.isNotEmpty &&
            message.data["notification_type"].toString() ==
                "media_house_tasks") {
          debugPrint("Inside Task Assigned notification");
          if (mounted) {
            callTaskDetailApi(message.data["broadCast_id"]);
          }
        } else {
          localNotificationService.showFlutterNotification(message);
        }
        if (message.notification != null) {
          debugPrint(message.notification!.title);
          debugPrint(message.notification!.body);
          debugPrint("message.data22:::: ${message.data.toString()}");
        }
      },
    );
  }

  /// Not Use
  void showMediaTaskDialog(Map<String, dynamic> taskDetail) {
    var dis = calculateDistance(
            double.parse(taskDetail["lat"].toString()),
            double.parse(taskDetail["long"]),
            double.parse(sharedPreferences!.getString(latitudeKey)!),
            double.parse(sharedPreferences!.getString(longitudeKey)!)) * 0.621371;
    debugPrint("DistanceNew: $dis");
  }

  Future<void> getFcmToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken() ?? "";

    debugPrint("FCM Token:::: $fcmToken");

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      debugPrint('Running on ${androidInfo.model}');
      deviceId = androidInfo.id;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      debugPrint('Running on ${iosInfo.utsname.machine}');
      deviceId = iosInfo.identifierForVendor!;
    }
    callAddDeviceApi(
        deviceId, Platform.isAndroid ? "android" : "ios", fcmToken);
  }

  /// Current Location
  /// Location permission request
  requestLocationPermissions() async {
    lc.PermissionStatus permissionGranted;
    bool serviceEnabled;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    if (serviceEnabled) {
      permissionGranted = await location.hasPermission();

      debugPrint("PG: $permissionGranted");

      switch (permissionGranted) {
        case lc.PermissionStatus.granted:
          getCurrentLocationFxn();
          break;
        case lc.PermissionStatus.grantedLimited:
          showSnackBar("Error", "Permission is limited", Colors.red);

          break;
        case lc.PermissionStatus.denied:
          serviceEnabled = await location.requestService().then((value) {
            getCurrentLocationFxn();
            return true;
          });
          break;
        case lc.PermissionStatus.deniedForever:
          openAppSettings().then((value) {
            if (value) {
              getCurrentLocationFxn();
            }
          });
          break;
      }
    }
  }

  getCurrentLocationFxn() async {
    try {
      locationData = await location.getLocation();
      debugPrint("GettingLocation ==> $locationData");
      if (locationData != null) {
        debugPrint("NotNull");
        if (locationData!.latitude != null) {
          latitude = locationData!.latitude!;
          longitude = locationData!.longitude!;

          List<Placemark> placeMarkList =
              await placemarkFromCoordinates(latitude, longitude);

          debugPrint("PlaceHolder: ${placeMarkList.first}");

          String street = placeMarkList.first.name!;
          String nagar = placeMarkList.first.subLocality!;
          String cityValue = placeMarkList.first.locality!;
          String stateValue = placeMarkList.first.administrativeArea!;
          String countryValue = placeMarkList.first.country!;
          String pinCode = placeMarkList.first.postalCode!;

          /*mediaAddress = "$nagar, $street, $pinCode";
          country = countryValue;
          state = stateValue;
          city = cityValue;*/
          sharedPreferences!.setDouble(currentLat, latitude);
          sharedPreferences!.setDouble(currentLon, latitude);
          sharedPreferences!
              .setString(currentAddress, "$nagar, $street, $pinCode");
          sharedPreferences!.setString(currentCountry, countryValue);
          sharedPreferences!.setString(currentState, stateValue);
          sharedPreferences!.setString(currentCity, cityValue);

          debugPrint("MyLatttt: ${locationData!.latitude}");
          debugPrint("MyLonggggg: ${locationData!.longitude}");
          debugPrint("mediaAddress: $nagar, $street, $pinCode");
          debugPrint("country==>:  $countryValue");
          debugPrint("state: $stateValue");
          debugPrint("city: $cityValue");
          isGetLatLong = false;
          setState(() {});
          if (alertDialog != null) {
            alertDialog = null;
            Navigator.of(navigatorKey.currentContext!).pop();
          }
        }
      } else {
        debugPrint("Null-ll");

        showSnackBar("Location Error", "nullLocationText", Colors.black);
      }
    } on Exception catch (e) {
      debugPrint("PEx: $e");

      showSnackBar("Exception", e.toString(), Colors.black);
    }
  }

  void _onBottomBarItemTapped(int index) {
    currentIndex = index;

    setState(() {});
  }

  void callAddDeviceApi(String deviceId, String deviceType, String fcmToken) {
    Map<String, String> params = {
      "device_id": deviceId,
      "type": deviceType,
      "device_token": fcmToken,
    };
    debugPrint('map: $params');

    NetworkClass.fromNetworkClass(
            addDeviceUrl, this, addDeviceUrlRequest, params)
        .callRequestServiceHeader(false, "post", null);
  }

  /// Get BroadCast task Detail
  void callTaskDetailApi(String id) {
    NetworkClass("$taskDetailUrl$id", this, taskDetailUrlRequest)
        .callRequestServiceHeader(false, "get", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        /// Get BroadCast task Detail
        case taskDetailUrlRequest:
          debugPrint("BroadcastData::::Error");
          break;

        case addDeviceUrlRequest:
          debugPrint("AddDeviceError: $response");
          break;
      }
    } on Exception catch (e) {
      debugPrint("Exception: $e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case addDeviceUrlRequest:
          debugPrint("AddDeviceSuccess: $response");
          break;

        /// Get BroadCast task Detail
        case taskDetailUrlRequest:
          debugPrint("BroadcastData::::Success:  $response");
          var map = jsonDecode(response);
          if (map["code"] == 200 && map["task"] != null) {
            var broadCastedData = TaskDetailModel.fromJson(map["task"]);
            broadcastDialog(
                size: MediaQuery.of(context).size, taskDetail: broadCastedData);
          }
          setState(() {});
          break;
      }
    } on Exception catch (e) {
      debugPrint("Exception: $e");
    }
  }
}