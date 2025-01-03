import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as PH;
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../utils/CommonModel.dart';
import '../../utils/PermissionHandler.dart';
import '../../utils/countdownTimerScreen.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../dashboard/Dashboard.dart';
import 'package:http/http.dart' as http;

class BroadCastScreen extends StatefulWidget {
  String taskId = "";
  String mediaHouseId = "";

  BroadCastScreen(
      {super.key, required this.taskId, required this.mediaHouseId});

  @override
  State<BroadCastScreen> createState() => _BroadCastScreenState();
}

class _BroadCastScreenState extends State<BroadCastScreen>
    implements NetworkResponse {
  late Size size;

  LatLng? _latLng;

  String _hopperAcceptedCount = "";
  String _distance = "";
  String _drivingEstTime = "";
  String _walkingEstTime = "";
  String googleUrl =
      'https://www.google.com/maps/dir/?api=1&origin=30.9010,75.8573&destination=31.3260,75.5762&travelmode=driving&dir_action=navigate';
  String appleUrl =
      'http://maps.apple.com/maps?saddr=30.9010,75.8573&daddr=31.3260,75.5762';

  bool _showMap = false;
  bool _isAccepted = false;
  bool isDirection = false;
  bool isMultipleContact = false;

  BitmapDescriptor? mapIcon;
  BroadcastedData? broadCastedData;

  List<Marker> marker = [];
  Timer? _hopperCountTimer;
  TaskDetailModel? taskDetail;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  TextEditingController contactSearchController = TextEditingController();
  List<ContactListModel> contactsDataList = [];
  List<ContactListModel> contactSearch = [];

  @override
  void initState() {
    getAllIcons();
    debugPrint("Class Name : $runtimeType");
    getCurrentLocation();
    requestContactsPermission();

    super.initState();
  }

  @override
  void dispose() {
    _hopperCountTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: null,
      body: broadCastedData != null && _showMap
          ? Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: size.height / 2,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                    bottomLeft:
                                        Radius.circular(size.width * numD06),
                                    bottomRight:
                                        Radius.circular(size.width * numD06)),
                                child: Stack(
                                  children: [
                                    GoogleMap(
                                      mapType: MapType.normal,
                                      initialCameraPosition: _kGooglePlex,
                                      markers: marker.map((e) => e).toSet(),
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        _controller.complete(controller);
                                      },
                                      zoomControlsEnabled: false,
                                      /*
                                      zoomGesturesEnabled: true,
                                      rotateGesturesEnabled: true,
                                      scrollGesturesEnabled: true,*/
                                    ),
                                    Positioned.fill(child: InkWell(
                                      onTap: () {
                                        isDirection = false;
                                        setState(() {});
                                        openUrl();
                                      },
                                    ))
                                  ],
                                ),
                              ),

                              /// Estimate Time or Hopper Count
                              Positioned(
                                bottom: size.width * numD02,
                                left: size.width * numD04,
                                right: size.width * numD04,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * numD02,
                                          vertical: size.width * numD02),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD04),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.my_location,
                                            size: size.width * numD05,
                                          ),
                                          SizedBox(
                                            width: size.width * numD01,
                                          ),
                                          Text(
                                            "$_hopperAcceptedCount Hoppers",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD035,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * numD02,
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * numD05,
                                            vertical: size.width * numD02),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD04),
                                        ),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              "${iconsPath}ic_marker.png",
                                              width: size.width * numD04,
                                            ),
                                            SizedBox(
                                              width: size.width * numD01,
                                            ),
                                            Text(
                                              _distance,
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize:
                                                      size.width * numD035,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                            const Spacer(),
                                            Container(
                                              width: 1,
                                              height: size.width * numD04,
                                              color: Colors.grey,
                                            ),
                                            const Spacer(),
                                            Image.asset(
                                              "${iconsPath}ic_man_walking.png",
                                              height: size.width * numD05,
                                            ),
                                            SizedBox(
                                              width: size.width * numD01,
                                            ),
                                            Text(
                                              _walkingEstTime,
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize:
                                                      size.width * numD035,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                            const Spacer(),
                                            Container(
                                              width: 1,
                                              height: size.width * numD04,
                                              color: Colors.grey,
                                            ),
                                            const Spacer(),
                                            Image.asset(
                                              "${iconsPath}ic_car.png",
                                              width: size.width * numD05,
                                            ),
                                            SizedBox(
                                              width: size.width * numD01,
                                            ),
                                            Text(
                                              _drivingEstTime,
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize:
                                                      size.width * numD035,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: EdgeInsets.only(
                                top: size.width * numD08,
                                right: size.width * numD04),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.shade300,
                                      spreadRadius: 2,
                                      blurRadius: 2)
                                ]),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                child: Image.network(
                                  taskDetail!.mediaHouseImage,
                                  height: size.width * numD14,
                                  width: size.width * numD14,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, object, stacktrace) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.all(size.width * numD02),
                                      child: Image.asset(
                                        "${commonImagePath}rabbitLogo.png",
                                        height: size.width * numD14,
                                        width: size.width * numD14,
                                      ),
                                    );
                                  },
                                )),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: size.width * numD07,
                        vertical: size.width * numD01,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * numD03,
                          ),

                          /// News Company Name
                          Text(
                            broadCastedData!.mediaHouseName,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.black,
                                fontWeight: FontWeight.w300),
                          ),

                          SizedBox(
                            height: size.width * numD05,
                          ),

                          /// News Headline
                          Text(
                            broadCastedData!.headline,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.black,
                                lineHeight: 1.5,
                                fontWeight: FontWeight.w600),
                          ),

                          SizedBox(
                            height: size.width * numD02,
                          ),

                          /// News Description
                          Text(
                            "${broadCastedData!.taskDescription}\n\n${broadCastedData!.specialRequirements}",
                            style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD03,
                              color: Colors.black,
                              lineHeight: 1.8,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.justify,
                          ),

                          /// Divider
                          const Divider(
                            thickness: 1,
                            color: colorLightGrey,
                          ),

                          Container(
                            margin: EdgeInsets.only(
                              top: size.width * numD04,
                              bottom: size.width * numD05,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: size.width * numD20,
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.width * numD03,
                                        horizontal: size.width * numD02),
                                    decoration: BoxDecoration(
                                        color: colorLightGrey,
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD03)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color: Colors.black,
                                              size: size.width * numD04,
                                            ),
                                            SizedBox(
                                              width: size.width * numD01,
                                            ),
                                            Text(
                                              deadlineText,
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize: size.width * numD03,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: size.width * numD01,
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: size.width * numD01,
                                                top: size.width * numD01),
                                            child: TimerCountdown(
                                              endTime:
                                                  broadCastedData!.deadLine,
                                              spacerWidth: 3,
                                              enableDescriptions: false,
                                              countDownFormatter:
                                                  (day, hour, min, sec) {
                                                if (broadCastedData!.deadLine
                                                        .difference(
                                                            DateTime.now())
                                                        .inDays >
                                                    0) {
                                                  return "${day}d:${hour}h:${min}m:${sec}s";
                                                } else {
                                                  return "${hour}h:${min}m:${sec}s";
                                                }
                                              },
                                              format: CountDownTimerFormat
                                                  .customFormats,
                                              timeTextStyle: commonTextStyle(
                                                  size: size,
                                                  fontSize: size.width * numD03,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ) /*Text(
                                            "1h: 21m: 11s",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          ),*/
                                            ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * numD05,
                                ),
                                Expanded(
                                  child: Container(
                                    height: size.width * numD20,
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.width * numD03,
                                        horizontal: size.width * numD02),
                                    decoration: BoxDecoration(
                                        color: colorLightGrey,
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD03)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              "${iconsPath}ic_location.png",
                                              width: size.width * numD03,
                                            ),
                                            SizedBox(
                                              width: size.width * numD01,
                                            ),
                                            Text(
                                              locationText.toUpperCase(),
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize: size.width * numD03,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: size.width * numD01,
                                            top: size.width * numD01,
                                          ),
                                          child: Text(
                                            broadCastedData!.location,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          priceOfferWidget(),

                          SizedBox(
                            height: size.width * numD1,
                          ),

                          /// Button
                          Row(
                            children: [
                              Expanded(
                                  child: SizedBox(
                                height: size.width * numD15,
                                child: commonElevatedButton(
                                    declineText.toTitleCase(),
                                    size,
                                    commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD04,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                    commonButtonStyle(size, Colors.black), () {
                                  _isAccepted = false;
                                  callAcceptRejectApi();
                                  debugPrint("rejected====>");
                                  setState(() {});
                                }),
                              )),
                              SizedBox(
                                width: size.width * numD03,
                              ),
                              Expanded(
                                  child: SizedBox(
                                height: size.width * numD15,
                                child: commonElevatedButton(
                                    acceptAndGoText,
                                    size,
                                    commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD04,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                    commonButtonStyle(size, colorThemePink),
                                    () {
                                  _isAccepted = true;
                                  //isDirection = true;
                                  callAcceptRejectApi();

                                  debugPrint("accepted====>");
                                  setState(() {});
                                }),
                              ))
                            ],
                          ),

                          SizedBox(
                            height: size.width * numD05,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            top: size.width * numD08,
                            left: size.width * numD04),
                        padding: EdgeInsets.all(size.width * numD02),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Image.asset(
                          "${iconsPath}ic_arrow_left.png",
                          height: size.width * numD06,
                          width: size.width * numD06,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showShareBottomSheet();
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            top: size.width * numD08,
                            left: size.width * numD04),
                        padding: EdgeInsets.all(size.width * numD02),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Image.asset(
                          "${iconsPath}ic_share_now.png",
                          height: size.width * numD06,
                          width: size.width * numD06,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          : showLoader(),
    );
  }

  /// Price Offer widget
  Widget priceOfferWidget() {
    return Column(
      children: [
        const Divider(),

        SizedBox(
          height: size.width * numD05,
        ),

        /*/// Price Offer
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    taskDetail!.isNeedPhoto
                        ? "$euroUniqueCode${taskDetail!.photoPrice}"
                        : "- -",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD065,
                        color: colorThemePink,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    offeredText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD04,
                        color: colorHint,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                        vertical: size.width * numD02),
                    decoration: BoxDecoration(
                        color: colorLightGrey,
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                    child: Text(
                      pictureText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD04,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    taskDetail!.isNeedInterview
                        ? "$euroUniqueCode${taskDetail!.interviewPrice}"
                        : "- -",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD065,
                        color: colorThemePink,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    offeredText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD04,
                        color: colorHint,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                        vertical: size.width * numD02),
                    decoration: BoxDecoration(
                        color: colorLightGrey,
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                    child: Text(
                      interviewText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD04,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    taskDetail!.isNeedVideo
                        ? "$euroUniqueCode${taskDetail!.videoPrice}"
                        : "- -",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD065,
                        color: colorThemePink,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    offeredText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD04,
                        color: colorHint,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                        vertical: size.width * numD02),
                    decoration: BoxDecoration(
                        color: colorLightGrey,
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                    child: Text(
                      videoText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD04,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),*/

        /// Price Offer
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    taskDetail!.isNeedPhoto
                        ? "$euroUniqueCode${taskDetail!.photoPrice}"
                        : "-",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD06,
                        color: colorThemePink,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    offeredText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: colorHint,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                        vertical: size.width * numD02),
                    decoration: BoxDecoration(
                        color: colorLightGrey,
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                    child: Text(
                      pictureText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    taskDetail!.isNeedInterview
                        ? "$euroUniqueCode${taskDetail!.interviewPrice}"
                        : "-",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD06,
                        color: colorThemePink,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    offeredText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: colorHint,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                        vertical: size.width * numD02),
                    decoration: BoxDecoration(
                        color: colorLightGrey,
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                    child: Text(
                      interviewText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    taskDetail!.isNeedVideo
                        ? "$euroUniqueCode${taskDetail!.videoPrice}"
                        : "-",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD06,
                        color: colorThemePink,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    offeredText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: colorHint,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                        vertical: size.width * numD02),
                    decoration: BoxDecoration(
                        color: colorLightGrey,
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                    child: Text(
                      videoText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(
          height: size.width * numD05,
        ),

        const Divider(),
      ],
    );
  }

  Future<void> showShareBottomSheet() async {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * numD085),
          topRight: Radius.circular(size.width * numD085),
        )),
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter stateSetter) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Heading
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * numD05,
                  ).copyWith(
                    top: size.width * numD05,
                    bottom: size.width * numD02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        splashRadius: size.width * numD05,
                        icon: Icon(
                          Icons.close,
                          color: Colors.black,
                          size: size.width * numD06,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Share the task",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD045,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),

                      /*    /// Share Button
                      isMultipleContact
                          ? commonElevatedButton(
                              shareText,
                              size,
                              commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                              commonButtonStyle(size, colorThemePink),
                              () {})
                          : Container(),*/
                    ],
                  ),
                ),

                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * numD04,
                      vertical: size.width * numD04,
                    ),
                    children: [
                      /// Share Sub Text
                      Text(
                        boardCastShareSubText,
                        textAlign: TextAlign.center,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: size.width * numD03,
                      ),

                      /// Search
                      TextFormField(
                        controller: contactSearchController,
                        cursorColor: colorTextFieldIcon,
                        onChanged: (value) {
                          contactSearch = contactsDataList
                              .where((element) => element.displayName!
                                  .trim()
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();

                          debugPrint("searchResult :: ${contactSearch.length}");
                          setState(() {});
                          stateSetter(() {});
                        },
                        decoration: InputDecoration(
                          fillColor: colorLightGrey,
                          isDense: true,
                          filled: true,
                          hintText: searchHintText,
                          hintStyle: TextStyle(
                              color: colorHint, fontSize: size.width * numD04),
                          disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0, color: colorLightGrey)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0, color: colorLightGrey)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0, color: colorLightGrey)),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0, color: colorLightGrey)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0, color: colorLightGrey)),
                          suffixIcon: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * numD02),
                            child: Image.asset(
                              "${iconsPath}ic_search.png",
                              color: Colors.black,
                            ),
                          ),
                          suffixIconConstraints:
                              BoxConstraints(maxHeight: size.width * numD06),
                        ),
                        textAlignVertical: TextAlignVertical.center,
                      ),

                      /// User List
                      contactsDataList.isNotEmpty
                          ? ListView.separated(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.width * numD06),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                var item =
                                    contactSearchController.text.isNotEmpty
                                        ? contactSearch[index]
                                        : contactsDataList[index];
                                return InkWell(
                                  onTap: () {
                                    /* contactsDataList[index].isContactSelected = !contactsDataList[index].isContactSelected;
                                if( contactsDataList[index].isContactSelected){
                                  isMultipleContact = true;
                                }*/
                                    stateSetter(() {});
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.all(size.width * numD02),
                                    color: item.isContactSelected
                                        ? colorLightGrey
                                        : Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: size.width * numD15,
                                              width: size.width * numD15,
                                              padding: EdgeInsets.all(
                                                  size.width * numD01),
                                              decoration: const BoxDecoration(
                                                  color: colorThemePink,
                                                  shape: BoxShape.circle),
                                              child: ClipOval(
                                                child: item.avatar != null
                                                    ? Image.memory(
                                                        item.avatar!,
                                                        height:
                                                            size.width * numD09,
                                                        width:
                                                            size.width * numD09,
                                                        fit: BoxFit.contain,
                                                      )
                                                    : Center(
                                                        child: Text(
                                                        item.displayName![0]
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize:
                                                                size.width *
                                                                    numD05,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      )),
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width * numD025,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: size.width * numD30,
                                                  child: Text(
                                                    item.displayName.toString(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: commonTextStyle(
                                                        size: size,
                                                        fontSize: size.width *
                                                            numD037,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                Text(
                                                  item.phones!.isNotEmpty
                                                      ? item.phones!.first.value
                                                          .toString()
                                                      : '',
                                                  style: commonTextStyle(
                                                      size: size,
                                                      fontSize:
                                                          size.width * numD035,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                                onPressed: () async {
                                                  String phoneNumber = item
                                                      .phones!.first.value
                                                      .toString()
                                                      .trim();
                                                   final url = 'sms:$phoneNumber&body=${broadCastedData!.headline}\n${broadCastedData!.taskDescription}\n${Uri.parse(baseShareUrl)}';
                                                    if (!await launchUrl(Uri.parse(url),mode: LaunchMode.externalApplication)) {
                                                      showSnackBar(
                                                          'PRESSHOP',
                                                          errorOpenSMS,
                                                          Colors.black);
                                                      throw ('Error launching SMS');
                                                    }


                                               /*   Uri sms = Uri.parse(
                                                      'sms:$phoneNumber?body=${broadCastedData!.headline}\n${broadCastedData!.taskDescription}'
                                                      '\n ${Uri.parse(baseShareUrl)}');
                                                  if (await canLaunchUrl(sms)) {
                                                    debugPrint("====> $sms");
                                                    await launchUrl(sms);
                                                  } else {
                                                    showSnackBar(
                                                        'PRESSHOP',
                                                        errorOpenSMS,
                                                        Colors.black);
                                                    throw ('Error launching SMS');
                                                  }*/
                                                },
                                                splashRadius:
                                                    size.width * numD05,
                                                icon: Image.asset(
                                                  "${iconsPath}message_icon.png",
                                                  height: size.width * numD06,
                                                )),
                                            IconButton(
                                                splashRadius:
                                                    size.width * numD05,
                                                onPressed: () async {
                                                  String phoneNumber = item
                                                      .phones!.first.value
                                                      .toString()
                                                      .trim();

                                                  Uri whatsappUrl = Uri.parse(
                                                      "whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent("${broadCastedData!.headline}\n\n ${broadCastedData!.taskDescription}"
                                                          "\n\n ${Uri.parse(baseShareUrl)}")}");
                                                  if (await canLaunchUrl(
                                                      whatsappUrl)) {
                                                    await launchUrl(
                                                        whatsappUrl);
                                                  } else {
                                                    showSnackBar(
                                                        'PRESSHOP',
                                                        errorOpenWhatsapp,
                                                        Colors.black);
                                                    // Handle the case when the URL can't be launched.
                                                    throw ('Error launching Whatsapp');
                                                  }
                                                },
                                                icon: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          size.width * numD006),
                                                  child: Image.asset(
                                                    "${iconsPath}whatsapp_icon.png",
                                                    height:
                                                        size.width * numD058,
                                                  ),
                                                ))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  height: size.width * numD04,
                                );
                              },
                              itemCount: contactSearchController.text.isNotEmpty
                                  ? contactSearch.length
                                  : contactsDataList.length)
                          : Center(
                              child: Padding(
                                padding: EdgeInsets.all(size.width * numD05),
                                child: const Text("Not Contact Available"),
                              ),
                            ),

                      /* /// Share Button
                      contactsDataList != null
                          ? Container(
                        width: size.width,
                        height: size.width * numD14,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD08,
                        ),
                        margin: EdgeInsets.only(
                          top: size.width * numD06,
                          bottom: size.width * numD08,
                        ),
                        child: commonElevatedButton(
                            shareText,
                            size,
                            commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                            commonButtonStyle(size, colorThemePink),
                                () {}),
                      )
                          : Container(),*/
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }

  /// Update Map Location
  Future<void> _updateGoogleMap(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    marker.add(Marker(
      markerId: const MarkerId("1"),
      position: latLng,
      icon: mapIcon!,
    ));
    controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(latLng.latitude, latLng.longitude), 14));
    setState(() {});

