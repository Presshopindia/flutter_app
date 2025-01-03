import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../utils/CommonAppBar.dart';
import '../dashboard/Dashboard.dart';

class DigitalIdScreen extends StatefulWidget {
  const DigitalIdScreen({super.key});

  @override
  State<DigitalIdScreen> createState() => _DigitalIdScreenState();
}

class _DigitalIdScreenState extends State<DigitalIdScreen> {
  late Size size;
  String userId = "0";
  String userImage = "";
  String userName = "";

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        title: Text(
          digitalId,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSize),
        ),
        centerTitle: true,
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
        hideLeading: false,
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: size.width * numD05,
          right: size.width * numD05,
          top: size.width * numD1,
          bottom: size.width * numD1,
        ),
        decoration: BoxDecoration(
            color: colorLightGrey,
            borderRadius: BorderRadius.circular(size.width * numD03),
            border: Border.all(width: 1.0, color: Colors.black)),
        padding: EdgeInsets.only(
          left: size.width * numD05,
          right: size.width * numD05,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: size.width * numD09,
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: size.width * numD30,
                      width: size.width * numD30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 1.5, color: Colors.black),
                          image: DecorationImage(
                            image: NetworkImage(userImage),
                            fit: BoxFit.cover,
                            onError: (context, stacktrace) {
                              Padding(
                                padding: EdgeInsets.all(size.width * numD07),
                                child: Image.asset(
                                  "${commonImagePath}rabbitLogo.png",
                                ),
                              );
                            },
                          )),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(size.width * numD08),
                        /*child: Image.network(
                          height: size.width * numD20,
                          width: size.width * numD20,
                          userImage,
                          // fit: BoxFit.cover,
                          errorBuilder: (context, exception, stacktrace) {
                            return Padding(
                              padding: EdgeInsets.all(size.width * numD07),
                              child: Image.asset(
                                "${commonImagePath}rabbitLogo.png",
                              ),
                            );
                          },
                        ),*/
                      ),
                    ),

                    SizedBox(
                      height: size.width * numD03,
                    ),

                    /// Name
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(
                        left: size.width * numD02,
                        bottom: size.width * numD05,
                      ),
                      child: Text(
                        userName,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD05,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                )),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    height: size.width * numD30,
                    child: QrImageView(
                     // data: "$userId\n https://www.presshop.co.uk",
                      data: "https://www.presshop.co.uk",
                      version: QrVersions.auto,
                    ),
                  ),
                )
              ],
            ),

            Container(
                padding: EdgeInsets.symmetric(
                  vertical: size.width * numD03,
                  horizontal: size.width * numD03,
                ),
                decoration: BoxDecoration(
                  color: colorThemePink,
                  borderRadius: BorderRadius.circular(size.width * numD03),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "${iconsPath}ic_verified.png",
                      height: size.width * numD085,
                      width: size.width * numD085,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: size.width * numD05,
                    ),
                    Text(
                      verifiedHopperText,
                      textAlign: TextAlign.start,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD06,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                )),

            /// Digital ID Expire
            Container(
                width: size.width,
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: size.width * numD05),
                padding: EdgeInsets.symmetric(
                  vertical: size.width * numD03,
                  horizontal: size.width * numD03,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size.width * numD03),
                    border: Border.all(width: 1.0, color: Colors.black)),
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    text: digitalIdExpireOnText,
                    style: TextStyle(
                        fontSize: size.width * numD038,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        height: 1.5),
                    children: [
                      TextSpan(
                        text: DateFormat("dd MMM yyyy").format(DateTime.now()),
                        style: TextStyle(
                            fontSize: size.width * numD038,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            height: 1.5),
                      )
                    ],
                  ),
                )),

            /// Company Address
            Container(
                margin: EdgeInsets.only(top: size.width * numD05),
                padding: EdgeInsets.symmetric(
                  vertical: size.width * numD05,
                  horizontal: size.width * numD03,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size.width * numD03),
                    border: Border.all(width: 1.0, color: Colors.black)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width / 4,
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        height: size.width * numD13,
                        width: size.width * numD13,
                      ),
                    ),
                    SizedBox(
                      width: size.width * numD03,
                    ),
                    /*  Expanded(
                        child: RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: mediaUk,
                        style: TextStyle(
                            fontSize: size.width * numD038,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            height: 1.5),
                        children: [
                          TextSpan(
                            text: companyName,
                            style: TextStyle(
                                fontSize: size.width * numD038,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                height: 1.5),
                          )
                        ],
                      ),
                    )),*/
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mediaUk,
                            style: TextStyle(
                                fontSize: size.width * numD038,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                height: 1.5),
                          ),
                          Text(
                            companyName,
                            style: TextStyle(
                                fontSize: size.width * numD038,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                height: 1.5),
                          ),
                        ],
                      ),
                    )
                  ],
                )),

            SizedBox(
              height: size.width * numD1,
            )
          ],
        ),
      ),
    );
  }

  void getUserData() {
    userImage = avatarImageUrl + (sharedPreferences!.getString(avatarKey) ?? "");
    userName = sharedPreferences!.getString(userNameKey)!;
    userId = sharedPreferences!.getString(hopperIdKey) ?? "";

    debugPrint("OriginalName: $userName");

    setState(() {});
  }
}
