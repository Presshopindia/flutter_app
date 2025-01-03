import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:location/location.dart' as lc;
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/CommonTextField.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';

import '../../main.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../authentication/SignUpScreen.dart';
import '../dashboard/Dashboard.dart';

class MyProfile extends StatefulWidget {
  bool
  editProfileScreen = false;
  MyProfile({super.key, required this.editProfileScreen});

  @override
  State<StatefulWidget> createState() {
    return MyProfileState();
  }
}

class MyProfileState extends State<MyProfile> implements NetworkResponse {
  late Size size;

  var formKey = GlobalKey<FormState>();
  var scrollController = ScrollController();

  TextEditingController userNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController postCodeController = TextEditingController();

  List<AvatarsData> avatarList = [];
  MyProfileData? myProfileData;
  String selectedCountryCode = "",
      userImagePath = "",
      latitude = "",
      longitude = "";
  bool userNameAutoFocus = false,
      userNameAlreadyExists = false,
      emailAlreadyExists = false,
      phoneAlreadyExists = false,
      showAddressError = false,
      showPostalCodeError = false;
  lc.LocationData? locationData;
  lc.Location location = lc.Location();

  @override
  void initState() {
    debugPrint("class:::: $runtimeType");
    super.initState();
    debugPrint("editStatus===> ${widget.editProfileScreen}");
    setUserNameListener();
    setPhoneListener();
    setEmailListener();
    Future.delayed(Duration.zero, () {
      myProfileApi();
      getAvatarsApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return /*WillPopScope(
      onWillPop: () async {
        if (widget.editProfileScreen) {
          widget.editProfileScreen = false;
        }
        return true;
      },
      child:*/
        Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          widget.editProfileScreen
              ? editProfileText.toTitleCase()
              : myProfileText.toTitleCase(),
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
          /*  if (widget.editProfileScreen) {
              widget.editProfileScreen = false;
            }*/
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
            width: size.width * numD02,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Form(
            key: formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  topProfileWidget(),
                  SizedBox(
                    height: size.width * numD06,
                  ),
                  Text("${userText.toTitleCase()} $nameText",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD032,
                          color: Colors.black,
                          fontWeight: FontWeight.normal)),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  CommonTextField(
                    size: size,
                    maxLines: 1,
                    textInputFormatters: null,
                    borderColor: colorTextFieldBorder,
                    controller: userNameController,
                    hintText: "${enterText.toTitleCase()} $userText $nameText",
                    prefixIcon: const ImageIcon(
                      AssetImage(
                        "${iconsPath}ic_user.png",
                      ),
                    ),
                    hidePassword: false,
                    keyboardType: TextInputType.text,
                    validator: null /*userNameValidator*/,
                    enableValidations: false,
                    filled: true,
                    filledColor: colorLightGrey,
                    autofocus: userNameAutoFocus,
                    readOnly: true,
                    prefixIconHeight: size.width * numD045,
                    suffixIconIconHeight: size.width * numD04,
                    suffixIcon: /*widget.editProfileScreen &&
                              userNameController.text.trim().isNotEmpty &&
                              userNameController.text.trim().length >= 4
                          ? userNameAlreadyExists
                              ? const Icon(
                                  Icons.highlight_remove,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                          :*/
                        null,
                  ),
                  SizedBox(
                    height: size.width * numD06,
                  ),
                  Text("${firstText.toTitleCase()} $nameText",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD032,
                          color: Colors.black,
                          fontWeight: FontWeight.normal)),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  CommonTextField(
                    size: size,
                    maxLines: 1,
                    textInputFormatters: null,
                    borderColor: colorTextFieldBorder,
                    controller: firstNameController,
                    hintText: "${enterText.toTitleCase()} $firstText $nameText",
                    prefixIcon: const ImageIcon(
                      AssetImage(
                        "${iconsPath}ic_user.png",
                      ),
                    ),
                    prefixIconHeight: size.width * numD045,
                    suffixIconIconHeight: 0,
                    suffixIcon: null,
                    hidePassword: false,
                    keyboardType: TextInputType.text,
                    validator: checkRequiredValidator,
                    enableValidations: true,
                    filled: true,
                    filledColor: colorLightGrey,
                    autofocus: false,
                    readOnly: widget.editProfileScreen ? false : true,
                  ),
                  SizedBox(
                    height: size.width * numD06,
                  ),
                  Text("${lastText.toTitleCase()} $nameText",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD032,
                          color: Colors.black,
                          fontWeight: FontWeight.normal)),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  CommonTextField(
                    size: size,
                    maxLines: 1,
                    textInputFormatters: null,
                    borderColor: colorTextFieldBorder,
                    controller: lastNameController,
                    hintText: "${enterText.toTitleCase()} $lastText $nameText",
                    prefixIcon: const ImageIcon(
                      AssetImage(
                        "${iconsPath}ic_user.png",
                      ),
                    ),
                    prefixIconHeight: size.width * numD045,
                    suffixIconIconHeight: 0,
                    suffixIcon: null,
                    hidePassword: false,
                    keyboardType: TextInputType.text,
                    validator: checkRequiredValidator,
                    enableValidations: true,
                    filled: true,
                    filledColor: colorLightGrey,
                    autofocus: false,
                    readOnly: widget.editProfileScreen ? false : true,
                  ),
                  SizedBox(
                    height: size.width * numD06,
                  ),
                  Text("${phoneText.toTitleCase()} $numberText",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD032,
                          color: Colors.black,
                          fontWeight: FontWeight.normal)),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  CommonTextField(
                    size: size,
                    maxLines: 1,
                    textInputFormatters: null,
                    borderColor: colorTextFieldBorder,
                    controller: phoneNumberController,
                    hintText:
                        "${enterText.toTitleCase()} $phoneText $numberText",
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ImageIcon(
                          AssetImage(
                            "${iconsPath}ic_phone.png",
                          ),
                        ),
                        SizedBox(
                          width: size.width * numD02,
                        ),
                        Text(
                          selectedCountryCode,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD032,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        SizedBox(
                          width: size.width * 0.01,
                        ),
                        Image.asset(
                          "${iconsPath}ic_drop_down.png",
                          width: size.width * 0.025,
                        ),
                        SizedBox(
                          width: size.width * 0.01,
                        ),

                        /*  InkWell(
                          onTap: () {},
                          child: Row(
                            children: [
                              Text(
                                selectedCountryCode,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                              SizedBox(
                                height: size.width*numD06,
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.black,
                                  size: size.width * numD07,
                                ),
                              )
                            ],
                          ),
                        )*/
                      ],
                    ),
                    prefixIconHeight: size.width * numD045,
                    suffixIconIconHeight: 0,
                    suffixIcon: null,
                    hidePassword: false,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: false, signed: true),
                    validator: null /*checkSignupPhoneValidator*/,
                    enableValidations: false,
                    filled: true,
                    filledColor: colorLightGrey,
                    autofocus: false,
                    readOnly: true,
                  ),
                  SizedBox(
                    height: size.width * numD06,
                  ),
                  Text(emailAddressText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD032,
                          color: Colors.black,
                          fontWeight: FontWeight.normal)),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  CommonTextField(
                    size: size,
                    maxLines: 1,
                    textInputFormatters: null,
                    borderColor: colorTextFieldBorder,
                    controller: emailAddressController,
                    hintText: "${enterText.toTitleCase()} $emailAddressText",
                    prefixIcon: const ImageIcon(
                      AssetImage(
                        "${iconsPath}ic_email.png",
                      ),
                    ),
                    prefixIconHeight: size.width * numD045,
                    suffixIconIconHeight: 0,
                    suffixIcon: null,
                    hidePassword: false,
                    keyboardType: TextInputType.emailAddress,
                    validator: null /*checkSignupEmailValidator*/,
                    enableValidations: false,
                    filled: true,
                    filledColor: colorLightGrey,
                    autofocus: false,
                    readOnly: true,
                  ),
                  SizedBox(
                    height: size.width * numD06,
                  ),
                  Text(postalCodeText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD032,
                          color: Colors.black,
                          fontWeight: FontWeight.normal)),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  /* CommonTextField(
                    size: size,
                    maxLines: 1,
                    textInputFormatters: null,
                    borderColor: colorTextFieldBorder,
                    controller: addressController,
                    hintText: "${enterText.toTitleCase()} $addressText",
                    prefixIcon: const ImageIcon(
                      AssetImage(
                        "${iconsPath}ic_location.png",
                      ),
                    ),
                    prefixIconHeight: size.width * numD045,
                    suffixIconIconHeight: 0,
                    suffixIcon: null,
                    hidePassword: false,
                    keyboardType: TextInputType.text,
                    validator: checkRequiredValidator,
                    enableValidations: true,
                    filled: true,
                    filledColor: colorLightGrey,
                    autofocus: false,
                    readOnly: widget.editProfileScreen ? false : true,
                  ),
                  SizedBox(
                    height: size.width * numD06,
                  ),
                  Text(postalCodeText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD032,
                          color: Colors.black,
                          fontWeight: FontWeight.normal)),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  CommonTextField(
                    size: size,
                    maxLines: 1,
                    textInputFormatters: null,
                    borderColor: colorTextFieldBorder,
                    controller: postCodeController,
                    hintText: "${enterText.toTitleCase()} $postalCodeText",
                    prefixIcon: const ImageIcon(
                      AssetImage(
                        "${iconsPath}ic_location.png",
                      ),
                    ),
                    prefixIconHeight: size.width * numD045,
                    suffixIconIconHeight: 0,
                    suffixIcon: null,
                    hidePassword: false,
                    keyboardType: TextInputType.text,
                    validator: checkRequiredValidator,
                    enableValidations: true,
                    filled: true,
                    filledColor: colorLightGrey,
                    autofocus: false,
                    readOnly: widget.editProfileScreen ? false : true,
                  ),*/

                  widget.editProfileScreen
                      ? SizedBox(
                          height: size.width * numD13,
                          child: GooglePlaceAutoCompleteTextField(
                            textEditingController: postCodeController,
                            googleAPIKey:
                                "AIzaSyAzccAqyrfD-V43gI9eBXqLf0qpqlm0Gu0",

                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * numD032,
                                fontFamily: 'AirbnbCereal_W_Md'),
                            inputDecoration: InputDecoration(
                              fillColor: colorLightGrey,
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: size.width * numD02),
                              hintText:
                                  "${enterText.toTitleCase()} ${addressText.toLowerCase()}",
                              hintStyle: TextStyle(
                                  color: colorHint,
                                  fontSize: size.width * numD035,
                                  fontFamily: 'AirbnbCereal_W_Md'),
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
                                  maxHeight: size.width * numD045),
                              prefixIconColor: colorTextFieldIcon,
                            ),
                            debounceTime: 800,
                            // default 600 ms,
                            countries: const ["uk", "in"],
                            // optional by default null is set
                            isLatLngRequired: true,
                            // if you required coordinates from place detail
                            getPlaceDetailWithLatLng: (Prediction prediction) {
                              latitude = prediction.lat.toString();
                              longitude = prediction.lng.toString();
                              debugPrint("placeDetails${prediction.lng}");
                              getCurrentLocationFxn(prediction.lat ?? "",
                                      prediction.lng ?? "")
                                  .then((value) {
                                debugPrint(" pinCode===> $value");
                                postCodeController.text = value ?? '';
                              });
                              showAddressError = false;
                              setState(() {});
                            },
                            // this callback is called when isLatLngRequired is true

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
                        )
                      : CommonTextField(
                          size: size,
                          maxLines: 1,
                          textInputFormatters: null,
                          borderColor: colorTextFieldBorder,
                          controller: postCodeController,
                          hintText:
                              "${enterText.toTitleCase()} $postalCodeText",
                          prefixIcon: const ImageIcon(
                            AssetImage(
                              "${iconsPath}ic_location.png",
                            ),
                          ),
                          prefixIconHeight: size.width * numD045,
                          suffixIconIconHeight: 0,
                          suffixIcon: null,
                          hidePassword: false,
                          keyboardType: TextInputType.text,
                          validator: checkRequiredValidator,
                          enableValidations: true,
                          filled: true,
                          filledColor: colorLightGrey,
                          autofocus: false,
                          readOnly: true,
                        ),
                  showAddressError && addressController.text.trim().isEmpty
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
                    height: addressController.text.isNotEmpty
                        ? size.width * numD06
                        : 0,
                  ),
                  addressController.text.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(addressText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD032,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal)),
                            SizedBox(
                              height: size.width * numD02,
                            ),
                            CommonTextField(
                              size: size,
                              maxLines: 1,
                              textInputFormatters: null,
                              borderColor: colorTextFieldBorder,
                              controller: addressController,
                              hintText:
                                  "${enterText.toTitleCase()} $postalCodeText",
                              prefixIcon: const ImageIcon(
                                AssetImage(
                                  "${iconsPath}ic_location.png",
                                ),
                              ),
                              prefixIconHeight: size.width * numD045,
                              suffixIconIconHeight: 0,
                              suffixIcon: null,
                              hidePassword: false,
                              keyboardType: TextInputType.text,
                              validator: checkRequiredValidator,
                              enableValidations: true,
                              filled: true,
                              filledColor: colorLightGrey,
                              autofocus: false,
                              readOnly: widget.editProfileScreen ? false : true,
                            ),
                          ],
                        )
                      : Container(),
                  showPostalCodeError &&
                          postCodeController.text.trim().isEmpty &&
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
                    height: size.width * numD25,
                  ),
                  Container(
                    width: size.width,
                    height: size.width * numD14,
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * numD08),
                    child: commonElevatedButton(
                        widget.editProfileScreen
                            ? saveText.toTitleCase()
                            : editProfileText.toTitleCase(),
                        size,
                        commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                        commonButtonStyle(size, colorThemePink), () {
                      if (!widget.editProfileScreen) {
                        widget.editProfileScreen = !widget.editProfileScreen;
                        scrollController.animateTo(
                            scrollController.position.minScrollExtent,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                        userNameAutoFocus = true;
                      } else {
                        scrollController.animateTo(
                            scrollController.position.minScrollExtent,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                        if (formKey.currentState!.validate()) {
                          editProfileApi();
                        }
                      }
                      setState(() {});
                    }),
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
    // );
  }

  Widget topProfileWidget() {
    return Container(
      height: size.width * numD35,
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(size.width * numD04)),
      child: Row(
        children: [
          Stack(
            fit: StackFit.loose,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04)),
                  child: Image.network(
                    myProfileData != null
                        ? "$avatarImageUrl${myProfileData!.avatarImage}"
                        : "",
                    errorBuilder: (context, exception, stacktrace) {
                      return Padding(
                        padding: EdgeInsets.all(size.width * numD04),
                        child: Image.asset(
                          "${commonImagePath}rabbitLogo.png",
                          fit: BoxFit.contain,
                          width: size.width * numD35,
                          height: size.width * numD35,
                        ),
                      );
                    },
                    fit: BoxFit.cover,
                    width: size.width * numD37,
                    height: size.width * numD35,
                  )),
              widget.editProfileScreen
                  ? Positioned(
                      bottom: size.width * numD01,
                      right: size.width * numD01,
                      child: InkWell(
                        onTap: () {
                          avatarBottomSheet(size);
                        },
                        child: Container(
                          padding: EdgeInsets.all(size.width * 0.005),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Container(
                              padding: EdgeInsets.all(size.width * 0.005),
                              decoration: const BoxDecoration(
                                  color: colorThemePink,
                                  shape: BoxShape.circle),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: size.width * numD04,
                              )),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
          SizedBox(
            width: size.width * numD04,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  myProfileData != null
                      ? myProfileData!.userName.toCapitalized()
                      : "",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD04,
                      color: colorThemePink,
                      fontWeight: FontWeight.w500)),
              SizedBox(
                height: size.width * numD01,
              ),
              Text(
                  "$joinedText - ${myProfileData != null ? myProfileData!.joinedDate : ""}",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.white,
                      fontWeight: FontWeight.normal)),
              SizedBox(
                height: size.width * numD005,
              ),
              Text("$earningsText - ${euroUniqueCode}0",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.white,
                      fontWeight: FontWeight.normal)),
              SizedBox(
                height: size.width * numD005,
              ),
              Text(myProfileData != null ? myProfileData!.address : "",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.white,
                      fontWeight: FontWeight.normal))
            ],
          ))
        ],
      ),
    );
  }

  void setProfileData() {
    if (myProfileData != null) {
      firstNameController.text = myProfileData!.firstName;
      lastNameController.text = myProfileData!.lastName;
      userNameController.text = myProfileData!.userName;
      selectedCountryCode = myProfileData!.countryCode;
      addressController.text = myProfileData!.address;
      phoneNumberController.text = myProfileData!.phoneNumber;
      emailAddressController.text = myProfileData!.email;
      postCodeController.text = myProfileData!.postCode;
    }
  }

  String? userNameValidator(String? value) {
    //<-- add String? as a return type
    if (value!.isEmpty) {
      return requiredText;
    } else if (firstNameController.text.trim().isEmpty) {
      return "First name must be filled.";
    } else if (lastNameController.text.trim().isEmpty) {
      return "Last name must be filled.";
    }
    if (value.toLowerCase().contains(firstNameController.text.toLowerCase()) ||
        value.toLowerCase().contains(lastNameController.text.toLowerCase())) {
      return "First name or Last name are not allowed in user name.";
    } else if (value.length < 4) {
      return "Your user name must be at least 4 characters in length";
    } else if (userNameAlreadyExists) {
      return "This user name already occupied. Please try another one";
    }
    return null;
  }

  void setUserNameListener() {
    userNameController.addListener(() {
      if (widget.editProfileScreen) {
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
          debugPrint("notsuccess");
          checkUserNameApi();
        } else {
          userNameAlreadyExists = false;
        }
        setState(() {});
      }
    });
  }

  void setEmailListener() {
    emailAddressController.addListener(() {
      if (widget.editProfileScreen) {
        debugPrint("Emil:${emailAddressController.text}");
        if (emailAddressController.text.trim().isNotEmpty) {
          debugPrint("notsuccess");
          checkEmailApi();
        } else {
          emailAlreadyExists = false;
        }

        setState(() {});
      }
    });
  }

  void setPhoneListener() {
    phoneNumberController.addListener(() {
      if (widget.editProfileScreen) {
        debugPrint("Phone:${phoneNumberController.text}");
        if (phoneNumberController.text.trim().isNotEmpty &&
            phoneNumberController.text.trim().length > 9) {
          debugPrint("notsuccess");
          checkPhoneApi();
        } else {
          phoneAlreadyExists = false;
        }

        setState(() {});
      }
    });
  }

  /// Avatar Images
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
                            fontSize: size.width * numD04,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
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

                          myProfileData!.avatarImage = item.avatar;
                          myProfileData!.avatarId = item.id;
                          item.selected = true;
                          avatarState(() {});
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: Stack(
                          children: [
                            Image.network("$avatarImageUrl${item.avatar}"),
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

        myProfileData!.countryCode = country.phoneCode;
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
    //<-- add String? as a return type
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
      NetworkClass("$checkEmailUrl${emailAddressController.text.trim()}", this,
              checkEmailUrlRequest)
          .callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void checkPhoneApi() {
    try {
      NetworkClass("$checkPhoneUrl${phoneNumberController.text.trim()}", this,
              checkPhoneUrlRequest)
          .callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void getAvatarsApi() {
    try {
      NetworkClass(getAvatarsUrl, this, getAvatarsUrlRequest)
          .callRequestServiceHeader(true, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void myProfileApi() {
    NetworkClass(myProfileUrl, this, myProfileUrlRequest)
        .callRequestServiceHeader(true, "get", null);
  }

  void editProfileApi() {
    try {
      Map<String, String> params = {
        firstNameKey: firstNameController.text.trim(),
        lastNameKey: lastNameController.text.trim(),
        userNameKey: userNameController.text.trim().toLowerCase(),
        emailKey: emailAddressController.text.trim(),
        countryCodeKey: myProfileData!.countryCode,
        phoneKey: phoneNumberController.text.trim(),
        addressKey: addressController.text.trim(),
        latitudeKey: myProfileData!.latitude,
        longitudeKey: myProfileData!.longitude,
        avatarIdKey: myProfileData!.avatarId,
        postCodeKey:postCodeController.text,
        roleKey: "Hopper",
      };
      NetworkClass.fromNetworkClass(
              editProfileUrl, this, editProfileUrlRequest, params)
          .callRequestServiceHeader(true, "patch", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case myProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileError:$map");

          break;
        case editProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("EditProfileError:$map");

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
        case myProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileSuccess:$map");

          if (map["code"] == 200) {
            myProfileData = MyProfileData.fromJson(map["userData"]);
            setProfileData();
            setState(() {});
          }

          break;
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

          var list = map["response"] as List;
          avatarList = list.map((e) => AvatarsData.fromJson(e)).toList();
          debugPrint("AvatarList: ${avatarList.length}");
          setState(() {});
          break;
        case editProfileUrlRequest:
          var map = jsonDecode(response);
          if (map["code"] == 200) {
            widget.editProfileScreen = false;
           /* showSnackBar("Profile Updated!",
                "Your profile has been updated successfully", colorOnlineGreen);*/
            debugPrint("heloooo::::${myProfileData!.avatarId}");

            myProfileApi();
            sharedPreferences!
                .setString(avatarKey,myProfileData!.avatarImage);
          }
          setState(() {});
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}

class MyProfileData {
  String firstName = "";
  String lastName = "";
  String userName = "";
  String countryCode = "";
  String phoneNumber = "";
  String email = "";
  String address = "";
  String postCode = "";
  String latitude = "";
  String longitude = "";
  String avatarImage = "";
  String avatarId = "";
  String joinedDate = "";
  String earnings = "0";
  String validDegree = "";
  String validMemberShip = "";
  String validBritishPassport = "";

  MyProfileData.fromJson(json) {
    firstName = json[firstNameKey];
    lastName = json[lastNameKey];
    userName = json[userNameKey];
    countryCode = json[countryCodeKey];
    phoneNumber = json[phoneKey].toString();
    debugPrint("MyPhone: $phoneNumber");
    email = json[emailKey];
    address = json[addressKey];
    postCode = json[postCodeKey] ?? "";
    latitude = json[latitudeKey].toString();
    longitude = json[longitudeKey].toString();
    avatarImage = json["avatarData"] != null ? json["avatarData"]["avatar"] : "";
    avatarId = json["avatarData"] != null ? json["avatarData"]["_id"] : "";
    joinedDate = changeDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", json["createdAt"], "dd MMMM, yyyy");
    validDegree =json["doc_to_become_pro"] != null ? json["doc_to_become_pro"]["govt_id_mediatype"].toString() : "";
    validMemberShip =json["doc_to_become_pro"] != null ? json["doc_to_become_pro"]["photography_mediatype"].toString() : "";
    validBritishPassport =json["doc_to_become_pro"] != null ? json["doc_to_become_pro"]["comp_incorporation_cert_mediatype"].toString() : "";
  }
}
