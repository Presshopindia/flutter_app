import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/VideoWidget.dart';
import 'package:presshop/view/publishContentScreen/PublishContentScreen.dart';
import 'package:video_player/video_player.dart';
import '../../main.dart';
import '../../utils/CommonWigdets.dart';
import 'dart:ui' as ui;
import '../dashboard/Dashboard.dart';
import 'CameraScreen.dart';
import 'package:path/path.dart' as path;

class PreviewScreen extends StatefulWidget {
  CameraData? cameraData;
  List<CameraData> cameraListData;
  bool pickAgain = false;
  String type = '';

  PreviewScreen(
      {super.key,
      required this.cameraData,
      required this.pickAgain,
      required this.cameraListData,
      required this.type});

  @override
  State<StatefulWidget> createState() {
    return PreviewScreenState();
  }
}

class PreviewScreenState extends State<PreviewScreen> {
  VideoPlayerController? _controller;

  String currentTIme = "00:00",
      mediaAddress = "",
      mediaDate = "",
      country = "",
      state = "",
      city = "";
  AudioPlayer audioPlayer = AudioPlayer();
  PlayerController controller = PlayerController(); // Initialise

  int currentPage = 0;

  bool isLoading = false;
  bool videoPlaying = false, audioPlaying = false,isMoreDisable=false;

  List<MediaData> mediaList = [];
  @override
  void initState() {
    debugPrint("class:::::$runtimeType");
    debugPrint("type:::::${widget.type}");
    super.initState();
    addMediaDataList(widget.cameraListData);

  }

