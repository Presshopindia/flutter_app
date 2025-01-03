import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:presshop/view/menuScreen/ContactUsScreen.dart';
import 'package:presshop/view/menuScreen/FAQScreen.dart';
import 'package:presshop/view/menuScreen/MyContentScreen.dart';
import 'package:presshop/view/menuScreen/MyDraftScreen.dart';
import 'package:presshop/view/publishContentScreen/ContentSubmittedScreen.dart';
import 'package:presshop/view/publishContentScreen/HashTagSearchScreen.dart';
import 'package:presshop/view/publishContentScreen/TutorialsScreen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../utils/networkOperations/NetworkClass.dart';
import '../cameraScreen/PreviewScreen.dart';
import 'AudioRecorderScreen.dart';

class PublishContentScreen extends StatefulWidget {
  PublishData? publishData;
  MyContentData? myContentData;
  bool hideDraft = false;

  PublishContentScreen(
      {super.key,
      required this.publishData,
      required this.myContentData,
      required this.hideDraft});

  @override
  State<StatefulWidget> createState() {
    return PublishContentScreenState();
  }
}

class PublishContentScreenState extends State<PublishContentScreen>
    implements NetworkResponse {
  var formKey = GlobalKey<FormState>();
  PlayerController controller = PlayerController(); // Initialise
  List<HashTagData> hashtagList = [];
  List<CategoryDataModel> categoryList = [];

  String selectedSellType = sharedText;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController timestampController = TextEditingController();
  TextEditingController hashtagController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String dropDownValue = "",
      audioPath = "",
      audioDuration = "",
      sharedPrice = "",
      exclusivePrice = "";
  CategoryDataModel? selectedCategory;
  bool audioPlaying = false, draftSelected = false;

  @override
  void initState() {
    debugPrint("Class Name : $runtimeType");
    debugPrint("hashtagList Name : ${hashtagList.length}");
    super.initState();
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
      categoryApi();
      callGetShareExclusivePrice();
    });
    addPreData();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          publishContentText,
          style: commonTextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSize,
              size: size),
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
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: size.width * numD06,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: SizedBox(
                    height: size.width * numD35,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(size.width * numD06),
                          child: Stack(
                            children: [
                              widget.hideDraft && widget.myContentData != null
                                  ? widget.myContentData!.contentMediaList.first
                                              .mediaType ==
                                          'audio'
                                      ? Container(
                                          padding: EdgeInsets.all(
                                              size.width * numD01),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black, width: 1),
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD06),
                                          ),
                                          child: Image.asset(
                                              "${iconsPath}ic_waves.png",
                                              width: size.width * numD30),
                                        )
                                      : widget.myContentData!.contentMediaList
                                                  .first.mediaType ==
                                              "doc"
                                          ? Container(
                                              padding: EdgeInsets.all(
                                                  size.width * numD01),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: colorGreyNew),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD06),
                                              ),
                                              child: Image.asset(
                                                  "${dummyImagePath}doc_black_icon.png",
                                                  width: size.width * numD30),
                                            )
                                          : widget
                                                      .myContentData!
                                                      .contentMediaList
                                                      .first
                                                      .mediaType ==
                                                  "pdf"
                                              ? Container(
                                                  padding: EdgeInsets.all(
                                                      size.width * numD01),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: colorGreyNew),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size.width *
                                                                numD06),
                                                  ),
                                                  child: Image.asset(
                                                      "${dummyImagePath}pngImage.png",
                                                      width:
                                                          size.width * numD30),
                                                )
                                              : Image.network(
                                                  widget
                                                              .myContentData!
                                                              .contentMediaList
                                                              .first
                                                              .mediaType ==
                                                          'video'
                                                      ? "$contentImageUrl${widget.myContentData!.contentMediaList.first.thumbNail}"
                                                      : "$contentImageUrl${widget.myContentData!.contentMediaList.first.thumbNail}",
                                                  width: size.width * numD30,
                                                  height: size.width * numD35,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context,
                                                      exception, stackTrace) {
                                                    return Padding(
                                                      padding: EdgeInsets.all(
                                                          size.width * numD07),
                                                      child: Image.asset(
                                                        "${commonImagePath}rabbitLogo.png",
                                                      ),
                                                    );
                                                  },
                                                )
                                  : widget.publishData != null
                                      ? (widget.publishData!.mimeType
                                              .contains("audio")
                                          ? Container(
                                              padding: EdgeInsets.all(
                                                  size.width * numD01),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: colorGreyNew),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD06),
                                              ),
                                              child: Image.asset(
                                                "${iconsPath}ic_waves.png",
                                                width: size.width * numD30,
                                                height: size.width * numD35,
                                              ),
                                            )
                                          : widget.publishData!.mimeType
                                                  .contains("doc")
                                              ? Container(
                                                  padding: EdgeInsets.all(
                                                      size.width * numD01),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: colorGreyNew),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size.width *
                                                                numD06),
                                                  ),
                                                  child: Image.asset(
                                                      "${dummyImagePath}doc_black_icon.png",
                                                      width:
                                                          size.width * numD30),
                                                )
                                              : widget.publishData!.mimeType
                                                      .contains("pdf")
                                                  ? Container(
                                                      padding: EdgeInsets.all(
                                                          size.width * numD01),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                colorGreyNew),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    size.width *
                                                                        numD06),
                                                      ),
                                                      child: Image.asset(
                                                          "${dummyImagePath}pngImage.png",
                                                          width: size.width *
                                                              numD30),
                                                    )
                                                  : Image.file(
                                                      File(widget
                                                              .publishData!
                                                              .mediaList
                                                              .first
                                                              .mimeType
                                                              .contains("video")
                                                          ? widget
                                                              .publishData!
                                                              .mediaList
                                                              .first
                                                              .thumbnail
                                                          : widget
                                                              .publishData!
                                                              .mediaList
                                                              .first
                                                              .mediaPath),
                                                      width:
                                                          size.width * numD30,
                                                      height:
                                                          size.width * numD35,
                                                      fit: BoxFit.cover,
                                                    ))
                                      : Container(),
                              widget.publishData != null
                                  ? (!widget
                                          .publishData!.mediaList.first.mimeType
                                          .contains("audio")
                                      ? Positioned(
                                          top: 0,
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              child: Image.asset(
                                                "${commonImagePath}watermark1.png",
                                                width: size.width * numD30,
                                                height: size.width * numD35,
                                                fit: BoxFit.cover,
                                              )),
                                        )
                                      : Container())
                                  : Container(),
                              widget.hideDraft && widget.myContentData != null
                                  ? Positioned(
                                      right: size.width * numD02,
                                      top: size.width * numD02,
                                      child: Container(
                                          width: size.width * numD06,
                                          height: size.width * numD06,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width * numD01,
                                              vertical: size.width * 0.002),
                                          decoration: BoxDecoration(
                                              color: colorLightGreen
                                                  .withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD015)),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: widget
                                                                .myContentData!
                                                                .contentMediaList
                                                                .first
                                                                .mediaType ==
                                                            "video" ||
                                                        widget
                                                                .myContentData!
                                                                .contentMediaList
                                                                .first
                                                                .mediaType ==
                                                            "audio"
                                                    ? 0
                                                    : size.width * 0.005,
                                                vertical: widget
                                                            .myContentData!
                                                            .contentMediaList
                                                            .first
                                                            .mediaType ==
                                                        "video"
                                                    ? size.width * 0.005
                                                    : widget
                                                                .myContentData!
                                                                .contentMediaList
                                                                .first
                                                                .mediaType ==
                                                            "audio"
                                                        ? size.width * 0.009
                                                        : size.width * 0.01),
                                            child: Image.asset(
                                              widget
                                                          .myContentData!
                                                          .contentMediaList
                                                          .first
                                                          .mediaType ==
                                                      "image"
                                                  ? "${iconsPath}ic_camera_publish.png"
                                                  : widget
                                                              .myContentData!
                                                              .contentMediaList
                                                              .first
                                                              .mediaType ==
                                                          "video"
                                                      ? "${iconsPath}ic_v_cam.png"
                                                      : widget
                                                                  .myContentData!
                                                                  .contentMediaList
                                                                  .first
                                                                  .mediaType ==
                                                              "audio"
                                                          ? "${iconsPath}ic_mic.png"
                                                          : "${iconsPath}doc_icon.png",
                                              color: Colors.white,
                                              height: widget
                                                          .myContentData!
                                                          .contentMediaList
                                                          .first
                                                          .mediaType ==
                                                      "video"
                                                  ? size.width * numD09
                                                  : widget
                                                              .myContentData!
                                                              .contentMediaList
                                                              .first
                                                              .mediaType ==
                                                          "image"
                                                      ? size.width * numD05
                                                      : size.width * numD08,
                                            ),
                                          )),
                                    )
                                  : const SizedBox.shrink(),
                              /*widget.publishData != null
                                  ? Positioned(
                                      right: size.width * numD02,
                                      top: size.width * numD02,
                                      child: Container(
                                          width: size.width * numD06,
                                          height: size.width * numD06,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width * numD01,
                                              vertical: size.width * 0.002),
                                          decoration: BoxDecoration(
                                              color: colorLightGreen
                                                  .withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD015)),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: widget
                                                                .publishData!
                                                                .mediaList
                                                                .first
                                                                .mimeType ==
                                                            "video" ||
                                                        widget
                                                                .publishData!
                                                                .mediaList
                                                                .first
                                                                .mimeType ==
                                                            "audio"
                                                    ? 0
                                                    : size.width * 0.005,
                                                vertical: widget
                                                            .publishData!
                                                            .mediaList
                                                            .first
                                                            .mimeType ==
                                                        "video"
                                                    ? size.width * 0.005
                                                    : widget
                                                                .publishData!
                                                                .mediaList
                                                                .first
                                                                .mimeType ==
                                                            "audio"
                                                        ? size.width * 0.009
                                                        : size.width * 0.01),
                                            child: Image.asset(
                                              widget.publishData!.mediaList
                                                          .first.mimeType ==
                                                      "image"
                                                  ? "${iconsPath}ic_camera_publish.png"
                                                  : widget
                                                              .publishData!
                                                              .mediaList
                                                              .first
                                                              .mimeType ==
                                                          "video"
                                                      ? "${iconsPath}ic_v_cam.png"
                                                      : widget
                                                                  .publishData!
                                                                  .mediaList
                                                                  .first
                                                                  .mimeType ==
                                                              "audio"
                                                          ? "${iconsPath}ic_mic.png"
                                                          : "${iconsPath}doc_icon.png",
                                              color: Colors.white,
                                              height: widget
                                                          .publishData!
                                                          .mediaList
                                                          .first
                                                          .mimeType ==
                                                      "video"
                                                  ? size.width * numD09
                                                  : widget
                                                              .publishData!
                                                              .mediaList
                                                              .first
                                                              .mimeType ==
                                                          "image"
                                                      ? size.width * numD05
                                                      : size.width * numD08,
                                            ),
                                          )),
                                    )
                                  : const SizedBox.shrink(),*/
                              /*   widget.publishData != null
                                  ? Positioned.fill(
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width * numD01,
                                              vertical: size.width * 0.002),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD015)),
                                          child: GridView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 4,
                                              ),
                                              itemCount: widget.publishData!
                                                  .mediaList.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Padding(
                                                  padding: EdgeInsets.all(
                                                      size.width * numD015),
                                                  child: Image.asset(
                                                    widget.publishData!
                                                                .mediaList[index]
                                                                .mimeType ==
                                                            "image"
                                                        ?"${iconsPath}ic_camera_publish.png"
                                                        :widget.publishData!.mediaList[index]
                                                                    .mimeType ==
                                                                "video"
                                                            ? "${iconsPath}ic_v_cam.png"
                                                            : widget.publishData!
                                                                        .mediaList[
                                                                            index]
                                                                        .mimeType ==
                                                                    "audio"
                                                                ? "${iconsPath}ic_mic.png"
                                                                : "${iconsPath}doc_icon.png",
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    height: widget
                                                                .publishData!
                                                                .mediaList[
                                                                    index]
                                                                .mimeType ==
                                                            "video"
                                                        ? size.width * numD09
                                                        : widget
                                                                    .publishData!
                                                                    .mediaList[
                                                                        index]
                                                                    .mimeType ==
                                                                "image"
                                                            ? size.width *
                                                                numD05
                                                            : size.width *
                                                                numD08,
                                                  ),
                                                );
                                              })),
                                    )
                                  : const SizedBox.shrink(),*/

                              ///aditya
                              widget.publishData != null
                                  ? Padding(
                                      padding:
                                          EdgeInsets.all(size.width * numD018),
                                      child: Image.asset(
                                        widget.publishData!.mediaList[0]
                                                    .mimeType ==
                                                "image"
                                            ? "${iconsPath}ic_camera_publish.png"
                                            : widget.publishData!.mediaList[0]
                                                        .mimeType ==
                                                    "video"
                                                ? "${iconsPath}ic_v_cam.png"
                                                : widget
                                                            .publishData!
                                                            .mediaList[0]
                                                            .mimeType ==
                                                        "audio"
                                                    ? "${iconsPath}ic_mic.png"
                                                    : "${iconsPath}doc_icon.png",
                                        color: Colors.white.withOpacity(0.8),
                                        height: widget.publishData!.mediaList[0]
                                                    .mimeType ==
                                                "video"
                                            ? size.width * numD09
                                            : widget.publishData!.mediaList[0]
                                                        .mimeType ==
                                                    "image"
                                                ? size.width * numD05
                                                : size.width * numD08,
                                      ),
                                    )
                                  : Container(),
                              widget.publishData != null
                                  ? Positioned(
                                      bottom: size.width * numD03,
                                      right: size.width * numD04,
                                      child: Text(
                                        widget.publishData!.mediaList.length > 1
                                            ? "+${widget.publishData!.mediaList.length}"
                                            : "${widget.publishData!.mediaList.length}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * numD035,
                                            fontWeight: FontWeight.w700),
                                      ))
                                  : Container()
                            ],
                          ),
                        ),
                        SizedBox(
                          width: size.width * numD03,
                        ),
                        Expanded(
                          child: SizedBox(
                            height: size.height,
                            child: TextFormField(
                              controller: descriptionController,
                              maxLines: 100,
                              keyboardType: TextInputType.multiline,
                              cursorColor: Colors.black,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD03,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                              decoration: InputDecoration(
                                hintText: publishContentHintText,
                                hintStyle: TextStyle(
                                    color: colorHint,
                                    fontWeight: FontWeight.normal,
                                    fontSize: size.width * numD03),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black)),
                              ),
                              // validator: checkRequiredValidator,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: size.width * numD02,
                ),
                const Divider(
                  color: colorLightGrey,
                  thickness: 1,
                ),
                SizedBox(
                  height: size.width * numD04,
                ),

                /// Speak
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Row(
                    children: [
                      SizedBox(
                        width: size.width * numD40,
                        child: Text(
                          speakText.toUpperCase(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) =>
                                      const AudioRecorderScreen()))
                              .then((value) {
                            if (value != null) {
                              audioPath = value[0].toString();
                              audioDuration = value[1].toString();
                              setState(() {});
                              debugPrint("AudioPath:$audioPath");
                              debugPrint("audioDuration:$audioDuration");
                              initWaveData();
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: size.width * numD03,
                              horizontal: size.width * numD05),
                          decoration: BoxDecoration(
                              color: colorLightGrey,
                              borderRadius:
                                  BorderRadius.circular(size.width * numD06)),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: audioPath.isNotEmpty
                                    ? () {
                                        if (audioPlaying) {
                                          pauseSound();
                                        } else {
                                          playSound();
                                        }
                                        audioPlaying = !audioPlaying;
                                        setState(() {});
                                      }
                                    : null,
                                child: SizedBox(
                                  height: size.width * numD06,
                                  child: audioPath.isEmpty
                                      ? Image.asset(
                                          "${iconsPath}ic_mic.png",
                                          width: size.width * numD04,
                                          height: size.width * numD04,
                                        )
                                      : Icon(
                                          audioPlaying
                                              ? Icons.pause_circle
                                              : Icons.play_circle,
                                          color: Colors.black,
                                          size: size.width * numD06,
                                        ),
                                ),
                              ),
                              audioPath.isNotEmpty
                                  ? Expanded(
                                      child: AudioFileWaveforms(
                                        size: Size(
                                            size.width, size.width * numD04),
                                        playerController: controller,
                                        enableSeekGesture: false,
                                        animationCurve: Curves.bounceIn,
                                        waveformType: WaveformType.long,
                                        continuousWaveform: true,
                                        playerWaveStyle: PlayerWaveStyle(
                                          fixedWaveColor: Colors.black,
                                          liveWaveColor: colorThemePink,
                                          spacing: 6,
                                          liveWaveGradient: ui.Gradient.linear(
                                            const Offset(70, 50),
                                            Offset(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                0),
                                            [Colors.green, Colors.white70],
                                          ),
                                          fixedWaveGradient: ui.Gradient.linear(
                                            const Offset(70, 50),
                                            Offset(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                0),
                                            [Colors.green, Colors.white70],
                                          ),
                                          seekLineColor: colorThemePink,
                                          seekLineThickness: 2,
                                          showSeekLine: true,
                                          showBottom: true,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * numD02),
                                      child: Text(
                                        "00:00",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD03,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD04,
                ),
                const Divider(
                  color: colorLightGrey,
                  thickness: 1,
                ),
                SizedBox(
                  height: size.width * numD04,
                ),

                /// Location
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Row(
                    children: [
                      SizedBox(
                        width: size.width * numD40,
                        child: Text(
                          locationText.toUpperCase(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                          child: TextFormField(
                        controller: locationController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        readOnly: true,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD028,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: colorLightGrey,
                            hintText: "",
                            hintStyle: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: colorHint,
                                fontWeight: FontWeight.normal),
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                  left: size.width * numD04,
                                  right: size.width * numD02),
                              child: const ImageIcon(
                                  AssetImage("${iconsPath}ic_location.png")),
                            ),
                            prefixIconConstraints: BoxConstraints(
                              maxHeight: size.width * numD05,
                            ),
                            prefixIconColor: colorTextFieldIcon,
                            disabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            contentPadding:
                                EdgeInsets.only(left: size.width * numD06)),
                        //  validator: checkRequiredValidator,
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD02,
                ),
                const Divider(
                  color: colorLightGrey,
                  thickness: 1,
                ),
                SizedBox(
                  height: size.width * numD04,
                ),

                /// Time Stamp
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Row(
                    children: [
                      SizedBox(
                        width: size.width * numD40,
                        child: Text(
                          timestampText.toUpperCase(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                          child: TextFormField(
                        readOnly: true,
                        controller: timestampController,
                        style: commonTextStyle(
                            fontSize: size.width * numD028,
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            size: size),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: colorLightGrey,
                            hintText: "Grenfell Tower, London",
                            hintStyle: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: colorHint,
                                fontWeight: FontWeight.normal),
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                  left: size.width * numD04,
                                  right: size.width * numD02),
                              child: const ImageIcon(
                                  AssetImage("${iconsPath}ic_clock.png")),
                            ),
                            prefixIconConstraints: BoxConstraints(
                              maxHeight: size.width * numD04,
                            ),
                            prefixIconColor: colorTextFieldIcon,
                            disabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            contentPadding:
                                EdgeInsets.only(left: size.width * numD06)),
                        //  validator: checkRequiredValidator,
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD02,
                ),
                const Divider(
                  color: colorLightGrey,
                  thickness: 1,
                ),
                SizedBox(
                  height: size.width * numD02,
                ),

                /// hash Tags
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: size.width * numD40,
                        margin: EdgeInsets.only(top: size.width * numD04),
                        child: Text(
                          "${hashtagText.toUpperCase()}S",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children:
                                  List.generate(hashtagList.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      right: index < (hashtagList.length - 1)
                                          ? size.width * numD02
                                          : 0),
                                  child: Chip(
                                    label: Text(
                                      "#${hashtagList[index].name}",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    backgroundColor: colorLightGrey,
                                  ),
                                );
                              }),
                            ),
                            TextFormField(
                              controller: hashtagController,
                              readOnly: true,
                              autofocus: false,
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            HashTagSearchScreen(
                                              country: widget.publishData !=
                                                      null
                                                  ? widget.publishData!.country
                                                  : '',
                                              tagData: hashtagList,
                                              countryTagId:
                                                  hashtagList.isNotEmpty
                                                      ? hashtagList.first.id
                                                      : "",
                                            )))
                                    .then((value) {
                                  if (value != null) {
                                    // hashtagList.clear();
                                    hashtagList
                                        .addAll(value as List<HashTagData>);
                                    hashtagController.text = "Add more";
                                    setState(() {});
                                  }
                                });
                              },
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD03,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                              decoration: InputDecoration(
                                  hintText: "#Add more hashtags",
                                  hintStyle: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: colorHint,
                                      fontWeight: FontWeight.normal),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD08),
                                      borderSide: const BorderSide(
                                          width: 1,
                                          color: colorGoogleButtonBorder)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD08),
                                      borderSide: const BorderSide(
                                          width: 1,
                                          color: colorGoogleButtonBorder)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD08),
                                      borderSide: const BorderSide(
                                          width: 1,
                                          color: colorGoogleButtonBorder)),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(size.width * numD08),
                                      borderSide: const BorderSide(width: 1, color: colorGoogleButtonBorder)),
                                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(size.width * numD08), borderSide: const BorderSide(width: 1, color: colorGoogleButtonBorder)),
                                  contentPadding: EdgeInsets.only(left: size.width * numD06)),
                              /* validator: (value) {
                                if (hashtagList.isEmpty) {
                                  return requiredText;
                                }
                                return null;
                              },*/
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD02,
                ),
                const Divider(
                  color: colorLightGrey,
                  thickness: 1,
                ),
                SizedBox(
                  height: size.width * numD04,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Row(
                    children: [
                      Text(
                        categoryText.toUpperCase(),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      selectedCategory != null
                          ? InkWell(
                              onTap: () {
                                int selectedPos = categoryList
                                    .indexWhere((element) => element.selected);
                                if (selectedPos > 0) {
                                  categoryList.swap(0, selectedPos);
                                }
                                //  showCategoryDialogBox(context, size);
                                showCategoryBottomSheet(size);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    selectedCategory!.name.toCapitalized(),
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD03,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.black,
                                    size: size.width * numD06,
                                  )
                                ],
                              ),
                            )
                          : Container(),

                      /*selectedCategory != null
                          ? DropdownButton<CategoryData>(
                              underline: Container(),
                              value: selectedCategory,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD03,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value!;
                                  dropDownValue = value.name;
                                });
                              },
                              items: categoryList
                                  .map<DropdownMenuItem<CategoryData>>(
                                      (CategoryData e) {
                                return DropdownMenuItem<CategoryData>(
                                    value: e, child: Text(e.name));
                              }).toList(),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.black,
                                size: size.width * numD06,
                              ),
                            )
                          : Container()*/
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD02,
                ),
                const Divider(
                  color: colorLightGrey,
                  thickness: 1,
                ),
                SizedBox(
                  height: size.width * numD04,
                ),
                Text(
                  chooseHowSellText.toUpperCase(),
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD04,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: size.width * numD06,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD12),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            selectedSellType = sharedText;
                            setState(() {});
                          },
                          child: Container(
                            height: size.width * numD40,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: selectedSellType == sharedText
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1.5),
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04)),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      color: selectedSellType == sharedText
                                          ? colorThemePink
                                          : Colors.white,
                                      alignment: Alignment.topCenter,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        width: size.width * numD35,
                                        height: size.width * numD08,
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.width * numD017),
                                        decoration: BoxDecoration(
                                          color: selectedSellType == sharedText
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                        child: Text(
                                          recommendedPriceText,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: size.width * numD026,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.width * numD04,
                                      ),
                                      Image.asset(
                                        "${iconsPath}ic_share.png",
                                        height: size.width * numD07,
                                      )
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          sharedText,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD04,
                                              color:
                                                  selectedSellType == sharedText
                                                      ? Colors.white
                                                      : Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: size.width * numD01,
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: size.width * numD35,
                                          height: size.width * numD08,
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.width * numD017),
                                          decoration: BoxDecoration(
                                            color:
                                                selectedSellType == sharedText
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                          child: Text(
                                            sharedPrice,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: size.width * numD03,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * numD12,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            selectedSellType = exclusiveText;
                            setState(() {});
                          },
                          child: Container(
                            height: size.width * numD40,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: selectedSellType == exclusiveText
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1.5),
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04)),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      color: selectedSellType == exclusiveText
                                          ? colorThemePink
                                          : Colors.white,
                                      alignment: Alignment.topCenter,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        width: size.width * numD35,
                                        height: size.width * numD08,
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.width * numD017),
                                        decoration: BoxDecoration(
                                          color:
                                              selectedSellType == exclusiveText
                                                  ? Colors.black
                                                  : Colors.white,
                                        ),
                                        child: Text(
                                          recommendedPriceText,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: size.width * numD026,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.width * numD04,
                                      ),
                                      Image.asset(
                                        "${iconsPath}ic_exclusive.png",
                                        height: size.width * numD07,
                                      )
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          exclusiveText,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD04,
                                              color: selectedSellType ==
                                                      exclusiveText
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: size.width * numD01,
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: size.width * numD35,
                                          height: size.width * numD08,
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.width * numD017),
                                          decoration: BoxDecoration(
                                            color: selectedSellType ==
                                                    exclusiveText
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                          child: Text(
                                            exclusivePrice,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: size.width * numD03,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD06,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Text(
                    selectedSellType == exclusiveText
                        ? publishContentSellNote2Text
                        : publishContentSellNote1Text,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD03,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                    textAlign: TextAlign.justify,
                  ),
                ),
                SizedBox(
                  height: size.width * numD06,
                ),
                Text(
                  enterYourPriceText.toUpperCase(),
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: size.width * numD04,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD09),
                  child: TextFormField(
                    controller: priceController,
                    textAlign: TextAlign.center,
                    cursorColor: Colors.black,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: false),
                    inputFormatters: [
                      CurrencyTextInputFormatter(
                        decimalDigits: 0,
                        symbol: euroUniqueCode,
                      )
                    ],
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD06,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                    decoration: InputDecoration(
                      hintText: "     ${euroUniqueCode}000",
                      hintStyle: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD06,
                          color: colorHint,
                          fontWeight: FontWeight.normal),
                      prefixIconColor: colorTextFieldIcon,
                      disabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black)),
                      errorBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black)),
                    ),
                    //validator: checkRequiredValidator,
                  ),
                ),

                SizedBox(
                  height: size.width * numD04,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "${iconsPath}ic_tag.png",
                        height: size.width * numD045,
                      ),
                      SizedBox(width: size.width * numD01),
                      Text(
                        "Check",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      SizedBox(width: size.width * numD005),
                      TextButton(
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0)),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => FAQScreen(
                                    priceTipsSelected: true,
                                    type: 'price_tips',
                                  )));
                        },
                        child: Text(
                          "price tips",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: colorThemePink,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: size.width * numD002),
                      Text(
                        "and",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      SizedBox(width: size.width * numD004),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const TutorialsScreen()));
                        },
                        child: Text(
                          " tutorials",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: colorThemePink,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD06),
                  child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD03,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                          children: [
                            const TextSpan(
                              text: "$publishContentFooter1Text ",
                            ),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FAQScreen(
                                                  priceTipsSelected: true,
                                                  type: '',
                                                )));
                                  },
                                  child: Text(priceTipsText.toLowerCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: colorThemePink,
                                          fontWeight: FontWeight.w500)),
                                )),
                            const TextSpan(
                              text: " $publishContentFooter2Text ",
                            ),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const TutorialsScreen()));
                                  },
                                  child: Text(tutorialsText.toLowerCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: colorThemePink,
                                          fontWeight: FontWeight.w500)),
                                )),
                            const TextSpan(
                              text: " $publishContentFooter3Text ",
                            ),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ContactUsScreen()));
                                  },
                                  child: Text(contactText.toLowerCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: colorThemePink,
                                          fontWeight: FontWeight.w500)),
                                )),
                            const TextSpan(
                              text: publishContentFooter4Text,
                            ),
                          ])),
                ),
                SizedBox(
                  height: size.width * numD15,
                ),

                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD06),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      !widget.hideDraft
                          ? Expanded(
                              child: SizedBox(
                              height: size.width * numD15,
                              child: commonElevatedButton(
                                  "${saveText.toTitleCase()} ${draftText.toTitleCase()}",
                                  size,
                                  commonButtonTextStyle(size),
                                  commonButtonStyle(size, Colors.black), () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                draftSelected = true;
                                callUploadMediaApi();
                              }),
                            ))
                          : Container(),
                      SizedBox(
                        width: !widget.hideDraft ? size.width * numD04 : 0,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD15,
                        child: commonElevatedButton(
                            sellText.toTitleCase(),
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, colorThemePink), () {
                          draftSelected = false;

                          if (descriptionController.text.trim().isEmpty &&
                              audioPath.isEmpty) {
                            showSnackBar(
                                // "Error", "Description is required", Colors.red);
                                "Error",
                                "Description or speak is required",
                                Colors.red);
                          } else if (locationController.text.trim().isEmpty) {
                            showSnackBar(
                                "Error", "Location is required", Colors.red);
                          } else if (timestampController.text.trim().isEmpty) {
                            showSnackBar(
                                "Error", "TimeStamp is required", Colors.red);
                          }
                          /*else if (hashtagController.text.trim().isEmpty) {
                            showSnackBar(
                                "Error", "Hashtag are required", Colors.red);
                          } */
                          else if (priceController.text.trim().isEmpty ||
                              priceController.text == '0') {
                            showSnackBar(
                                "Error", "Price is required", Colors.red);
                          } else {
                            callUploadMediaApi();
                          }
                        }),
                      )),
                    ],
                  ),
                ),

                SizedBox(
                  height: size.width * numD04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showCategoryBottomSheet(Size size) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, sheetState) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: size.width * numD04),
                  child: Row(
                    children: [
                      Text(
                        categoryText.toUpperCase(),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD04,
                            color: Colors.black,
                            fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                          splashRadius: size.width * numD06,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.cancel_outlined,
                            size: size.width * numD08,
                          ))
                    ],
                  ),
                ),
                Flexible(
                  child: GridView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * numD04),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: size.width * numD04),
                    itemBuilder: (context, index) {
                      String selectedCat = selectedCategory!.name;
                      return InkWell(
                        onTap: () {
                          int selPos = categoryList
                              .indexWhere((element) => element.selected);

                          if (selPos >= 0) {
                            categoryList[selPos].selected = false;
                          }

                          categoryList[index].selected = true;

                          if (categoryList[index].selected) {
                            if (categoryList[index].name == "Shared" ||
                                categoryList[index].name == "Exclusive") {
                              selectedSellType = categoryList[index].name;
                            }
                          }
                          selectedCategory = categoryList[index];
                          setState(() {});

                          Navigator.pop(context);
                        },
                        child: Chip(
                          label: Text(
                            categoryList[index].name,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: categoryList[index].selected
                                    ? Colors.white
                                    : colorHint,
                                fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: categoryList[index].selected
                              ? Colors.black
                              : colorLightGrey,
                        ),
                      );
                    },
                    itemCount: categoryList.length,
                  ),
                ),
              ],
            );
          });
        });
  }

  void addPreData() {
    if (widget.hideDraft) {
      locationController.text = widget.myContentData!.location;
      timestampController.text = widget.myContentData!.time;
      descriptionController.text = widget.myContentData!.textValue;
      hashtagList.addAll(widget.myContentData!.hashTagList);
      debugPrint("priceValuee=====> ${widget.myContentData!.amount}");
      priceController.text = widget.myContentData!.amount.isNotEmpty
          ? widget.myContentData!.amount
          : '';
      selectedCategory = widget.myContentData!.categoryData;
      selectedSellType =
          widget.myContentData!.exclusive ? exclusiveText : sharedText;
    } else {
      locationController.text = widget.publishData!.address;
      timestampController.text = widget.publishData!.date;
      Future.delayed(Duration.zero, () {
        getHashTagsApi(widget.publishData!.country);
      });
    }
  }

  Future initWaveData() async {
// Or directly extract from preparePlayer and initialise audio player
    await controller.preparePlayer(
      path: audioPath,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );

    controller.onPlayerStateChanged.listen((event) {
      if (event.isPaused) {
        audioPlaying = false;
        setState(() {});
      }
    });
  }

  Future playSound() async {
    await controller.startPlayer(
        finishMode: FinishMode.pause); // Start audio player
  }

  Future pauseSound() async {
    await controller.pausePlayer(); // Start audio player
  }

  ///--------Apis Section------------

  /// Hash Tag
  void getHashTagsApi(String searchParam) {
    Map<String, String> params = {};
    if (searchParam.trim().isNotEmpty) {
      params["tagName"] = searchParam;
      params["type"] = "hopper";
      debugPrint("GetHashTagsQueryParams: $params");
    }

    NetworkClass(getHashTagsUrl, this, getHashTagsUrlRequest)
        .callRequestServiceHeader(
            true, "get", searchParam.trim().isNotEmpty ? params : null);
  }

  /// Category
  void categoryApi() {
    NetworkClass(categoryUrl, this, categoryUrlRequest)
        .callRequestServiceHeader(true, "get", null);
  }

  void callGetShareExclusivePrice() {
    Map<String, String> map = {
      'type': 'selling_price',
    };
    NetworkClass(getAllCmsUrl, this, getAllCmsUrlRequest)
        .callRequestServiceHeader(true, "get", map);
  }

  /// Uploaded Document
  void callUploadMediaApi() async {
    List<Map<String, String>> mediaList = [];

    if (widget.publishData != null) {
      for (int i = 0; i < widget.publishData!.mediaList.length; i++) {
        var element = widget.publishData!.mediaList[i];

        String mediaPath = "";
        String thumbnail = "";
        String waterMarkImage = "";
        String mediaType = "";
        var res = await NetworkClass.multipartSingleImageNetworkClass(
                uploadContentUrl,
                this,
                uploadContentReq,
                {},
                element.mediaPath,
                "image")
            .callMultipartServiceWithReturn(true, "post");

        debugPrint("uploadContentReq : $res");

        if (res[0]) {
          var jsonParse = jsonDecode(res[1]);
          mediaPath = (jsonParse["data"] ?? "").toString();
          waterMarkImage = (jsonParse["watermark"] ?? "").toString();
          debugPrint("mediaPath {$i} : $mediaPath");
          mediaType = jsonParse["media_type"] ?? "";
          if (element.mimeType == "video") {
            final thumbnailGen = await VideoThumbnail.thumbnailFile(
              video: element.mediaPath,
              thumbnailPath: (await getTemporaryDirectory()).path,
              imageFormat: ImageFormat.PNG,
              maxHeight: 300,
              quality: 100,
            );

            var res1 = await NetworkClass.multipartSingleImageNetworkClass(
                    uploadContentUrl,
                    this,
                    uploadContentReq,
                    {},
                    thumbnailGen!,
                    "image")
                .callMultipartServiceWithReturn(true, "post");

            debugPrint("element.thumbnail : $res1");

            if (res1[0]) {
              var jsonParse = jsonDecode(res1[1]);
              thumbnail = (jsonParse["data"] ?? "").toString();
              waterMarkImage = (jsonParse["watermark"] ?? "").toString();
              debugPrint("thumbnail {$i} : $thumbnail");
            }
          }
        } else if (widget.publishData!.mediaList.isNotEmpty &&
            widget.publishData!.mediaList.length == 1) {
          var errorList = res as List;
          Map errorMap = jsonDecode(res[1]);
          showSnackBar("Nudity", errorMap['message'].toString(), Colors.red);
          /*if (errorMap["error"]["msg"].toString().contains("Nudity")) {
            showSnackBar("Nudity", errorMap["error"]["msg"], Colors.red);
          }*/
        }

        if (mediaPath.isNotEmpty) {
          mediaList.add({
            "media_type": element.mimeType,
            "media": mediaPath,
            "thumbnail": thumbnail,
            "watermark": waterMarkImage
          });
        }
      }
    } else {
      for (int i = 0; i < widget.myContentData!.contentMediaList.length; i++) {
        var element = widget.myContentData!.contentMediaList[i];

        mediaList.add({
          "media_type": element.mediaType,
          "media": element.media,
          "thumbnail": element.thumbNail,
          "watermark": element.waterMark
        });
      }
      debugPrint("content media length=====> ${mediaList.length}");
    }

    if (mediaList.isNotEmpty) {
      addContentApi(mediaList);
    }
  }

  void addContentApi(dynamic mediaList) {
    debugPrint("inside uploaded content====>");
    List<String> tagsIdList = [];

    for (int i = 0; i < hashtagList.length; i++) {
      tagsIdList.add(hashtagList[i].id);
    }

    Map<String, String> params = {
      "media": jsonEncode(mediaList),
      "description": descriptionController.text.trim(),
      "location": widget.publishData != null
          ? widget.publishData!.address
          : widget.myContentData!.location,
      "latitude": widget.publishData != null
          ? widget.publishData!.latitude
          : widget.myContentData!.latitude,
      "longitude": widget.publishData != null
          ? widget.publishData!.longitude
          : widget.myContentData!.longitude,
      "tag_ids": jsonEncode(tagsIdList),
      "category_id": selectedCategory!.id,
      "type": selectedSellType == sharedText ? "shared" : "exclusive",
      "ask_price": priceController.text.isNotEmpty
          ? priceController.text.trim().replaceAll(',', '').split(euroUniqueCode).last
          : "",
      "timestamp": widget.publishData != null
          ? changeDateFormat("HH:mm, dd MMM yyyy", widget.publishData!.date,
              "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
          : changeDateFormat("HH:mm, dd MMM yyyy", widget.myContentData!.time,
              "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
    };
    if (audioDuration.isNotEmpty) {
      params["audio_description_duration"] = audioDuration;
    }

    if (draftSelected) {
      params["is_draft"] = draftSelected.toString();
    }

    debugPrint("AddContentParams========>:$params");

    if (audioPath.isEmpty) {
      NetworkClass.fromNetworkClass(
              addContentUrl, this, addContentUrlRequest, params)
          .callRequestServiceHeader(true, "post", null);
    } else {
      NetworkClass.fromNetworkClass(
              addContentUrl, this, addContentUrlRequest, params)
          .callMultipartServiceNew(
              true, "post", {"audio_description": audioPath});
    }
  }
  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case getHashTagsUrlRequest:
          debugPrint("getHashTagsUrlRequestError: $response");
          break;
        case addContentUrlRequest:
          debugPrint("AddContentError: $response");
          break;

        case getAllCmsUrlRequest:
          debugPrint("getAllCmsUrlRequestError===>: $response");
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case getHashTagsUrlRequest:
          var map = jsonDecode(response);
          debugPrint("GetHashTags: $response");
          if (map["code"] == 200) {
            var list = map["tags"] as List;
            hashtagList = list.map((e) => HashTagData.fromJson(e)).toList();
            setState(() {});
          }

          break;
        case categoryUrlRequest:
          var map = jsonDecode(response);
          debugPrint("CategoryData:$response");
          if (map["code"] == 200) {
            var list = map["categories"] as List;

            categoryList =
                list.map((e) => CategoryDataModel.fromJson(e)).toList();
            if (categoryList.isNotEmpty) {
              dropDownValue = categoryList.first.name;
              selectedCategory = categoryList.first;
              selectedCategory!.selected = true;
              categoryList.first.selected = true;
            }
            setState(() {});
          }

          break;
        case addContentUrlRequest:
          debugPrint("AddContentResponse: $response");

          var map = jsonDecode(response);

          MyContentData detail = MyContentData.fromJson(map["data"] ?? {});

          if (map["code"] == 200) {
            if (draftSelected) {
              draftSelected = false;
            /*  Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => MyDraftScreen(
                            publishedContent: true,
                          )),
                  (route) => false);*/

              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Dashboard(
                       initialPosition: 2,
                      )),
                      (route) => false);
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => ContentSubmittedScreen(
                            myContentDetail: detail,
                          )),
                  (route) => false);
            }
          }

          break;

        case getAllCmsUrlRequest:
          debugPrint("getAllCmsUrlRequest======>: $response");
          var data = jsonDecode(response);

          sharedPrice = data['status']['shared'] ?? '';
          exclusivePrice = data['status']['exclusive'] ?? '';
          setState(() {});
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}
