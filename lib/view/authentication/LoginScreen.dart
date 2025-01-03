import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonTextField.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/authentication/ForgotPasswordScreen.dart';
import 'package:presshop/view/authentication/SignUpScreen.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../main.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../bankScreens/AddBankScreen.dart';
import 'UploadDocumnetsScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> implements NetworkResponse {
  var formKey = GlobalKey<FormState>();
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

/*  String socialId = "",
      socialName = "",
      socialEmail = "",
      socialPhoneNumber = "";*/

  bool hidePassword = true;

  late GoogleSignInAccount _userObj;
  bool _isLoggedIn = false;
  String socialEmail = "";
  String socialId = "";
  String socialName = "";
  String socialProfileImage = "";
  String socialType = "";

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD25,
                  ),
                  Text(
                    goodMorningText,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: size.width * numD07),
                  ),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  Text(loginSubTitleText,
                      style: TextStyle(
                          color: Colors.black, fontSize: size.width * numD035)),

                  SizedBox(
                    height: size.width * numD08,
                  ),

                  /// User name controller
                  CommonTextField(
                    size: size,
                    borderColor: colorTextFieldBorder,
                    maxLines: 1,
                    controller: loginController,
                    hintText: loginUserHint,
                    textInputFormatters: null,
                    prefixIcon: const ImageIcon(
                      AssetImage(
                        "${iconsPath}ic_user.png",
                      ),
                    ),
                    prefixIconHeight: size.width * numD05,
                    suffixIconIconHeight: 0,
                    suffixIcon: null,
                    hidePassword: false,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return requiredText;
                      } else if (value.trim().length < 4) {
                        return validUserNameOrPhoneText;
                      }
                      return null;
                    },
                    enableValidations: true,
                    filled: false,
                    filledColor: Colors.transparent,
                    autofocus: false,
                  ),

                  SizedBox(
                    height: size.width * numD08,
                  ),

                  /// Password Controller
                  CommonTextField(
                    size: size,
                    maxLines: 1,
                    borderColor: colorTextFieldBorder,
                    controller: passwordController,
                    hintText: enterPasswordHint,
                    textInputFormatters: null,
                    prefixIcon: const ImageIcon(
                      AssetImage(
                        "${iconsPath}ic_key.png",
                      ),
                    ),
                    prefixIconHeight: size.width * numD07,
                    suffixIconIconHeight: size.width * numD06,
                    suffixIcon: InkWell(
                      onTap: () {
                        hidePassword = !hidePassword;
                        setState(() {});
                      },
                      child: ImageIcon(
                        !hidePassword
                            ? const AssetImage(
                                "${iconsPath}ic_show_eye.png",
                              )
                            : const AssetImage(
                                "${iconsPath}ic_block_eye.png",
                              ),
                        color: !hidePassword ? colorTextFieldIcon : colorHint,
                      ),
                    ),
                    hidePassword: hidePassword,
                    keyboardType: TextInputType.text,
                    validator: checkPasswordValidator,
                    enableValidations: true,
                    filled: false,
                    filledColor: Colors.transparent,
                    autofocus: false,
                  ),

                  /// Forgot password
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen()));
                          },
                          child: Text(
                            "$forgotPasswordText?",
                            style: TextStyle(
                                color: colorThemePink,
                                fontSize: size.width * numD035,
                                fontWeight: FontWeight.w500),
                          ))),

                  SizedBox(
                    height: size.width * numD08,
                  ),

                  /// SignIn Button
                  SizedBox(
                    width: size.width,
                    height: size.width * numD13,
                    child: commonElevatedButton(
                        signInText,
                        size,
                        commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                        commonButtonStyle(size, colorThemePink), () async {
                      if (formKey.currentState!.validate()) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        loginApi();
                      }
                    }),
                  ),

                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.width * numD02),
                      child: Text(
                        orText,
                        style: TextStyle(
                            color: Colors.black, fontSize: size.width * numD04),
                      ),
                    ),
                  ),

                  /// Apple Id Login
              /*    Platform.isAndroid
                      ? Column(
                          children: [
                            SizedBox(
                              height: size.width * numD13,
                              width: size.width,
                              child: SignInWithAppleButton(
                                height: size.width*numD09,

                                onPressed: () async {
                                  final credential = await SignInWithApple
                                      .getAppleIDCredential(
                                    scopes: [
                                      AppleIDAuthorizationScopes.email,
                                      AppleIDAuthorizationScopes.fullName,
                                    ],
                                  );

                                  debugPrint("AppleCredentials: $credential");
                                  if (credential != null) {
                                    // socialId = credential.userIdentifier ?? "";
                                    socialId = credential.userIdentifier ?? "";
                                    socialEmail = credential.email ?? "";
                                    socialName = credential.givenName ??
                                        credential.familyName ??
                                        "";
                                    //socialPhoneNumber = '';

                                    debugPrint("socialEmail: $socialEmail");
                                    debugPrint("socialName: $socialName");
                                    debugPrint("SocialId: $socialId");
                                    socialExistsApi();
                                  }
                                },
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                              ),
                            ),
                            SizedBox(
                              height: size.width * numD04,
                            ),
                          ],
                        )
                      : Container(),*/

                  Platform.isIOS?Container(
                    width: size.width,
                    height: size.width * numD13,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.black,
                        borderRadius:
                        BorderRadius.circular(size.width * numD04),
                        border: Border.all(color: colorGoogleButtonBorder)),
                    child: InkWell(
                      splashColor: Colors.grey.shade300,
                      onTap: () async {
                        final credential = await SignInWithApple
                            .getAppleIDCredential(
                          scopes: [
                            AppleIDAuthorizationScopes.email,
                            AppleIDAuthorizationScopes.fullName,
                          ],
                        );

                        debugPrint("AppleCredentials: $credential");
                        if (credential != null) {
                          socialId = credential.userIdentifier ?? "";
                          socialEmail = credential.email ?? "";
                          socialName = credential.givenName ??
                              credential.familyName ??
                              "";
                          //socialPhoneNumber = '';

                          debugPrint("socialEmail: $socialEmail");
                          debugPrint("socialName: $socialName");
                          debugPrint("SocialId: $socialId");
                          socialExistsApi();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "${iconsPath}appleLogo.png",
                            height:size.width *numD045,
                            width:size.width *numD045,
                            color: Colors.white,
                          ),
                          SizedBox(
                              width:size.width*numD01
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Sign in with Apple",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * numD036,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    ),
                  ):Container(),
                  SizedBox(
                    height: size.width * numD04,
                  ),
               /*   Platform.isIOS
                      ? Container(
                    width: size.width,
                    height: size.width * numD12,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(size.width * numD04),
                        border: Border.all(color: colorGoogleButtonBorder)),
                    child: InkWell(
                      splashColor: Colors.grey.shade300,
                      onTap: () async {
                        User? user = await Authentication.signInWithGoogle(
                            context: context);
                        if (user != null) {
                          final credential = await SignInWithApple
                              .getAppleIDCredential(
                            scopes: [
                              AppleIDAuthorizationScopes.email,
                              AppleIDAuthorizationScopes.fullName,
                            ],
                          );

                          debugPrint("AppleCredentials: $credential");
                          if (credential != null) {
                            // socialId = credential.userIdentifier ?? "";
                            socialId = credential.userIdentifier ?? "";
                            socialEmail = credential.email ?? "";
                            socialName = credential.givenName ??
                                credential.familyName ??
                                "";
                            //socialPhoneNumber = '';

                            debugPrint("socialEmail: $socialEmail");
                            debugPrint("socialName: $socialName");
                            debugPrint("SocialId: $socialId");
                            socialExistsApi();
                          }
                        } else {
                          debugPrint("Some Google Login Error");
                        }
                      },
                      child: Stack(
                        children: [
                          Positioned(
                              top: 0,
                              bottom: 0,
                              left: size.width * numD01,
                              child: Padding(
                                padding: EdgeInsets.all(size.width * numD025),
                                child: Image.asset(
                                  "assets/icons/appleLogo.png",
                                ),
                              )),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              continueGoogleText,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD035,
                                  fontWeight: FontWeight.w700),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                      : Container(),*/
                  /// Google SignIn
                  Container(
                    width: size.width,
                    height: size.width * numD13,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                        border: Border.all(color: colorGoogleButtonBorder)),
                    child: InkWell(
                      splashColor: Colors.grey.shade300,
                      onTap: () async {
                        debugPrint("inside::::::");
                        googleLogin();
                        /*User? user = await Authentication.signInWithGoogle(
                            context: context);
                        debugPrint("google ::::::");
                        if (user != null) {
                          socialId = user.uid;
                          socialEmail = user.email ?? "";
                          socialName = user.displayName ?? "";
                          socialPhoneNumber = user.phoneNumber ?? "";
                          socialExistsApi();
                        } else {
                          debugPrint("Some Google Login Error");
                        }*/

                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left:size.width * numD07),
                            child: Image.asset(
                              "${iconsPath}ic_google.png",
                              height:size.width *numD045,
                              width:size.width *numD045,
                            ),
                          ),
                          SizedBox(
                            width:size.width*numD01
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              continueGoogleText,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD036,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),



                  SizedBox(
                    height: size.width * numD04,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                          text: donotHaveAccountText,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * numD035,
                              fontWeight: FontWeight.normal)),
                      WidgetSpan(
                          child: SizedBox(
                        width: size.width * 0.005,
                      )),
                      WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SignUpScreen(
                                        socialLogin: false,
                                        socialId: "",
                                        name: "",
                                        email: "",
                                        phoneNumber: '',
                                      )));
                            },
                            child: Text(clickHereToJoinText,
                                style: TextStyle(
                                    color: colorThemePink,
                                    fontSize: size.width * numD035,
                                    fontWeight: FontWeight.w500)),
                          ))
                    ]),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> googleLogin() async {
    googleSignIn.signIn().then((userData) {
      _isLoggedIn = true;
      _userObj = userData!;

      socialId = _userObj.id;
      socialType = "google";

      if (_userObj.email.isNotEmpty) {
        socialEmail = _userObj.email;
      }
      if (_userObj.displayName != null) {
        socialName = _userObj.displayName!;
      }
      if (_userObj.photoUrl != null) {
        socialProfileImage = _userObj.photoUrl!;
      } else {
        socialProfileImage = "";
      }
      /*callSocialLoginGoogleApi(
          "google", socialId, socialName, socialEmail, socialProfileImage);*/
      socialExistsApi();
      debugPrint("userObj ::${_userObj.toString()}");
      debugPrint("social email ::${_userObj.email.toString()}");
      debugPrint("social displayName ::${_userObj.displayName.toString()}");
      debugPrint("social photoUrl ::${_userObj.photoUrl.toString()}");
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  ///-------LoginApi-----------


  void loginApi() {
    try {
      Map<String, String> params = {
        "userNameOrPhone": loginController.text.trim(),
        "password": passwordController.text.trim()
      };

      debugPrint("LoginParams: $params");
      NetworkClass.fromNetworkClass(loginUrl, this, loginUrlRequest, params)
          .callRequestServiceHeader(true, "post", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void socialExistsApi() {
    try {
      Map<String, String> params = {
        "social_id": socialId,
        "social_type": Platform.isIOS ? "apple" : "google"
      };

      NetworkClass.fromNetworkClass(
              socialExistUrl, this, socialExistUrlRequest, params)
          .callRequestServiceHeader(true, "post", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case loginUrlRequest:
          var map = jsonDecode(response);
          debugPrint("LoginError:$map");
          if (map["code"] == 409) {
            commonErrorDialogDialog(MediaQuery.of(context).size,
                map["errors"]["msg"].toString().replaceAll("_", " "), map["code"].toString(), () {
              Navigator.pop(context);
            });
          } else if (map["code"] == 422) {
            commonErrorDialogDialog(MediaQuery.of(context).size,
                map["errors"]["msg"].toString().replaceAll("_", " "), map["code"].toString(), () {
                  Navigator.pop(context);
                });
          } else {
            commonErrorDialogDialog(
                MediaQuery.of(context).size,
                "Please enter valid username, phone number or password",
                map["code"].toString(), () {
              Navigator.pop(context);
            });
          }
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
        case loginUrlRequest:
          var map = jsonDecode(response);
          debugPrint("LoginResponse:::::::$map");

          if (map["code"] == 200) {
            rememberMe = true;
            sharedPreferences!.setBool(rememberKey, true);
            sharedPreferences!.setString(tokenKey, map[tokenKey]);
            sharedPreferences!.setString(hopperIdKey, map["user"][hopperIdKey]);
            sharedPreferences!
                .setString(firstNameKey, map["user"][firstNameKey]);
            sharedPreferences!.setString(lastNameKey, map["user"][lastNameKey]);
            sharedPreferences!.setString(userNameKey, map["user"][userNameKey]);
            sharedPreferences!.setString(emailKey, map["user"][emailKey]);
            sharedPreferences!
                .setString(countryCodeKey, map["user"][countryCodeKey]);
            sharedPreferences!.setString(addressKey, map["user"][addressKey]);
            if (map["user"][postCodeKey] != null) {
              sharedPreferences!
                  .setString(addressKey, map["user"][postCodeKey]);
            }

            sharedPreferences!
                .setString(latitudeKey, map["user"][latitudeKey].toString());
            sharedPreferences!
                .setString(longitudeKey, map["user"][longitudeKey].toString());
            if (map["user"][avatarIdKey] != null) {
              sharedPreferences!.setString(
                  avatarIdKey, map["user"][avatarIdKey]["_id"].toString());
              sharedPreferences!
                  .setString(avatarKey, map["user"][avatarIdKey][avatarKey]);
            }

            sharedPreferences!.setBool(receiveTaskNotificationKey,
                map["user"][receiveTaskNotificationKey]);
            sharedPreferences!
                .setBool(isTermAcceptedKey, map["user"][isTermAcceptedKey]);

            if (map["user"][profileImageKey] != null) {
              sharedPreferences!
                  .setString(profileImageKey, map["user"][profileImageKey]);
            }

            if (map["user"]["doc_to_become_pro"] != null) {
              debugPrint("InsideDocccc");
              if (map["user"]["doc_to_become_pro"]["govt_id"] != null) {
                debugPrint("InsideGov");

                sharedPreferences!.setString(
                    file1Key, map["user"]["doc_to_become_pro"]["govt_id"]);
                sharedPreferences!.setBool(skipDocumentsKey, true);
              }
              if (map["user"]["doc_to_become_pro"]["comp_incorporation_cert"] !=
                  null) {
                sharedPreferences!.setString(
                    file2Key,
                    map["user"]["doc_to_become_pro"]
                        ["comp_incorporation_cert"]);
                sharedPreferences!.setBool(skipDocumentsKey, true);
              }

              if (map["user"]["doc_to_become_pro"]["photography_licence"] !=
                  null) {
                sharedPreferences!.setString(file3Key,
                    map["user"]["doc_to_become_pro"]["photography_licence"]);
                sharedPreferences!.setBool(skipDocumentsKey, true);
              }
            }

            if (map["user"]["bank_detail"] != null) {
              var bankList = map["user"]["bank_detail"] as List;
              if (bankList.isEmpty) {
                onBoardingCompleteDialog(size:MediaQuery.of(context).size,func: (){
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => AddBankScreen(
                            showPageNumber: true,
                            hideLeading: true,
                            editBank: false,
                            myBankList: [],
                          )),
                          (route) => false);
                });

              } else {
                if (sharedPreferences!.getBool(skipDocumentsKey) != null) {
                  bool skipDoc = sharedPreferences!.getBool(skipDocumentsKey)!;

                  if (skipDoc) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                Dashboard(initialPosition: 2)),
                        (route) => false);
                  } else {
      onBoardingCompleteDialog(size:MediaQuery.of(context).size,func: (){
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => UploadDocumentsScreen(
                  menuScreen: false,
                  hideLeading: true,
                )),
                (route) => false);
      });
                  }
                } else {
                  onBoardingCompleteDialog(size:MediaQuery.of(context).size,func: (){
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => UploadDocumentsScreen(
                              menuScreen: false,
                              hideLeading: true,
                            )),
                            (route) => false);
                  });
                }
              }
            }
          }
          break;

        case socialExistUrlRequest:
          var map = jsonDecode(response);
          debugPrint("SocialExistResponse: $response");

          if (map["code"] == 200) {
            if (map["token"] != null) {
              debugPrint("inside this::::::");
              //rememberMe = true;
              //sharedPreferences!.setBool(rememberKey, true);
              sharedPreferences!.setString(tokenKey, map[tokenKey]);
              sharedPreferences!
                  .setString(hopperIdKey, map["user"][hopperIdKey]);
              sharedPreferences!
                  .setString(firstNameKey, map["user"][firstNameKey]);
              sharedPreferences!
                  .setString(lastNameKey, map["user"][lastNameKey]);
              sharedPreferences!
                  .setString(userNameKey, map["user"][userNameKey]);
              sharedPreferences!.setString(emailKey, map["user"][emailKey]);
              sharedPreferences!
                  .setString(countryCodeKey, map["user"][countryCodeKey]);
              sharedPreferences!.setString(addressKey, map["user"][addressKey]);
              sharedPreferences!
                  .setString(latitudeKey, map["user"][latitudeKey].toString());
              sharedPreferences!.setString(
                  longitudeKey, map["user"][longitudeKey].toString());
              if (map["user"][avatarIdKey] != null) {
                sharedPreferences!.setString(
                    avatarIdKey, map["user"][avatarIdKey]["_id"].toString());
                sharedPreferences!
                    .setString(avatarKey, map["user"][avatarIdKey][avatarKey]);
              }

              sharedPreferences!.setBool(receiveTaskNotificationKey,
                  map["user"][receiveTaskNotificationKey]);
              sharedPreferences!
                  .setBool(isTermAcceptedKey, map["user"][isTermAcceptedKey]);

              if (map["user"][profileImageKey] != null) {
                sharedPreferences!
                    .setString(profileImageKey, map["user"][profileImageKey]);
              }

              if (map["user"]["doc_to_become_pro"] != null) {
                debugPrint("InsideDoc");
                if (map["user"]["doc_to_become_pro"]["govt_id"] != null) {
                  debugPrint("InsideGov");

                  sharedPreferences!.setString(
                      file1Key, map["user"]["doc_to_become_pro"]["govt_id"]);
                  sharedPreferences!.setBool(skipDocumentsKey, true);
                }
                if (map["user"]["doc_to_become_pro"]
                        ["comp_incorporation_cert"] !=
                    null) {
                  sharedPreferences!.setString(
                      file2Key,
                      map["user"]["doc_to_become_pro"]
                          ["comp_incorporation_cert"]);
                  sharedPreferences!.setBool(skipDocumentsKey, true);
                }

                if (map["user"]["doc_to_become_pro"]["photography_licence"] !=
                    null) {
                  sharedPreferences!.setString(file3Key,
                      map["user"]["doc_to_become_pro"]["photography_licence"]);
                  sharedPreferences!.setBool(skipDocumentsKey, true);
                }
              }

              if (map["user"]["bank_detail"] != null) {
                var bankList = map["user"]["bank_detail"] as List;
                debugPrint("bankList:::::${bankList.length}");
                if (bankList.isEmpty) {
                onBoardingCompleteDialog(size: MediaQuery.of(context).size, func: (){
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => AddBankScreen(
                            showPageNumber: true,
                            hideLeading: true,
                            editBank: false,
                            myBankList: [],
                          )),
                          (route) => false);
                });
                } else {
                  if (sharedPreferences!.getBool(skipDocumentsKey) != null) {
                    bool skipDoc =
                        sharedPreferences!.getBool(skipDocumentsKey)!;
                    if (skipDoc) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) =>
                                  Dashboard(initialPosition: 2)),
                          (route) => false);
                    } else {
                      onBoardingCompleteDialog(size:MediaQuery.of(context).size,func: (){
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => UploadDocumentsScreen(
                                  menuScreen: false,
                                  hideLeading: true,
                                )),
                                (route) => false);
                      });

                    }
                  } else {
                    onBoardingCompleteDialog(size:MediaQuery.of(context).size,func: (){
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => UploadDocumentsScreen(
                                menuScreen: false,
                                hideLeading: true,
                              )),
                              (route) => false);
                    });
                  }
                }
              }
            } else {
              Navigator.of(navigatorKey.currentState!.context)
                  .push(MaterialPageRoute(
                      builder: (context) => SignUpScreen(
                            socialLogin: true,
                            socialId: socialId,
                            name: socialName,
                            email: socialEmail,
                            phoneNumber: "",
                          )));
            }
          }
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}

class Authentication {
  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    showLoaderDialog(context);
    FirebaseAuth auth = FirebaseAuth.instance;
    debugPrint('inside authentication====>');
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();
    debugPrint('inside authentication2====>');
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    debugPrint('inside authentication3====>');
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      debugPrint('inside authentication4====>');
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
        debugPrint("user===>$user");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          showSnackBar(
              "Error",
              "This account already exists with different credentials",
              Colors.red);

          //  showToast(message: "account-exists-with-different-credential");
        } else if (e.code == 'invalid-credential') {
          // showToast(message: "invalid-credential");
          showSnackBar(
              "Invalid Credentials", "The credentials are invalid", Colors.red);
        }
      } catch (e) {
        debugPrint("$e");
      }
    }
    Navigator.pop(navigatorKey.currentContext!);
    return user;
  }

  static Future<void> signOutWithGoogle({required BuildContext context}) async {
    showLoaderDialog(context);
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    googleSignIn.isSignedIn().then((value) {
      if (value) {
        auth.signOut();
        googleSignIn.signOut();
      }
    });
    Navigator.pop(navigatorKey.currentContext!);
  }

  static Future<bool> signInAlready() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    return await googleSignIn.isSignedIn();
  }
}
