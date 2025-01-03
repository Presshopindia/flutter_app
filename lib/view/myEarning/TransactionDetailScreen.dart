import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonWigdets.dart';
import '../menuScreen/PublicationListScreen.dart';
import 'earningDataModel.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String type;
  EarningTransactionDetail? transactionData;

  TransactionDetailScreen(
      {super.key, required this.type, required this.transactionData});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late Size size;
  PageController pageController = PageController();
  PlayerController controller = PlayerController();
  FlickManager? flickManager;
  int _currentMediaIndex = 0;
  int feedIndex = 0;
  bool audioPlaying = false;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(transactionDetailsText,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSize,
            )),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: true,
        leadingFxn: () {
          Navigator.pop(context);
        },
        actionWidget: [
          InkWell(
            child: Image.asset(
              "${commonImagePath}rabbitLogo.png",
              width: size.width * numD13,
            ),
          ),
          SizedBox(
            width: size.width * numD04,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * numD05,
              vertical: size.width * numD05,
            ),
            child: Column(
              children: [
                widget.type == "pending"
                    ? pendingPaymentWidget()
                    : receivedPaymentWidget(),
                SizedBox(
                  height:size.width * numD02
                ),

                Center(
                  child: TextButton(
                    onPressed: (){
                          Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  PublicationListScreen(
                                      contentId:widget.transactionData!.contentDataList[feedIndex].id,
                                      contentType:widget.transactionData!.contentType,
                                      publicationCount:"" )));
                    },
                    child: Text(
                      viewPublicationsPurchasedText,
                      style: commonTextStyle(
                          size: size,
                          fontSize:
                          size.width * numD033,
                          color: colorThemePink,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget receivedPaymentWidget() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * numD03,
            vertical: size.width * numD03,
          ),
          decoration: BoxDecoration(
              color: colorLightGrey,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 0,
                    spreadRadius: 0.5)
              ],
              borderRadius: BorderRadius.circular(size.width * numD03),
              border: Border.all(width: 1, color: Colors.black)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: size.width * numD025,
                      bottom: size.width * numD02,
                      left: size.width * numD03,
                      right: size.width * numD03,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: colorThemePink,
                        borderRadius:
                            BorderRadius.circular(size.width * numD015)),
                    child: Row(
                      children: [
                        Text(
                          receivedText,
                          style: TextStyle(
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontFamily: "AirbnbCereal_W_Bk"),
                        ),
                        Text(
                          " £${widget.transactionData!.payableT0Hopper}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * numD025),
                    child: Image.asset(
                      "${dummyImagePath}news.png",
                      width: size.width * numD11,
                    ),
                  )
                ],
              ),

              SizedBox(
                height: size.width * numD03,
              ),

              SizedBox(
                height: size.width * numD40,
                child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (value) {
                      _currentMediaIndex = value;
                      if (flickManager != null) {
                        flickManager?.dispose();
                        flickManager = null;
                      }
                      initialController(_currentMediaIndex);
                      setState(() {});
                    },
                    itemCount: widget.transactionData!.contentDataList.length,
                    itemBuilder: (context, idx) {
                      var item = widget.transactionData!.contentDataList[idx];
                      return ClipRRect(
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                        child: Stack(
                          children: [
                            item.mediaType == "audio"
                                ? playAudioWidget(size)
                                : item.mediaType == "video"
                                    ? videoWidget()
                                    : Image.network(
                                        item.mediaType == "video"
                                            ? "$contentImageUrl${item.thumbnail}"
                                            : "$contentImageUrl${item.media}",
                                        width: size.width,
                                        fit: BoxFit.cover,
                                      ),
                            Positioned(
                              right: size.width * numD02,
                              top: size.width * numD02,
                              child: Container(
                                  width: size.width * numD06,
                                  height: size.width * numD06,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * numD01,
                                      vertical: size.width * 0.002),
                                  decoration: BoxDecoration(
                                      color: colorLightGreen.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD015)),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.005,
                                      vertical: size.width * 0.005,
                                    ),
                                    child: Image.asset(
                                      item.mediaType == "image"
                                          ? "${iconsPath}ic_camera_publish.png"
                                          : item.mediaType == "video"
                                              ? "${iconsPath}ic_v_cam.png"
                                              : "${iconsPath}ic_mic.png",
                                      color: Colors.white,
                                      height: item.mediaType == "video"
                                          ? size.width * numD09
                                          : item.mediaType == "image"
                                              ? size.width * numD05
                                              : size.width * numD08,
                                    ),
                                  )),
                            ),
                            Positioned(
                              right: size.width * numD02,
                              bottom: size.width * numD02,
                              child: Visibility(
                                visible: widget.transactionData!.contentDataList
                                        .length >
                                    1,
                                child: Text(
                                  "+${widget.transactionData!.contentDataList.length}",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD04,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            item.mediaType == "image"
                                ? Image.asset(
                                    "${commonImagePath}watermark1.png",
                                    width: size.width,
                                    fit: BoxFit.cover,
                                  )
                                : Container(),
                            widget.transactionData!.contentDataList.length > 1
                                ? Align(
                                    alignment: Alignment.bottomCenter,
                                    child: DotsIndicator(
                                      dotsCount: widget.transactionData!
                                          .contentDataList.length,
                                      position: _currentMediaIndex,
                                      decorator: const DotsDecorator(
                                        color: Colors.grey, // Inactive color
                                        activeColor: Colors.redAccent,
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      );
                    }),
              ),

              /// Task completed
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD025,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.transactionData!.type == "content"
                          ? contentCompletedText
                          : taskCompletedText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "${iconsPath}ic_task.png",
                          width: size.width * numD05,
                        ),
                        SizedBox(
                          width: size.width * numD02,
                        ),
                        Text(
                          "Yes",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Time and date
         /*     Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeAndDateText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                    *//*  widget.transactionData!.createdAT.isNotEmpty
                          ? DateFormat('hh:mm a, dd MMMM,yyyy').format(
                              DateTime.parse(widget.transactionData!.createdAT))
                          : '',*//*
                        widget.transactionData!.createdAT,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),*/

              /// Payment date
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      paymentDateText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                     /* widget.transactionData!.createdAT.isNotEmpty
                          ? DateFormat('dd MMMM,yyyy').format(
                              DateTime.parse(widget.transactionData!.createdAT))
                          : '',*/
                        widget.transactionData!.createdAT,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// Payment made time
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      paymentMadeTimeText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                     /* widget.transactionData!.createdAT.isNotEmpty
                          ? DateFormat('hh:mm a').format(
                              DateTime.parse(widget.transactionData!.createdAT))
                          : '',*/

                        dateTimeFormatter(dateTime: widget.transactionData!.createdAT,time: true,format: "hh:mm a"),
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// Transaction ID
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transactionIdText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      widget.transactionData!.id,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: size.width * numD1,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * numD03,
            vertical: size.width * numD03,
          ),
          decoration: BoxDecoration(
              color: colorLightGrey,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 0,
                    spreadRadius: 0.5)
              ],
              borderRadius: BorderRadius.circular(size.width * numD03),
              border: Border.all(width: 1, color: Colors.black)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: size.width * numD03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.transactionData!.adminBankName,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD04,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: size.width * numD01,
                    ),
                    Text(
                      '',
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// Divider
              Padding(
                padding: EdgeInsets.only(top: size.width * numD01),
                child: const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
              ),

              /// to
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD025,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      toText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "${widget.transactionData!.userFirstName} ${widget.transactionData!.userLastName}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// From
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fromText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "${widget.transactionData!.adminFullName} ",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// Divider
              Padding(
                padding: EdgeInsets.only(top: size.width * numD01),
                child: const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
              ),

              /// Payment Summary
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Text(
                  paymentSummaryText,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD03,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),

              /// Offered amount
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      offeredAmountText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "£${widget.transactionData!.amount}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// PressHop fees
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      presshopFeesText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "£${widget.transactionData!.payableCommission}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// Amount paid
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      amountPaidText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "£${widget.transactionData!.payableT0Hopper}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future initWaveData(String url) async {
    var dio = Dio();
    dio.interceptors.add(LogInterceptor(responseBody: false));

    Directory appFolder = await getApplicationDocumentsDirectory();
    bool appFolderExists = await appFolder.exists();
    if (!appFolderExists) {
      final created = await appFolder.create(recursive: true);
      debugPrint(created.path);
    }

    final filepath = '${appFolder.path}/dummyFileRecordFile.m4a';
    debugPrint("Audio FilePath : $filepath");

    File(filepath).createSync();

    await dio.download(url, filepath);

    await controller.preparePlayer(
      path: filepath,
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
    setState(() {});
  }

  void initialController(currentMediaIndex) {
    if (widget.transactionData!.contentDataList[currentMediaIndex].mediaType ==
        "audio") {
      initWaveData(contentImageUrl +
          widget.transactionData!.contentDataList[currentMediaIndex].media);
    } else if (widget
            .transactionData!.contentDataList[currentMediaIndex].mediaType ==
        "video") {
      debugPrint(
          "videoLink=====> ${widget.transactionData!.contentDataList[currentMediaIndex].media}");
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(contentImageUrl +
              widget.transactionData!.contentDataList[currentMediaIndex].media),
        ),
        autoPlay: false,
      );
    }
    setState(() {});
  }

  Widget playAudioWidget(size) {
    return Container(
      width: size.width,
      alignment: Alignment.center,
      padding: EdgeInsets.all(size.width * numD04),
      decoration: BoxDecoration(
        border: Border.all(color: colorGreyNew),
        borderRadius: BorderRadius.circular(size.width * numD06),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: size.width * numD05,
          ),
          AudioFileWaveforms(
            size: Size(size.width, size.width * numD15),
            playerController: controller,
            enableSeekGesture: true,
            waveformType: WaveformType.long,
            continuousWaveform: true,
            playerWaveStyle: PlayerWaveStyle(
              fixedWaveColor: Colors.black,
              liveWaveColor: colorThemePink,
              spacing: 6,
              liveWaveGradient: ui.Gradient.linear(
                const Offset(70, 50),
                Offset(MediaQuery.of(context).size.width / 2, 0),
                [Colors.red, Colors.green],
              ),
              fixedWaveGradient: ui.Gradient.linear(
                const Offset(70, 50),
                Offset(MediaQuery.of(context).size.width / 2, 0),
                [Colors.red, Colors.green],
              ),
              seekLineColor: colorThemePink,
              seekLineThickness: 2,
              showSeekLine: true,
              showBottom: true,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () async {
              if (!audioPlaying) {
                await controller.startPlayer(finishMode: FinishMode.pause);
              } else {
                await controller.pausePlayer(); // Start audio player
              }

              audioPlaying = !audioPlaying;
              setState(() {});
            },
            child: Icon(
              audioPlaying ? Icons.pause_circle : Icons.play_circle,
              color: colorThemePink,
              size: size.width * numD1,
            ),
          ),
        ],
      ),
    );
  }

  /*Widget videoWidget() {
    return FlickVideoPlayer(
      flickManager: flickManager!,
      flickVideoWithControls: const FlickVideoWithControls(
        playerLoadingFallback: Center(
            child: CircularProgressIndicator(
          color: colorThemePink,
        )),
      ),
      flickVideoWithControlsFullscreen: const FlickVideoWithControls(
        playerLoadingFallback: CircularProgressIndicator(
          color: colorThemePink,
        ),
        controls: FlickLandscapeControls(),
      ),
    );
  }*/

  Widget videoWidget() {
    return VisibilityDetector(
      key: ObjectKey(flickManager),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && mounted) {
          flickManager?.flickControlManager?.autoPause();
        } else if (visibility.visibleFraction == 1) {
          flickManager?.flickControlManager?.autoResume();
        }
      },
      child: flickManager != null
          ? FlickVideoPlayer(
              flickManager: flickManager!,
              flickVideoWithControls: const FlickVideoWithControls(
                playerLoadingFallback: Center(
                    child: CircularProgressIndicator(
                  color: colorThemePink,
                )),
                closedCaptionTextStyle: TextStyle(fontSize: 8),
                controls: FlickPortraitControls(),
              ),
              flickVideoWithControlsFullscreen: const FlickVideoWithControls(
                playerLoadingFallback: Center(
                    child: CircularProgressIndicator(
                  color: colorThemePink,
                )),
                controls: FlickLandscapeControls(),
              ),
            )
          : Container(),
    );
  }

  Widget pendingPaymentWidget() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * numD03,
            vertical: size.width * numD03,
          ),
          decoration: BoxDecoration(
              color: colorLightGrey,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 0,
                    spreadRadius: 0.5)
              ],
              borderRadius: BorderRadius.circular(size.width * numD03),
              border: Border.all(width: 1, color: Colors.black)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: size.width * numD025,
                      bottom: size.width * numD02,
                      left: size.width * numD03,
                      right: size.width * numD03,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(size.width * numD015),
                        border: Border.all(
                            color: const Color(0xFFAEB4B3), width: 1)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pendingText,
                          style: TextStyle(
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontFamily: "AirbnbCereal_W_Bk"),
                        ),
                        Text(
                          " £${widget.transactionData!.amount}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * numD025),
                    child: Image.asset(
                      "${dummyImagePath}news.png",
                      width: size.width * numD11,
                    ),
                  )
                ],
              ),

              SizedBox(
                height: size.width * numD03,
              ),

              SizedBox(
                height: size.width * numD40,
                child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (value) {
                      _currentMediaIndex = value;
                      if (flickManager != null) {
                        flickManager?.dispose();
                        flickManager = null;
                      }
                      initialController(_currentMediaIndex);
                      setState(() {});
                    },
                    itemCount: widget.transactionData!.contentDataList.length,
                    itemBuilder: (context, idx) {
                      var item = widget.transactionData!.contentDataList[idx];
                      return ClipRRect(
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                        child: InkWell(
                          onTap: (){
                            if (item.mediaType == "pdf" || item.mediaType == "doc") {
                              openUrl(contentImageUrl + item.media);
                            }
                          },
                          child: Stack(
                            children: [
                              /* item.mediaType == "audio"
                                  ? playAudioWidget(size)
                                  : item.mediaType == "video"
                                      ? videoWidget()
                                      : Image.network(
                                          item.mediaType == "video"
                                              ? "$contentImageUrl${item.thumbnail}"
                                              : "$contentImageUrl${item.media}",
                                          width: size.width,
                                          fit: BoxFit.cover,
                                        ),*/

                              item.mediaType == "audio"
                                  ? playAudioWidget(size)
                                  : item.mediaType == "video"
                                      ? videoWidget()
                                      : item.mediaType == "pdf"
                                          ? Padding(
                                              padding: EdgeInsets.all(
                                                  size.width * numD04),
                                              child: Image.asset(
                                                "${dummyImagePath}pngImage.png",
                                                fit: BoxFit.contain,
                                                width: size.width,
                                              ),
                                            )
                                          : item.mediaType == "doc"
                                              ? Padding(
                                                  padding: EdgeInsets.all(
                                                      size.width * numD04),
                                                  child: Image.asset(
                                                    "${dummyImagePath}doc_black_icon.png",
                                                    fit: BoxFit.contain,
                                                    width: size.width,
                                                  ),
                                                )
                                              : Image.network(
                                                  item.mediaType == "video"
                                                      ? "$contentImageUrl${item.thumbnail}"
                                                      : "$contentImageUrl${item.media}",
                                                  width: size.width,
                                                  fit: BoxFit.cover,
                                                ),
                              Positioned(
                                right: size.width * numD02,
                                top: size.width * numD02,
                                child: Container(
                                    width: size.width * numD06,
                                    height: size.width * numD06,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * numD01,
                                        vertical: size.width * 0.002),
                                    decoration: BoxDecoration(
                                        color: colorLightGreen.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD015)),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.005,
                                        vertical: size.width * 0.005,
                                      ),
                                      child: Image.asset(
                                        item.mediaType == "image"
                                            ? "${iconsPath}ic_camera_publish.png"
                                            : item.mediaType == "video"
                                                ? "${iconsPath}ic_v_cam.png"
                                                : item.mediaType == "audio"
                                                    ? "${iconsPath}ic_mic.png"
                                                    : "${iconsPath}doc_icon.png",
                                        color: Colors.white,
                                        height: item.mediaType == "video"
                                            ? size.width * numD09
                                            : item.mediaType == "image"
                                                ? size.width * numD05
                                                : item.mediaType == "audio"
                                                    ? size.width * numD08
                                                    : size.width * numD1,
                                      ),
                                    )),
                              ),
                              Positioned(
                                right: size.width * numD02,
                                bottom: size.width * numD02,
                                child: Visibility(
                                  visible: widget.transactionData!.contentDataList
                                          .length >
                                      1,
                                  child: Text(
                                    "+${widget.transactionData!.contentDataList.length}",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD04,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              item.mediaType == "image"
                                  ? Image.asset(
                                      "${commonImagePath}watermark1.png",
                                      width: size.width,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(),
                              widget.transactionData!.contentDataList.length > 1
                                  ? Align(
                                      alignment: Alignment.bottomCenter,
                                      child: DotsIndicator(
                                        dotsCount: widget.transactionData!
                                            .contentDataList.length,
                                        position: _currentMediaIndex,
                                        decorator: const DotsDecorator(
                                          color: Colors.grey, // Inactive color
                                          activeColor: Colors.redAccent,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      );
                    }),
              ),

              /// Content sold
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD025,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      contentSoldText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          widget.transactionData!.type == "shared"
                              ? "${iconsPath}ic_share.png"
                              : "${iconsPath}ic_exclusive.png",
                          width: size.width * numD05,
                        ),
                        SizedBox(
                          width: size.width * numD02,
                        ),
                        Text(
                          widget.transactionData!.type,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Date of sale
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateOfSaleText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      widget.transactionData!.createdAT,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: size.width * numD1,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * numD03,
            vertical: size.width * numD03,
          ),
          decoration: BoxDecoration(
              color: colorLightGrey,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 0,
                    spreadRadius: 0.5)
              ],
              borderRadius: BorderRadius.circular(size.width * numD03),
              border: Border.all(width: 1, color: Colors.black)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Payment Summary
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Text(
                  paymentSummaryText,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD042,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),

              /// Divider
              Padding(
                padding: EdgeInsets.only(top: size.width * numD01),
                child: const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
              ),

              /// Your earnings
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      offeredAmountText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "£${widget.transactionData!.amount}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// Presshop fees
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      presshopFeesText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "£${widget.transactionData!.payableCommission}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// Amount pending
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      amountPaidText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "£${widget.transactionData!.payableT0Hopper}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /* /// Payment due date
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      paymentDueDateText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      widget.transactionData!.createdAT.isNotEmpty
                          ? DateFormat('dd MMMM,yyyy').format(
                              DateTime.parse(widget.transactionData!.createdAT))
                          : '',
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),*/
            ],
          ),
        ),
      ],
    );
  }


  openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }
  }
}
