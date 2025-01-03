import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/commonWebView.dart';
import 'package:presshop/view/authentication/UploadDocumnetsScreen.dart';
import '../../utils/CommonTextField.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import 'MyBanksScreen.dart';

class AddBankScreen extends StatefulWidget {
  bool showPageNumber = false;
  bool hideLeading = false;
  bool editBank = false;
  MyBankData? myBankData;
  List<MyBankData> myBankList = [];

  AddBankScreen(
      {super.key,
      required this.showPageNumber,
      required this.hideLeading,
      required this.editBank,
      this.myBankData,
      required this.myBankList});

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen>
    implements NetworkResponse {
  var formKey = GlobalKey<FormState>();
  TextEditingController accountHolderNameController = TextEditingController();
  TextEditingController bankController = TextEditingController();
  TextEditingController sortCodeController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  String stripOnBoardURL = '';
  bool defaultValue = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => crateStripAccount());
    if (widget.editBank) {
      setBankData();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: widget.hideLeading,
        title: Container(
          margin: EdgeInsets.only(left: size.width*numD13),
          child: Text(
            widget.hideLeading?addBankDetailsText:addBankDetailsText,
            style: commonBigTitleTextStyle(size, Colors.black),
          ),
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
          key: formKey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: size.width * numD13, right: size.width * numD1),
                child: Text(
                  addBankDetailsSubHeadingText,
                  style: TextStyle(
                      color: Colors.black, fontSize: size.width * numD035),
                ),
              ),
              SizedBox(
                height: size.width*numD03,
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * numD06,
                      vertical: size.width * numD04),
                  children: [
                    Text(
                      accountHolderNameText,
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
                      controller: accountHolderNameController,
                      hintText: enterAccountHolderNameText,
                      textInputFormatters: null,
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
                    Text(
                      bankText,
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
                      controller: bankController,
                      hintText: enterBankText,
                      textInputFormatters: null,
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_bank.png",
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
                    Text(
                      sortCodeText,
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
                      controller: sortCodeController,
                      hintText: enterSortCodeText,
                      maxLength: 8,
                      textInputFormatters: null,
                      onChanged: (value) {
                      /*  if (value!.trim().isEmpty) {
                          return requiredText;
                        } else if (value.length < 9) {
                          return sortCodeErrorText;
                        }
                        return null;*/
                        if (value!.endsWith("-") && value.isNotEmpty) {
                          sortCodeController.text =
                              value.substring(0, value.length - 2);
                        } else if ([2, 5].contains(value.length)) {
                          sortCodeController.text += "-";
                        }
                        sortCodeController.selection = TextSelection.collapsed(
                            offset: sortCodeController.text.length);
                        setState(() {});
                      },
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_locker.png",
                        ),
                      ),
                      prefixIconHeight: size.width * numD06,
                      suffixIconIconHeight: 0,
                      suffixIcon: null,
                      hidePassword: false,
                      keyboardType: TextInputType.number,
                      validator: checkRequiredValidator,
                      enableValidations: true,
                      filled: false,
                      filledColor: Colors.transparent,
                      autofocus: false,
                    ),
                    SizedBox(
                      height: size.width * numD06,
                    ),
                    Text(
                      accountNumberText,
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
                      controller: accountNumberController,
                      hintText: enterAccountNumberText,
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_piggy.png",
                        ),
                      ),
                      prefixIconHeight: size.width * numD06,
                      suffixIconIconHeight: 0,
                      suffixIcon: null,
                      hidePassword: false,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: false),
                      textInputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                      ],
                      validator: (value) {
                        //<-- add String? as a return type
                        if (value!.trim().isEmpty) {
                          return requiredText;
                        } else if (value.length < 7) {
                          return bankErrorText;
                        }
                        return null;
                      },
                      enableValidations: true,
                      filled: false,
                      filledColor: Colors.transparent,
                      autofocus: false,
                    ),
                    SizedBox(
                      height: size.width * numD06,
                    ),
                    !widget.showPageNumber && widget.myBankList.isNotEmpty
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  defaultValue = !defaultValue;
                                  setState(() {});
                                },
                                child: defaultValue
                                    ? Image.asset(
                                        "${iconsPath}ic_checkbox_filled.png",
                                        height: size.width * numD05,
                                      )
                                    : Image.asset(
                                        "${iconsPath}ic_checkbox_empty.png",
                                        height: size.width * numD05),
                              ),
                              SizedBox(
                                width: size.width * numD02,
                              ),
                              Expanded(
                                child: Text(
                                  setAsDefaultText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: size.width * numD15,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: size.width*numD04),
                      width: size.width,
                      height: size.width * numD13,

                      child: commonElevatedButton(
                          widget.showPageNumber
                              ? nextText
                              : widget.editBank
                                  ? updateText
                                  : submitText,
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, colorThemePink), () {
                        if (formKey.currentState!.validate()) {
                          if (widget.editBank) {
                            editBankApi();
                          } else {
                          /*  debugPrint("helllo-----");
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => const CommonWebView(
                                    webUrl:'https://flutter.dev',
                                    title: "")));*/
                            if(stripOnBoardURL.isNotEmpty){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CommonWebView(
                                          webUrl: stripOnBoardURL,
                                          title: ""))).then((value) {
                                debugPrint('value data===> $value');
                                if (value) {
                                 addBankApi();
                                }
                              });
                            }else{
                              addBankApi();
                            }

                          }
                        }
                      }),
                    ),

                    SizedBox(
                      height: widget.showPageNumber ? size.width * numD04 : 0,
                    ),
                    widget.showPageNumber
                        ? Align(
                            alignment: Alignment.center,
                            child: Text("2 of 3",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD035,
                                    fontWeight: FontWeight.w500)))
                        : Container(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void setBankData() {
    if (widget.myBankData != null) {
      accountHolderNameController.text = widget.myBankData!.accountHolderName;
      bankController.text = widget.myBankData!.bankName;
      sortCodeController.text = widget.myBankData!.sortCode;
      accountNumberController.text = widget.myBankData!.accountNumber;
      defaultValue = widget.myBankData!.isDefault;
    }
    setState(() {});
  }

  ///-------ApisSection-----------
  void addBankApi() {
    Map<String, String> params = {
      "acc_holder_name": accountHolderNameController.text.trim(),
      "bank_name": bankController.text.trim(),
      "sort_code": sortCodeController.text.toString(),
      "acc_number": accountNumberController.text.trim(),
      "is_default": widget.showPageNumber
          ? true.toString()
          : widget.myBankList.isNotEmpty
              ? defaultValue.toString()
              : true.toString(),
    };
    debugPrint("AddBankParams:$params");
    NetworkClass.fromNetworkClass(addBankUrl, this, addBankUrlRequest, params)
        .callRequestServiceHeader(true, "patch", null);
  }

  void editBankApi() {
    Map<String, String> bankDetails = {
      "acc_holder_name": accountHolderNameController.text.trim(),
      "bank_name": bankController.text.trim(),
      "sort_code": sortCodeController.text.trim(),
      "acc_number": accountNumberController.text.trim(),
      "is_default":
          widget.showPageNumber ? true.toString() : defaultValue.toString(),
    };
    Map<String, String> params = {
      "bank_detail_id": widget.myBankData!.id,
      "bank_detail": jsonEncode(bankDetails),
    };
    debugPrint("EditBankParams: $params");
    NetworkClass.fromNetworkClass(editBankUrl, this, editBankUrlRequest, params)
        .callRequestServiceHeader(true, "patch", null);
  }

  /// Add Stripe Account
  void crateStripAccount() {
    NetworkClass.fromNetworkClass(
            createStripeAccount, this, reqCreateStipeAccount, {})
        .callRequestServiceHeader(false, "post", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case addBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileError:$map");

          break;
        case editBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("EditBankError:$map");

          break;
        case reqCreateStipeAccount:
          debugPrint(
              "reqCreateStipeAccountErrorResponse===>${jsonDecode(response)} ");
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
        case addBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileSuccess:$map");
          if (map["code"] == 200) {
            if (widget.showPageNumber) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => UploadDocumentsScreen(
                        menuScreen: false,
                        hideLeading: false,
                      )));
            } else {
              Navigator.pop(context);
            }
          }

          break;
        case editBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("EditBankresponse:$map");

          if (map["code"] == 200) {
            Navigator.pop(context);
          }
          break;
        case reqCreateStipeAccount:
          debugPrint(
              "reqCreateStipeAccountSuccessResponse===>${jsonDecode(response)} ");
          var data = jsonDecode(response);
          stripOnBoardURL = data['message']['url'];


          debugPrint("stripBoardURK ====> $stripOnBoardURL");
          setState(() {});

          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}
