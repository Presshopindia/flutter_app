import 'dart:convert';
import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/authentication/TermCheckScreen.dart';
import 'package:presshop/view/authentication/VerifyAccountScreen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../main.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../../utils/CommonTextField.dart';
import '../../utils/CommonWigdets.dart';
import '../bankScreens/AddBankScreen.dart';
import '../dashboard/Dashboard.dart';
import 'LoginScreen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'UploadDocumnetsScreen.dart';

class SignUpScreen extends StatefulWidget {
  bool socialLogin = false;
  String socialId = "";
  String name = "";
  String email = "";
  String phoneNumber = "";

  SignUpScreen(
      {super.key,
      required this.socialLogin,
      required this.socialId,
      required this.email,
      required this.name,
      required this.phoneNumber});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin
    implements NetworkResponse {
  var formKey = GlobalKey<FormState>();
  var scrollController = ScrollController();

  late AnimationController controller;

  final ImagePicker _picker = ImagePicker();
  final RegExp _restrictPattern = RegExp(
    r"@(gmail\.com|yahoo\.com|hotmail\.com|outlook\.com)$",
    caseSensitive: true,
  );
  final RegExp _restrictPatter2 = RegExp(r'@(gmail|yahoo|hotmail|outlook)\.');
  final RegExp _restrictPatter3 =
      RegExp('gmail|yahoo|hotmail|outlook', caseSensitive: false);

  ///TextEditingController
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController avatarController = TextEditingController();

  String passwordStrengthValue = "",
      userImagePath = "",
      avatarBaseUrl = "",
      selectedAvatar = "",
      selectedAvatarId = "",
      latitude = "",
      longitude = "",
      selectedCountryCodePicker = "+44";

  bool hidePassword = true,
      hideConfirmPassword = true,
      enableNotifications = false,
      showImageError = false,
      userNameAlreadyExists = false,
      emailAlreadyExists = false,
      phoneAlreadyExists = false,
      showAvatarError = false,
      showAddressError = false,
      showPostalCodeError = false,
      termConditionsChecked = false,
      showTermConditionError = false,
      isSelectCheck = false;

  List<AvatarsData> avatarList = [];

  /*String socialId = "",
      socialName = "",
      socialEmail = "",
      socialPhoneNumber = "";*/

  late GoogleSignInAccount _userObj;
  bool _isLoggedIn = false;
  String socialEmail = "";
  String socialId = "";
  String socialName = "";
  String socialProfileImage = "";
  String socialType = "";


  @override
  void initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    super.initState();

    if (widget.socialLogin) {
      List<String> nameParts = widget.name.split(' ');
      firstNameController.text = nameParts[0];
      lastNameController.text = nameParts.length > 1 ? nameParts[1] : '';
      emailController.text = widget.email;
      phoneController.text = widget.phoneNumber;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => getAvatarsApi());
    if (Platform.isIOS) {
    } else if (Platform.isAndroid) {}
    setUserNameListener();
    setPasswordListener();
    setPhoneListener();
    setEmailListener();
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

    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: const Text(""),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: false,
        actionWidget: null,
        leadingFxn: () {
          Navigator.pop(context);
        },
        leadingLeftSPace: size.width * numD04,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signUpText,
                    style: commonBigTitleTextStyle(size, Colors.black),
                  ),
                  SizedBox(
                    height: size.width * numD01,
                  ),
                  Text(
                    signUpSubTitleText,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: size.width * numD035,
                        fontFamily: 'AirbnbCereal_W_Lt'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: size.width * numD01,
                      top: size.width * numD04,
                      bottom: size.width * numD04,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.width * numD04,
                        ),

