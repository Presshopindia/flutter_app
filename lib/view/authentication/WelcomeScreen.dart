import 'package:flutter/material.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonTextField.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/authentication/SignUpScreen.dart';
import 'package:presshop/view/bankScreens/AddBankScreen.dart';

import '../../utils/CommonAppBar.dart';
import '../dashboard/Dashboard.dart';

class WelcomeScreen extends StatefulWidget {

  bool hideLeading = false;

   WelcomeScreen({
    super.key,
     required this.hideLeading
  });

  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  String userName = "Strong 1";

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
        child: Form(
          child: ListView(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * numD06, vertical: size.width * numD05),
            children: [
              Text(
                "$hiText $userName, $welcomeToText $presshopText",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: size.width * numD07),
              ),
              SizedBox(
                height: size.width * numD02,
              ),
              Text(
                welcomeSubTitleText,
                style: TextStyle(
                    color: Colors.black, fontSize: size.width * numD04),
              ),
              SizedBox(
                height: size.width * numD08,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(size.width * numD03)),
                padding: EdgeInsets.all(size.width * numD04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(welcomeSubTitle1Text,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD04,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: size.width * numD04,
                    ),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colorThemePink,
                            size: size.width * numD06,
                          ),
                          SizedBox(
                            width: size.width * numD02,
                          ),
                          Expanded(
                            child: Text(acceptedTermsText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD045,
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
                            Icons.check_circle,
                            color: colorThemePink,
                            size: size.width * numD06,
                          ),
                          SizedBox(
                            width: size.width * numD02,
                          ),
                          Expanded(
                            child: Text(verifyYourAccountText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD045,
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
                            Icons.check_circle,
                            color: colorThemePink,
                            size: size.width * numD06,
                          ),
                          SizedBox(
                            width: size.width * numD02,
                          ),
                          Expanded(
                            child: Text(addedBankDetailsText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD045,
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
                            Icons.check_circle,
                            color: colorThemePink,
                            size: size.width * numD06,
                          ),
                          SizedBox(
                            width: size.width * numD02,
                          ),
                          Expanded(
                            child: Text(uploadedDocumentsProText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD045,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ]),
                  ],
                ),
              ),
              SizedBox(
                height: size.width * numD15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: SizedBox(
                    height: size.width * numD15,
                    child: commonElevatedButton(
                        myAccountText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, Colors.black), () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => Dashboard(
                                    initialPosition: 4,
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
                        cameraText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink), () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => Dashboard(
                                initialPosition: 2,
                                  )),
                          (route) => false);
                    }),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
