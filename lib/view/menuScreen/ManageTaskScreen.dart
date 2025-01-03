import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonModel.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/PermissionHandler.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import '../cameraScreen/CameraScreen.dart';
import '../cameraScreen/imagePreview.dart';
import '../chatScreens/FullVideoView.dart';
import '../dashboard/Dashboard.dart';
import 'FAQScreen.dart';

class ManageTaskScreen extends StatefulWidget {
  final TaskDetailModel? taskDetail;
  final String roomId;
  final Widget? contentMedia;
  final Widget? contentHeader;
  final String? contentId;
  final ManageTaskChatModel? mediaHouseDetail;
  final String type;

  const ManageTaskScreen(
      {super.key,
      this.mediaHouseDetail,
      this.contentId,
      this.taskDetail,
      required this.roomId,
      required this.type,
      this.contentMedia,
      this.contentHeader});

  @override
  State<StatefulWidget> createState() {
    return ManageTaskScreenState();
  }
}

class ManageTaskScreenState extends State<ManageTaskScreen>
    implements NetworkResponse {
  late Size size;

  late IO.Socket socket;

  final String _senderId = sharedPreferences!.getString(hopperIdKey) ?? "";

  List<ManageTaskChatModel> chatList = [];
  var scrollController = ScrollController();

  String _chatId = "";
  bool _againUpload = false;
  String imageId = "";

  @override
  void initState() {
    debugPrint("Class name :::::: $runtimeType");
    super.initState();
    socketConnectionFunc();
    callGetManageTaskListingApi();
  }

  @override
  void dispose() {
    // _chatUpdateTimer?.cancel();
    socket.disconnect();
    socket.onDisconnect(
        (_) => socket.emit('room join', {"room_id": widget.roomId}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: CommonAppBar(
          elevation: 0,
          hideLeading: false,
          title: Text(
            widget.contentMedia != null && widget.contentHeader != null
                ? manageContentText
                : manageTaskText,
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
            Navigator.pop(context);
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
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      // oldDataWidget(),

                      /*Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: size.width * numD04),
                            padding: EdgeInsets.all(size.width * numD03),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.shade300, spreadRadius: 2)
                                ]),
                            child: Image.asset(
                              "${commonImagePath}rabbitLogo.png",
                              width: size.width * numD07,
                            ),
                          ),
                          SizedBox(
                            width: size.width * numD04,
                          ),
                          Expanded(
                              child: Container(
                                margin: EdgeInsets.only(top: size.width * numD06),
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD05,
                                    vertical: size.width * numD02),
                                width: size.width,
                                decoration: BoxDecoration(
                                    color: colorLightGrey,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(size.width * numD04),
                                        bottomLeft: Radius.circular(size.width * numD04),
                                        bottomRight:
                                        Radius.circular(size.width * numD04))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.width * numD04,
                                    ),
                                    Text(
                                      "Send the content for approval",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD035,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: size.width * numD04,
                                    ),
                                    SizedBox(
                                      height: size.width * numD13,
                                      width: size.width,
                                      child: commonElevatedButton(
                                          uploadText,
                                          size,
                                          commonButtonTextStyle(size),
                                          commonButtonStyle(size, colorThemePink), () {
                                      }),
                                    )
                                  ],
                                ),
                              ))
                        ],
                      )*/

                      widget.contentMedia != null &&
                              widget.contentHeader != null
                          ? contentDetailWidget()
                          : const SizedBox.shrink(),

                      widget.taskDetail != null
                          ? showTaskPriceWidget()
                          : const SizedBox.shrink(),

                      ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * numD04,
                            vertical: size.width * numD04,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var item = chatList[index];
                            if (item.messageType == "media") {
                              if (item.media!.type == "video") {
                                return rightVideoChatWidget(
                                    item.media!.thumbnail,
                                    item.media!.imageVideoUrl);
                              } else if (item.media!.type == "audio") {
                                return rightAudioChatWidget(
                                    item.media!.imageVideoUrl);
                              } else {
                                return rightImageChatWidget(
                                    item.media!.type == "video"
                                        ? item.media!.thumbnail
                                        : item.media!.imageVideoUrl);
                              }
                            } else if (item.messageType == "buy") {
                              return paymentReceivedWidget(item.amount);
                            } else if (item.messageType ==
                                "request_more_content") {
                              return moreContentReqWidget(item);
                            } else if (item.messageType == "contentupload") {
                              return moreContentUploadWidget(item);
                            } else if ([
                              "Mediahouse_final_offer",
                              "Mediahouse_initial_offer"
                            ].contains(item.messageType)) {
                              return mediaHouseOfferWidget(
                                  item,
                                  item.messageType ==
                                      "Mediahouse_initial_offer");
                            } else if (item.messageType ==
                                "hopper_counter_offer") {
                              return counterFieldWidget(item);
                            } else if (item.messageType == "rating_hopper") {
                              return ratingWidget(item);
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: size.width * numD01,
                            );
                          },
                          itemCount: chatList.length),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: (chatList.isEmpty || _againUpload) &&
                    widget.taskDetail != null,
                child: Container(
                  height: size.width * numD30,
                  color: colorLightGrey,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            left: size.width * numD05,
                            right: size.width * numD03,
                          ),
                          height: size.width * numD16,
                          child: commonElevatedButton(
                              galleryText,
                              size,
                              commonButtonTextStyle(size),
                              commonButtonStyle(size, Colors.black), () {
                            getImage(ImageSource.gallery);
                          }),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            left: size.width * numD03,
                            right: size.width * numD05,
                          ),
                          height: size.width * numD16,
                          child: commonElevatedButton(
                              cameraText,
                              size,
                              commonButtonTextStyle(size),
                              commonButtonStyle(size, colorThemePink), () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CameraScreen(
                                          picAgain: true,
                                        ))).then((value) {
                              if (value != null) {
                                debugPrint("value=====>$value");
                                List<CameraData> cameraData = value;

                                if (cameraData.first.mimeType == "video") {
                                  generateVideoThumbnail(cameraData.first.path);
                                } else if (cameraData.first.mimeType ==
                                    "audio") {
                                  Map<String, String> mediaMap = {
                                    "imageAndVideo": cameraData.first.path,
                                  };
                                  callUploadMediaApi(mediaMap, "audio");
                                } else {
                                  Map<String, String> mediaMap = {
                                    "imageAndVideo": cameraData.first.path,
                                  };
                                  callUploadMediaApi(mediaMap, "image");
                                }
                              }
                            });
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget contentDetailWidget() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * numD01),
          child: widget.contentMedia!,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
          child: widget.contentHeader!,
        ),
        SizedBox(
          height: size.width * numD03,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
          child: const Divider(
            color: colorGrey1,
          ),
        ),
      ],
    );
  }

  /// Rating
  Widget ratingWidget(ManageTaskChatModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* profilePicWidget(),*/
        Container(
          padding: EdgeInsets.all(
            size.width * numD01,
          ),
          height: size.width * numD09,
          width: size.width * numD09,
          decoration: const BoxDecoration(
              color: colorSwitchBack, shape: BoxShape.circle),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Image.asset(
              "${commonImagePath}rabbitLogo.png",
              height: size.width * numD09,
              width: size.width * numD09,
            ),
          ),
        ),
        SizedBox(
          width: size.width * numD04,
        ),
        Expanded(
            child: Container(
          margin: EdgeInsets.only(top: size.width * numD06),
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD05, vertical: size.width * numD02),
          width: size.width,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size.width * numD04),
                  bottomLeft: Radius.circular(size.width * numD04),
                  bottomRight: Radius.circular(size.width * numD04))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: size.width * numD04,
              ),
              Text(
                "Rate your experience with Reuters Media",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              RatingBar(
                ratingWidget: RatingWidget(
                  empty: Image.asset("${iconsPath}ic_empty_star.png"),
                  full: Image.asset("${iconsPath}ic_full_star.png"),
                  half: Image.asset("${iconsPath}ic_half_star.png"),
                ),
                onRatingUpdate: (value) {
                  item.rating = value;
                  setState(() {});
                },
                itemSize: size.width * numD09,
                itemCount: 5,
                ignoreGestures: item.isRatingGiven,
                initialRating: item.rating,
                allowHalfRating: true,
                itemPadding: EdgeInsets.only(left: size.width * numD03),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Write your review here",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              Stack(
                children: [
                  SizedBox(
                    height: size.width * numD35,
                    child: TextFormField(
                      controller: item.ratingReviewController,
                      cursorColor: colorTextFieldIcon,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      readOnly: item.isRatingGiven,
                      decoration: InputDecoration(
                        hintText:
                            "Please share your feedback on your experience"
                            " with the publication. Your feedback is very "
                            "important for improving your experience, "
                            "and our service. Thank you",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: size.width * numD035),
                        disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        contentPadding: EdgeInsets.only(
                            left: size.width * numD08,
                            right: size.width * numD03,
                            top: size.width * numD04,
                            bottom: size.width * numD04),
                        alignLabelWithHint: true,
                      ),
                      validator: checkRequiredValidator,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: size.width * numD04, left: size.width * numD01),
                    child: Icon(
                      Icons.sticky_note_2_outlined,
                      size: size.width * numD06,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              SizedBox(
                height: size.width * numD13,
                width: size.width,
                child: commonElevatedButton(
                    submitText,
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(
                      size,
                      item.isRatingGiven ? Colors.grey : colorThemePink,
                    ), () {
                  if (!item.isRatingGiven) {
                    if (item.ratingReviewController.text.isNotEmpty) {
                      var map = {
                        "chat_id": item.id,
                        "rating": item.rating,
                        "review": item.ratingReviewController.text,
                        //  "image_id": widget.taskDetail?.id ?? widget.contentId ?? "",
                        "image_id": widget.type == "content"
                            ? widget.contentId
                            : imageId,
                        //"type": ,
                      };
                      socketEmitFunc(
                          socketEvent: "rating", messageType: "", dataMap: map);
                      Timer(
                          const Duration(milliseconds: 50),
                          () => scrollController.jumpTo(
                              scrollController.position.maxScrollExtent));
                    } else {
                      showSnackBar(
                          "Required *",
                          "Please Enter some review for mediahouse",
                          Colors.red);
                    }
                  }
                }),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
            ],
          ),
        ))
      ],
    );
  }

  /// offer From Media House
  Widget mediaHouseOfferWidget(ManageTaskChatModel item, bool isMakeCounter) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        profilePicWidget(),
        SizedBox(
          width: size.width * numD04,
        ),
        Expanded(
            child: Container(
          margin: EdgeInsets.only(top: size.width * numD06),
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD05, vertical: size.width * numD02),
          width: size.width,
          decoration: BoxDecoration(
              color: colorLightGrey,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size.width * numD04),
                bottomLeft: Radius.circular(size.width * numD04),
                bottomRight: Radius.circular(size.width * numD04),
              )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * numD04,
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: "${item.mediaHouseName} Media has offered ",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD036,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text:
                  "$euroUniqueCode${isMakeCounter ? amountFormat(item.initialOfferAmount) : amountFormat(item.finalCounterAmount)} ",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD036,
                      color: colorThemePink,
                      fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: "to buy your content",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD036,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              ])),
              SizedBox(
                height: size.width * numD04,
              ),
              Row(
                children: [
                  Expanded(
                      child: SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        if (item.requestStatus.isEmpty &&
                            !item.isMakeCounterOffer) {
                          var map1 = {
                            "chat_id": item.id,
                            "status": false,
                          };

                          socketEmitFunc(
                              socketEvent: "reqstatus",
                              messageType: "",
                              dataMap: map1);

                          socketEmitFunc(
                            socketEvent: "chat message",
                            messageType: "reject_mediaHouse_offer",
                          );

                          socketEmitFunc(
                            socketEvent: "chat message",
                            messageType: "rating_hopper",
                          );

                          socketEmitFunc(
                            socketEvent: "chat message",
                            messageType: "rating_mediaHouse",
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: item.requestStatus.isEmpty &&
                                  !item.isMakeCounterOffer
                              ? Colors.black
                              : item.requestStatus == "false"
                                  ? Colors.grey
                                  : Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              side: (item.requestStatus == "false" ||
                                          item.requestStatus.isEmpty) &&
                                      !item.isMakeCounterOffer
                                  ? BorderSide.none
                                  : const BorderSide(
                                      color: Colors.black, width: 1))),
                      child: Text(
                        rejectText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD037,
                            color: (item.requestStatus == "false" ||
                                        item.requestStatus.isEmpty) &&
                                    !item.isMakeCounterOffer
                                ? Colors.white
                                : colorLightGreen,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
                  SizedBox(
                    width: size.width * numD04,
                  ),
                  Expanded(
                      child: SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        if (item.requestStatus.isEmpty &&
                            !item.isMakeCounterOffer) {
                          var map1 = {
                            "chat_id": item.id,
                            "status": true,
                          };

                          socketEmitFunc(
                              socketEvent: "reqstatus",
                              messageType: "",
                              dataMap: map1);

                          socketEmitFunc(
                              socketEvent: "chat message",
                              messageType: "accept_mediaHouse_offer",
                              dataMap: {
                                "amount": isMakeCounter
                                    ? item.initialOfferAmount
                                    : item.finalCounterAmount,
                                "image_id": widget.contentId!,
                                /* "image_id": imageId ??
                                    widget.contentId ??
                                    "",*/
                              });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: item.requestStatus.isEmpty &&
                                  !item.isMakeCounterOffer
                              ? colorThemePink
                              : item.requestStatus == "true"
                                  ? Colors.grey
                                  : Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              side: (item.requestStatus == "true" ||
                                          item.requestStatus.isEmpty) &&
                                      !item.isMakeCounterOffer
                                  ? BorderSide.none
                                  : const BorderSide(
                                      color: Colors.black, width: 1))),
                      child: Text(
                        acceptText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD037,
                            color: (item.requestStatus == "true" ||
                                        item.requestStatus.isEmpty) &&
                                    !item.isMakeCounterOffer
                                ? Colors.white
                                : colorLightGreen,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),

                  /* Expanded(
                          child: SizedBox(
                            height: size.width * numD13,
                            width: size.width,
                            child: ElevatedButton(
                              onPressed: () {
                                if(item.requestStatus.isEmpty){

                                  var map1 = {
                                    "chat_id" : item.id,
                                    "status" : true,
                                  };

                                  socketEmitFunc(
                                      socketEvent: "reqstatus",
                                      messageType: "",
                                      dataMap: map1
                                  );

                                  socketEmitFunc(
                                      socketEvent: "chat message",
                                      messageType: "contentupload",
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  item.requestStatus.isEmpty
                                      ? colorThemePink
                                      :item.requestStatus == "true"
                                      ?  Colors.grey
                                      :  Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                      side: item.requestStatus == "true" || item.requestStatus.isEmpty ? BorderSide.none : const BorderSide(
                                          color: colorGrey1, width: 2)
                                  )),
                              child: Text(
                                yesText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD04,
                                    color: item.requestStatus == "true" || item.requestStatus.isEmpty ? Colors.white : colorLightGreen,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )),*/
                ],
              ),
              SizedBox(
                height: size.width * numD05,
              ),
              Visibility(
                visible: isMakeCounter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(
                          color: colorGrey1,
                        )),
                        SizedBox(
                          width: size.width * 0.01,
                        ),
                        Text(
                          "or",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          width: size.width * 0.01,
                        ),
                        const Expanded(
                            child: Divider(
                          color: colorGrey1,
                        )),
                      ],
                    ),
                    SizedBox(
                      height: size.width * numD04,
                    ),
                    SizedBox(
                      height: size.width * numD13,
                      width: size.width,
                      child: commonElevatedButton(
                          "Make a Counter Offer",
                          size,
                          commonButtonTextStyle(size),
                          commonButtonStyle(
                              size,
                              item.requestStatus.isEmpty &&
                                      !item.isMakeCounterOffer
                                  ? colorThemePink
                                  : Colors.grey), () {
                        Timer(
                            const Duration(milliseconds: 50),
                            () => scrollController.jumpTo(
                                scrollController.position.maxScrollExtent));
                        if (item.requestStatus.isEmpty &&
                            !item.isMakeCounterOffer) {
                          socketEmitFunc(
                              socketEvent: "updatehide",
                              messageType: "",
                              dataMap: {
                                "chat_id": item.id,
                              });

                          socketEmitFunc(
                            socketEvent: "chat message",
                            messageType: "hopper_counter_offer",
                          );
                        }
                      }),
                    ),
                    SizedBox(
                      height: size.width * numD04,
                    ),
                    Text(
                      "You can make a counter offer only once",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            ],
          ),
        ))
      ],
    );
  }

  /// Counter Offer
  Widget counterFieldWidget(ManageTaskChatModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        presshopPicWidget(),
        SizedBox(
          width: size.width * numD04,
        ),
        Expanded(
            child: Container(
          margin: EdgeInsets.only(top: size.width * numD06),
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD05, vertical: size.width * numD02),
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size.width * numD04),
                  bottomLeft: Radius.circular(size.width * numD04),
                  bottomRight: Radius.circular(size.width * numD04))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: size.width * numD04,
              ),
              Text(
                "Make a counter offer to ${item.mediaHouseName} Media",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD036,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              TextFormField(
                controller: item.priceController,
                readOnly: item.finalCounterAmount.isNotEmpty,
                cursorColor: colorTextFieldIcon,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    counterText: "",
                    filled: false,
                    hintText: "Enter price here...",
                    hintStyle: TextStyle(
                      color: colorHint,
                      fontSize: size.width * numD035,
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.black)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.black)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.black)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.black)),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: size.width * numD02)),
                textAlignVertical: TextAlignVertical.center,
                validator: null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              SizedBox(
                height: size.width * numD13,
                width: size.width,
                child: commonElevatedButton(
                    submitText,
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(
                        size,
                        item.finalCounterAmount.isEmpty
                            ? colorThemePink
                            : Colors.grey), () {
                  var map = {
                    "finaloffer_price": item.priceController.text,
                    "content_id": widget.contentId,
                    "initial_offer_price": "",
                    "chat_id": item.id
                  };

                  socketEmitFunc(
                      socketEvent: "initialoffer",
                      messageType: "hopper_final_offer",
                      dataMap: map);
                  Timer(
                      const Duration(milliseconds: 50),
                      () => scrollController
                          .jumpTo(scrollController.position.maxScrollExtent));
                }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "${iconsPath}ic_tag.png",
                    height: size.width * numD06,
                  ),
                  SizedBox(
                    width: size.width * numD02,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FAQScreen(
                                    priceTipsSelected: true,
                                    type: 'price_tips')));
                      },
                      child: Text(
                        "Check price tips, and learnings",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                ],
              ),
              Text(
                "You can make a counter offer only once",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD034,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ))
      ],
    );
  }

  Widget showTaskPriceWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: size.width * numD04),
            //  padding: EdgeInsets.all(size.width * numD03),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                ]),
            child: ClipOval(
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * numD09,
                height: size.width * numD09,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(
            width: size.width * numD04,
          ),
          Expanded(
              child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: size.width * numD06),
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * numD03,
                    vertical: size.width * numD02),
                width: size.width,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(size.width * numD04),
                        bottomLeft: Radius.circular(size.width * numD04),
                        bottomRight: Radius.circular(size.width * numD04))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.width * numD04,
                    ),
                    Text(
                      "$taskText ${widget.taskDetail?.status}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: size.width * numD04,
                    ),
                    Text("${widget.taskDetail?.title}",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w600)),
                    SizedBox(
                      height: size.width * numD04,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                widget.taskDetail!.isNeedPhoto
                                    ? "$euroUniqueCode${widget.taskDetail?.photoPrice}"
                                    : "-",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD055,
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
                                height: size.width * numD03,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04,
                                    vertical: size.width * numD02),
                                decoration: BoxDecoration(
                                    color: colorLightGrey,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD02)),
                                child: Text(
                                  pictureText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD033,
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
                                widget.taskDetail!.isNeedInterview
                                    ?"$euroUniqueCode${amountFormat(widget.taskDetail?.interviewPrice)}"
                                    : "-",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD055,
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
                                height: size.width * numD03,
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD03,
                                    vertical: size.width * numD02),
                                decoration: BoxDecoration(
                                    color: colorLightGrey,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD02)),
                                child: Text(
                                  interviewText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD033,
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
                                widget.taskDetail!.isNeedVideo
                                    ? "$euroUniqueCode${widget.taskDetail?.videoPrice}"
                                    : "-",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD055,
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
                                height: size.width * numD03,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04,
                                    vertical: size.width * numD02),
                                decoration: BoxDecoration(
                                    color: colorLightGrey,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD02)),
                                child: Text(
                                  videoText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD033,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(size.width * numD03),
                  decoration: const BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: size.width * numD07,
                  ),
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }

  Widget rightVideoChatWidget(String thumbnail, String videoUrl) {
    debugPrint("----------------$videoUrl");
    debugPrint("-thumbnail---------------$thumbnail");
    return Container(
      margin: EdgeInsets.only(
          left: size.width * numD20, bottom: size.width * numD03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MediaViewScreen(
                              mediaFile: videoUrl,
                              type: MediaTypeEnum.video,
                            )));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * numD04),
                    child: Image.network(
                      thumbnail,
                      height: size.height / 3,
                      width: size.width / 1.7,
                      fit: BoxFit
                          .cover, /* errorBuilder: (BuildContext context,
                            Object exception, StackTrace? stackTrace) {
                      return Center(
                        child: Image.asset(
                          "${commonImagePath}rabbitLogo.png",
                          height: size.height / 3,
                          fit: BoxFit.contain,
                        ),
                      );
                    }*/
                    ),
                  ),
                ),
                Icon(
                  Icons.play_circle,
                  color: Colors.white,
                  size: size.width * numD07,
                )
              ],
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
          (avatarImageUrl + (sharedPreferences!.getString(avatarKey) ?? ""))
                  .isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(
                    size.width * numD01,
                  ),
                  decoration: const BoxDecoration(
                      color: colorLightGrey, shape: BoxShape.circle),
                  child: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        avatarImageUrl +
                            (sharedPreferences!.getString(avatarKey) ?? ""),
                        fit: BoxFit.cover,
                        height: size.width * numD09,
                        width: size.width * numD09,
                      )))
              : Container(
                  padding: EdgeInsets.all(
                    size.width * numD01,
                  ),
                  height: size.width * numD09,
                  width: size.width * numD09,
                  decoration: const BoxDecoration(
                      color: colorSwitchBack, shape: BoxShape.circle),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Image.asset("${commonImagePath}rabbitLogo.png",
                        fit: BoxFit.contain),
                  ),
                ),
        ],
      ),
    );
  }

  Widget rightAudioChatWidget(String audioUrl) {
    debugPrint("----------------$audioUrl");
    return Container(
      margin: EdgeInsets.only(left: size.width * numD20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MediaViewScreen(
                              mediaFile: audioUrl,
                              type: MediaTypeEnum.audio,
                            )));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * numD04),
                    child: Container(
                      color: colorLightGrey,
                      child: Image.asset(
                        "${iconsPath}ic_waves.png",
                        height: size.height / 3,
                        width: size.width / 1.7,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.play_circle,
                  color: Colors.white,
                  size: size.width * numD07,
                ),
                Positioned(
                    top: size.width * numD02,
                    right: size.width * numD02,
                    child: Icon(
                      Icons.mic,
                      color: Colors.grey.shade500,
                    ))
              ],
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
          (avatarImageUrl + (sharedPreferences!.getString(avatarKey) ?? ""))
                  .isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(
                    size.width * numD01,
                  ),
                  decoration: const BoxDecoration(
                      color: colorLightGrey, shape: BoxShape.circle),
                  child: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        avatarImageUrl +
                            (sharedPreferences!.getString(avatarKey) ?? ""),
                        fit: BoxFit.cover,
                        height: size.width * numD09,
                        width: size.width * numD09,
                      )))
              : Container(
                  padding: EdgeInsets.all(
                    size.width * numD01,
                  ),
                  height: size.width * numD09,
                  width: size.width * numD09,
                  decoration: const BoxDecoration(
                      color: colorSwitchBack, shape: BoxShape.circle),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Image.asset("${commonImagePath}rabbitLogo.png",
                        fit: BoxFit.contain),
                  ),
                ),
        ],
      ),
    );
  }

  Widget rightImageChatWidget(String imageUrl) {
    return InkWell(
      onTap: () {
        debugPrint(
            "imageTabed======${sharedPreferences!.getString(avatarKey)}");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImagePreview(imageURL: imageUrl)));
      },
      child: Container(
        margin: EdgeInsets.only(
            left: size.width * numD20, bottom: size.width * numD03),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(size.width * numD04),
                      child: Image.network(
                        imageUrl,
                        height: size.height / 3,
                        width: size.width / 1.7,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Center(
                            child: Image.asset(
                              "${commonImagePath}rabbitLogo.png",
                              height: size.height / 3,
                              width: size.width / 1.7,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      )),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                      ),
                      child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          child: Image.asset(
                            "${commonImagePath}watermark1.png",
                            height: size.height / 3,
                            width: size.width / 1.7,
                            fit: BoxFit.cover,
                          ))),
                ],
              ),
            ),
            SizedBox(
              width: size.width * numD02,
            ),
            sharedPreferences!.getString(avatarKey).toString().isNotEmpty
                ? Container(
                    padding: EdgeInsets.all(
                      size.width * numD01,
                    ),
                    decoration: const BoxDecoration(
                        color: colorLightGrey, shape: BoxShape.circle),
                    child: ClipOval(
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                            avatarImageUrl +
                                sharedPreferences!
                                    .getString(avatarKey)
                                    .toString(),
                            height: size.width * numD09,
                            width: size.width * numD09,
                            fit: BoxFit.cover, errorBuilder:
                                (BuildContext context, Object exception,
                                    StackTrace? stackTrace) {
                          return Center(
                            child: Image.asset(
                              "${commonImagePath}rabbitLogo.png",
                              height: size.width * numD09,
                              width: size.width * numD09,
                              fit: BoxFit.contain,
                            ),
                          );
                        })))
                : Container(
                    padding: EdgeInsets.all(
                      size.width * numD01,
                    ),
                    height: size.width * numD09,
                    width: size.width * numD09,
                    decoration: const BoxDecoration(
                        color: colorSwitchBack, shape: BoxShape.circle),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        height: size.width * numD09,
                        width: size.width * numD09,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget paymentReceivedWidget(String amount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*profilePicWidget(),*/
        Container(
          margin: EdgeInsets.only(top: size.width * numD04),
          padding: EdgeInsets.all(size.width * numD03),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
              ]),
          child: Image.asset(
            "${commonImagePath}rabbitLogo.png",
            width: size.width * numD07,
          ),
        ),
        SizedBox(
          width: size.width * numD04,
        ),
        Expanded(
            child: Container(
          margin: EdgeInsets.only(top: size.width * numD06),
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD05, vertical: size.width * numD02),
          width: size.width,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size.width * numD04),
                  bottomLeft: Radius.circular(size.width * numD04),
                  bottomRight: Radius.circular(size.width * numD04))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * numD04,
              ),
              Text(
                "Congrats, you’ve received £$amount from Reuters Media ",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              SizedBox(
                height: size.width * numD13,
                width: size.width,
                child: commonElevatedButton(
                    viewDetailsText,
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(size, colorThemePink),
                    () {}),
              )
            ],
          ),
        ))
      ],
    );
  }

  Widget profilePicWidget() {
    return Container(
        margin: EdgeInsets.only(top: size.width * numD04),
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
            ]),
        child: ClipOval(
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            widget.taskDetail?.mediaHouseImage ??
                widget.mediaHouseDetail?.mediaHouseImage ??
                "",
            width: size.width * numD09,
            height: size.width * numD09,
            fit: BoxFit.cover,
            errorBuilder: (ctx, obj, stace) {
              return Image.asset(
                "${dummyImagePath}news.png",
                width: size.width * numD09,
                height: size.width * numD09,
              );
            },
          ),
        ));
  }

  /// Presshope Profile
  Widget presshopPicWidget() {
    return Container(
        margin: EdgeInsets.only(top: size.width * numD04),
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
            ]),
        child: ClipOval(
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            "${commonImagePath}rabbitLogo.png",
            width: size.width * numD09,
            height: size.width * numD09,
          ),
        ));
  }

  /// Do you have additional pictures
  Widget moreContentReqWidget(ManageTaskChatModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        profilePicWidget(),
        SizedBox(
          width: size.width * numD04,
        ),
        Expanded(
            child: Container(
          margin: EdgeInsets.only(top: size.width * numD06),
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD05, vertical: size.width * numD02),
          width: size.width,
          decoration: BoxDecoration(
              color: colorLightGrey,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size.width * numD04),
                  bottomLeft: Radius.circular(size.width * numD04),
                  bottomRight: Radius.circular(size.width * numD04))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * numD04,
              ),
              Text(
                "Do you have additional pictures related to the task?",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              Row(
                children: [
                  Expanded(
                      child: SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        if (item.requestStatus.isEmpty) {
                          var map1 = {
                            "chat_id": item.id,
                            "status": false,
                          };

                          socketEmitFunc(
                              socketEvent: "reqstatus",
                              messageType: "",
                              dataMap: map1);

                          socketEmitFunc(
                            socketEvent: "chat message",
                            messageType: "NocontentUpload",
                          );

                          socketEmitFunc(
                            socketEvent: "chat message",
                            messageType: "rating_hopper",
                          );

                          socketEmitFunc(
                            socketEvent: "chat message",
                            messageType: "rating_mediaHouse",
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: item.requestStatus.isEmpty
                              ? Colors.black
                              : item.requestStatus == "false"
                                  ? Colors.grey
                                  : Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              side: item.requestStatus == "false" ||
                                      item.requestStatus.isEmpty
                                  ? BorderSide.none
                                  : const BorderSide(
                                      color: Colors.black, width: 1))),
                      child: Text(
                        noText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD04,
                            color: item.requestStatus == "false" ||
                                    item.requestStatus.isEmpty
                                ? Colors.white
                                : colorLightGreen,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
                  SizedBox(
                    width: size.width * numD04,
                  ),
                  Expanded(
                      child: SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        if (item.requestStatus.isEmpty) {
                          var map1 = {
                            "chat_id": item.id,
                            "status": true,
                          };

                          socketEmitFunc(
                              socketEvent: "reqstatus",
                              messageType: "",
                              dataMap: map1);

                          socketEmitFunc(
                            socketEvent: "chat message",
                            messageType: "contentupload",
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: item.requestStatus.isEmpty
                              ? colorThemePink
                              : item.requestStatus == "true"
                                  ? Colors.grey
                                  : Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              side: item.requestStatus == "true" ||
                                      item.requestStatus.isEmpty
                                  ? BorderSide.none
                                  : const BorderSide(
                                      color: Colors.black, width: 1))),
                      child: Text(
                        yesText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD04,
                            color: item.requestStatus == "true" ||
                                    item.requestStatus.isEmpty
                                ? Colors.white
                                : colorLightGreen,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),

                  /* Expanded(
                          child: SizedBox(
                            height: size.width * numD13,
                            width: size.width,
                            child: ElevatedButton(
                              onPressed: () {
                                if(item.requestStatus.isEmpty){

                                  var map1 = {
                                    "chat_id" : item.id,
                                    "status" : true,
                                  };

                                  socketEmitFunc(
                                      socketEvent: "reqstatus",
                                      messageType: "",
                                      dataMap: map1
                                  );

                                  socketEmitFunc(
                                      socketEvent: "chat message",
                                      messageType: "contentupload",
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  item.requestStatus.isEmpty
                                      ? colorThemePink
                                      :item.requestStatus == "true"
                                      ?  Colors.grey
                                      :  Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                      side: item.requestStatus == "true" || item.requestStatus.isEmpty ? BorderSide.none : const BorderSide(
                                          color: colorGrey1, width: 2)
                                  )),
                              child: Text(
                                yesText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD04,
                                    color: item.requestStatus == "true" || item.requestStatus.isEmpty ? Colors.white : colorLightGreen,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )),*/
                ],
              )
            ],
          ),
        ))
      ],
    );
  }

  Widget moreContentUploadWidget(ManageTaskChatModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        profilePicWidget(),
        SizedBox(
          width: size.width * numD04,
        ),
        Expanded(
            child: Container(
          margin: EdgeInsets.only(
              top: size.width * numD06, bottom: size.width * numD04),
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD05, vertical: size.width * numD02),
          width: size.width,
          decoration: BoxDecoration(
              color: colorLightGrey,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size.width * numD04),
                  bottomLeft: Radius.circular(size.width * numD04),
                  bottomRight: Radius.circular(size.width * numD04))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * numD04,
              ),
              Text(
                "Send the content for approval",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              SizedBox(
                height: size.width * numD13,
                width: size.width,
                child: commonElevatedButton(
                    uploadText,
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(
                        size,
                        item.requestStatus == "true"
                            ? Colors.grey
                            : colorThemePink), () {
                  if (item.requestStatus.isEmpty) {
                    _againUpload = true;
                    _chatId = item.id;
                    setState(() {});
                  }
                }),
              )
            ],
          ),
        ))
      ],
    );
  }

  Widget errorImage() {
    return Container(
      alignment: Alignment.center,
      child: Image.asset(
        '${commonImagePath}rabbitLogo.png',
        height: 150.0,
        width: size.width,
      ),
    );
  }

  /// Not In use But Important
  Widget oldDataWidget() {
    return Column(
      children: [
        SizedBox(
          height: size.width * numD08,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicWidget(),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top: size.width * numD06),
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * numD03,
                      vertical: size.width * numD02),
                  width: size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(size.width * numD04),
                          bottomLeft: Radius.circular(size.width * numD04),
                          bottomRight: Radius.circular(size.width * numD04))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.width * numD04,
                      ),
                      Text(
                        "$taskText ${widget.taskDetail?.status}",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: size.width * numD04,
                      ),
                      Text(
                          "Cate Blanchett and Rihanna while filming Oceans Eight",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w600)),
                      SizedBox(
                        height: size.width * numD04,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "${euroUniqueCode}150",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD055,
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
                                      horizontal: size.width * numD02,
                                      vertical: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD02)),
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
                                  "${euroUniqueCode}350",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD055,
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
                                      horizontal: size.width * numD02,
                                      vertical: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD02)),
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
                                  "${euroUniqueCode}500",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD055,
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
                                      horizontal: size.width * numD02,
                                      vertical: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD02)),
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
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(size.width * numD03),
                    decoration: const BoxDecoration(
                        color: Colors.black, shape: BoxShape.circle),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: size.width * numD07,
                    ),
                  ),
                ),
              ],
            ))
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(size.width * numD04),
                      child: Image.asset(
                        "${dummyImagePath}walk5.png",
                        height: size.height / 3,
                        width: size.width / 1.7,
                        fit: BoxFit.cover,
                      )),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                      ),
                      child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          child: Image.asset(
                            "${commonImagePath}watermark.png",
                            height: size.height / 3,
                            width: size.width / 1.7,
                            fit: BoxFit.cover,
                          )))
                ],
              ),
              SizedBox(
                width: size.width * numD02,
              ),
              ClipRRect(
                  borderRadius: BorderRadius.circular(size.width * numD08),
                  child: Image.asset(
                    "${dummyImagePath}avatar.png",
                    height: size.width * numD08,
                    width: size.width * numD08,
                    fit: BoxFit.cover,
                  ))
            ],
          ),
        ),
        SizedBox(
          height: size.width * numD05,
        ),

        /// Pending Request
        Row(
          children: [
            const Expanded(
                child: Divider(
              color: colorGrey1,
              thickness: 1,
            )),
            Text(
              "Pending reviews from Reuters",
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * numD035,
                  color: colorGrey2,
                  fontWeight: FontWeight.w600),
            ),
            const Expanded(
                child: Divider(
              color: colorGrey1,
              thickness: 1,
            )),
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),

        /// payment recicved
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: size.width * numD04),
              padding: EdgeInsets.all(size.width * numD03),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * numD07,
              ),
            ),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "Congrats, you’ve received £200 from Reuters Media ",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        viewDetailsText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink),
                        () {}),
                  )
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),

        /// More Content
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicWidget(),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: colorLightGrey,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "Do you have additional pictures related to the task?",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
                                  side: const BorderSide(
                                      color: colorGrey1, width: 2))),
                          child: Text(
                            noText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: colorLightGreen,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                      SizedBox(
                        width: size.width * numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colorThemePink,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                              )),
                          child: Text(
                            viewDetailsText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                    ],
                  )
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),

        /// send Approval
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*Container(
              margin: EdgeInsets.only(top: size.width * numD04),
              padding: EdgeInsets.all(size.width * numD03),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * numD07,
              ),
            ),*/
            profilePicWidget(),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: colorLightGrey,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "Send the content for approval",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        uploadText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink),
                        () {}),
                  )
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),

        /// Upload Video
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(size.width * numD04),
                      child: Image.asset(
                        "${dummyImagePath}walk6.png",
                        height: size.height / 3,
                        width: size.width / 1.7,
                        fit: BoxFit.cover,
                      )),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                      ),
                      child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          child: Image.asset(
                            "${commonImagePath}watermark.png",
                            height: size.height / 3,
                            width: size.width / 1.7,
                            fit: BoxFit.cover,
                          )))
                ],
              ),
              SizedBox(
                width: size.width * numD02,
              ),
              ClipRRect(
                  borderRadius: BorderRadius.circular(size.width * numD08),
                  child: Image.asset(
                    "${dummyImagePath}avatar.png",
                    height: size.width * numD08,
                    width: size.width * numD08,
                    fit: BoxFit.cover,
                  ))
            ],
          ),
        ),
        SizedBox(
          height: size.width * numD05,
        ),

        /// Pending Reviews
        Row(
          children: [
            const Expanded(
                child: Divider(
              color: colorGrey1,
              thickness: 1,
            )),
            Text(
              "Pending reviews from Reuters",
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * numD035,
                  color: colorGrey2,
                  fontWeight: FontWeight.w600),
            ),
            const Expanded(
                child: Divider(
              color: colorGrey1,
              thickness: 1,
            )),
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),

        /// Offers From Media House
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*   Container(
              margin: EdgeInsets.only(top: size.width * numD04),
              padding: EdgeInsets.all(size.width * numD01),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * numD04),
                child: Image.asset(
                  "${dummyImagePath}news.png",
                  height: size.width * numD09,
                ),
              ),
            ),*/
            profilePicWidget(),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: colorLightGrey,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: "Reuters Media has offered ",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: "${euroUniqueCode}150 ",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: colorThemePink,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: "to buy your content",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  ])),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
                                  side: const BorderSide(
                                      color: Colors.black, width: 1))),
                          child: Text(
                            rejectText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: colorLightGreen,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                      SizedBox(
                        width: size.width * numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colorThemePink,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                              )),
                          child: Text(
                            acceptText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD05,
                  ),
                  Row(
                    children: [
                      const Expanded(
                          child: Divider(
                        color: colorTextFieldIcon,
                        thickness: 1,
                      )),
                      Text(
                        "or",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      const Expanded(
                          child: Divider(
                        color: colorTextFieldIcon,
                        thickness: 1,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        "Make a Counter Offer",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink),
                        () {}),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "You can make a counter offer only once",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),

        /// Counter Field
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: size.width * numD04),
              padding: EdgeInsets.all(size.width * numD03),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * numD07,
              ),
            ),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "Make a counter offer to Reuters Media",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: TextFormField(
                      cursorColor: colorTextFieldIcon,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: false,
                        hintText: "Enter price here...",
                        hintStyle: TextStyle(
                            color: Colors.black, fontSize: size.width * numD04),
                        disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      validator: checkRequiredValidator,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        submitText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink),
                        () {}),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "${iconsPath}ic_tag.png",
                        height: size.width * numD06,
                      ),
                      SizedBox(
                        width: size.width * numD02,
                      ),
                      Expanded(
                        child: Text(
                          "Check price tips, and learnings",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "You can make a counter offer only once",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD031,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ))
          ],
        ),

        SizedBox(
          height: size.width * numD07,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*  Container(
              margin: EdgeInsets.only(top: size.width * numD04),
              padding: EdgeInsets.all(size.width * numD01),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * numD04),
                child: Image.asset(
                  "${dummyImagePath}news.png",
                  height: size.width * numD09,
                ),
              ),
            ),*/
            profilePicWidget(),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: colorLightGrey,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: "Reuters Media have increased their offered to ",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: "${euroUniqueCode}200 ",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: colorThemePink,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: "to buy your content",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  ])),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
                                  side: const BorderSide(
                                      color: Colors.black, width: 1))),
                          child: Text(
                            rejectText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: colorLightGreen,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                      SizedBox(
                        width: size.width * numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colorThemePink,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
                                  side: const BorderSide(
                                      color: Colors.black, width: 1))),
                          child: Text(
                            acceptText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: size.width * numD04),
              padding: EdgeInsets.all(size.width * numD03),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * numD07,
              ),
            ),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "Congrats, you’ve received £200 from Reuters Media ",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        viewDetailsText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink),
                        () {}),
                  )
                ],
              ),
            ))
          ],
        ),

        SizedBox(
          height: size.width * numD07,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(
                size.width * numD01,
              ),
              height: size.width * numD09,
              width: size.width * numD09,
              decoration: const BoxDecoration(
                  color: colorSwitchBack, shape: BoxShape.circle),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset(
                  "${commonImagePath}rabbitLogo.png",
                  height: size.width * numD09,
                  width: size.width * numD09,
                ),
              ),
            ),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "Rate your experience with Reuters Media",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  RatingBar(
                    ratingWidget: RatingWidget(
                      empty: Image.asset("${iconsPath}ic_empty_star.png"),
                      full: Image.asset("${iconsPath}ic_full_star.png"),
                      half: Image.asset("${iconsPath}ic_half_star.png"),
                    ),
                    onRatingUpdate: (value) {},
                    itemSize: size.width * numD09,
                    itemCount: 5,
                    initialRating: 0,
                    allowHalfRating: true,
                    itemPadding: EdgeInsets.only(left: size.width * numD03),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Write your review here",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Stack(
                    children: [
                      SizedBox(
                        height: size.width * numD35,
                        child: TextFormField(
                          cursorColor: colorTextFieldIcon,
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                "Please share your feedback on your experience with the publication. Your feedback is very important for improving your experience, and our service. Thank you",
                            hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: size.width * numD035),
                            disabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.03),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.03),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.03),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.03),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.03),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            contentPadding: EdgeInsets.only(
                                left: size.width * numD08,
                                right: size.width * numD03,
                                top: size.width * numD04,
                                bottom: size.width * numD04),
                            alignLabelWithHint: true,
                          ),
                          validator: checkRequiredValidator,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: size.width * numD04,
                            left: size.width * numD01),
                        child: Icon(
                          Icons.sticky_note_2_outlined,
                          size: size.width * numD06,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        submitText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink),
                        () {}),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                ],
              ),
            ))
          ],
        ),
      ],
    );
  }

  /// Get Image
  Future<void> getImage(ImageSource source) async {
    bool cameraValue = await cameraPermission();
    bool storageValue = await storagePermission();

    if (cameraValue && storageValue) {
      final ImagePicker picker = ImagePicker();

      if (source == ImageSource.gallery) {
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(type: FileType.media, allowMultiple: false);
        if (result != null && result.files.isNotEmpty) {
          if (result?.files.first.extension == 'jpeg' ||
              result?.files.first.extension == 'jpg' ||
              result?.files.first.extension == 'png') {
            debugPrint("fileType====> ${result?.files.first.extension}");
            debugPrint("imagePath======£> ${result.files.first.path!}");
            Map<String, String> mediaMap = {
              "imageAndVideo": result.files.first.path!,
            };
            callUploadMediaApi(mediaMap, "image");
          } else if (result?.files.first.extension == '.mp4' ||
              result?.files.first.extension == '.avi' ||
              result?.files.first.extension == '.mov' ||
              result?.files.first.extension == '.mkv') {
            debugPrint("fileType====> ${result?.files.first.extension}");
            debugPrint("videoPath======> ${result.files.first.path!}");
            generateVideoThumbnail(result.files.first.path!);
          } else {
            Map<String, String> mediaMap = {
              "imageAndVideo": result.files.first.path!,
            };
            callUploadMediaApi(mediaMap, "audio");
          }
        }
      }
    } else {
      debugPrint("Permission Denied");
    }
  }

  void generateVideoThumbnail(String path) async {
    final mimeType = lookupMimeType(path);
    debugPrint("mimeType====> : $mimeType");

    if (mimeType!.toLowerCase().contains("video")) {
      final thumnail = await VideoThumbnail.thumbnailFile(
        video: path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 1024,
        maxWidth: 1024,
        quality: 100,
      );

      Map<String, String> mediaMap = {
        "imageAndVideo": path,
        "videothubnail": thumnail!
      };
      callUploadMediaApi(mediaMap, "video");
    } else {
      debugPrint("hello=====>");
      Map<String, String> mediaMap = {
        "imageAndVideo": path,
      };
      callUploadMediaApi(mediaMap, "image");
    }
  }

  void socketEmitFunc({
    required String socketEvent,
    required String messageType,
    Map<String, dynamic>? dataMap,
    String mediaType = "",
  }) {
    debugPrint(":::: Inside Socket Emit :::::");

    Map<String, dynamic> map = {
      "message_type": messageType,
      "receiver_id": widget.taskDetail?.mediaHouseId ??
          widget.mediaHouseDetail?.mediaHouseId,
      "sender_id": _senderId,
      "message": "",
      "primary_room_id": "",
      "room_id": widget.roomId,
      "media_type": mediaType,
      "sender_type": "hopper",
    };

    if (dataMap != null) {
      map.addAll(dataMap);
    }

    debugPrint("Emit Socket : $map");
    debugPrint(" Socket=====>  : $socketEvent");

    socket.emit(socketEvent, map);

    callGetManageTaskListingApi();
  }

  void socketConnectionFunc() {
    debugPrint(":::: Inside Socket Func :::::");
    debugPrint("socketUrl:::::$socketUrl");

    socket = IO.io(
        /* "https://developers.promaticstechnologies.com:3005"*/
        socketUrl,
        OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
            //.disableAutoConnect() // disable auto-connection
            //.setExtraHeaders({'id': tokenId}) // optional
            .build());

    debugPrint("Socket Disconnect : ${socket.disconnected}");
    debugPrint("Socket Disconnect : ${widget.taskDetail?.mediaHouseId}");

    socket.connect();

    socket.onConnect((_) {
      socket.emit('room join', {"room_id": widget.roomId});
      // socket.emit("chat message", {"room_id" : widget.roomId ,"receiver_id" : widget.taskDetail.mediaHouseId, "message" : "Tested Socket" ,"sender_id": _senderId});
    });

    socket.on("chat message", (data) => callGetManageTaskListingApi());
    socket.on("getallchat", (data) => callGetManageTaskListingApi());
    socket.on("updatehide", (data) => callGetManageTaskListingApi());
    socket.on("media message", (data) => callGetManageTaskListingApi());
    socket.on("offer message", (data) => callGetManageTaskListingApi());
    socket.on("rating", (data) => callGetManageTaskListingApi());
    socket.on("room join", (data) => callGetManageTaskListingApi());
    socket.on("initialoffer", (data) => callGetManageTaskListingApi());
    socket.on("updateOffer", (data) => callGetManageTaskListingApi());
    socket.on("leave room", (data) => callGetManageTaskListingApi());

    socket.onError((data) => debugPrint("Error Socket ::: $data"));
  }

  /// Upload media
  void callUploadMediaApi(Map<String, String> mediaMap, String type) {
    Map<String, String> map = {"type": type, 'task_id': widget.taskDetail!.id};

    NetworkClass.fromNetworkClass(
            uploadTaskMediaUrl, this, uploadTaskMediaReq, map)
        .callMultipartServiceNew(true, "post", mediaMap);
  }

  /// Get Listing
  void callGetManageTaskListingApi() {
    Map<String, String> map = {
      "room_id": widget.roomId,
    };

    NetworkClass.fromNetworkClass(
            getMediaTaskChatListUrl, this, getMediaTaskChatListReq, map)
        .callRequestServiceHeader(false, "post", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    switch (requestCode) {
      /// Upload Media
      case uploadTaskMediaReq:
        var data = jsonDecode(response);
        debugPrint("uploadTaskMediaReq Error : $data");
        if (data["errors"] != null) {
          showSnackBar("Error", data["errors"]["msg"].toString(), Colors.red);
        } else {
          showSnackBar("Error", data.toString(), Colors.red);
        }
        break;

      /// Get Chat Listing
      case getMediaTaskChatListReq:
        var data = jsonDecode(response);
        debugPrint("getMediaTaskChatListReq Error : $data");
        if (data["errors"] != null) {
          showSnackBar("Error", data["errors"]["msg"].toString(), Colors.red);
        } else {
          showSnackBar("Error", data.toString(), Colors.red);
        }
        break;
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    switch (requestCode) {
      /// Upload Media
      case uploadTaskMediaReq:
        var data = jsonDecode(response);
        debugPrint("uploadTaskMediaReq Success : $data");
        imageId = data["data"] != null ? data["data"]["_id"] : "";
        debugPrint("imageID=========> $imageId");
        var mediaMap = {
          "attachment": data["image_name"] ?? "",
          "watermark": data["watermark"] ?? "",
          "attachment_name": data["attachme_name"] ?? "",
          "attachment_size": data["video_size"] ?? "",
          "thumbnail_url": data["videothubnail_path"] ?? "",
          "image_id": data["data"] != null ? data["data"]["_id"] : "",
          // "image_id": widget.taskDetail?.id ?? widget.contentId ?? "",
        };

        socketEmitFunc(
            socketEvent: "media message",
            messageType: "media",
            dataMap: mediaMap,
            mediaType: data["type"] ?? "image");

        if (_chatId.isNotEmpty) {
          var map = {
            "chat_id": _chatId,
            "status": true,
          };

          socketEmitFunc(
              socketEvent: "reqstatus", messageType: "", dataMap: map);

          _chatId = "";
          _againUpload = false;
        }
        break;

      /// Get Chat Listing
      case getMediaTaskChatListReq:
        var data = jsonDecode(response);
        debugPrint("getMediaTaskChatListReq Success::::: $data");
        var dataModel = data["response"] as List;
        chatList.clear();
        chatList =
            dataModel.map((e) => ManageTaskChatModel.fromJson(e)).toList();
        debugPrint("chatList length : ${chatList.length}");
        if (mounted) {
          setState(() {});
        }
        // _chatUpdateTimer = Timer(const Duration(seconds: 2),()=>callGetManageTaskListingApi());
        break;
    }
  }
}