                        /*  userImagePath.isEmpty
                            ? InkWell(
                                onTap: () {
                                  openCamera();
                                },
                                child: Container(
                                  height: size.width * numD35,
                                  width: size.width * numD40,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: colorTextFieldBorder),
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD04)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.all(size.width * numD01),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black, width: 3),
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD025)),
                                        child: Image.asset(
                                          "${iconsPath}ic_add.png",
                                          width: size.width * numD05,
                                          height: size.width * numD05,
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.width * numD01,
                                      ),
                                      Text(
                                        addLatestPhotoText,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD035,
                                            color: colorHint,
                                            fontWeight: FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    child: Image.file(
                                      File(userImagePath),
                                      height: size.width * numD35,
                                      width: size.width * numD40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: InkWell(
                                      onTap: () {
                                        userImagePath = "";
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.all(size.width * numD01),
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                        child: Icon(Icons.cancel,
                                            color: Colors.black,
                                            size: size.width * numD04),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                        SizedBox(
                          height: size.width * numD01,
                        ),*/
/*
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            selectedAvatar.isEmpty
                                ? InkWell(
                              onTap: () {
                                avatarBottomSheet(size);
                              },
                              child: Container(
                                height: size.width * numD35,
                                width: size.width * numD40,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: colorTextFieldBorder),
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(
                                          size.width * numD01),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black,
                                              width: 3),
                                          borderRadius:
                                          BorderRadius.circular(
                                              size.width * numD025)),
                                      child: Image.asset(
                                        "${iconsPath}ic_add.png",
                                        width: size.width * numD05,
                                        height: size.width * numD05,
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.width * numD01,
                                    ),
                                    Text(
                                      chooseYourAvatarText,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD035,
                                          color: colorHint,
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            )
                                : Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
                                  child: Image.network(
                                    "$avatarBaseUrl/$selectedAvatar",
                                    height: size.width * numD35,
                                    width: size.width * numD40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: InkWell(
                                    onTap: () {
                                      selectedAvatar = "";
                                      if (selectedAvatar.isNotEmpty) {
                                        int pos = avatarList.indexWhere(
                                                (element) =>
                                            element.avatar ==
                                                selectedAvatar);

                                        if (pos >= 0) {
                                          avatarList[pos].selected =
                                          false;
                                        }
                                      }
                                      showAvatarError = true;

                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(
                                          size.width * numD01),
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle),
                                      child: Icon(Icons.cancel,
                                          color: Colors.black,
                                          size: size.width * numD04),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const Spacer(),
                            avatarList.isNotEmpty
                                ? Stack(
                              children: [
                                ClipOval(
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.network(
                                      "$avatarBaseUrl/${avatarList.first.avatar}",
                                      width: size.width * numD15,
                                      height: size.width * numD15,
                                      fit: BoxFit.cover,
                                    )),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: size.width * numD12),
                                  child: ClipOval(
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(
                                        "$avatarBaseUrl/${avatarList[1].avatar}",
                                        width: size.width * numD15,
                                        height: size.width * numD15,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: size.width * numD25),
                                  child: ClipOval(
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(
                                        "$avatarBaseUrl/${avatarList[2].avatar}",
                                        width: size.width * numD15,
                                        height: size.width * numD15,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                              ],
                            )
                                : Container()
                          ],
                        ),
*/
                        selectedAvatar.isEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      avatarBottomSheet(size);
                                    },
                                    child: Container(
                                      height: size.width * numD30,
                                      width: size.width * numD35,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: colorTextFieldBorder),
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD04)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "${iconsPath}ic_user.png",
                                            width: size.width * numD11,
                                          ),
                                          SizedBox(
                                            height: size.width * numD01,
                                          ),
                                          Text(
                                            chooseYourAvatarText,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: colorHint,
                                                fontWeight: FontWeight.normal),
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Align(
                                alignment: Alignment.centerLeft,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD04),
                                      child: Image.network(
                                        "$avatarBaseUrl/$selectedAvatar",
                                        height: size.width * numD30,
                                        width: size.width * numD35,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: InkWell(
                                        onTap: () {
                                          selectedAvatar = "";
                                          if (selectedAvatar.isNotEmpty) {
                                            int pos = avatarList.indexWhere(
                                                (element) =>
                                                    element.avatar ==
                                                    selectedAvatar);

                                            if (pos >= 0) {
                                              avatarList[pos].selected = false;
                                            }
                                          }
                                          showAvatarError = true;

                                          setState(() {});
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              size.width * numD01),
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle),
                                          child: Icon(Icons.cancel,
                                              color: Colors.black,
                                              size: size.width * numD035),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        showAvatarError && selectedAvatar.isEmpty
                            ? Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.width * numD01),
                                  child: Text(
                                    requiredText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD03,
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        Text(
                          chooseAvatarNoteText,
                          style: TextStyle(
                            color: colorHint,
                            fontSize: size.width * numD025,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        /*  showImageError && userImagePath.isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04,
                                    vertical: size.width * numD01),
                                child: Text(
                                  requiredText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.normal),
                                ),
                              )
                            : Container(),*/
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        CommonTextField(
                          size: size,
                          borderColor: colorTextFieldBorder,
                          maxLines: 1,
                          controller: firstNameController,
                          hintText: firstNameHintText,
                          textInputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp("[a-z A-Z]"))
                          ],
                          prefixIcon: const ImageIcon(
                            AssetImage(
                              "${iconsPath}ic_user.png",
                            ),
                          ),
                          prefixIconHeight: size.width * numD06,
                          suffixIconIconHeight: 0,
                          suffixIcon: null,
                          hidePassword: false,
                          keyboardType: TextInputType.text,
                          validator: checkRequiredValidator,
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: lastNameController,
                          hintText: lastNameHintText,
                          textInputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp("[a-z A-Z]"))
                          ],
                          prefixIcon: const ImageIcon(
                            AssetImage(
                              "${iconsPath}ic_user.png",
                            ),
                          ),
                          prefixIconHeight: size.width * numD06,
                          suffixIconIconHeight: 0,
                          suffixIcon: null,
                          hidePassword: false,
                          keyboardType: TextInputType.text,
                          validator: checkRequiredValidator,
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: userNameController,
                          hintText: userNameHintText,
                          errorMaxLines:2,
                          textInputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ \\]')),],
                          prefixIcon: const ImageIcon(
                            AssetImage(
                              "${iconsPath}ic_user.png",
                            ),
                          ),
                          prefixIconHeight: size.width * numD06,
                          suffixIconIconHeight: size.width * numD04,
                          suffixIcon: userNameController.text
                                      .trim()
                                      .isNotEmpty &&
                                  userNameController.text.trim().length >= 4
                              ? userNameAlreadyExists
                                  ? const Icon(
                                      Icons.highlight_remove,
                                      color: Colors.red,
                                    )
                                  : _restrictPattern.hasMatch(
                                              userNameController.text.trim()) ||
                                          _restrictPatter2.hasMatch(
                                              userNameController.text.trim()) ||
                                          _restrictPatter3.hasMatch(
                                              userNameController.text.trim())
                                      ? const Icon(
                                          Icons.highlight_remove,
                                          color: Colors.red,
                                        )
                                      : (userNameController.text
                                                  .toLowerCase()
                                                  .contains(firstNameController
                                                      .text
                                                      .toLowerCase()) ||
                                              userNameController.text
                                                  .toLowerCase()
                                                  .contains(lastNameController
                                                      .text
                                                      .toLowerCase()))
                                          ? const Icon(
                                              Icons.highlight_remove,
                                              color: Colors.red,
                                            )
                                          : const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            )
                              : null,
                          hidePassword: false,
                          keyboardType: TextInputType.text,
                          validator: userNameValidator,
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                        ),
                        SizedBox(
                          height: size.width * numD01,
                        ),
                        Text(
                          userNameNoteText,
                          style: TextStyle(
                              color: colorHint, fontSize: size.width * numD025),
                        ),
                        SizedBox(
                          height: size.width * numD04,
                        ),
                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: phoneController,
                          hintText: phoneHintText,
                          textInputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                          ],
                          prefixIcon: InkWell(
                            onTap: () {
                              openCountryCodePicker();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const ImageIcon(
                                  AssetImage(
                                    "${iconsPath}ic_phone.png",
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * numD01,
                                ),
                                Text(
                                  selectedCountryCodePicker,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: size.width * numD07,
                                )
                              ],
                            ),
                          ),
                          prefixIconHeight: size.width * numD06,
                          suffixIconIconHeight: size.width * numD04,
                          suffixIcon: phoneController.text.trim().isNotEmpty
                              ? phoneAlreadyExists
                                  ? const Icon(
                                      Icons.highlight_remove,
                                      color: Colors.red,
                                    )
                                  : const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                              : null,
                          hidePassword: false,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: false, signed: true),
                          validator: checkSignupPhoneValidator,
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: emailController,
                          hintText: emailHintText,
                          textInputFormatters: null,
                          prefixIcon: const ImageIcon(
                            AssetImage(
                              "${iconsPath}ic_email.png",
                            ),
                          ),
                          prefixIconHeight: size.width * numD06,
                          suffixIconIconHeight: 0,
                          suffixIcon: null,
                          hidePassword: false,
                          keyboardType: TextInputType.emailAddress,
                          validator: checkSignupEmailValidator,
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        SizedBox(
                          height: size.width * numD13,
                          child: GooglePlaceAutoCompleteTextField(
                            textEditingController: postalCodeController,
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * numD032,
                                fontFamily: 'AirbnbCereal_W_Md'),
                            googleAPIKey: "AIzaSyAzccAqyrfD-V43gI9eBXqLf0qpqlm0Gu0",
                            inputDecoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              hintText: "$enterText $postalCodeText",
                              hintStyle: TextStyle(
                                  color: colorHint,
                                  fontSize: size.width * numD035),
                              disabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.03),
                                  borderSide: const BorderSide(
                                      width: 1, color: colorTextFieldBorder)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.03),
                                  borderSide: const BorderSide(
                                      width: 1, color: colorTextFieldBorder)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.03),
                                  borderSide: const BorderSide(
                                      width: 1, color: colorTextFieldBorder)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.03),
                                  borderSide: const BorderSide(
                                      width: 1, color: colorTextFieldBorder)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(size.width * 0.03),
                                  borderSide: const BorderSide(
                                      width: 1, color: colorTextFieldBorder)),
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD02),
                                child: const ImageIcon(
                                  AssetImage(
                                    "${iconsPath}ic_location.png",
                                  ),
                                ),
                              ),
                              prefixIconConstraints: BoxConstraints(
                                  maxHeight: size.width * numD06),
                              prefixIconColor: colorTextFieldIcon,
                            ),
                            debounceTime: 800,
                            countries: const ["uk", "in"],
                            isLatLngRequired: true,
                            getPlaceDetailWithLatLng: (Prediction prediction) {
                              latitude = prediction.lat.toString();
                              longitude = prediction.lng.toString();
                              debugPrint("placeDetails${prediction.lng}");
                              debugPrint("placeDetails${prediction.lng}");
                              getCurrentLocationFxn(prediction.lat ?? "",
                                      prediction.lng ?? "")
                                  .then((value) {
                                debugPrint("pin code===> $value");
                                postalCodeController.text = value ?? '';
                              });
                              showAddressError = false;
                              setState(() {});
                            },
                            itmClick: (Prediction prediction) {
                              addressController.text =
                                  prediction.description ?? "";

                              latitude = prediction.lat ?? "";
                              longitude = prediction.lng ?? "";
                              String postalCode =
                                  prediction?.structuredFormatting?.mainText ??
                                      '';
                              debugPrint("postalCode=======> $postalCode");
                              addressController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: prediction.description != null
                                          ? prediction.description!.length
                                          : 0));
                            },
                          ),
                        ),
                        showAddressError &&
                                postalCodeController.text.trim().isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04,
                                    vertical: size.width * numD01),
                                child: Text(
                                  requiredText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.normal),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: postalCodeController.text.isNotEmpty
                              ? size.width * numD06
                              : 0,
                        ),
                        postalCodeController.text.isNotEmpty
                            ? CommonTextField(
                                size: size,
                                maxLines: 1,
                                borderColor: colorTextFieldBorder,
                                controller: addressController,
                                hintText:
                                    "${enterText.toTitleCase()} ${addressText.toLowerCase()}",
                                textInputFormatters: null,
                                prefixIcon: const ImageIcon(
                                  AssetImage(
                                    "${iconsPath}ic_location.png",
                                  ),
                                ),
                                prefixIconHeight: size.width * numD06,
                                suffixIconIconHeight: 0,
                                suffixIcon: null,
                                hidePassword: false,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: false, signed: false),
                                enableValidations: true,
                                filled: false,
                                filledColor: Colors.transparent,
                                autofocus: false,
                                validator: null,
                              )
                            : Container(),
                        showPostalCodeError &&
                                postalCodeController.text.trim().isEmpty &&
                                addressController.text.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04,
                                    vertical: size.width * numD01),
                                child: Text(
                                  requiredText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.normal),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        !widget.socialLogin
                            ? CommonTextField(
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
                                prefixIconHeight: size.width * numD08,
                                suffixIconIconHeight: size.width * numD08,
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
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
                                        color: !hidePassword
                                            ? colorTextFieldIcon
                                            : colorHint,
                                      ),
                                    ),
                                    SizedBox(
                                      width: passwordStrengthValue.isNotEmpty &&
                                              passwordStrengthValue ==
                                                  strongText
                                          ? size.width * numD02
                                          : 0,
                                    ),
                                    passwordStrengthValue.isNotEmpty &&
                                            passwordStrengthValue == strongText
                                        ? const ImageIcon(
                                            AssetImage(
                                              "${iconsPath}ic_right.png",
                                            ),
                                            color: colorThemePink,
                                          )
                                        : Container(),
                                  ],
                                ),
                                hidePassword: hidePassword,
                                keyboardType: TextInputType.text,
                                validator: checkPasswordValidator,
                                enableValidations: true,
                                filled: false,
                                filledColor: Colors.transparent,
                                autofocus: false,
                              )
                            : Container(),
                        SizedBox(
                          height: !widget.socialLogin
                              ? passwordStrengthValue.isNotEmpty
                                  ? size.width * numD02
                                  : 0
                              : 0,
                        ),
                        passwordStrengthValue.trim().isNotEmpty &&
                                !widget.socialLogin
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    passwordStrengthText,
                                    style: TextStyle(
                                        color: colorHint,
                                        fontSize: size.width * numD03),
                                  ),
                                  Text(
                                    passwordStrengthValue,
                                    style: TextStyle(
                                        color: colorThemePink,
                                        fontSize: size.width * numD03),
                                  ),
                                ],
                              )
                            : Container(),
                        SizedBox(
                          height: !widget.socialLogin ? size.width * numD04 : 0,
                        ),
                        !widget.socialLogin
                            ? CommonTextField(
                                size: size,
                                maxLines: 1,
                                borderColor: colorTextFieldBorder,
                                controller: confirmPasswordController,
                                hintText: confirmPwdHintText,
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
                                  if (value!.isEmpty) {
                                    return requiredText;
                                  }
                                  /*else if (value.length < 8) {
                                    return passwordErrorText;
                                  } */
                                  else if (passwordController.text != value) {
                                    return confirmPasswordErrorText;
                                  }
                                  return null;
                                },
                                enableValidations: true,
                                filled: false,
                                filledColor: Colors.transparent,
                                autofocus: false,
                              )
                            : Container(),
                        SizedBox(
                          height: !widget.socialLogin ? size.width * numD04 : 0,
                        ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                isSelectCheck = !isSelectCheck;
                                setState(() {});
                              },
                              child: isSelectCheck
                                  ? Container(
                                margin: EdgeInsets.only(top: size.width*numD008),
                                child: Image.asset(
                                  "${iconsPath}ic_checkbox_filled.png",
                                  height: size.width * numD06,
                                ),
                              )
                                  : Container(
                                margin: EdgeInsets.only(top: size.width*numD008),
                                child: Image.asset("${iconsPath}ic_checkbox_empty.png",
                                    height: size.width * numD06),
                              ),
                            ),
                            SizedBox(
                              width:size.width * numD02,
                            ),
                            Expanded(
                              child: Text(
                                enableNotificationText,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD035),
                              ),
                            ),
                            SizedBox(
                              width: size.width * numD02,
                            ),
                          /*  FlutterSwitch(
                                width: size.width * numD16,
                                height: size.width * numD08,
                                valueFontSize: size.width * numD035,
                                toggleSize: size.width * numD047,
                                borderRadius: size.width * numD045,
                                padding: size.width * numD015,
                                showOnOff: true,
                                activeColor: colorSwitchBack,
                                inactiveColor: colorSwitchBack,
                                activeText: yesText,
                                inactiveText: noText,
                                activeTextColor: Colors.black,
                                inactiveTextColor: Colors.black,
                                activeToggleColor: colorThemePink,
                                inactiveToggleColor: colorTextFieldIcon,
                                activeTextFontWeight: FontWeight.w500,
                                inactiveTextFontWeight: FontWeight.w500,
                                value: enableNotifications,
                                onToggle: (value) {
                                  setState(() {
                                    enableNotifications = value;
                                  });
                                })*/
                          ],
                        ),
                        SizedBox(
                          height: size.width * numD04,
                        ),

                      /*  AnimatedBuilder(
                            animation: offsetAnimation,
                            builder: (context, child) {
                              final dx =
                                  sin(offsetAnimation.value * 2 * pi) * 24;

                              return Transform.translate(
                                offset: Offset(dx, 0),
                                child: InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  TermCheckScreen(
                                                    type: 'legal',
                                                  )))
                                          .then((value) {
                                        if (value != null) {
                                          debugPrint("value::::$value");
                                          termConditionsChecked = value;
                                          setState(() {});
                                        }
                                      });
                                    },
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: clickHereToAgreeText,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize:
                                                    size.width * numD035)),
                                        WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: SizedBox(
                                              width: size.width * 0.01,
                                            )),
                                        TextSpan(
                                            text: termsAndConditionText,
                                            style: TextStyle(
                                                color: colorThemePink,
                                                fontSize: size.width * numD035,
                                                fontWeight: FontWeight.w700)),
                                        WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: SizedBox(
                                              width: size.width * 0.01,
                                            )),
                                        TextSpan(
                                            text: andText,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: size.width * numD035,
                                                fontWeight: FontWeight.w500)),
                                        WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: SizedBox(
                                              width: size.width * 0.01,
                                            )),
                                        TextSpan(
                                            text: privacyPolicyText,
                                            style: TextStyle(
                                                color: colorThemePink,
                                                fontSize: size.width * numD035,
                                                fontWeight: FontWeight.w700)),
                                      ]),
                                    )),
                              );
                            }),*/
                      /*  AnimatedBuilder(
                            animation: offsetAnimation,
                            builder: (context, child) {
                              final dx =
                                  sin(offsetAnimation.value * 2 * pi) * 24;

                              return Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      termConditionsChecked = !termConditionsChecked;
                                      setState(() {});
                                    },
                                    child: isSelectCheck
                                        ? Container(
                                      margin: EdgeInsets.only(top: size.width*numD008),
                                      child: Image.asset(
                                        "${iconsPath}ic_checkbox_filled.png",
                                        height: size.width * numD06,
                                      ),
                                    )
                                        : Container(
                                      margin: EdgeInsets.only(top: size.width*numD008),
                                      child: Image.asset("${iconsPath}ic_checkbox_empty.png",
                                          height: size.width * numD06),
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: "Click",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                              size.width * numD035)),

                                      TextSpan(
                                          text:" here",
                                          style: TextStyle(
                                              color: Colors.pink,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                              size.width * numD035)),
                                      WidgetSpan(
                                          alignment:
                                          PlaceholderAlignment.middle,
                                          child: SizedBox(
                                            width: size.width * 0.01,
                                          )),
                                      TextSpan(
                                          text: "T\&Cs",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: size.width * numD035,
                                             )),
                                      WidgetSpan(
                                          alignment:
                                          PlaceholderAlignment.middle,
                                          child: SizedBox(
                                            width: size.width * 0.01,
                                          )),
                                      TextSpan(
                                          text: andText,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: size.width * numD035,
                                              )),
                                      WidgetSpan(
                                          alignment:
                                          PlaceholderAlignment.middle,
                                          child: SizedBox(
                                            width: size.width * 0.01,
                                          )),
                                      TextSpan(
                                          text: privacyPolicyText,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: size.width * numD035,
                                              )),
                                    ]),
                                  ),
                                ],
                              );
                            }),*/

                        Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                builder: (context) =>
                                    TermCheckScreen(
                                      type: 'legal',
                                    )))
                                .then((value) {
                              if (value != null) {
                                debugPrint("value::::$value");
                                termConditionsChecked = value;
                              //  termConditionsChecked = !termConditionsChecked;
                                setState(() {});
                              }
                            });


                            setState(() {});
                          },
                          child: termConditionsChecked
                              ? Container(
                            margin: EdgeInsets.only(top: size.width*numD008),
                            child: Image.asset(
                              "${iconsPath}ic_checkbox_filled.png",
                              height: size.width * numD06,
                            ),
                          )
                              : Container(
                            margin: EdgeInsets.only(top: size.width*numD008),
                            child: Image.asset("${iconsPath}ic_checkbox_empty.png",
                                height: size.width * numD06),
                          ),
                        ),
                        SizedBox(
                          width:size.width * numD02,
                        ),
                   /*     RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "Click",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                    size.width * numD035)),

                            TextSpan(
                                text:" here",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD035,),

                            ),
                            WidgetSpan(
                                alignment:
                                PlaceholderAlignment.middle,
                                child: SizedBox(
                                  width: size.width * 0.01,
                                )),
                            TextSpan(
                                text: "T\&Cs",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD035,
                                )),
                            WidgetSpan(
                                alignment:
                                PlaceholderAlignment.middle,
                                child: SizedBox(
                                  width: size.width * 0.01,
                                )),
                            TextSpan(
                                text: andText,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD035,
                                )),
                            WidgetSpan(
                                alignment:
                                PlaceholderAlignment.middle,
                                child: SizedBox(
                                  width: size.width * 0.01,
                                )),
                            TextSpan(
                                text: privacyPolicyText,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD035,
                                )),
                          ]),
                        ),*/
                        Expanded(
                          child: Text(
                            "Accept our T\&Cs and Privacy Policy",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * numD035),
                          ),
                        ),
                      ],
                    ),

                        SizedBox(
                          height: size.width * numD06,
                        ),

                        /// Next Button
                        /*Container(
                          width: size.width,
                          height: size.width * numD14,
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          child: commonElevatedButton(
                              nextText,
                              size,
                              commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                              commonButtonStyle(size, colorThemePink), () {
                            */
                        /* if (userImagePath.isEmpty) {
                              showImageError = true;
                              scrollController.animateTo(
                                  scrollController.position.minScrollExtent,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut);
                            }*/
                        /*

                            showAvatarError =
                                selectedAvatar.isEmpty ? true : false;

                            if (selectedAvatar.isEmpty) {
                              scrollController.animateTo(
                                  scrollController.position.minScrollExtent,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut);
                            }

                            showAddressError =
                                addressController.text.trim().isEmpty
                                    ? true
                                    : false;

                            showPostalCodeError =
                                postalCodeController.text.trim().isEmpty
                                    ? true
                                    : false;

                            setState(() {});

                            if (formKey.currentState!.validate() &&
                                selectedAvatar.isNotEmpty) {
                              if (termConditionsChecked) {
                                sendOtpApi();
                              } else {
                                controller.forward(from: 0.0);
                                startVibration();
                                showTermConditionError = true;
                                setState(() {});
                              }
                            }
                          }),
                        ),*/
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          width: size.width,
                          height: size.width * numD13,
                          child: commonElevatedButton(
                              nextText,
                              size,
                              commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                              commonButtonStyle(size, colorThemePink),
                              () async {
                            showAvatarError =
                                selectedAvatar.isEmpty ? true : false;

                            if (selectedAvatar.isEmpty) {
                              scrollController.animateTo(
                                  scrollController.position.minScrollExtent,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut);
                            }


                            showAddressError =
                                addressController.text.trim().isEmpty
                                    ? true
                                    : false;

                            showPostalCodeError =
                                postalCodeController.text.trim().isEmpty
                                    ? true
                                    : false;

                            setState(() {});

                            if (formKey.currentState!.validate() &&
                                selectedAvatar.isNotEmpty) {
                              if (termConditionsChecked) {
                                sendOtpApi();
                              } else {
                                showSnackBar("Error","Please accept our T\&Cs and privacy policy", Colors.red);
                               /* controller.forward(from: 0.0);
                                startVibration();
                                showTermConditionError = true;*/
                                setState(() {});
                              }
                            }
                          }),
                        ),

                        /// Or
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * numD04),
                            child: Text(
                              orText,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD04),
                            ),
                          ),
                        ),

                        /*    Platform.isIOS
                            ? Container(
                          color: Colors.transparent,
                                margin: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04),
                                height: size.width * numD13,
                                width: size.width,
                                child: SignInWithAppleButton(

                                  onPressed: () async {
                                    final credential = await SignInWithApple
                                        .getAppleIDCredential(
                                      scopes: [
                                        AppleIDAuthorizationScopes.email,
                                        AppleIDAuthorizationScopes.fullName,
                                      ],
                                    );

                                    debugPrint("AppleCredentials: $credential");
                                    */
                        /* socialId = credential.userIdentifier ?? "";
                              socialEmail = credential.email ?? "";
                              socialName = credential.givenName ??
                                  credential.familyName ??
                                  "";
                              socialPhoneNumber = '';

                              debugPrint("SocialId: $socialId");
                              socialExistsApi();*/
                        /*
                                  },
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
                                  text: "Sign in with apple",

                                ),
                              )
                            : Container(
                                width: size.width,
                                height: size.width * numD12,
                                margin: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    border: Border.all(
                                        color: colorGoogleButtonBorder)),
                                child: InkWell(
                                  splashColor: Colors.grey.shade300,
                                  onTap: () async {
                                    User? user =
                                        await Authentication.signInWithGoogle(
                                            context: context);
                                    */
                        /* if (user != null) {
                                socialId = user.uid;
                                socialEmail = user.email ?? "";
                                socialName = user.displayName ?? "";
                                socialPhoneNumber = user.phoneNumber ?? "";
                                socialExistsApi();
                              } else {
                                debugPrint("Some Google Login Error");
                              }*/
                        /*
                                  },
                                  child: Stack(
                                    children: [
                                      Positioned(
                                          top: 0,
                                          bottom: 0,
                                          left: size.width * numD01,
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                size.width * numD025),
                                            child: Image.asset(
                                              "${iconsPath}ic_google.png",

                                            ),
                                          )),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          continueGoogleText,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: size.width * numD035,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ), */


                        /// change by aditya
                        Platform.isIOS
                            ? Container(
                          width: size.width,
                          height: size.width * numD13,
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
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
                              /* socialId = credential.userIdentifier ?? "";
                              socialEmail = credential.email ?? "";
                              socialName = credential.givenName ??
                                  credential.familyName ??
                                  "";
                              socialPhoneNumber = '';

                              debugPrint("SocialId: $socialId");
                              socialExistsApi();*/
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
                        )
                            : Container(
                          width: size.width,
                          height: size.width * numD13,
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(size.width * numD04),
                              border: Border.all(color: colorGoogleButtonBorder)),
                          child: InkWell(
                            splashColor: Colors.grey.shade300,
                            onTap: () async {
                              googleLogin();
                            //  User? user = await Authentication.signInWithGoogle(context: context);
                              /* if (user != null) {
                                socialId = user.uid;
                                socialEmail = user.email ?? "";
                                socialName = user.displayName ?? "";
                                socialPhoneNumber = user.phoneNumber ?? "";
                                socialExistsApi();
                              } else {
                                debugPrint("Some Google Login Error");
                              }*/


                            /*    User? user = await Authentication.signInWithGoogle(
                                    context: context);
                                debugPrint("google ::::::");
                                if (user != null) {
                                  socialId = user.uid;
                                  socialEmail = user.email ?? "";
                                  socialName = user.displayName ?? "";
                                  socialPhoneNumber = user.phoneNumber ?? "";
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

                        !widget.socialLogin
                            ? Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: alreadyHaveAccountText,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize:
                                                    size.width * numD035)),
                                        WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: SizedBox(
                                              width: size.width * 0.005,
                                            )),
                                        TextSpan(
                                            text: signInText,
                                            style: TextStyle(
                                                color: colorThemePink,
                                                fontSize: size.width * numD035,
                                                fontWeight: FontWeight.w700)),
                                      ]),
                                    )))
                            : Container(),
                      ],
                    ),
                  )
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

  void startVibration() async {
    bool canVibrate = await Vibrate.canVibrate;
    final Iterable<Duration> pauses = [
      const Duration(milliseconds: 50),
      const Duration(milliseconds: 50),
    ];

    if (canVibrate) {
      Vibrate.vibrateWithPauses(pauses);
    }
  }

  void setUserNameListener() {
    userNameController.addListener(() {
      debugPrint("UserName:${userNameController.text}");
      if (userNameController.text.trim().isNotEmpty &&
          firstNameController.text.trim().isNotEmpty &&
          lastNameController.text.trim().isNotEmpty &&
          userNameController.text.trim().length >= 4 &&
          !userNameController.text
              .trim()
              .toLowerCase()
              .contains(firstNameController.text.trim().toLowerCase()) &&
          !userNameController.text
              .trim()
              .toLowerCase()
              .contains(lastNameController.text.trim().toLowerCase())) {
        debugPrint("not-success");
        checkUserNameApi();
      } else {
        userNameAlreadyExists = false;
      }
      setState(() {});
    });
  }

  void setEmailListener() {
    emailController.addListener(() {
      debugPrint("Emil:${emailController.text}");
      if (emailController.text.trim().isNotEmpty) {
        debugPrint("notsuccess");
        checkEmailApi();
      } else {
        emailAlreadyExists = false;
      }

      setState(() {});
    });
  }

  void setPhoneListener() {
    phoneController.addListener(() {
      debugPrint("Phone:${phoneController.text}");
      if (phoneController.text.trim().isNotEmpty &&
          phoneController.text.trim().length > 9) {
        debugPrint("notsuccess");
        checkPhoneApi();
      } else {
        phoneAlreadyExists = false;
      }

      setState(() {});
    });
  }

  void setPasswordListener() {
    passwordController.addListener(() {
      var m = passwordExpression.hasMatch(passwordController.text.trim());

      debugPrint("EmailExpression: $m");

      if (passwordController.text.isNotEmpty &&
          passwordController.text.length >= 8 &&
          !passwordExpression.hasMatch(passwordController.text.trim())) {
        passwordStrengthValue = weakText;
      } else if (passwordController.text.isNotEmpty &&
          passwordController.text.length >= 8 &&
          passwordExpression.hasMatch(passwordController.text.trim())) {
        passwordStrengthValue = strongText;
      } else {
        passwordStrengthValue = "";
      }

      setState(() {});
    });
  }

  /// Get current Location
  Future<String?> getCurrentLocationFxn(String latitude, longitude) async {
    try {
      double lat = double.parse(latitude);
      double long = double.parse(longitude);
      List<Placemark> placeMarkList = await placemarkFromCoordinates(lat, long);
      debugPrint("PlaceHolder: ${placeMarkList.first}");
      return placeMarkList.first.postalCode!;
    } on Exception catch (e) {
      debugPrint("PEx: $e");
      showSnackBar("Exception", e.toString(), Colors.red);
    }
    return null;
  }

  void setSocialPreData() {
    if (widget.email.isNotEmpty) {}

    if (widget.name.isNotEmpty) {
      var nameArray = widget.name.split(" ");
      if (nameArray.length > 1) {
        firstNameController.text = nameArray.first;
        lastNameController.text = nameArray[1];
      }
    }
  }

  Future openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      return;
    }
    userImagePath = image.path;
    if (userImagePath.isNotEmpty) {
      showImageError = false;
    }

    setState(() {});
  }

  Future openGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    avatarController.text = File(image.path).uri.pathSegments.last;

    setState(() {});
  }

  String? userNameValidator(String? value) {
    if (value!.isEmpty) {
      return requiredText;
    } else if (firstNameController.text.trim().isEmpty) {
      return "First name must be filled.";
    } else if (lastNameController.text.trim().isEmpty) {
      return "Last name must be filled.";
    }
    if (value.toLowerCase().contains(firstNameController.text.toLowerCase()) ||
        value.toLowerCase().contains(lastNameController.text.toLowerCase())) {
      //return "First name or Last name are not allowed in user name.";
      return "First name or last name are not allowed for safety reasons.";
    } else if (value.length < 4) {
      return "Your user name must be at least 4 characters in length";
    } else if (_restrictPattern.hasMatch(value.trim()) ||
        _restrictPatter2.hasMatch(value.trim()) ||
        _restrictPatter3.hasMatch(value.trim())) {
      return "Domain names are not allowed for security reasons";
    } else if (userNameAlreadyExists) {
      return "This user name is already taken. Please choose another one";
    }

    return null;
  }

  void avatarBottomSheet(Size size) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, avatarState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: size.width * numD04),
                  child: Row(
                    children: [
                      Text(
                        chooseAvatarText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD05,
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
                            Icons.close,
                            color: Colors.black,
                            size: size.width * numD06,
                          ))
                    ],
                  ),
                ),
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: StaggeredGridView.count(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    crossAxisCount: 6,
                    padding: const EdgeInsets.all(2.0),
                    staggeredTiles: avatarList
                        .map<StaggeredTile>((_) => const StaggeredTile.fit(2))
                        .toList(),
                    mainAxisSpacing: 3.0,
                    crossAxisSpacing: 4.0,
                    children: avatarList.map<Widget>((item) {
                      return InkWell(
                        onTap: () {
                          int pos = avatarList
                              .indexWhere((element) => element.selected);

                          if (pos >= 0) {
                            avatarList[pos].selected = false;
                          }
                          selectedAvatar = item.avatar;
                          selectedAvatarId = item.id;
                          item.selected = true;
                          showAvatarError = false;
                          avatarState(() {});
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: Stack(
                          children: [
                            Image.network("$avatarBaseUrl/${item.avatar}"),
                            item.selected
                                ? Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.black,
                                      size: size.width * numD06,
                                    ))
                                : Container()
                          ],
                        ),
                      );
                    }).toList(), // add some space
                  ),
                ))
              ],
            );
          });
        });
  }

  void openCountryCodePicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        debugPrint('Select country: ${country.displayName}');
        debugPrint('Select country: ${country.countryCode}');
        debugPrint('Select country: ${country.hashCode}');
        debugPrint('Select country: ${country.displayNameNoCountryCode}');
        debugPrint('Select country: ${country.phoneCode}');
        selectedCountryCodePicker = "+${country.phoneCode}";
        setState(() {});
      },
    );
  }

  String? checkSignupPhoneValidator(String? value) {
    //<-- add String? as a return type
    if (value!.isEmpty) {
      return requiredText;
    } else if (value.length < 10) {
      return phoneErrorText;
    } else if (phoneAlreadyExists) {
      return phoneExistsErrorText;
    }
    return null;
  }

  String? checkSignupEmailValidator(String? value) {
    if (value!.isEmpty) {
      return requiredText;
    } else if (!emailExpression.hasMatch(value)) {
      return emailErrorText;
    } else if (emailAlreadyExists) {
      return emailExistsErrorText;
    }
    return null;
  }

  ///ApisSection------------
  void checkUserNameApi() {
    try {
      NetworkClass(
              "$checkUserNameUrl${userNameController.text.trim().toLowerCase()}",
              this,
              checkUserNameUrlRequest)
          .callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void checkEmailApi() {
    try {
      NetworkClass("$checkEmailUrl${emailController.text.trim()}", this,
              checkEmailUrlRequest)
          .callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void checkPhoneApi() {
    try {
      NetworkClass("$checkPhoneUrl${phoneController.text.trim()}", this,
              checkPhoneUrlRequest)
          .callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void getAvatarsApi() {
    try {
      NetworkClass(getAvatarsUrl, this, getAvatarsUrlRequest)
          .callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void sendOtpApi() {
    try {
      Map<String, String> params = {
        "phone": selectedCountryCodePicker+phoneController.text.trim(),
        "email": emailController.text.trim()
      };
      NetworkClass.fromNetworkClass(sendOtpUrl, this, sendOtpUrlRequest, params)
          .callRequestServiceHeader(true, "post", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  /// aditya

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
        case checkUserNameUrlRequest:
          var map = jsonDecode(response);
          debugPrint("CheckUserNameResponseError:$map");

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
        case checkUserNameUrlRequest:
          var map = jsonDecode(response);
          debugPrint("CheckUserNameResponse:$map");
          userNameAlreadyExists = map["userNameExist"];
          setState(() {});
          break;
        case checkPhoneUrlRequest:
          var map = jsonDecode(response);
          debugPrint("CheckPhoneResponse:$map");
          phoneAlreadyExists = map["phoneExist"];
          setState(() {});
          break;

        case checkEmailUrlRequest:
          var map = jsonDecode(response);
          debugPrint("CheckEmailResponse:$map");
          emailAlreadyExists = map["emailExist"];
          setState(() {});
          break;
        case getAvatarsUrlRequest:
          var map = jsonDecode(response);

          avatarBaseUrl = map["base_url"];
          var list = map["response"] as List;
          avatarList = list.map((e) => AvatarsData.fromJson(e)).toList();
          debugPrint("AvatarList: ${avatarList.length}");
          setState(() {});
          break;
        case sendOtpUrlRequest:
          var map = jsonDecode(response);
          Map<String, String> params = {};
          params[firstNameKey] = firstNameController.text.trim();
          params[lastNameKey] = lastNameController.text.trim();
          params[emailKey] = emailController.text.trim();
          params[countryCodeKey] = selectedCountryCodePicker;
          params[phoneKey] = phoneController.text.trim();
          params[addressKey] = addressController.text.trim();
          params[postCodeKey] = postalCodeController.text.trim();
          params[latitudeKey] = latitude;
          params[longitudeKey] = longitude;
          params[isTermAcceptedKey] = termConditionsChecked.toString();
          //params[receiveTaskNotificationKey] = enableNotifications.toString();
          params[receiveTaskNotificationKey] = isSelectCheck.toString();
          params[roleKey] = "Hopper";
          params[avatarIdKey] = selectedAvatarId;
          params[userNameKey] = userNameController.text.trim().toLowerCase();

          if (!widget.socialLogin) {
            params[passwordKey] = passwordController.text.trim();
          } else {
            params["social_id"] = widget.socialId;
            params["social_type"] = Platform.isIOS ? "apple" : "google";
          }

          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => VerifyAccountScreen(
                    countryCode: selectedCountryCodePicker,
                    emailAddressValue: emailController.text.trim(),
                    mobileNumberValue: phoneController.text.trim(),
                    params: params,
                    imagePath: userImagePath,
                    sociallogin: widget.socialLogin,
                  )));

          break;

        case socialExistUrlRequest:
          var map = jsonDecode(response);
          debugPrint("SocialExistResponse: $response");

          if (map["code"] == 200) {
            if (map["token"] != null) {
              debugPrint("inside this::::::");
              //  rememberMe = true;
              //   sharedPreferences!.setBool(rememberKey, true);
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
              firstNameController.text = socialName;
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

class AvatarsData {
  String id = "";
  String avatar = "";
  bool selected = false;

  AvatarsData.fromJson(json) {
    id = json["_id"]??"";
    avatar = json["avatar"]??"";
  }
}