  @override
  void dispose() {
    if (_controller != null && _controller!.value.isPlaying) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        mediaList.clear();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => Dashboard(
                      initialPosition: 2,
                    )),
            (route) => false);

        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
          appBar: null,
          body: SafeArea(
            child: Column(
              children: [
                Flexible(
                  child: PageView.builder(

                    onPageChanged: (value) {
                      currentPage = value;
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      debugPrint(
                          "Mime types====> : ${mediaList[index].mimeType}");
                      if(mediaList[index].mimeType.contains("audio")){
                        debugPrint("InsideAudioPath: ${mediaList[index].mediaPath}");
                       initWaveData(index);

                      }

                      return InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 2,
                          scaleEnabled:mediaList[index].mimeType == "image"?true:false,
                        child: Stack(
                          children: [
                            mediaList[index].mimeType.contains("video")
                                ? Align(
                                    alignment: Alignment.center,
                                    child: VideoWidget(
                                        mediaData: mediaList[index]),
                                  )
                                : mediaList[index].mimeType.contains("audio")
                                    ? Column(
                                        children: [
                                          SizedBox(
                                            height: size.width * numD05,
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(
                                                size.width * numD02),
                                            decoration: const BoxDecoration(
                                                color: colorThemePink,
                                                shape: BoxShape.circle),
                                            child: Container(
                                                padding: EdgeInsets.all(
                                                    size.width * numD07),
                                                decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: size.width *
                                                            numD01)),
                                                child: Icon(
                                                  Icons.mic_none_outlined,
                                                  size: size.width * numD25,
                                                  color: Colors.white,
                                                )),
                                          ),
                                          const Spacer(),
                                          AudioFileWaveforms(
                                            size: Size(size.width, 100.0),
                                            playerController: controller,
                                            enableSeekGesture: true,
                                            waveformType: WaveformType.long,
                                            continuousWaveform: true,
                                            playerWaveStyle: PlayerWaveStyle(
                                              fixedWaveColor: Colors.black,
                                              liveWaveColor: colorThemePink,
                                              spacing: 6,
                                              liveWaveGradient:
                                                  ui.Gradient.linear(
                                                const Offset(70, 50),
                                                Offset(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2,
                                                    0),
                                                [Colors.red, Colors.green],
                                              ),
                                              fixedWaveGradient:
                                                  ui.Gradient.linear(
                                                const Offset(70, 50),
                                                Offset(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2,
                                                    0),
                                                [Colors.red, Colors.green],
                                              ),
                                              seekLineColor: colorThemePink,
                                              seekLineThickness: 2,
                                              showSeekLine: true,
                                              showBottom: true,
                                              waveCap: StrokeCap.round
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.width * numD15,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (audioPlaying) {
                                                pauseSound();
                                              } else {
                                                playSound();
                                              }
                                              audioPlaying = !audioPlaying;
                                              setState(() {});
                                            },
                                            child: Icon(
                                              audioPlaying
                                                  ? Icons.pause_circle
                                                  : Icons.play_circle,
                                              color: colorThemePink,
                                              size: size.width * numD20,
                                            ),
                                          ),
                                          const Spacer(),
                                        ],
                                      )
                                    : mediaList[index].mimeType.contains("doc")
                                        ? Center(
                                            child: SizedBox(
                                              height: size.width * numD60,
                                              width: size.width * numD55,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    "${dummyImagePath}doc_black_icon.png",
                                                    fit: BoxFit.contain,
                                                    height: size.width * numD45,
                                                  ),
                                                  SizedBox(
                                                    height: size.width * numD04,
                                                  ),
                                                  Text(
                                                    path.basename(
                                                        mediaList[index]
                                                            .mediaPath),
                                                    textAlign: TextAlign.center,
                                                    style: commonTextStyle(
                                                        size: size,
                                                        fontSize:
                                                            size.width * numD03,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                    maxLines: 2,
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        : mediaList[index]
                                                .mimeType
                                                .contains("pdf")
                                            ? Center(
                                                child: SizedBox(
                                                  height: size.width * numD60,
                                                  width: size.width * numD55,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                        "${dummyImagePath}pngImage.png",
                                                        fit: BoxFit.contain,
                                                        height:
                                                            size.width * numD45,
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            size.width * numD04,
                                                      ),
                                                      Text(
                                                        path.basename(
                                                            mediaList[index]
                                                                .mediaPath),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: commonTextStyle(
                                                            size: size,
                                                            fontSize:
                                                                size.width *
                                                                    numD03,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                        maxLines: 2,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : SizedBox(
                                              height: size.height,
                                              width: size.width,
                                              child: Image.file(
                                                File(mediaList[index]
                                                    .mediaPath),
                                                fit: BoxFit.cover,
                                                gaplessPlayback: true,
                                              ),
                                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                margin: EdgeInsets.only(
                                    bottom: mediaList[index].mimeType == "video"
                                        ? size.width * numD08
                                        : 0),
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD06,
                                    vertical: size.width * numD04),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                          alignment: Alignment.center,
                                          height: size.width * numD11,
                                          decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD04)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                "${iconsPath}ic_clock.png",
                                                width: size.width * numD04,
                                                height: size.width * numD04,
                                              ),
                                              SizedBox(
                                                width: size.width * numD02,
                                              ),
                                              Text(
                                                mediaList[index].dateTime,
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize:
                                                        size.width * numD025,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              )
                                            ],
                                          )),
                                    ),
                                    SizedBox(
                                      width: size.width * numD04,
                                    ),
                                    Expanded(
                                      child: Container(
                                          height: size.width * numD11,
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD04)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                "${iconsPath}ic_location.png",
                                                width: size.width * numD04,
                                                height: size.width * numD04,
                                              ),
                                              SizedBox(
                                                width: size.width * numD02,
                                              ),
                                              SizedBox(
                                                width: size.width * numD25,
                                                child: Text(
                                                  mediaList[index].location,
                                                  style: commonTextStyle(
                                                      size: size,
                                                      fontSize:
                                                          size.width * numD025,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            !mediaList[index].mimeType.contains("audio")
                                ? Positioned(
                                    top: 0,
                                    bottom: mediaList[index]
                                            .mimeType
                                            .contains("video")
                                        ? size.width * numD08
                                        : 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.1),
                                        ),
                                        child: Image.asset(
                                          "${commonImagePath}watermark1.png",
                                          fit: BoxFit.cover,
                                        )))
                                : Container(),
                            Positioned(
                              top: size.width * numD1,
                              right: size.width * numD04,
                              child: InkWell(
                                onTap: () {
                                  debugPrint("tap:::");
                                  debugPrint("type:::::${widget.type}");
                                  mediaList.clear();
                                  widget.cameraData == null;
                                  widget.cameraListData.clear();
                                  if(widget.type=="camera"){
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => Dashboard(
                                              initialPosition: 2,
                                            )),
                                            (route) => true);
                                  }
                                  else{
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => Dashboard(
                                              initialPosition: 2,
                                            )),
                                            (route) => true);

                                  }
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  padding: EdgeInsets.all(size.width * numD01),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: size.width * numD05,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: mediaList.length,
                  ),
                ),
                mediaList.isNotEmpty && mediaList.length > 1
                    ? DotsIndicator(
                        dotsCount: mediaList.length,
                        position: currentPage,
                        decorator: const DotsDecorator(
                          color: Colors.grey, // Inactive color
                          activeColor: Colors.redAccent,
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: size.width * numD02,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: size.width * numD14,
                          child: commonElevatedButton(
                              "Add More",
                              size,
                              commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                              commonButtonStyle(size, isMoreDisable?Colors.grey:Colors.black), () {
                                if( mediaList.length == 10){
                                  isMoreDisable=true;
                                  setState(() {});
                                  showSnackBar("PRESSHOP", "Only 10 contents allowed!",colorThemePink);
                                }else{
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                      builder: (context) => const CameraScreen(
                                        picAgain: true,
                                      )))
                                      .then((value) {
                                    debugPrint(
                                        ":::: Inside Picked Again Image :::: $value");
                                    if (value != null) {
                                      addMediaDataList(value);
                                    }
                                  });
                                }

                            /*getImageMetaData(widget.cameraData);*/
                          }),
                        ),
                      ),
                      SizedBox(width: size.width * numD04),
                      Expanded(
                        child: SizedBox(
                          height: size.width * numD14,
                          child: commonElevatedButton(
                              "Next",
                              size,
                              commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                              commonButtonStyle(size, colorThemePink), () {
                            if (widget.pickAgain) {
                              Navigator.pop(navigatorKey.currentState!.context);
                              Navigator.pop(
                                  navigatorKey.currentState!.context,
                                  PublishData(
                                      imagePath: widget.cameraData!.path,
                                      address: mediaAddress.isNotEmpty
                                          ? mediaAddress
                                          : widget
                                              .cameraListData.first.location,
                                      date: mediaDate,
                                      city: city.isNotEmpty
                                          ? city
                                          : widget.cameraListData.first.city,
                                      state: state.isNotEmpty
                                          ? state
                                          : widget.cameraListData.first.state,
                                      country: country.isNotEmpty
                                          ? country
                                          : widget.cameraListData.first.country,
                                      latitude: widget.cameraData!.latitude,
                                      longitude: widget.cameraData!.longitude,
                                      mimeType: widget.cameraData!.mimeType,
                                      videoImagePath:
                                          widget.cameraData!.videoImagePath,
                                      mediaList: mediaList));
                            } else {
                              if (mediaList.isNotEmpty) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PublishContentScreen(
                                          publishData: PublishData(
                                              imagePath: widget.cameraData != null
                                                  ? widget.cameraData!.path
                                                  : widget.cameraListData.first
                                                      .path,
                                              address: mediaAddress.isNotEmpty
                                                  ? mediaAddress
                                                  : widget.cameraListData.first
                                                      .location,
                                              date: mediaDate.isNotEmpty
                                                  ? mediaDate
                                                  : widget.cameraListData.first
                                                      .dateTime,
                                              city: city.isNotEmpty
                                                  ? city
                                                  : widget.cameraListData.first
                                                      .city,
                                              state: state.isNotEmpty
                                                  ? state
                                                  : widget.cameraListData.first
                                                      .state,
                                              country: country.isNotEmpty
                                                  ? country
                                                  : widget.cameraListData.first
                                                      .country,
                                              latitude:
                                                  widget.cameraData != null ? widget.cameraData!.latitude : widget.cameraListData.first.latitude,
                                              longitude: widget.cameraData != null ? widget.cameraData!.longitude : widget.cameraListData.first.longitude,
                                              mimeType: widget.cameraData != null ? widget.cameraData!.mimeType : widget.cameraListData.first.mimeType,
                                              videoImagePath: widget.cameraData != null ? widget.cameraData!.videoImagePath : widget.cameraListData.first.videoImagePath,
                                              mediaList: mediaList),
                                          myContentData: null,
                                          hideDraft: false,
                                        )));
                              }
                            }

                            //  getImageMetaData();
                          }),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD04,
                ),
              ],
            ),
          )),
    );
  }

  void initVideoPlayer(MediaData mData) {
    _controller = null;

    if (mData.mimeType.contains("video") && mData.mediaPath.isNotEmpty) {
      _controller = VideoPlayerController.file(File(mData.mediaPath))
        ..initialize().then((_) {
          setState(() {});
        });

      _controller!.addListener(() {
        currentTIme = _controller!.value.position.inSeconds.toString();
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  /// Camera Image
  Future addMediaData(CameraData? cData) async {
    if (cData != null) {
      mediaList.add(MediaData(
          mediaPath: cData.path,
          mimeType: cData.mimeType,
          thumbnail: cData.videoImagePath,
          dateTime: cData.dateTime,
          location: cData.location,
          latitude: cData.latitude,
          longitude: cData.longitude));
    }
    debugPrint("MedListSize: ${mediaList.length}");
    setState(() {});
    //getImageMetaData(cData);
  }

  /// Gallery Image
  Future addMediaDataList(List<CameraData> cDataList) async {
    if (cDataList.isNotEmpty) {
      for (var element in cDataList) {
        mediaList.add(MediaData(
            mediaPath: element.path,
            mimeType: element.mimeType,
            thumbnail: element.videoImagePath,
            location: element.location,
            dateTime: element.dateTime.toString(),
            latitude: element.latitude,
            longitude: element.longitude));
        debugPrint("MedListSize: ${mediaList.length}");
        setState(() {});
      }
    }
  }

  Future initWaveData(int index) async {
// Or directly extract from preparePlayer and initialise audio player
    debugPrint("Wave-path:${mediaList[index].mediaPath}");
    await controller.preparePlayer(
      path: mediaList[index].mediaPath,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );

    controller.onPlayerStateChanged.listen((event) {
      if (event.isPaused) {
        audioPlaying = false;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

/*  Future getImageMetaData(var cData) async {
    final exif = await Exif.fromPath(cData.path)
      ..getAttributes().then((value) {
        debugPrint("ExifAttributes: $value");
        if (value != null) {
          if (Platform.isIOS && mediaDate.isEmpty) {
            mediaDate = value["DateTimeOriginal"] != null
                ? changeDateFormat("yyyy:MM:dd HH:mm:ss",
                    value["DateTimeOriginal"].toString(), "HH:mm, dd MMM yyyy")
                : "";
          } else if (Platform.isAndroid && mediaDate.isEmpty) {
            mediaDate = value["DateTime"] != null
                ? changeDateFormat("yyyy:MM:dd HH:mm:ss",
                    value["DateTime"].toString(), "HH:mm, dd MMM yyyy")
                : "";
          }

          if (mediaDate.isEmpty) {
            mediaDate = cData!.dateTime ?? "";

            mediaDate = changeDateFormat(
                "yyyy-MM-dd'T'HH:mm:ssZ", mediaDate, "HH:mm, dd MMM yyyy");
          }

          mediaList.last.dateTime = mediaDate;
          debugPrint("MediaDate: $mediaDate");
        }
      });

    if (cData!.latitude != "0.0" && cData.longitude != "0.0") {
      debugPrint("InnerLat: ${cData.latitude}");
      debugPrint("InnerLng: ${cData.longitude}");

      getCurrentLocation(
          widget.cameraData!.latitude, widget.cameraData!.longitude, cData);
    } else if (await checkGps() && await locationPermission()) {
      debugPrint("::::::: Inside Location Fetch :::::::::::");
      loc.LocationData currLoc = await loc.Location.instance.getLocation();
      getCurrentLocation(
          currLoc.latitude.toString(), currLoc.longitude.toString(), cData);
    }
  }
  void getCurrentLocation(String latitude, String longitude, var cData) async {
    try {
      List<Placemark> placeMarkList = await placemarkFromCoordinates(
          double.parse(latitude), double.parse(longitude));

      debugPrint("PlaceHolder: ${placeMarkList.first}");

      String name = placeMarkList.first.name!;
      String street = placeMarkList.first.name!;
      String nagar = placeMarkList.first.subLocality!;
      String cityValue = placeMarkList.first.locality!;
      String stateValue = placeMarkList.first.administrativeArea!;
      String countryValue = placeMarkList.first.country!;
      String pinCode = placeMarkList.first.postalCode!;

      mediaAddress = "$nagar, $street, $pinCode";
      country = countryValue;
      state = stateValue;
      city = cityValue;

      debugPrint("MyAddress: $mediaAddress");

      mediaList.last.location = mediaAddress;
      mediaList.last.latitude = latitude;
      mediaList.last.longitude = longitude;

      isLoading = false;
      setState(() {});
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }*/

  Future playSound() async {
    debugPrint("PlayTheSound");

    await controller.startPlayer(
        finishMode: FinishMode.pause); // Start audio player
  }

  Future pauseSound() async {
    await controller.pausePlayer(); // Start audio player
  }
}

class PublishData {
  String imagePath = "";
  String videoImagePath = "";
  String mimeType = "";
  String address = "";
  String date = "";
  String country = "";
  String state = "";
  String city = "";
  String latitude = "";
  String longitude = "";
  List<MediaData> mediaList = [];

  PublishData({
    required this.imagePath,
    required this.address,
    required this.date,
    required this.country,
    required this.state,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.videoImagePath,
    required this.mimeType,
    required this.mediaList,
  });
}

class MediaData {
  String mediaPath = "";
  String mimeType = "";
  String thumbnail = "";
  String dateTime = "";
  String location = "";
  String latitude = "";
  String longitude = "";

  MediaData({
    required this.mediaPath,
    required this.mimeType,
    required this.thumbnail,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.dateTime,
  });
}
