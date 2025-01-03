import 'dart:convert';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/menuScreen/PublicationListScreen.dart';
import 'package:presshop/view/myEarning/MyEarningScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../utils/CommonModel.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../dashboard/Dashboard.dart';
import '../myEarning/earningDataModel.dart';
import 'ManageTaskScreen.dart';
import 'MyContentScreen.dart';

class MyContentDetailScreen extends StatefulWidget {
  final String contentId;
  final String paymentStatus;
  final bool exclusive;
  final int offerCount;

  const MyContentDetailScreen(
      {super.key,
      required this.paymentStatus,
      required this.exclusive,
      required this.offerCount,
      required this.contentId});

  @override
  State<StatefulWidget> createState() {
    return MyContentDetailScreenState();
  }
}

class MyContentDetailScreenState extends State<MyContentDetailScreen>
    implements NetworkResponse {
  String selectedSellType = sharedText;
  ScrollController listController = ScrollController();
  MyContentData? myContentData;
  FlickManager? flickManager;
  AudioPlayer audioPlayer = AudioPlayer();
  PlayerController controller = PlayerController();
  String publicationCount = "";
  List<EarningTransactionDetail> publicationTransactionList = [];
  final List<ManageTaskChatModel> _mediaHouseList = [];

  bool audioPlaying = false;
  late Size size;
  bool isOfferAvailable = false;
  int _currentMediaIndex = 0;
  bool isMediaOffer = false;

  @override
  void initState() {
    debugPrint("statys::::::${widget.paymentStatus}");
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => myContentDetailApi());
  }

  @override
  void dispose() {
    flickManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      //  backgroundColor: Colors.white,
      appBar: CommonAppBar(
          elevation: 0,
          hideLeading: false,
          title: Text(
            "${myContentText.toTitleCase()} ${detailsText.toTitleCase()}",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: size.width * appBarHeadingFontSize),
          ),
          centerTitle: false,
          titleSpacing: 0,
          size: size,
          showActions: true,
          leadingFxn: () {
            Navigator.pop(context, true);
          },
          actionWidget: [
            InkWell(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => Dashboard(initialPosition: 2)),
                    (route) => false);
              },
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * numD13,
              ),
            ),
            SizedBox(
              width: size.width * numD04,
            )
          ]),
      body: SafeArea(
        child: myContentData != null
            ? SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(top: size.width * numD02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      showMediaWidget(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD04,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            headerWidget(),

                            /// Description
                            Text(
                              myContentData!.textValue,
                              textAlign: TextAlign.justify,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD03,
                                  color: Colors.black,
                                  lineHeight: 2,
                                  fontWeight: FontWeight.normal),
                            ),
                            SizedBox(
                              height: size.width * numD08,
                            ),

                            const Divider(
                              color: colorGrey1,
                            ),

                            SizedBox(
                              height: size.width * numD05,
                            ),

                            /// Manage Content Text
                            _mediaHouseList.isNotEmpty && isMediaOffer
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Manage Content".toUpperCase(),
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD038,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: size.width * numD07,
                                      ),
                                      showMediaHouseWidget(),
                                      SizedBox(
                                        height: size.width * numD07,
                                      ),
                                    ],
                                  )
                                : Container(),

                            publicationTransactionList.isNotEmpty
                                ? Column(
                                    children: [
                                      myContentData!.paidStatus == paidText
                                          ? Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: size.width * numD03,
                                                horizontal: size.width * numD05,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: colorLightGrey,
                                                  border: Border.all(
                                                      color: Colors.black),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * numD02)),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    paymentSummaryText,
                                                    style: commonTextStyle(
                                                        size: size,
                                                        fontSize: size.width *
                                                            numD035,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),

                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      top: size.width * numD01,
                                                    ),
                                                    child: const Divider(
                                                      color: Colors.white,
                                                      thickness: 1.5,
                                                    ),
                                                  ),

                                                  /// Your earnings
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: size.width *
                                                            numD04),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          yourEarningsText,
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        Text(
                                                          publicationTransactionList
                                                                  .isNotEmpty
                                                              ? "£${amountFormat(publicationTransactionList.first.amount)}"
                                                              : "",
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  /// Presshop fees
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: size.width *
                                                            numD02),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          presshopFeesText,
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        Text(
                                                          publicationTransactionList
                                                                  .isNotEmpty
                                                              ? "£${publicationTransactionList.first.payableCommission}"
                                                              : "",
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  /// Amount pending
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: size.width *
                                                            numD02),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          myContentData!.paidStatus ==
                                                                      paidText &&
                                                                  myContentData!
                                                                      .isPaidStatusToHopper
                                                              ? amountPaidText
                                                              : amountPendingText,
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        Text(
                                                          publicationTransactionList
                                                                  .isNotEmpty
                                                              ? "£${amountFormat(publicationTransactionList.first.payableT0Hopper)}"
                                                              : "",
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  /// Payment due date
                                    Padding(
                                      padding:
                                      EdgeInsets.only(
                                          top:
                                          size.width *
                                              numD02),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Text(
                                            paymentDueDateText,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size
                                                    .width *
                                                    numD035,
                                                color: Colors
                                                    .black,
                                                fontWeight:
                                                FontWeight
                                                    .w400),
                                          ),
                                          myContentData!.isPaidStatusToHopper?Text("made on",style:commonTextStyle(
                                              size: size,
                                              fontSize: size
                                                  .width *
                                                  numD035,
                                              color: Colors
                                                  .black,
                                              fontWeight:
                                              FontWeight
                                                  .w400),):Text(
                                            publicationTransactionList
                                                .first
                                                .createdAT,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size
                                                    .width *
                                                    numD035,
                                                color: Colors
                                                    .black,
                                                fontWeight:
                                                FontWeight
                                                    .w400),
                                          ),
                                        ],
                                      ),
                                    ),

                                                 /*   /// Payment due date
                                                      myContentData!
                                                                  .paidStatus ==
                                                              "paid"
                                                          ? Container()
                                                          : Padding(
                                                              padding: EdgeInsets.only(
                                                                  top: size
                                                                          .width *
                                                                      numD02),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "paymentDueDateText",
                                                                    style: commonTextStyle(
                                                                        size:
                                                                            size,
                                                                        fontSize:
                                                                            size.width *
                                                                                numD035,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                  Text(
                                                                    "23 December, 2022",
                                                                    style: commonTextStyle(
                                                                        size:
                                                                            size,
                                                                        fontSize:
                                                                            size.width *
                                                                                numD035,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ],
                                                              ),
                                                            )*/

                                                  /// Divider
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(
                                        height:
                                            myContentData!.paidStatus == "paid"
                                                ? size.width * numD07
                                                : 0,
                                      ),
                                      myContentData!.paidStatus == paidText &&
                                              myContentData!
                                                  .isPaidStatusToHopper
                                          ? Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: size.width * numD03,
                                                horizontal: size.width * numD05,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: colorLightGrey,
                                                  border: Border.all(
                                                      color: Colors.black),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * numD02)),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    transactionDetails
                                                        .toTitleCase(),
                                                    style: commonTextStyle(
                                                        size: size,
                                                        fontSize: size.width *
                                                            numD035,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),

                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      top: size.width * numD01,
                                                    ),
                                                    child: const Divider(
                                                      color: Colors.white,
                                                      thickness: 1.5,
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: size.width *
                                                            numD02),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          paymentMadeToText,
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        Text(
                                                          publicationTransactionList
                                                                  .isNotEmpty
                                                              ? publicationTransactionList
                                                                  .first
                                                                  .adminBankName
                                                              : '',
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: size.width *
                                                            numD02),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          accountNumberText,
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        Text(
                                                          publicationTransactionList
                                                                  .isNotEmpty
                                                              ? publicationTransactionList
                                                                  .first
                                                                  .adminAccountNumber
                                                              : '',
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: size.width *
                                                            numD02),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          paymentDateText,
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        Text(
                                                          publicationTransactionList
                                                                  .isNotEmpty
                                                              ? DateFormat(
                                                                      'dd MMMM yyyy')
                                                                  .format(DateTime.parse(
                                                                      publicationTransactionList
                                                                          .first
                                                                          .createdAT))
                                                              : '',
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  /// Amount pending
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: size.width *
                                                            numD02),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          paymentMadeTimeText,
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        Text(
                                                          publicationTransactionList
                                                                  .isNotEmpty
                                                              ? DateFormat(
                                                                      'hh:mm a')
                                                                  .format(DateTime.parse(
                                                                      publicationTransactionList
                                                                          .first
                                                                          .createdAT))
                                                              : '',
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: size.width *
                                                            numD02),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          transactionIDText,
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        Text(
                                                          publicationTransactionList
                                                                  .isNotEmpty
                                                              ? publicationTransactionList
                                                                  .first.id
                                                              : '',
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  )

                                                  /// Divider
                                                ],
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  )
                                : Container(),

                            myContentData!.paidStatus == paidText
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: size.width * numD05,
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PublicationListScreen(
                                                            contentId:
                                                            myContentData!
                                                                .id,
                                                            contentType:
                                                            myContentData!
                                                                .contentType,
                                                            publicationCount:
                                                            publicationCount)));
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
                                          )),
                                      InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyEarningScreen(
                                                            openDashboard:
                                                                false)));
                                          },
                                          child: Center(
                                            child: Text(
                                              viewYourEarnings,
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize:
                                                      size.width * numD033,
                                                  color: colorThemePink,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          )),
                                    ],
                                  )
                                : Container(),
                            SizedBox(
                              height: size.width * numD05,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Container(),
      ),
    );
  }

  Widget showMediaWidget() {
    return SizedBox(
      height: size.width * numD50,
      child: PageView.builder(
          onPageChanged: (value) {
            _currentMediaIndex = value;

            if (flickManager != null) {
              flickManager?.dispose();
              flickManager = null;
            }
            initialController();
            setState(() {});
          },
          itemCount: myContentData!.contentMediaList.length,
          itemBuilder: (context, index) {
            var item = myContentData!.contentMediaList[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * numD04),
                child: InkWell(
                  onTap: () {
                    if (item.mediaType == "pdf" || item.mediaType == "doc") {
                      openUrl(myContentData!.paidStatus == paidText?contentImageUrl + item.media:item.waterMark);
                    }
                  },
                  child: Stack(
                    children: [
                      item.mediaType == "audio"
                          ? playAudioWidget()
                          : item.mediaType == "video"
                              ? videoWidget()
                              : item.mediaType == "pdf"
                                  ? Padding(
                                      padding:
                                          EdgeInsets.all(size.width * numD04),
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
                                          myContentData!.contentMediaList[index]
                                                      .mediaType ==
                                                  "video"
                                              ? "$contentImageUrl${myContentData!.contentMediaList[index].thumbNail}"
                                              : "$contentImageUrl${myContentData!.contentMediaList[index].media}",
                                          width: size.width,
                                          fit: BoxFit.cover,
                                        ),

                      /*   mediaList[index]
                          .mimeType
                          .contains("doc")
                          ? SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Image.asset(
                          "${dummyImagePath}docImage.png",
                          fit: BoxFit.contain,
                        ),
                      )
                          : mediaList[index]
                          .mimeType
                          .contains("pdf")
                          ? SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Image.asset(
                          "${dummyImagePath}pngImage.png",
                          fit: BoxFit.contain,
                        ),
                      )*/
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
                                height: myContentData!.contentMediaList[index]
                                            .mediaType ==
                                        "video"
                                    ? size.width * numD09
                                    : myContentData!.contentMediaList[index]
                                                .mediaType ==
                                            "image"
                                        ? size.width * numD05
                                        : myContentData!.contentMediaList[index]
                                                    .mediaType ==
                                                "audio"
                                            ? size.width * numD08
                                            : size.width * numD1,
                              ),
                            )),
                      ),
                      Positioned(
                        right: size.width * numD02,
                        bottom: size.width * numD02,
                        child: Visibility(
                          visible: myContentData!.contentMediaList.length > 1,
                          child: Text(
                            "+${myContentData!.contentMediaList.length - 1}",
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
                      myContentData!.contentMediaList.length > 1
                          ? Align(
                        alignment: Alignment.bottomCenter,
                        child: DotsIndicator(
                          dotsCount:
                          myContentData!.contentMediaList.length,
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
              ),
            );
          }),
    );
  }

  Widget headerWidget() {
    return Column(
      children: [
        SizedBox(
          height: size.width * numD02,
        ),
        Row(
          children: [
            Text(
              myContentData!.exclusive ? "" : multipleText.toUpperCase(),
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * numD033,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
            const Spacer(),
            Row(
              children: [
                Image.asset(
                  myContentData!.exclusive
                      ? "${iconsPath}ic_exclusive.png"
                      : "${iconsPath}ic_share.png",
                  height: size.width * numD035,
                ),
                SizedBox(
                  width: size.width * numD02,
                ),
                Text(
                  myContentData!.exclusive ? exclusiveText : sharedText,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ],
            )
          ],
        ),
        SizedBox(
          height: size.width * numD04,
        ),

        /// Title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD005,
                  ),
                  Text(
                    myContentData!.title.toCapitalized(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

                  /// Offers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageIcon(const AssetImage("${iconsPath}ic_view.png"),
                          color: (myContentData!.paidStatus == paidText &&
                                      widget.offerCount == 1) ||
                                  widget.offerCount == 0
                              ? Colors.grey
                              : colorThemePink,
                          size: size.width * numD053),
                      SizedBox(width: size.width * numD01),
                      Text(
                        '${widget.offerCount.toString()} ${widget.offerCount > 1 ? '${offerText}s' : offerText}',
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD029,
                            color: (myContentData!.paidStatus == paidText &&
                                        widget.offerCount == 1) ||
                                    widget.offerCount == 0
                                ? Colors.grey
                                : colorThemePink,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD01,
                  ),

                  /// Time Date
                  Row(
                    children: [
                      Image.asset(
                        "${iconsPath}ic_clock.png",
                        height: size.width * numD04,
                        color: colorTextFieldIcon,
                      ),
                      SizedBox(
                        width: size.width * numD01,
                      ),
                      Text(
                        DateFormat('HH:mm a')
                            .format(DateTime.parse(myContentData!.dateTime)),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD028,
                            color: colorHint,
                            fontWeight: FontWeight.normal),
                      ),
                      SizedBox(
                        width: size.width * numD02,
                      ),
                      Image.asset(
                        "${iconsPath}ic_yearly_calendar.png",
                        height: size.width * numD04,
                        color: colorTextFieldIcon,
                      ),
                      SizedBox(
                        width: size.width * numD01,
                      ),
                      Text(
                        DateFormat("dd MMM yyyy")
                            .format(DateTime.parse(myContentData!.dateTime)),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD028,
                            color: colorHint,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD02,
                  ),

                  /// Location
                  Row(
                    children: [
                      Image.asset(
                        "${iconsPath}ic_location.png",
                        height: size.width * numD045,
                        color: colorTextFieldIcon,
                      ),
                      SizedBox(
                        width: size.width * numD01,
                      ),
                      Expanded(
                        child: Text(
                          myContentData!.location,
                          overflow: TextOverflow.ellipsis,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD028,
                              color: colorHint,
                              fontWeight: FontWeight.normal),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: size.width * numD075,
            ),

            /// price
            Container(
              width: size.width * numD30,
              padding: EdgeInsets.symmetric(vertical: size.width * numD012),
              /*    padding: EdgeInsets.symmetric(
                  horizontal: myContentData!.paidStatus == unPaidText
                      ? size.width * numD06
                      : myContentData!.paidStatus == paidText &&
                              !myContentData!.isPaidStatusToHopper
                          ? size.width * numD04
                          : size.width * numD06,
                  vertical: size.width * numD01),*/
              decoration: BoxDecoration(
                  color: myContentData!.paidStatus == unPaidText
                      ? colorThemePink
                      : /*myContentData!.paidStatus == paidText &&
                              !myContentData!.isPaidStatusToHopper
                          ? colorThemePink
                          :*/
                      colorLightGrey,
                  borderRadius: BorderRadius.circular(size.width * numD03)),
              child: Column(
                children: [
                  Text(
                    myContentData!.paidStatus == unPaidText
                        ? 'Published'
                        : myContentData!.paidStatus == paidText &&
                                myContentData!.isPaidStatusToHopper
                            ? receivedText
                            : soldText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: myContentData!.paidStatus == unPaidText
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w600),
                    /*myContentData!.paidStatus == unPaidText
                            ? size.width * numD035
                            : myContentData!.paidStatus == paidText &&
                                    myContentData!.isPaidStatusToHopper
                                ? size.width * numD035
                                : size.width * numD03,*/
                    /*myContentData!.paidStatus == paidText &&
                                    myContentData!.isPaidStatusToHopper
                                ?
                                : Colors.white*/
                  ),
                  FittedBox(
                    child: Container(
                      margin: EdgeInsets.only(left: size.width * numD02,right: size.width * numD02,),
                      child: Text(
                        "$euroUniqueCode${amountFormat(myContentData!.amount)}",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD05,
                            color: myContentData!.paidStatus == unPaidText
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold),
                        /*myContentData!.paidStatus == paidText &&
                                        myContentData!.isPaidStatusToHopper
                                    ?
                        : Colors.white*/
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  /// Media House Offers
  Widget showMediaHouseWidget() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        var item = _mediaHouseList[index];
        return !_mediaHouseList[index].paidStatus
            ? InkWell(
                onTap: () {
                  debugPrint("tab::::::");
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => ManageTaskScreen(
                                roomId: item.roomId,
                                contentId: myContentData!.id,
                                type: 'content',
                                mediaHouseDetail: item,
                                contentMedia: showMediaWidget(),
                                contentHeader: headerWidget(),
                              )))
                      .then((value) => myContentDetailApi());
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * numD04,
                    vertical: size.width * numD035,
                  ),
                  decoration: BoxDecoration(
                      color: colorLightGrey,
                      borderRadius: BorderRadius.circular(size.width * numD05)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            /// Image
                            Container(
                              margin:
                                  EdgeInsets.only(right: size.width * numD03),
                              width: size.width * numD21,
                              height: size.width * numD21,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                              ),
                              child: Image.network(
                                item.mediaHouseImage,
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.all(size.width * numD01),
                                    child: Image.asset(
                                        "${dummyImagePath}news.png",
                                        fit: BoxFit.contain,
                                    ),
                                  );
                                },
                              ),
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Title
                                  Text(
                                    item.mediaHouseName,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD033,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),

                                  SizedBox(
                                    height: size.width * numD02,
                                  ),

                                  /// Time
                                  Row(
                                    children: [
                                      Image.asset(
                                        "${iconsPath}ic_clock.png",
                                        height: size.width * numD04,
                                        color: colorTextFieldIcon,
                                      ),
                                      SizedBox(
                                        width: size.width * numD01,
                                      ),
                                      Text(
                                        dateTimeFormatter(
                                            dateTime: item.createdAtTime,
                                            format: "hh:mm a",
                                            time: true),
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD03,
                                            color: colorHint,
                                            fontWeight: FontWeight.normal),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.width * numD02,
                                  ),

                                  /// date
                                  Row(
                                    children: [
                                      Image.asset(
                                        "${iconsPath}ic_yearly_calendar.png",
                                        height: size.width * numD04,
                                        color: colorTextFieldIcon,
                                      ),
                                      SizedBox(
                                        width: size.width * numD01,
                                      ),
                                      Expanded(
                                        child: Text(
                                          dateTimeFormatter(
                                              dateTime: item.createdAtTime,
                                              format: "dd.MM.yyyy"),
                                          overflow: TextOverflow.ellipsis,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD03,
                                              color: colorHint,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.width * numD02,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      /*    Container(
                        height: size.width * numD11,
                        width: size.width * numD27,
                        margin: EdgeInsets.only(top: size.width * numD02),
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD04,
                        ),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius:
                                BorderRadius.circular(size.width * numD03)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Offer Price",
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD03,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal),
                            ),
                            Text(
                              "$euroUniqueCode${item.initialOfferAmount}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD05,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),*/

                      Container(
                        width: size.width * numD30,
                        padding: EdgeInsets.symmetric(
                            //horizontal: size.width * numD06,
                            vertical: size.width * numD012),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius:
                                BorderRadius.circular(size.width * numD03)),
                        child: Column(
                          children: [
                            Text(
                              "Offered Price",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "$euroUniqueCode${amountFormat(item.initialOfferAmount)}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD05,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Container();
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: size.width * numD05,
        );
      },
      itemCount: _mediaHouseList.length,
    );
  }

  Widget playAudioWidget() {
    return Container(
      width: size.width,
      alignment: Alignment.center,
      padding: EdgeInsets.all(size.width * numD04),
      decoration: BoxDecoration(
        border: Border.all(color: colorGreyNew),
        borderRadius: BorderRadius.circular(size.width * numD06),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          /*AudioFileWaveforms(
            size: Size(size.width, size.width * numD20),
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

          */
          audioPlaying
              ? Lottie.asset(
                  "assets/lottieFiles/ripple.json",
                )
              : Container(),
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
                  : Icons.play_circle_fill_rounded,
              color: audioPlaying ? Colors.white : colorThemePink,
              size: size.width * numD15,
            ),
          ),
        ],
      ),
    );
  }


  /*Widget videoWidget(int index) {
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
          );}*/

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

  openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }
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

  Future playSound() async {
    debugPrint("PlayTheSound");

    await controller.startPlayer(
        finishMode: FinishMode.pause); // Start audio player
  }

  Future pauseSound() async {
    await controller.pausePlayer(); // Start audio player
  }

  String intToTimeLeft(int value) {
    int h, m, s;

    h = value ~/ 3600;

    m = ((value - h * 3600)) ~/ 60;

    s = value - (h * 3600) - (m * 60);

    String result = "$h:$m:$s";

    return result;
  }

  void initialController() {
    if (myContentData!.contentMediaList[_currentMediaIndex].mediaType ==
        "audio") {
    /*  initWaveData(contentImageUrl +
          myContentData!.contentMediaList[_currentMediaIndex].media);*/
        initWaveData(myContentData!.paidStatus == paidText?contentImageUrl + myContentData!.contentMediaList[_currentMediaIndex].media:
          myContentData!.contentMediaList[_currentMediaIndex].waterMark);
    } else if (myContentData!.contentMediaList[_currentMediaIndex].mediaType ==
        "video") {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(myContentData!.contentMediaList[_currentMediaIndex].media),
        ),
        autoPlay: false,
      );
    }
  }

  ///--------Apis Section------------

  void myContentDetailApi() {
    NetworkClass("$myContentDetailUrl${widget.contentId}", this,
            myContentDetailUrlRequest)
        .callRequestServiceHeader(true, "get", null);
  }

  /// Get content Media House Offer
  void getMediaOfferApi() {
    Map<String, String> map = {"image_id": widget.contentId};

    NetworkClass(
      getContentMediaHouseOfferUrl,
      this,
      getContentMediaHouseOfferReq,
    ).callRequestServiceHeader(true, "get", map);
  }

  callGetAllTransactionDetail() {
    Map<String, String> map = {
      //"content_id":widget.contentId,
      "content_id": myContentData!.id,
      "limit": '10',
      "offset": '0'
    };
    debugPrint('map value ==> $map');
    NetworkClass(
            getPublicationTransactionAPI, this, reqGetPublicationTransactionAPI)
        .callRequestServiceHeader(true, 'get', map);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        /// Get Content detail
        case myContentDetailUrlRequest:
          var data = jsonDecode(response);
          debugPrint("myContentError: $response");
          if (data["errors"] != null) {
            showSnackBar("Error", data["errors"]["msg"].toString(), Colors.red);
          } else {
            showSnackBar("Error", data.toString(), Colors.red);
          }
          break;

        /// Get content Media House Offer
        case getContentMediaHouseOfferReq:
          var data = jsonDecode(response);
          debugPrint("getContentMediaHouseOfferReq Error: $response");
          if (data["errors"] != null) {
            showSnackBar("Error", data["errors"]["msg"].toString(), Colors.red);
          } else {
            showSnackBar("Error", data.toString(), Colors.red);
          }
          break;

        case reqGetPublicationTransactionAPI:
          debugPrint(
              "reqGetPublicationTransactionAPI_ErrorResponse==> ${jsonDecode(response)}");
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case myContentDetailUrlRequest:
          var map = jsonDecode(response);
          debugPrint("myContentDetailResponse: $response");
          if (map["code"] == 200) {
            if (map["contentDetail"] != null) {
              myContentData = MyContentData.fromJson(map["contentDetail"]);
              setState(() {});
              getMediaOfferApi();
              initialController();
              Future.delayed(const Duration(microseconds: 500), () {
                callGetAllTransactionDetail();
              });
            }
          }
          break;
        /// Get content Media House Offer
        case getContentMediaHouseOfferReq:
          var data = jsonDecode(response);
          debugPrint("get ContentMediaHouseOfferReq Success: $data");
          var dataModel = data["response"] as List;
          _mediaHouseList.clear();
          _mediaHouseList.addAll(dataModel
              .map((e) => ManageTaskChatModel.fromJson(e ?? {}))
              .toList());
          for (var element in _mediaHouseList) {
            if (!element.paidStatus) {
              isMediaOffer = true;
            }
          }
          setState(() {});
          break;
        case reqGetPublicationTransactionAPI:
          debugPrint(
              "reqGetPublicationTransactionAPI_successResponse==> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var dataList = data['data'] as List;
          publicationCount = data['countofmediahouse'].toString() ?? '';
          publicationTransactionList = dataList
              .map((e) => EarningTransactionDetail.fromJson(e))
              .toList();
          setState(() {});
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

}
