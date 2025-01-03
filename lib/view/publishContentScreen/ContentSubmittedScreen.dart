import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/authentication/TermCheckScreen.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:presshop/view/menuScreen/ContactUsScreen.dart';
import 'package:presshop/view/menuScreen/FAQScreen.dart';
import 'package:presshop/view/myEarning/MyEarningScreen.dart';
import '../menuScreen/MyContentScreen.dart';

class ContentSubmittedScreen extends StatefulWidget {
  final MyContentData myContentDetail;

  ContentSubmittedScreen({super.key, required this.myContentDetail});

  @override
  State<StatefulWidget> createState() {
    return ContentSubmittedScreenState();
  }
}

class ContentSubmittedScreenState extends State<ContentSubmittedScreen> {
  String selectedSellType = sharedText;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => Dashboard(initialPosition: 2)),
            (route) => false);
        return Future.value(false);
      },
      child: Scaffold(
          appBar: CommonAppBar(
            elevation: 0,
            hideLeading: true,
            title: Text(
              contentSubmittedText,
              style: commonTextStyle(
                  size: size,
                  color: Colors.black,
                  fontSize: size.width * appBarHeadingFontSize,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
            titleSpacing: size.width * numD04,
            size: size,
            showActions: true,
            leadingFxn: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)),
                  (route) => false);
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
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                        vertical: size.width * numD04),
                    decoration: BoxDecoration(
                        color: colorLightGrey,
                        borderRadius:
                            BorderRadius.circular(size.width * numD04)),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                height: size.width * numD30,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD06),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD06),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      showImage(
                                        widget.myContentDetail
                                            .contentMediaList[0].mediaType,
                                        widget
                                                    .myContentDetail
                                                    .contentMediaList[0]
                                                    .mediaType ==
                                                "video"
                                            ? widget.myContentDetail
                                                .contentMediaList[0].thumbNail
                                            : widget.myContentDetail
                                                .contentMediaList[0].media,
                                      ),
                                      Visibility(
                                        visible: widget
                                                .myContentDetail
                                                .contentMediaList[0]
                                                .mediaType !=
                                            "audio",
                                        child: Container(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            child: Image.asset(
                                              "${commonImagePath}watermark.png",
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: size.width * numD04,
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    EdgeInsets.only(top: size.width * numD04),
                                child: Text(
                                  contentSubmittedHeadingText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD038,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: size.width * numD15,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ImageIcon(
                                      AssetImage(
                                          widget.myContentDetail.exclusive
                                              ? "${iconsPath}ic_exclusive.png"
                                              : "${iconsPath}ic_share.png"),
                                      size: size.width * numD06,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      widget.myContentDetail.exclusive
                                          ? "Exclusive"
                                          : "Shared",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD04,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: size.width * numD06,
                            ),
                            Expanded(
                              child: Container(
                                height: size.width * numD15,
                                decoration: BoxDecoration(
                                    color: colorThemePink,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      amountQuoted,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD035,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    SizedBox(
                                      height: size.width * numD01,
                                    ),
                                    Text(
                                      "$euroUniqueCode ${amountFormat(widget.myContentDetail.amount.toString())}",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD045,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: size.width * numD04,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(children: [
                        TextSpan(
                          text: "$contentSubmittedMessageText ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD03,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        WidgetSpan(
                            child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TermCheckScreen(
                                          type: 'legal',
                                        )));
                          },
                          child: Text(
                            "${privacyLawText.toLowerCase()} ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: colorThemePink,
                                fontWeight: FontWeight.w600),
                          ),
                        )),
                        TextSpan(
                          text: " $contentSubmittedMessage1Text\n\n",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD03,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              lineHeight: 1.5),
                        ),
                        TextSpan(
                          text: "$contentSubmittedMessage2Text ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD03,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              lineHeight: 1.5),
                        ),
                        WidgetSpan(
                            child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FAQScreen(
                                          priceTipsSelected: false,
                                          type: '',
                                        )));
                          },
                          child: Text(
                            faqText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: colorThemePink,
                                fontWeight: FontWeight.w600),
                          ),
                        )),
                        TextSpan(
                          text: " $orText ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD03,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                        WidgetSpan(
                            child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ContactUsScreen()));
                          },
                          child: Text(
                            "${contactText.toLowerCase()} ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: colorThemePink,
                                fontWeight: FontWeight.w600),
                          ),
                        )),
                        TextSpan(
                          text: "$contentSubmittedMessage3Text ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD03,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      ])),
                ),
                const Spacer(),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD06),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD15,
                        child: commonElevatedButton(
                            myContentText.toTitleCase(),
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, Colors.black), () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => Dashboard(
                                        initialPosition: 0,
                                      )),
                              (route) => false);
                        }),
                      )),
                      SizedBox(
                        width: size.width * numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD15,
                        child: commonElevatedButton(
                            "Home",
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, colorThemePink), () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => Dashboard(initialPosition: 2)),
                                  (route) => false);
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
          )),
    );
  }

  Widget showImage(String type, String url) {
    return type == "audio"
        ? Image.asset(
            "${iconsPath}ic_waves.png",
            fit: BoxFit.cover,
          )
        : type == "pdf"
            ? Image.asset(
                "${dummyImagePath}pngImage.png",
                fit: BoxFit.contain,
              )
            : type == "doc"
                ? Image.asset(
                    "${dummyImagePath}doc_black_icon.png",
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    "$contentImageUrl$url",
                    fit: BoxFit.cover,
                  );
  }
}
