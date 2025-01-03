import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presshop/utils/CommonTextField.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';

import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonWigdets.dart';
import '../dashboard/Dashboard.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    implements NetworkResponse {
  var formKey = GlobalKey<FormState>();

  late Size size;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  bool hideNewPassword = false;
  bool hideCurrentPassword = false;
  bool hideConfirmPassword = false;
  String passwordStrengthValue = "";

  @override
  void initState() {
    super.initState();
    setPasswordListener();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          changePasswordText,
          style: TextStyle(
              color: Colors.black,
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
        child: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * numD05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: size.width * numD11, right: size.width * numD1),
                  child: Text(
                    changePasswordSubTitleText,
                    style: TextStyle(
                        color: Colors.black, fontSize: size.width * numD033),
                  ),
                ),
                SizedBox(
                  height: size.width * numD06,
                ),
                Expanded(
                    child: ListView(
                  children: [
                    /// Current Password
                    Text(
                      currentPasswordText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),
                    CommonTextField(
                      size: size,
                      controller: _currentPasswordController,
                      hintText: enterCurrentPasswordHintText,
                      textInputFormatters: null,
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_key.png",
                        ),
                      ),
                      prefixIconHeight: size.width * numD08,
                      suffixIconIconHeight: size.width * numD08,
                      suffixIcon: InkWell(
                        onTap: () {
                          hideCurrentPassword = !hideCurrentPassword;
                          setState(() {});
                        },
                        child: ImageIcon(
                          !hideCurrentPassword
                              ? const AssetImage(
                                  "${iconsPath}ic_show_eye.png",
                                )
                              : const AssetImage(
                                  "${iconsPath}ic_block_eye.png",
                                ),
                          color: !hideCurrentPassword
                              ? colorTextFieldIcon
                              : colorHint,
                        ),
                      ),
                      hidePassword: hideCurrentPassword,
                      keyboardType: TextInputType.text,
                      validator: checkPasswordValidator,
                      enableValidations: true,
                      filled: false,
                      filledColor: Colors.transparent,
                      maxLines: 1,
                      borderColor: colorTextFieldBorder,
                      autofocus: false,
                    ),
                    SizedBox(
                      height: size.width * numD06,
                    ),

                    /// New Password
                    Text(
                      newPasswordText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),
                    /*     CommonTextField(
                        size: size,
                        controller: _confirmNewPasswordController,
                        hintText: enterNewPasswordHint,
                        textInputFormatters: null,
                        prefixIcon: const ImageIcon(
                          AssetImage(
                            "${iconsPath}ic_key.png",
                          ),
                        ),
                        prefixIconHeight: size.width * numD06,
                        suffixIconIconHeight: 0,
                        suffixIcon: null,
                        hidePassword: false,
                        keyboardType: TextInputType.text,
                        validator: checkPasswordValidator,
                        enableValidations: true,
                        filled: false,
                        filledColor: Colors.transparent,
                        maxLines: 1,
                        borderColor: colorTextFieldBorder,
                      autofocus: false,

                    ),
                    SizedBox(
                      height: size.width * numD06,
                    ),*/
                    CommonTextField(
                      size: size,
                      maxLines: 1,
                      borderColor: colorTextFieldBorder,
                      controller: _newPasswordController,
                      hintText: enterNewPasswordHint,
                      textInputFormatters: null,
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_key.png",
                        ),
                      ),
                      prefixIconHeight: size.width * numD08,
                      suffixIconIconHeight: size.width * numD08,
                      suffixIcon: InkWell(
                        onTap: () {
                          hideNewPassword = !hideNewPassword;
                          setState(() {});
                        },
                        child: ImageIcon(
                          !hideNewPassword
                              ? const AssetImage(
                            "${iconsPath}ic_show_eye.png",
                          )
                              : const AssetImage(
                            "${iconsPath}ic_block_eye.png",
                          ),
                          color: !hideNewPassword
                              ? colorTextFieldIcon
                              : colorHint,
                        ),
                      ),
                      hidePassword: hideNewPassword,
                      keyboardType: TextInputType.text,
                      validator: checkPasswordValidator,
                      enableValidations: true,
                      filled: false,
                      filledColor: Colors.transparent,
                      autofocus: false,
                    ),

                    SizedBox(
                      height: size.width * numD06,
                    ),

                    /// Confirm New Password
                    Text(
                      confirmNewPasswordText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),
                    CommonTextField(
                      size: size,
                      maxLines: 1,
                      borderColor: colorTextFieldBorder,
                      controller: _confirmNewPasswordController,
                      hintText: confirmNewPasswordText,
                      textInputFormatters: null,
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_key.png",
                        ),
                      ),
                      prefixIconHeight: size.width * numD08,
                      suffixIconIconHeight: size.width * numD08,
                      suffixIcon: InkWell(
                        onTap: () {
                          hideConfirmPassword = !hideConfirmPassword;
                          setState(() {});
                        },
                        child: ImageIcon(
                          !hideConfirmPassword
                              ? const AssetImage(
                                  "${iconsPath}ic_show_eye.png",
                                )
                              : const AssetImage(
                                  "${iconsPath}ic_block_eye.png",
                                ),
                          color: !hideConfirmPassword
                              ? colorTextFieldIcon
                              : colorHint,
                        ),
                      ),
                      hidePassword: hideConfirmPassword,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return requiredText;
                        } else if (value.length < 8) {
                          return passwordErrorText;
                        } else if (_newPasswordController.text.trim() !=
                            value) {
                          return confirmPasswordErrorText;
                        }
                        return null;
                      },
                      enableValidations: true,
                      filled: false,
                      filledColor: Colors.transparent,
                      autofocus: false,
                    ),

                    SizedBox(
                      height: size.width * numD30,
                    ),

                    /// Button
                    Container(
                      width: size.width,
                      height: size.width * numD13,
                      margin:
                          EdgeInsets.symmetric(horizontal: size.width * numD04),
                      child: commonElevatedButton(
                          submitText,
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, colorThemePink), () {
                        if (formKey.currentState!.validate()) {
                          changePasswordApi();
                        }
                      }),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setPasswordListener() {
    _newPasswordController.addListener(() {
      var m = passwordExpression.hasMatch(_newPasswordController.text.trim());

      debugPrint("EmailExpression: $m");

      if (_newPasswordController.text.isNotEmpty &&
              _newPasswordController.text.length >=
                  8 /*&&
          !passwordExpression.hasMatch(_newPasswordController.text.trim())*/
          ) {
        passwordStrengthValue = weakText;
      } else if (_newPasswordController.text.isNotEmpty &&
          _newPasswordController.text.length >= 8 &&
          passwordExpression.hasMatch(_newPasswordController.text.trim())) {
        passwordStrengthValue = strongText;
      } else {
        passwordStrengthValue = "";
      }

      setState(() {});
    });
  }

  ///--------Apis Section------------

  void changePasswordApi() {
    Map<String, String> params = {
      "old_password": _currentPasswordController.text.trim(),
      "new_password": _newPasswordController.text.trim()
    };
    debugPrint("ChangePasswordParams: $params");
    NetworkClass.fromNetworkClass(
            changePasswordUrl, this, changePasswordUrlRequest, params)
        .callRequestServiceHeader(true, "post", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case changePasswordUrlRequest:
          debugPrint("ChangePasswordError: $response");
          var map = jsonDecode(response);
          debugPrint("LoginError:$map");
          showSnackBar("Error", map["errors"]["msg"], Colors.red);
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
        case changePasswordUrlRequest:
          var map = jsonDecode(response);
          debugPrint("ChangePasswordResponse: $response");

          if (map["code"] == 200) {
            _newPasswordController.clear();
            _currentPasswordController.clear();
            _confirmNewPasswordController.clear();
            Navigator.pop(context);
            showSnackBar(
                "Password Updated!",
                "Your password has been changed successfully!",
                colorOnlineGreen);
          }
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}
