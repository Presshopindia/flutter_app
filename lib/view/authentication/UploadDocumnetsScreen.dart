import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:presshop/view/menuScreen/FAQScreen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/CommonAppBar.dart';
import '../menuScreen/MyProfile.dart';
import 'WelcomeScreen.dart';

class UploadDocumentsScreen extends StatefulWidget {
  bool menuScreen = false;
  bool hideLeading = false;

  UploadDocumentsScreen(
      {super.key, required this.menuScreen, required this.hideLeading});

  @override
  State<StatefulWidget> createState() => UploadDocumentsScreenState();
}

class UploadDocumentsScreenState extends State<UploadDocumentsScreen>
    with SingleTickerProviderStateMixin
    implements NetworkResponse {
  late AnimationController controller;
  bool govIdUploaded = false,
      photoLicenseUploaded = false,
      incorporateLicenseUploaded = false,
      isFirst = false,
      isSecond = false,
      isThird = false,
      isFourth = false,
      isFifth = false,
      uploadComplete = false,
      networkData = false;

  File? file1;
  File? file2;
  File? file3;

  List<File> selectedImages = [];
  final picker = ImagePicker();

  String selectedType = "",
      doc1 = "",
      doc2 = "",
      doc3 = "",
      doc1Name = "",
      doc2Name = "",
      doc3Name = "",
      type = "";
  List<DocumentDataModel> documentTypeList = [];
  List<String> selectedDocument = [];
  MyProfileData? myProfileData;

  @override
  void initState() {
    debugPrint("class:::::::: $runtimeType");
    debugPrint("menuScreen:::::::: ${widget.menuScreen}");
    debugPrint("file1:::::::: $file1");
    debugPrint("file2:::::::: $file2");
    debugPrint("file3:::::::: $file3");

    controller = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => callGetCertificatesAPI());
    super.initState();
    /*sharedPreferences?.remove(file1Key);
    sharedPreferences?.remove(file1NameKey);
    sharedPreferences?.remove(file2Key);
    sharedPreferences?.remove(file2NameKey);
    sharedPreferences?.remove(file3Key);
    sharedPreferences?.remove(file3NameKey);*/
    addFileData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        }
      });
    debugPrint("file1:::::::: $file1");
    debugPrint("file2:::::::: $file2");
    debugPrint("file3:::::::: $file3");
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: widget.hideLeading,
        title: Text(
          "",
          style: commonBigTitleTextStyle(size, Colors.black),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: false,
        leadingFxn: () {
          Navigator.pop(context);
        },
        actionWidget: null,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD06, vertical: size.width * numD05),
          children: [
            Text(
              uploadDocsHeadingText,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: size.width * numD07),
            ),
            SizedBox(
              height: size.width * numD02,
            ),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "$uploadDocsSubHeading1Text ",
                    style: TextStyle(
                        color: Colors.black, fontSize: size.width * numD035)),
                WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Image.asset("${iconsPath}ic_pro.png",
                        height: size.width * numD06)),
                TextSpan(
                    text: " $uploadDocsSubHeading2Text",
                    style: TextStyle(
                        color: Colors.black, fontSize: size.width * numD035)),
              ]),
            ),
            SizedBox(
              height: size.width * numD02,
            ),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "$uploadDocsSubHeading3Text ",
                    style: TextStyle(
                        color: Colors.black, fontSize: size.width * numD035)),
                WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Image.asset("${iconsPath}ic_pro.png",
                        height: size.width * numD06)),
                TextSpan(
                    text: " $uploadDocsSubHeading4Text",
                    style: TextStyle(
                        color: Colors.black, fontSize: size.width * numD035)),
                WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: SizedBox(
                      width: size.width * numD01,
                    )),
                WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => FAQScreen(
                                  priceTipsSelected: false,
                                  type: 'faq',
                                  benefits: "benefits",
                                )));
                      },
                      child: Text(benefitText,
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * numD035)),
                    )),
              ]),
            ),
            SizedBox(
              height: size.width * numD08,
            ),
            !widget.menuScreen
                ? Text(uploadDocsSubHeading5Text,
                    style: TextStyle(
                        color: Colors.black, fontSize: size.width * numD035))
                : Container(),

            SizedBox(
              height: !widget.menuScreen ? size.width * numD08 : 0,
            ),
            AnimatedBuilder(
              animation: offsetAnimation,
              builder: (context, child) {
                final dx = sin(offsetAnimation.value * 2 * pi) * 24;
                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius:
                            BorderRadius.circular(size.width * numD03)),
                    padding: EdgeInsets.all(size.width * numD04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: uploadYourDocumentsText,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: " ($anyText)",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500)),
                        ])),
                        SizedBox(
                          height: size.width * numD04,
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            /*   itemCount: documentTypeList.length >= 5
                                ? 5
                                : documentTypeList.length,*/
                            itemCount: documentTypeList.length,
                            itemBuilder: (BuildContext context, index) {
                              debugPrint(
                                  "isSelected:::::::${documentTypeList[index].isSelected}");
                              return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.width * numD003),
                                      child: Icon(
                                        /* documentTypeList[index].isSelected
                                            ? Icons.check_circle
                                            :*/
                                        Icons.circle,
                                        color: colorThemePink,
                                        size: size.width * numD035,
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * numD02,
                                    ),
                                    Expanded(
                                      child: Text(
                                          documentTypeList[index].documentName,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD029,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400)),
                                    ),
                                  ]);
                            }),
                        /*     Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                govIdUploaded
                                    ? Icons.check_circle
                                    : Icons.circle,
                                color: govIdUploaded
                                    ? colorThemePink
                                    : colorThemePink,
                                size: govIdUploaded
                                    ? size.width * numD04
                                    : size.width * numD03,
                              ),
                              SizedBox(
                                width: size.width * numD02,
                              ),
                              Expanded(
                                child: Text(
                                    "$govIdText ($passportText / $driverLicenseText)",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400)),
                              ),
                            ]),
                        SizedBox(
                          height: size.width * numD03,
                        ),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                photoLicenseUploaded
                                    ? Icons.check_circle
                                    : Icons.circle,
                                color: photoLicenseUploaded
                                    ? colorThemePink
                                    : colorThemePink,
                                size: photoLicenseUploaded
                                    ? size.width * numD04
                                    : size.width * numD03,
                              ),
                              SizedBox(
                                width: size.width * numD02,
                              ),
                              Expanded(
                                child: Text(photographyLicenseText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400)),
                              ),
                            ]),
                        SizedBox(
                          height: size.width * numD03,
                        ),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                incorporateLicenseUploaded
                                    ? Icons.check_circle
                                    : Icons.circle,
                                color: incorporateLicenseUploaded
                                    ? colorThemePink
                                    : colorThemePink,
                                size: incorporateLicenseUploaded
                                    ? size.width * numD04
                                    : size.width * numD03,
                              ),
                              SizedBox(
                                width: size.width * numD02,
                              ),
                              Expanded(
                                child: Text(companyIncorporationText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400)),
                              ),
                            ]),*/
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(
              height: size.width * numD06,
            ),

            /*   !networkData
                ? Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * numD04),
                    child: Row(
                      children: [
                        file1 != null
                            ? Expanded(
                                child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      file1!.path.contains("jpg")
                                          ? Image.file(
                                              file1!,
                                              height: size.width * numD35,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              "${dummyImagePath}doc_black_icon.png",
                                              height: size.width * numD35,
                                              fit: BoxFit.cover,
                                            ),
                                      SizedBox(
                                        height: size.width * numD02,
                                      ),
                                      SizedBox(
                                        height: size.width * numD07,
                                        child: Text(
                                          doc1Name.toCapitalized(),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD03,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    ],
                                  ),
                                  CircleAvatar(
                                    radius: size.width * numD03,
                                    backgroundColor: colorThemePink,
                                    child: InkWell(
                                        onTap: () {
                                          file1 == null;
                                          doc1Name == "";
                                          setState(() {});
                                        },
                                        child: Icon(Icons.close,
                                            color: Colors.white,
                                            size: size.width * numD04)),
                                  )
                                ],
                              ))
                            : Container(),
                        SizedBox(
                          width: size.width * numD01,
                        ),
                        file2 != null
                            ? Expanded(
                                child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      file2!.path.contains("jpg")
                                          ? Image.file(
                                              file2!,
                                              height: size.width * numD35,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              "${dummyImagePath}doc_black_icon.png",
                                              height: size.width * numD35,
                                              fit: BoxFit.cover,
                                            ),
                                      SizedBox(
                                        height: size.width * numD02,
                                      ),
                                      SizedBox(
                                        height: size.width * numD07,
                                        child: Text(
                                          doc2Name.toCapitalized(),
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD03,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    ],
                                  ),
                                  CircleAvatar(
                                    radius: size.width * numD03,
                                    backgroundColor: colorThemePink,
                                    child: InkWell(
                                        onTap: () {
                                          file2 == null;
                                          doc2Name == "";
                                          setState(() {});
                                        },
                                        child: Icon(Icons.close,
                                            color: Colors.white,
                                            size: size.width * numD04)),
                                  )
                                ],
                              ))
                            : Container(),
                        SizedBox(
                          width: size.width * numD01,
                        ),
                        file3 != null
                            ? Expanded(
                                child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      file3!.path.contains("jpg")
                                          ? Image.file(
                                              file3!,
                                              height: size.width * numD35,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              "${dummyImagePath}doc_black_icon.png",
                                              height: size.width * numD35,
                                              fit: BoxFit.cover,
                                            ),
                                      SizedBox(
                                        height: size.width * numD01,
                                      ),
                                      SizedBox(
                                        height: size.width * numD07,
                                        child: Text(
                                          doc3Name.toCapitalized(),
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD03,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    ],
                                  ),
                                  CircleAvatar(
                                    radius: size.width * numD03,
                                    backgroundColor: colorThemePink,
                                    child: InkWell(
                                        onTap: () {
                                          file3 == null;
                                          doc3Name == "";
                                          setState(() {});
                                        },
                                        child: Icon(Icons.close,
                                            color: Colors.white,
                                            size: size.width * numD04)),
                                  )
                                ],
                              ))
                            : Container(),
                      ],
                    ),
                  )
                :*/

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                doc1.isNotEmpty
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                onTap: () {
                                  openUrl("$docImageUrl$doc1");
                                },
                                child: doc1.contains("jpg")
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD01),
                                        child: Image.network(
                                          "$docImageUrl$doc1",
                                          height: size.width * numD29,
                                          width: size.width * numD23,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : doc1.contains("pdf")
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD01),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset(
                                                    1.0,
                                                    1.0,
                                                  ),
                                                  blurRadius: 1.0,
                                                  spreadRadius: 1.0,
                                                ), //BoxShadow
                                                BoxShadow(
                                                  color: Colors.white,
                                                  offset: Offset(0.0, 0.0),
                                                  blurRadius: 0.0,
                                                  spreadRadius: 0.0,
                                                ), //BoxShadow
                                              ],
                                            ),
                                            child: Image.asset(
                                              "${iconsPath}pdfIcon.png",
                                              fit: BoxFit.cover,
                                              height: size.width * numD29,
                                              width: size.width * numD23,
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD01),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset(
                                                    1.0,
                                                    1.0,
                                                  ),
                                                  blurRadius: 1.0,
                                                  spreadRadius: 1.0,
                                                ), //BoxShadow
                                                BoxShadow(
                                                  color: Colors.white,
                                                  offset: Offset(0.0, 0.0),
                                                  blurRadius: 0.0,
                                                  spreadRadius: 0.0,
                                                ), //BoxShadow
                                              ],
                                            ),
                                            child: Image.asset(
                                              "${iconsPath}docIcon.png",
                                              fit: BoxFit.cover,
                                              height: size.width * numD29,
                                              width: size.width * numD23,
                                            ),
                                          ),
                              ),
                              SizedBox(
                                height: size.width * numD02,
                              ),
                              SizedBox(
                                width: size.width * numD25,
                                height: size.width * numD19,
                                child: Text(
                                  sharedPreferences!
                                      .getString(file1Key)
                                      .toString(),
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          ),
                          CircleAvatar(
                            radius: size.width * numD025,
                            backgroundColor: colorThemePink,
                            child: InkWell(
                                onTap: () {
                                  type = 'firstDoc';
                                  deleteCertificatesApi(
                                      doc1, documentTypeList[0].id);

                                  setState(() {});
                                },
                                child: Icon(Icons.close,
                                    color: Colors.white,
                                    size: size.width * numD04)),
                          )
                        ],
                      )

                    ///aditya
                    : file1 != null
                        ? Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  file1!.path.contains("jpg")
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD01),
                                          child: Image.file(
                                            file1!,
                                            height: size.width * numD29,
                                            width: size.width * numD23,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : file1!.path.contains("pdf")
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white24,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD01),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(
                                                      1.0,
                                                      1.0,
                                                    ),
                                                    blurRadius: 1.0,
                                                    spreadRadius: 1.0,
                                                  ), //BoxShadow
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    offset: Offset(0.0, 0.0),
                                                    blurRadius: 0.0,
                                                    spreadRadius: 0.0,
                                                  ), //BoxShadow
                                                ],
                                              ),
                                              child: Image.asset(
                                                "${iconsPath}pdfIcon.png",
                                                height: size.width * numD29,
                                                width: size.width * numD23,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white24,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD01),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(
                                                      1.0,
                                                      1.0,
                                                    ),
                                                    blurRadius: 1.0,
                                                    spreadRadius: 1.0,
                                                  ), //BoxShadow
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    offset: Offset(0.0, 0.0),
                                                    blurRadius: 0.0,
                                                    spreadRadius: 0.0,
                                                  ), //BoxShadow
                                                ],
                                              ),
                                              child: Image.asset(
                                                "${iconsPath}docIcon.png",
                                                height: size.width * numD29,
                                                width: size.width * numD23,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                  SizedBox(
                                    height: size.width * numD02,
                                  ),
                                  SizedBox(
                                    height: size.width * numD19,
                                    width: size.width * numD25,
                                    child: Text(
                                      file1!.path.toString().split("/").last,
                                      maxLines: 2,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                ],
                              ),
                              CircleAvatar(
                                radius: size.width * numD025,
                                backgroundColor: colorThemePink,
                                child: InkWell(
                                    onTap: () {
                                      file1 = null;
                                      doc1Name = "";
                                      documentTypeList[0].isSelected = false;
                                      setState(() {});
                                    },
                                    child: Icon(Icons.close,
                                        color: Colors.white,
                                        size: size.width * numD04)),
                              )
                            ],
                          )
                        : Container(),
                SizedBox(
                  width: size.width * numD05,
                ),
                doc2.isNotEmpty
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  openUrl("$docImageUrl$doc2");
                                },
                                child: doc2.contains("jpg")
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD01),
                                        child: Image.network(
                                          "$docImageUrl$doc2",
                                          height: size.width * numD29,
                                          width: size.width * numD23,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : doc2.contains("pdf")
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD01),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset(
                                                    1.0,
                                                    1.0,
                                                  ),
                                                  blurRadius: 1.0,
                                                  spreadRadius: 1.0,
                                                ), //BoxShadow
                                                BoxShadow(
                                                  color: Colors.white,
                                                  offset: Offset(0.0, 0.0),
                                                  blurRadius: 0.0,
                                                  spreadRadius: 0.0,
                                                ), //BoxShadow
                                              ],
                                            ),
                                            child: Image.asset(
                                              "${iconsPath}pdfIcon.png",
                                              fit: BoxFit.cover,
                                              height: size.width * numD29,
                                              width: size.width * numD23,
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD01),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset(
                                                    1.0,
                                                    1.0,
                                                  ),
                                                  blurRadius: 1.0,
                                                  spreadRadius: 1.0,
                                                ), //BoxShadow
                                                BoxShadow(
                                                  color: Colors.white,
                                                  offset: Offset(0.0, 0.0),
                                                  blurRadius: 0.0,
                                                  spreadRadius: 0.0,
                                                ), //BoxShadow
                                              ],
                                            ),
                                            child: Image.asset(
                                              "${iconsPath}docIcon.png",
                                              fit: BoxFit.cover,
                                              height: size.width * numD29,
                                              width: size.width * numD23,
                                            ),
                                          ),
                              ),
                              SizedBox(
                                height: size.width * numD02,
                              ),
                              SizedBox(
                                height: size.width * numD19,
                                width: size.width * numD25,
                                child: Text(
                                  sharedPreferences!
                                      .getString(file2Key)
                                      .toString(),
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: size.width * numD025,
                            backgroundColor: colorThemePink,
                            child: InkWell(
                                onTap: () {
                                  type = "secondDoc";
                                  deleteCertificatesApi(
                                      doc2, documentTypeList[1].id);
                                  setState(() {});
                                },
                                child: Icon(Icons.close,
                                    color: Colors.white,
                                    size: size.width * numD04)),
                          )
                        ],
                      )
                    : file2 != null
                        ? Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  file2!.path.contains("jpg")
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD01),
                                          child: Image.file(
                                            file2!,
                                            height: size.width * numD29,
                                            width: size.width * numD23,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : file2!.path.contains("pdf")
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white24,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD01),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(
                                                      1.0,
                                                      1.0,
                                                    ),
                                                    blurRadius: 1.0,
                                                    spreadRadius: 1.0,
                                                  ), //BoxShadow
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    offset: Offset(0.0, 0.0),
                                                    blurRadius: 0.0,
                                                    spreadRadius: 0.0,
                                                  ), //BoxShadow
                                                ],
                                              ),
                                              child: Image.asset(
                                                "${iconsPath}pdfIcon.png",
                                                height: size.width * numD29,
                                                width: size.width * numD23,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white24,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD01),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(
                                                      1.0,
                                                      1.0,
                                                    ),
                                                    blurRadius: 1.0,
                                                    spreadRadius: 1.0,
                                                  ), //BoxShadow
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    offset: Offset(0.0, 0.0),
                                                    blurRadius: 0.0,
                                                    spreadRadius: 0.0,
                                                  ), //BoxShadow
                                                ],
                                              ),
                                              child: Image.asset(
                                                "${iconsPath}docIcon.png",
                                                height: size.width * numD29,
                                                width: size.width * numD23,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                  SizedBox(
                                    height: size.width * numD02,
                                  ),
                                  SizedBox(
                                    height: size.width * numD19,
                                    width: size.width * numD25,
                                    child: Text(
                                      file2!.path.toString().split("/").last,
                                      maxLines: 2,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                radius: size.width * numD025,
                                backgroundColor: colorThemePink,
                                child: InkWell(
                                    onTap: () {
                                      file2 = null;
                                      doc2Name = "";
                                      documentTypeList[1].isSelected = false;

                                      setState(() {});
                                    },
                                    child: Icon(Icons.close,
                                        color: Colors.white,
                                        size: size.width * numD04)),
                              )
                            ],
                          )
                        : Container(),
                SizedBox(
                  width: size.width * numD05,
                ),
                doc3.isNotEmpty
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  openUrl("$docImageUrl$doc3");
                                },
                                child: doc3.contains("jpg")
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD01),
                                        child: Image.network(
                                          "$docImageUrl$doc3",
                                          height: size.width * numD29,
                                          width: size.width * numD23,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : doc3.contains("pdf")
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD01),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset(
                                                    1.0,
                                                    1.0,
                                                  ),
                                                  blurRadius: 1.0,
                                                  spreadRadius: 1.0,
                                                ), //BoxShadow
                                                BoxShadow(
                                                  color: Colors.white,
                                                  offset: Offset(0.0, 0.0),
                                                  blurRadius: 0.0,
                                                  spreadRadius: 0.0,
                                                ), //BoxShadow
                                              ],
                                            ),
                                            child: Image.asset(
                                              "${iconsPath}pdfIcon.png",
                                              fit: BoxFit.cover,
                                              height: size.width * numD29,
                                              width: size.width * numD23,
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD01),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset(
                                                    1.0,
                                                    1.0,
                                                  ),
                                                  blurRadius: 1.0,
                                                  spreadRadius: 1.0,
                                                ), //BoxShadow
                                                BoxShadow(
                                                  color: Colors.white,
                                                  offset: Offset(0.0, 0.0),
                                                  blurRadius: 0.0,
                                                  spreadRadius: 0.0,
                                                ), //BoxShadow
                                              ],
                                            ),
                                            child: Image.asset(
                                              "${iconsPath}docIcon.png",
                                              fit: BoxFit.cover,
                                              height: size.width * numD29,
                                              width: size.width * numD23,
                                            ),
                                          ),
                              ),
                              SizedBox(
                                height: size.width * numD02,
                              ),
                              SizedBox(
                                width: size.width * numD25,
                                height: size.width * numD19,
                                child: Text(
                                  sharedPreferences!
                                      .getString(file3Key)
                                      .toString(),
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: size.width * numD025,
                            backgroundColor: colorThemePink,
                            child: InkWell(
                                onTap: () {
                                  type = "thirdDoc";
                                  deleteCertificatesApi(
                                      doc3, documentTypeList[2].id);
                                  setState(() {});
                                },
                                child: Icon(Icons.close,
                                    color: Colors.white,
                                    size: size.width * numD04)),
                          )
                        ],
                      )
                    : file3 != null
                        ? Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  file3!.path.contains("jpg")
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD01),
                                          child: Image.file(
                                            file3!,
                                            height: size.width * numD29,
                                            width: size.width * numD23,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : file3!.path.contains("pdf")
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white24,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD01),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(
                                                      1.0,
                                                      1.0,
                                                    ),
                                                    blurRadius: 1.0,
                                                    spreadRadius: 1.0,
                                                  ), //BoxShadow
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    offset: Offset(0.0, 0.0),
                                                    blurRadius: 0.0,
                                                    spreadRadius: 0.0,
                                                  ), //BoxShadow
                                                ],
                                              ),
                                              child: Image.asset(
                                                "${iconsPath}pdfIcon.png",
                                                height: size.width * numD29,
                                                width: size.width * numD23,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white24,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD01),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(
                                                      1.0,
                                                      1.0,
                                                    ),
                                                    blurRadius: 1.0,
                                                    spreadRadius: 1.0,
                                                  ), //BoxShadow
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    offset: Offset(0.0, 0.0),
                                                    blurRadius: 0.0,
                                                    spreadRadius: 0.0,
                                                  ), //BoxShadow
                                                ],
                                              ),
                                              child: Image.asset(
                                                "${iconsPath}docIcon.png",
                                                height: size.width * numD29,
                                                width: size.width * numD23,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                  SizedBox(
                                    height: size.width * numD02,
                                  ),
                                  SizedBox(
                                    height: size.width * numD19,
                                    width: size.width * numD25,
                                    child: Text(
                                      file3!.path.toString().split("/").last,
                                      maxLines: 2,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                radius: size.width * numD025,
                                backgroundColor: colorThemePink,
                                child: InkWell(
                                    onTap: () {
                                      file3 = null;
                                      doc3Name = "";
                                      documentTypeList[2].isSelected = false;
                                      setState(() {});
                                    },
                                    child: Icon(Icons.close,
                                        color: Colors.white,
                                        size: size.width * numD04)),
                              )
                            ],
                          )
                        : Container(),
              ],
            ),



            /*   GridView.builder(
              itemCount: selectedImages.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3

              ),
              itemBuilder: (BuildContext context, int index) {
                return Center(
                    child: kIsWeb
                        ? Image.network(selectedImages[index].path)
                        :Image.asset(selectedImages[index].path)









                );
              },
            ),*/

            /*Padding(
              padding: EdgeInsets.only(right: size.width * numD12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  doc1.isNotEmpty
                      ? Expanded(
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            InkWell(
                              onTap: () {
                                openUrl("$docImageUrl$doc1");
                              },
                              child: doc1.contains("jpg")
                                  ? Image.network(
                                "$docImageUrl$doc1",
                                height: size.width * numD29,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                "${dummyImagePath}doc_black_icon.png",
                                fit: BoxFit.cover,
                                height: size.width * numD29,
                              ),
                            ),
                            SizedBox(
                              height: size.width * numD02,
                            ),
                            SizedBox(
                              child: Text(
                                sharedPreferences!
                                    .getString(file1Key)
                                    .toString(),
                                textAlign: TextAlign.start,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD03,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          ],
                        ),
                        CircleAvatar(
                          radius: size.width * numD025,
                          backgroundColor: colorThemePink,
                          child: InkWell(
                              onTap: () {
                                type = 'firstDoc';
                                deleteCertificatesApi(
                                    doc1, documentTypeList[0].id);
                                setState(() {});
                              },
                              child: Icon(Icons.close,
                                  color: Colors.white,
                                  size: size.width * numD04)),
                        )
                      ],
                    ),
                  )

                  ///aditya
                      : file1 != null
                      ? Expanded(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              file1!.path.contains("jpg")
                                  ? Image.file(
                                file1!,
                                height: size.width * numD29,
                                width: size.width * numD29,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                "${dummyImagePath}doc_black_icon.png",
                                height: size.width * numD29,
                                width: size.width * numD29,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(
                                height: size.width * numD02,
                              ),
                              SizedBox(
                                child: Text(
                                  "",
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          ),
                          CircleAvatar(
                            radius: size.width * numD025,
                            backgroundColor: colorThemePink,
                            child: InkWell(
                                onTap: () {
                                  file1 = null;
                                  setState(() {});
                                },
                                child: Icon(Icons.close,
                                    color: Colors.white,
                                    size: size.width * numD04)),
                          )
                        ],
                      ))
                      : Container(),
                  SizedBox(
                    width: size.width * numD06,
                  ),
                  doc2.isNotEmpty
                      ? Expanded(
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                openUrl("$docImageUrl$doc2");
                              },
                              child: doc2.contains("jpg")
                                  ? Image.network(
                                "$docImageUrl$doc2",
                                height: size.width * numD29,
                                width: size.width * numD29,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                "${dummyImagePath}doc_black_icon.png",
                                fit: BoxFit.cover,
                                height: size.width * numD29,
                                width: size.width * numD29,
                              ),
                            ),
                            SizedBox(
                              height: size.width * numD02,
                            ),
                            Text(
                              sharedPreferences!
                                  .getString(file2Key)
                                  .toString(),
                              textAlign: TextAlign.start,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD03,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: size.width * numD025,
                          backgroundColor: colorThemePink,
                          child: InkWell(
                              onTap: () {
                                type = "secondDoc";
                                deleteCertificatesApi(
                                    doc2, documentTypeList[1].id);
                                setState(() {});
                              },
                              child: Icon(Icons.close,
                                  color: Colors.white,
                                  size: size.width * numD04)),
                        )
                      ],
                    ),
                  )
                      : file2 != null
                      ? Expanded(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              file2!.path.contains("jpg")
                                  ? Image.file(
                                file2!,
                                height: size.width * numD29,
                                width: size.width * numD29,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                "${dummyImagePath}doc_black_icon.png",
                                height: size.width * numD29,
                                width: size.width * numD29,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(
                                height: size.width * numD02,
                              ),
                              Text(
                                "",
                                textAlign: TextAlign.start,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD03,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: size.width * numD025,
                            backgroundColor: colorThemePink,
                            child: InkWell(
                                onTap: () {
                                  file2 = null;
                                  doc2Name = "";
                                  setState(() {});
                                },
                                child: Icon(Icons.close,
                                    color: Colors.white,
                                    size: size.width * numD04)),
                          )
                        ],
                      ))
                      : Container(),
                  SizedBox(
                    width: size.width * numD06,
                  ),
                  doc3.isNotEmpty
                      ? Expanded(
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                openUrl("$docImageUrl$doc3");
                              },
                              child: doc3.contains("jpg")
                                  ? Image.network(
                                "$docImageUrl$doc3",
                                height: size.width * numD29,
                                width: size.width * numD29,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                "${dummyImagePath}doc_black_icon.png",
                                fit: BoxFit.cover,
                                height: size.width * numD29,
                                width: size.width * numD29,
                              ),
                            ),
                            Text(
                              sharedPreferences!
                                  .getString(file3Key)
                                  .toString(),
                              textAlign: TextAlign.start,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD03,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: size.width * numD025,
                          backgroundColor: colorThemePink,
                          child: InkWell(
                              onTap: () {
                                type = "thirdDoc";
                                deleteCertificatesApi(
                                    doc3, documentTypeList[2].id);
                                setState(() {});
                              },
                              child: Icon(Icons.close,
                                  color: Colors.white,
                                  size: size.width * numD04)),
                        )
                      ],
                    ),
                  )
                      : file3 != null
                      ? Expanded(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              file3!.path.contains("jpg")
                                  ? Image.file(
                                file3!,
                                height: size.width * numD29,
                                width: size.width * numD29,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                "${dummyImagePath}doc_black_icon.png",
                                height: size.width * numD29,
                                width: size.width * numD29,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(
                                height: size.width * numD02,
                              ),
                              Text(
                                "",
                                textAlign: TextAlign.start,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD03,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: size.width * numD025,
                            backgroundColor: colorThemePink,
                            child: InkWell(
                                onTap: () {
                                  file3 = null;
                                  doc3Name = "";
                                  setState(() {});
                                },
                                child: Icon(Icons.close,
                                    color: Colors.white,
                                    size: size.width * numD04)),
                          )
                        ],
                      ))
                      : Container(),

                ],
              ),
            ),*/

            /* : Padding(
              padding:
              EdgeInsets.symmetric(horizontal: size.width * numD04),
                    child: Row(
                      children: [
                        doc1.isNotEmpty
                            ? doc1.contains("jpg")
                                ? Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            openUrl("$docImageUrl$doc1");
                                          },
                                          child: Image.network(
                                            "$docImageUrl$doc1",
                                            height: size.width * numD35,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(
                                          height: size.width * numD02,
                                        ),
                                        SizedBox(
                                          height: size.width * numD07,
                                          child: Text(
                                            doc1Name.toCapitalized(),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Expanded(
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            openUrl("$docImageUrl$doc1");
                                          },
                                          child: Image.asset(
                                            "${iconsPath}ic_file.png",
                                            fit: BoxFit.cover,
                                            height: size.width * numD35,
                                          ),
                                        ),
                                        SizedBox(
                                          height: size.width * numD02,
                                        ),
                                        SizedBox(
                                          height: size.width * numD07,
                                          child: Text(
                                            doc1Name.toCapitalized(),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                            : file1 != null
                                ? Expanded(
                                    child: Column(
                                    children: [
                                      file1!.path.contains("jpg")
                                          ? Image.file(
                                              file1!,
                                              height: size.width * numD35,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              "${iconsPath}ic_file.png",
                                              height: size.width * numD35,
                                            ),
                                      SizedBox(
                                        height: size.width * numD02,
                                      ),
                                      SizedBox(
                                        height: size.width * numD07,
                                        child: Text(
                                          doc1Name.toCapitalized(),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD03,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    ],
                                  ))
                                : Container(),
                        SizedBox(
                          width: size.width * numD01,
                        ),
                        doc2.isNotEmpty
                            ? doc2.contains("jpg")
                                ? Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            openUrl("$docImageUrl$doc2");
                                          },
                                          child: Image.network(
                                            "$docImageUrl$doc2",
                                            height: size.width * numD35,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(
                                          height: size.width * numD02,
                                        ),
                                        SizedBox(
                                          height: size.width * numD07,
                                          child: Text(
                                            doc2Name.toCapitalized(),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Expanded(
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            openUrl("$docImageUrl$doc2");
                                          },
                                          child: Image.asset(
                                            "${iconsPath}ic_file.png",
                                            fit: BoxFit.cover,
                                            height: size.width * numD35,
                                          ),
                                        ),
                                        SizedBox(
                                          height: size.width * numD02,
                                        ),
                                        SizedBox(
                                          height: size.width * numD07,
                                          child: Text(
                                            doc2Name.toCapitalized(),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                            : file2 != null
                                ? Expanded(
                                    child: Column(
                                    children: [
                                      file2!.path.contains("jpg")
                                          ? Image.file(
                                              file2!,
                                              height: size.width * numD35,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              "${iconsPath}ic_file.png",
                                              height: size.width * numD35,
                                            ),
                                      SizedBox(
                                        height: size.width * numD02,
                                      ),
                                      SizedBox(
                                        height: size.width * numD07,
                                        child: Text(
                                          doc2Name.toCapitalized(),
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD03,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    ],
                                  ))
                                : Container(),
                        SizedBox(
                          width: size.width * numD01,
                        ),
                        doc3.isNotEmpty
                            ? doc3.contains("jpg")
                                ? Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            openUrl("$docImageUrl$doc3");
                                          },
                                          child: Image.network(
                                            "$docImageUrl$doc3",
                                            height: size.width * numD35,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(
                                          height: size.width * numD02,
                                        ),
                                        SizedBox(
                                          height: size.width * numD07,
                                          child: Text(
                                            doc3Name.toCapitalized(),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Expanded(
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            openUrl("$docImageUrl$doc3");
                                          },
                                          child: Image.asset(
                                            "${iconsPath}ic_file.png",
                                            fit: BoxFit.cover,
                                            height: size.width * numD35,
                                          ),
                                        ),
                                        SizedBox(
                                          height: size.width * numD02,
                                        ),
                                        SizedBox(
                                          height: size.width * numD07,
                                          child: Text(
                                            doc3Name.toCapitalized(),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                            : file3 != null
                                ? Expanded(
                                    child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      file3!.path.contains("jpg")
                                          ? Image.file(
                                              file3!,
                                              height: size.width * numD35,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              "${iconsPath}ic_file.png",
                                              height: size.width * numD35,
                                            ),
                                      SizedBox(
                                        height: size.width * numD01,
                                      ),
                                      SizedBox(
                                        height: size.width * numD07,
                                        child: Text(
                                          doc3Name.toCapitalized(),
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD03,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    ],
                                  ))
                                : Container()
                      ],
                    ),
                  ),*/

            SizedBox(
              height: file1 != null ? 0.0 : size.width * numD06,
            ),

            /*      widget.menuScreen
                ? Container()
                : SizedBox(
                    height: size.width * numD15,
                    child: commonElevatedButton(
                        selectOptionText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, Colors.black), () {
                    //  chooseUploadOptionsBottomSheet(size);
                      showUploadImageBottomSheet();
                    }),
                  ),*/

            ///
            widget.menuScreen
                ? /*SizedBox(
                        height: size.width * numD15,
                        child: commonElevatedButton(
                            uploadText,
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, colorThemePink), () {
                          int count = 0;
                          if (file1 != null) {
                            count = count + 1;
                          }

                          if (file2 != null) {
                            count = count + 1;
                          }

                          if (file3 != null) {
                            count = count + 1;
                          }
                          if (count < 2) {
                            controller.forward(from: 0.0);
                            startVibration();
                          } else {
                            uploadCertificatesApi();
                          }
                        }),
                      )*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      (file1 != null && file2 != null || file3 != null)
                          ? Expanded(
                              child: SizedBox(
                              height: size.width * numD15,
                              child: commonElevatedButton(
                                  "Save",
                                  size,
                                  commonButtonTextStyle(size),
                                  commonButtonStyle(size, colorThemePink), () {
                                uploadCertificatesApi();
                              }),
                            ))
                          : Expanded(
                              child: SizedBox(
                              height: size.width * numD15,
                              child: commonElevatedButton(
                                  uploadText,
                                  size,
                                  commonButtonTextStyle(size),
                                  commonButtonStyle(size, colorThemePink), () {
                                int count = 0;
                                if (file1 != null) {
                                  count = count + 1;
                                }
                                if (file2 != null) {
                                  count = count + 1;
                                }
                                if (file3 != null) {
                                  count = count + 1;
                                }
                                if (count < 3) {
                                  debugPrint("count:::");
                                  /* controller.forward(from: 0.0);
                            startVibration();*/
                                  if (doc1.isEmpty ||
                                      doc2.isEmpty ||
                                      doc3.isEmpty) {
                                    showUploadImageBottomSheet();
                                  } else {
                                    showSnackBar("Error",
                                        "You upload all document.", Colors.red);
                                  }
                                } else {
                                  uploadCertificatesApi();
                                }
                              }),
                            )),
                      SizedBox(width: size.width * numD04),
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD15,
                        child: commonElevatedButton(
                            "Exit",
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, Colors.black), () {
                          Navigator.pop(context);
                        }),
                      )),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      /*   Expanded(
                          child: SizedBox(
                        height: size.width * numD15,
                        child: commonElevatedButton(
                            uploadText,
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, Colors.black), () {
                          int count = 0;
                          if (file1 != null) {
                            count = count + 1;
                          }
                          if (file2 != null) {
                            count = count + 1;
                          }
                          if (file3 != null) {
                            count = count + 1;
                          }

                          if (count < 2) {
                            controller.forward(from: 0.0);
                            startVibration();
                          } else {
                            uploadCertificatesApi();
                          }
                        }),
                      )),*/
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD15,
                        child: commonElevatedButton(
                            uploadText,
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, Colors.black), () {
                          int count = 0;
                          if (file1 != null) {
                            count = count + 1;
                          }
                          if (file2 != null) {
                            count = count + 1;
                          }
                          if (file3 != null) {
                            count = count + 1;
                          }

                          if (count < 2) {
                            showUploadImageBottomSheet();
                          } else {
                            uploadCertificatesApi();
                          }
                        }),
                      )),
                      SizedBox(
                        width: size.width * numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD15,
                        child: commonElevatedButton(
                            finishText,
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, colorThemePink), () {
                          sharedPreferences!.setBool(skipDocumentsKey, true);
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => WelcomeScreen(
                                        hideLeading: true,
                                      )),
                              (route) => false);
                        }),
                      )),
                    ],
                  ),



            SizedBox(
              height: !uploadComplete ? size.width * numD04 : 0,
            ),
            !widget.menuScreen
                ? Align(
                    alignment: Alignment.center,
                    child: Text("3 of 3",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: size.width * numD035,
                            fontWeight: FontWeight.w500)))
                : Container(),
          ],
        ),
      ),
    );
  }

  void addFileData() {
    int count = 0;
    if (sharedPreferences!.getString(file1Key) != null) {
      doc1 = sharedPreferences!.getString(file1Key)!;
      if (sharedPreferences!.getString(file1NameKey) != null) {
        debugPrint("docName:::::: ${sharedPreferences!.getString(file1NameKey)}");
        doc1Name = sharedPreferences!.getString(file1NameKey)!;
      }
      govIdUploaded = true;
      count = count + 1;
      networkData = true;
      setState(() {});
    }
    if (sharedPreferences!.getString(file2Key) != null) {
      doc2 = sharedPreferences!.getString(file2Key)!;
      if (sharedPreferences!.getString(file2NameKey) != null) {
        doc2Name = sharedPreferences!.getString(file2NameKey).toString();
      }
      photoLicenseUploaded = true;
      count = count + 1;
      networkData = true;
      setState(() {});
    }

    if (sharedPreferences!.getString(file3Key) != null) {
      doc3 = sharedPreferences!.getString(file3Key)!;
      if (sharedPreferences!.getString(file2NameKey) != null) {
        doc3Name = sharedPreferences!.getString(file3NameKey)!;
      }
      incorporateLicenseUploaded = true;
      count = count + 1;
      networkData = true;
      setState(() {});
    }

    if (count > 1) {
      uploadComplete = true;
    }

    setState(() {});
  }

  void chooseUploadOptionsBottomSheet(size) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, avatarState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: size.width * numD04),
                  child: Row(
                    children: [
                      Text(
                        selectOptionText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD05,
                            color: Colors.black,
                            fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                          color: colorLightGrey,
                          splashRadius: size.width * numD05,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: size.width * numD06,
                          ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD025,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: documentTypeList.length >= 5
                      ? 5
                      : documentTypeList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.width * numD01),
                      child: InkWell(
                        onTap: () {
                          debugPrint(
                              "documentName=====> ${documentTypeList[index].documentName}");
                          documentTypeList[index].isSelected =
                              !documentTypeList[index].isSelected;

                          if (documentTypeList[index].isSelected) {
                            /* if (selectedDocument.contains(
                                documentTypeList[index].documentName)) {
                              showSnackBar("Become Pro",
                                  "Document already Selected", colorThemePink);
                              setState(() {});
                            } else {*/
                            pickFile(documentTypeList[index].documentName);

                            selectedDocument
                                .add(documentTypeList[index].documentName);
                            //sharedPreferences!.setBool(isCheckKey, documentTypeList[index].isSelected);
                            Navigator.pop(context);
                            // }
                          } else {
                            if (selectedDocument.isNotEmpty) {
                              selectedDocument
                                  .remove(documentTypeList[index].documentName);
                            }
                          }

                          setState(() {});
                        },
                        child: Container(
                          padding: EdgeInsets.all(size.width * numD02),
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: documentTypeList[index].isSelected
                                      ? Colors.blue
                                      : Colors.black),
                              borderRadius:
                                  BorderRadius.circular(size.width * numD02)),
                          child: Text(
                            "$uploadText ${documentTypeList[index].documentName.toCapitalized()}",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: size.width * numD06,
                ),
                /*  !govIdUploaded
                    ? InkWell(
                        onTap: () {
                          selectedType = "GovId";
                          pickFile();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(size.width * numD02),
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius:
                                  BorderRadius.circular(size.width * numD02)),
                          child: Text(
                            "$uploadText $govIdText ($passportText / $driverLicenseText)",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: !govIdUploaded ? size.width * numD04 : 0,
                ),
                !photoLicenseUploaded
                    ? InkWell(
                        onTap: () {
                          selectedType = "Photo";
                          pickFile();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: size.width,
                          padding: EdgeInsets.all(size.width * numD02),
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius:
                                  BorderRadius.circular(size.width * numD02)),
                          child: Text(
                            "$uploadText $photographyLicenseText",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: !photoLicenseUploaded ? size.width * numD04 : 0,
                ),
                !incorporateLicenseUploaded
                    ? InkWell(
                        onTap: () {
                          selectedType = "Company";
                          pickFile();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: size.width,
                          padding: EdgeInsets.all(size.width * numD02),
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius:
                                  BorderRadius.circular(size.width * numD02)),
                          child: Text(
                            "$uploadText $companyIncorporationText",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: size.width * numD04,
                ),*/
              ],
            );
          });
        });
  }

  /*  void pickFile(String fileName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc'],
        allowMultiple: false);

    if (result != null) {
      */
  /*  if (selectedType == "GovId") {
        govIdUploaded = true;*/
  /*
      debugPrint("docFile=====> $fileName");
      if (file1 == null) {
        file1 = File(result.files.single.path!);
        doc1Name = fileName;
      } else if (file2 == null) {
        file2 = File(result.files.single.path!);
        doc2Name = fileName;
      } else {
        file3 = File(result.files.single.path!);
        doc3Name = fileName;
      }

      */
  /*  } else if (selectedType == "Photo") {
        photoLicenseUploaded = true;

      } else if (selectedType == "Company") {
        incorporateLicenseUploaded = true;

      }*/
  /*
      */
  /* if(documentTypeList.isNotEmpty){
        documentTypeList[index].imageFile = File(result.files.single.path!);
      }*/
  /*
    }
    setState(() {});
  }*/

  void startVibration() async {
    bool canVibrate = await Vibrate.canVibrate;
    final Iterable<Duration> pauses = [
      const Duration(milliseconds: 50),
    ];

    if (canVibrate) {
      Vibrate.vibrateWithPauses(pauses);
    }
  }

  openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }
  }

  ///---------Apis Section---------

  void uploadCertificatesApi() {
    List<String> imgParams = [];
    List<Map<String, String>> docParam = [];
    List<File> filesPath = [];
    Map<String, String> map = {};
    docParam.clear();
    for (int i = 0; i < documentTypeList.length; i++) {
      if (documentTypeList[i].isSelected) {
        docParam.add({
          'doc_id': documentTypeList[i].id,
        });
      }
    }

    if (file1 != null) {
      imgParams.add("govt_id");
      filesPath.add(file1!);
      map.addAll({'govt_id_mediatype': documentTypeList[0].documentName});
    }

    if (file2 != null) {
      imgParams.add("photography_licence");
      filesPath.add(file2!);
      map.addAll({'photography_mediatype': documentTypeList[1].documentName});
    }

    if (file3 != null) {
      imgParams.add("comp_incorporation_cert");
      filesPath.add(file3!);
      map.addAll({
        'comp_incorporation_cert_mediatype': documentTypeList[2].documentName
      });
    }

    map.addAll({"doc": jsonEncode(docParam)});

    debugPrint("map======> $map");
    debugPrint("imgParams======> $imgParams");
    debugPrint("docParam======> $docParam");

    NetworkClass.multipartNetworkClassFiles(uploadCertificateUrl, this,
            uploadCertificateUrlRequest, map, filesPath)
        .callMultipartService(true, 'patch', imgParams, null);
  }

  void showUploadImageBottomSheet() {
    var size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size.width * numD04),
                      topRight: Radius.circular(size.width * numD04))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: size.width * numD06,
                        right: size.width * numD03,
                        top: size.width * numD018),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Option",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * numD048,
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close_rounded,
                                color: Colors.black,
                                size: size.width * numD08)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: size.width * numD06, right: size.width * numD06),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              getFromGallery("");
                              // getImages();
                            },
                            child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD02),
                                ),
                                height: size.width * numD25,
                                padding: EdgeInsets.all(size.width * numD02),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.upload,
                                        size: size.width * numD08),
                                    SizedBox(
                                      height: size.width * numD03,
                                    ),
                                    Text(
                                      "My Gallery",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * numD035,
                                          fontFamily: "AirbnbCereal",
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.05,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              pickFile("");
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD02),
                                ),
                                height: size.width * numD25,
                                padding: EdgeInsets.all(size.width * numD04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.file_copy_outlined,
                                      size: size.width * numD08,
                                    ),
                                    SizedBox(
                                      height: size.width * numD03,
                                    ),
                                    Text(
                                      "My Files",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * numD035,
                                          fontFamily: "AirbnbCereal",
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.width * numD06,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void getFromGallery(String fileName) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      if (file1 == null && doc1.isEmpty) {
        file1 = File(pickedFile.path);
        doc1Name = fileName;
        documentTypeList[0].isSelected = true;
        debugPrint("first image:::");
      } else if (file2 == null && doc2.isEmpty) {
        file2 = File(pickedFile.path);
        doc2Name = fileName;
        documentTypeList[1].isSelected = true;

        debugPrint("second image:::");
      } else {
        file3 = File(pickedFile.path);
        doc3Name = fileName;
        documentTypeList[2].isSelected = true;
        debugPrint("three image:::");
      }
      setState(() {});
    }
  }

  void pickFile(String fileName) async {
    debugPrint("inside in this if ::::::");
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false);
    if (result != null) {
      govIdUploaded = true;
      debugPrint("docFile=====> $fileName");

      if (file1 == null && doc1.isEmpty) {
        file1 = File(result.files.single.path!);
        doc1Name = fileName;
        documentTypeList[0].isSelected = true;
        debugPrint("first file:::::");
      } else if (file2 == null && doc2.isEmpty) {
        file2 = File(result.files.single.path!);
        doc2Name = fileName;
        documentTypeList[1].isSelected = true;

        debugPrint("second file:::::");
      } else {
        file3 = File(result.files.single.path!);
        doc3Name = fileName;
        documentTypeList[2].isSelected = true;
        debugPrint("third file:::::");
      }

      setState(() {});
    }
  }

  void deleteCertificatesApi(String path, String docId) {
    Map<String, String> map = {};

    if (type == "firstDoc") {
      map["govt_id"] = path;
      map.addAll({"doc_id": documentTypeList[0].id});
    } else if (type == "secondDoc") {
      map["photography_licence"] = path;
      map.addAll({"doc_id": documentTypeList[1].id});
    } else {
      map["comp_incorporation_cert"] = path;
      map.addAll({"doc_id": documentTypeList[2].id});
    }
    //  map.addAll({"doc_id":docId});

    debugPrint("map:::::::: $map");
    debugPrint("docId:::::$docId");
    NetworkClass.fromNetworkClass(
            deleteCertificateAPI, this, reqDeleteCertificateAPI, map)
        .callRequestServiceHeader(true, 'patch', null);
  }

  /// Document Type List
  void callGetCertificatesAPI() {
    Map<String, String> map = {
      'type': 'doc',
    };
    NetworkClass(getAllCmsUrl, this, getAllCmsUrlRequest)
        .callRequestServiceHeader(true, "get", map);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case uploadCertificateUrlRequest:
          debugPrint(
              'uploadCertificateUrlRequest_errorResponse ===> ${jsonDecode(response)}');
          showSnackBar("Error", uploadDocErrorMessage, Colors.red);
          break;
        case getAllCmsUrlRequest:
          debugPrint(
              'getAllCmsUrlRequest_errorResponse ===> ${jsonDecode(response)}');
          break;

        case reqDeleteCertificateAPI:
          debugPrint(
              'reqDeleteCertificateAPI_errorResponse ===> ${jsonDecode(response)}');
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
        case uploadCertificateUrlRequest:
          var map = jsonDecode(response);
          debugPrint("uploadCertificateUrlRequest========> $map");

          if (map["code"] == 200) {
            debugPrint("InsideDoc:::::::");
            if (map["docData"]["govt_id"] != null) {
              debugPrint("InsideGov");
              sharedPreferences!.setString(file1Key, map["docData"]["govt_id"]);
              sharedPreferences!
                  .setString(file1NameKey, map["docData"]["govt_id_mediatype"]);
              sharedPreferences!.setBool(skipDocumentsKey, true);
            }
            if (map["docData"]["photography_licence"] != null) {
              sharedPreferences!
                  .setString(file2Key, map["docData"]["photography_licence"]);
              sharedPreferences!.setString(
                  file2NameKey, map["docData"]["photography_mediatype"]);
              sharedPreferences!.setBool(skipDocumentsKey, true);
            }
            if (map["docData"]["comp_incorporation_cert"] != null) {
              sharedPreferences!.setString(
                  file3Key, map["docData"]["comp_incorporation_cert"]);
              sharedPreferences!.setString(file3NameKey,
                  map["docData"]["comp_incorporation_cert_mediatype"]);
              sharedPreferences!.setBool(skipDocumentsKey, true);
            }
            setState(() {});
          }
          showSnackBar(
              "Documents uploaded!", uploadDocMessage, colorOnlineGreen);
          debugPrint("uploadComplete::::$uploadComplete");
          debugPrint("menuScreen::::${widget.menuScreen}");
          if (widget.menuScreen) {
            uploadComplete = true;
            setState(() {});
          } else {
            uploadComplete = true;
            setState(() {});
            sharedPreferences!.setBool(skipDocumentsKey, true);
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => WelcomeScreen(
                          hideLeading: true,
                        )),
                (route) => false);
          }

          if (uploadComplete) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => Dashboard(
                          initialPosition: 4,
                        )),
                (route) => false);
          }
          break;

        case getAllCmsUrlRequest:
          debugPrint(
              'getAllCmsUrlRequest_successResponse ===> ${jsonDecode(response)}');
          var data = jsonDecode(response);
          var dataList = data['status'] as List;
          documentTypeList =
              dataList.map((e) => DocumentDataModel.fromJson(e)).toList();
          setState(() {});
          break;

        case reqDeleteCertificateAPI:
          debugPrint(
              'reqDeleteCertificateAPI_successResponse ===> ${jsonDecode(response)}');
          if (type == "firstDoc") {
            sharedPreferences?.remove(file1Key);
            sharedPreferences?.remove(file1NameKey);
            doc1 = "";
            doc1Name = "";
            file1 == null;
            setState(() {});
          } else if (type == "secondDoc") {
            sharedPreferences?.remove(file2Key);
            sharedPreferences?.remove(file2NameKey);
            doc2 = "";
            doc2Name = "";
            file2 == null;
            setState(() {});
          } else {
            sharedPreferences?.remove(file3Key);
            sharedPreferences?.remove(file3NameKey);
            doc3 = "";
            doc3Name = "";
            file3 == null;
            setState(() {});
          }

          callGetCertificatesAPI();

          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}

class DocumentDataModel {
  String id = "";
  String documentName = "";
  String documentId = "";
  File? imageFile;
  bool isSelected = false;

  DocumentDataModel({
    required this.id,
    required this.documentName,
    required this.documentId,
    required this.imageFile,
    required this.isSelected,
  });

  factory DocumentDataModel.fromJson(Map<String, dynamic> json) {
    return DocumentDataModel(
      id: json['_id'] ?? '',
      documentName: json['document_name'] ?? '',
      imageFile: null,
      isSelected:
          json['doc_details'] != null ? json['doc_details']['status'] : false,
      documentId:
          json['doc_details'] != null ? json['doc_details']['doc_id'] : "",
    );
  }
}