/*
    setState(() {
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: latLng,
        zoom: 14.4746,
      )));
    });*/
  }

  /// Current Lat Lng
  void getCurrentLocation() async {
    bool serviceEnable = await checkGps();
    bool locationEnable = await locationPermission();
    if (serviceEnable && locationEnable) {
      LocationData loc = await Location.instance.getLocation();
      setState(() {
        _latLng = LatLng(loc.latitude!, loc.longitude!);
        _showMap = true;
        debugPrint("_longitude: $_latLng");
      });
      taskDetailApi();
    } else {
      showSnackBar(
          "Permission Denied", "Please Allow Loction permission", Colors.red);
    }
  }

  /// Initialize Map icon
  void getAllIcons() async {
    mapIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(5, 5)),
        "${commonImagePath}ic_cover_radius.png");
  }

  openUrl() async {
    String googleUrl = isDirection
        ? 'https://www.google.com/maps/dir/?api=1&origin=${_latLng!.latitude},'
            '${_latLng!.longitude}&destination=${broadCastedData!.latitude},'
            '${broadCastedData!.longitude}&travelmode=driving&dir_action=navigate'
        : 'https://www.google.com/maps/search/?api=1&query=${broadCastedData!.latitude},${broadCastedData!.longitude}';

    String appleUrl = isDirection
        ? 'http://maps.apple.com/maps?saddr=${_latLng!.latitude},'
            '${_latLng!.longitude}&daddr=${broadCastedData!.latitude},'
            '${broadCastedData!.longitude}'
        : 'http://maps.apple.com/?q=${broadCastedData!.latitude},'
            '${broadCastedData!.longitude}';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(googleUrl),
          mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(Uri.parse(appleUrl))) {
      debugPrint('launching apple url');
      await launchUrl(Uri.parse(appleUrl),
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }
  }

  /// Contact Permission
  Future<void> requestContactsPermission() async {
    PH.PermissionStatus permissionStatus = await Permission.contacts.request();
    if (permissionStatus.isGranted) {
      // Permission granted, proceed with retrieving contacts
      getContacts();
    } else {
      // Permission denied, handle accordingly (e.g., show error message)
    }
  }

  /// Contact List
  Future<void> getContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    for (var contact in contacts) {
      contactsDataList.add(ContactListModel(
        displayName: contact.displayName,
        givenName: contact.givenName,
        middleName: contact.middleName,
        phones: contact.phones,
        avatar: contact.avatar,
        isContactSelected: false,
      ));
    }
  }

  ///--------Apis Section------------

  void taskDetailApi() {
    NetworkClass("$taskDetailUrl${widget.taskId}", this, taskDetailUrlRequest)
        .callRequestServiceHeader(false, "get", null);
  }

  void getEstimateTime() {
    debugPrint("::: Inside estimate Time Fuc ::::");

    String drivingMode =
        "https://maps.googleapis.com/maps/api/distancematrix/json?origins="
        "${_latLng!.latitude},${broadCastedData!.longitude}&&destinations="
        "${_latLng!.latitude},${broadCastedData!.longitude}"
        "&mode=driving&key=$googleMapAPiKey";

    String walkingMode =
        "https://maps.googleapis.com/maps/api/distancematrix/json?origins="
        "${_latLng!.latitude},${broadCastedData!.longitude}&destinations="
        "${_latLng!.latitude},${broadCastedData!.longitude}&mode=walking&key=$googleMapAPiKey";

    debugPrint("drivingMode : $drivingMode");
    debugPrint("walkingMode : $walkingMode");

    var res = http.get(Uri.parse(drivingMode)).then((value) {
      debugPrint("Status Code : ${value.statusCode}");
      debugPrint("Body : ${value.body}");
      if (value.statusCode <= 201) {
        var data = jsonDecode(value.body);
        var dataModel = data["rows"] as List;
        if (dataModel.isNotEmpty) {
          var dataModel2 = dataModel.first["elements"] as List;
          if (dataModel2.isNotEmpty) {
            _drivingEstTime = dataModel2.first["duration"]["text"] ?? "";
            _distance = dataModel2.first["distance"]["text"] ?? "";
          }
        }
      }
      setState(() {});
    });

    var res1 = http.get(Uri.parse(walkingMode)).then((value) {
      debugPrint("Status Code : ${value.statusCode}");
      debugPrint("Body : ${value.body}");
      debugPrint("");
      if (value.statusCode <= 201) {
        var data = jsonDecode(value.body);
        var dataModel = data["rows"] as List;
        if (dataModel.isNotEmpty) {
          var dataModel2 = dataModel.first["elements"] as List;
          if (dataModel2.isNotEmpty) {
            _walkingEstTime = dataModel2.first["duration"]["text"] ?? "";
            _distance = dataModel2.first["distance"]["text"] ?? "";
          }
          setState(() {});
        }
      }
    });
  }

  /// Accept Reject Api
  void callAcceptRejectApi() {
    Map<String, String> map = {
      "task_id": widget.taskId,
      "mediahouse_id": widget.mediaHouseId,
      "task_status": _isAccepted ? "accepted" : "rejected"
    };

    debugPrint("map accepted value===>: $map");
    NetworkClass.fromNetworkClass(
            taskAcceptRejectRequestUrl, this, taskAcceptRejectRequestReq, map)
        .callRequestServiceHeader(true, "post", null);
  }

  /// Get Room Id
  void callGetRoomIdApi() {
    Map<String, String> map = {
      "receiver_id": broadCastedData!.mediaHouseId,
      "room_type": "HoppertoAdmin",
      "type": "external_task",
      "task_id": widget.taskId,
    };

    debugPrint("Map : $map");

    NetworkClass.fromNetworkClass(getRoomIdUrl, this, getRoomIdReq, map)
        .callRequestServiceHeader(true, "post", null);
  }

  /// Get Hopper Accepted List
  void callGetHopperAcceptedCount() {
    NetworkClass(
      "$getHopperAcceptedCountUrl?task_id=${broadCastedData!.broadcastedId}",
      this,
      getHopperAcceptedCountReq,
    ).callRequestServiceHeader(false, "get", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        /// Get Hopper Accepted List
        case getHopperAcceptedCountReq:
          {
            var data = jsonDecode(response);
            debugPrint("getHopperAcceptedCountReq Error : $data");
            showSnackBar("Error", data.toString(), Colors.red);
            break;
          }

        /// Get Room Id
        case getRoomIdReq:
          {
            var data = jsonDecode(response);
            debugPrint("getRoomIdReq Error : $data");
            showSnackBar("Error", data.toString(), Colors.red);
            break;
          }

        case taskDetailUrlRequest:
          debugPrint("BroadcastedData::::Error");
          break;

        /// Task Accept Reject
        case taskAcceptRejectRequestReq:
          {
            var data = jsonDecode(response);
            debugPrint("taskAcceptRejectRequestReq Success : $data");
            if (data != null && data['errors'] != null) {
              showSnackBar(
                  "Error", data['errors']['msg'].toString(), Colors.red);
            } else {
              showSnackBar("Error", data.toString(), Colors.red);
            }
            break;
          }
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        /// Get Hopper Accepted List
        case getHopperAcceptedCountReq:
          var data = jsonDecode(response);
          debugPrint("getHopperAcceptedCountReq Success : $data");
          _hopperAcceptedCount = (data["count"] ?? "0").toString();
          /*  _hopperCountTimer = Timer(
              const Duration(seconds: 10), () => callGetHopperAcceptedCount());*/
          break;

        /// Get Room Id
        case getRoomIdReq:
          var data = jsonDecode(response);
          debugPrint("getRoomIdReq Success : $data");
          //  openUrl();
          Navigator.pushAndRemoveUntil(
              navigatorKey.currentState!.context,
              MaterialPageRoute(
                  builder: (context) =>
                      Dashboard(initialPosition: 1, taskStatus: "accepted")),
              (route) => false);
          break;

        /// Task Accept Reject
        case taskAcceptRejectRequestReq:
          var data = jsonDecode(response);
          debugPrint("taskAcceptRejectRequestReq Success : $data");
          debugPrint("taskStatus ========> $_isAccepted");
          if (_isAccepted) {
            debugPrint("taskStatus true ========> $_isAccepted");
            callGetRoomIdApi();
            showSnackBar("Accepted", "Accepted", Colors.green);
          } else {
            var taskStatusValue = data['data']['task_status'].toString();
            debugPrint("taskStatus false========> $_isAccepted");

            Navigator.pushAndRemoveUntil(
                navigatorKey.currentState!.context,
                MaterialPageRoute(
                    builder: (context) => Dashboard(
                        initialPosition: 1, taskStatus: taskStatusValue)),
                (route) => false);
          }
          break;

        case taskDetailUrlRequest:
          debugPrint("BroadcastedData::::Success:  $response");

          var map = jsonDecode(response);
          if (map["code"] == 200 && map["task"] != null) {
            broadCastedData = BroadcastedData.fromJson(map["task"]);
            taskDetail = TaskDetailModel.fromJson(map["task"] ?? {});
            callGetHopperAcceptedCount();
            getEstimateTime();
            _updateGoogleMap(
                LatLng(broadCastedData!.latitude, broadCastedData!.longitude));
            // Future.delayed(const Duration(seconds: 5),()=>_updateGoogleMap(LatLng(broadcastedData!.latitude, broadcastedData!.longitude)));
          }
          setState(() {});

          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}

class ContactListModel {
  String? identifier, displayName, givenName, middleName;
  List<Item>? phones = [];
  Uint8List? avatar;
  bool isContactSelected = false;

  ContactListModel(
      {required this.displayName,
      required this.givenName,
      required this.middleName,
      required this.phones,
      required this.avatar,
      required this.isContactSelected});
}

class BroadcastedData {
  String broadcastedId = "";
  String headline = "";
  String taskDescription = "";
  String specialRequirements = "";
  String photoPrice = "";
  String videoPrice = "";
  String interviewPrice = "";
  String location = "";
  String deadLineDate = "";
  DateTime deadLine = DateTime.now();
  String mediaHouseName = "";
  String mediaHouseImage = "";
  String mediaHouseId = "";
  double latitude = 0;
  double longitude = 0;
  bool showPhotoPrice = false;
  bool showVideoPrice = false;
  bool showInterviewPrice = false;

  BroadcastedData.fromJson(json) {
    broadcastedId = json["_id"];
    headline = json["heading"] ?? "";
    taskDescription = json["task_description"];
    specialRequirements = json["any_spcl_req"];
    location = json["location"];
    deadLineDate = json["deadline_date"];
    deadLine = DateTime.parse(dateTimeFormatter(
        dateTime: (json["deadline_date"] ?? "").toString(),
        format: "yyyy-MM-dd HH:mm:ss",
        time: true));
    photoPrice = json["photo_price"].toString();
    videoPrice = json["videos_price"].toString();
    interviewPrice = json["interview_price"].toString();
    if (json["mediahouse_id"] != null &&
        json["mediahouse_id"]["admin_detail"] != null) {
      mediaHouseName = json["mediahouse_id"]["admin_detail"]["full_name"];
      mediaHouseImage = json["mediahouse_id"]["admin_detail"]["admin_profile"];
      mediaHouseId = json["mediahouse_id"]["_id"].toString();
    }
    if (json["address_location"] != null &&
        json["address_location"]["coordinates"] != null) {
      var coordinatesList = json["address_location"]["coordinates"] as List;

      if (coordinatesList.isNotEmpty) {
        latitude = coordinatesList.first;
        longitude = coordinatesList[1];
      }
    }

    showPhotoPrice = json["need_photos"];
    showVideoPrice = json["need_videos"];
    showInterviewPrice = json["need_interview"];
  }
}
