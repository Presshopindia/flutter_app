import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../dashboard/Dashboard.dart';
import 'AddBankScreen.dart';

class MyBanksScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyBanksScreenState();
  }
}

class MyBanksScreenState extends State<MyBanksScreen>
    implements NetworkResponse {
  List<MyBankData> myBankList = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      bankListApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          paymentMethods,
          style: TextStyle(
              fontWeight: FontWeight.bold,
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
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: EdgeInsets.only(right: size.width * numD04),
                height: size.width * numD11,
                child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => AddBankScreen(
                                    showPageNumber: false,
                                    hideLeading: false,
                                    editBank: false,
                                    myBankList: myBankList,
                                  )))
                          .then((value) {
                        myBankList.clear();
                        bankListApi();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorThemePink,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * numD03))),
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: size.width * numD06,
                    ),
                    label: Text("Add new bank",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD033,
                            color: Colors.white,
                            fontWeight: FontWeight.normal))),
              ),
            ),
            Flexible(
                child: ListView.separated(
                    padding:
                        EdgeInsets.symmetric(vertical: size.width * numD05),
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(
                            horizontal: size.width * numD04),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * numD04),
                            side: BorderSide(
                                color: myBankList[index].isDefault
                                    ? colorThemePink
                                    : Colors.transparent)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04,
                              vertical: size.width * numD03),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                "${iconsPath}ic_payment_method.png",
                                height: size.width * numD09,
                                width: size.width * numD09,
                              ),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    myBankList[index].bankName,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD034,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  SizedBox(
                                    height: size.width*numD01,
                                  ),
                                  Text(
                                    myBankList[index].accountNumber.replaceRange(0, 8,"********"),
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD03,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              )),
                              !myBankList[index].isDefault
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    AddBankScreen(
                                                      showPageNumber: false,
                                                      hideLeading: false,
                                                      editBank: true,
                                                      myBankData:
                                                          myBankList[index],
                                                      myBankList: myBankList,
                                                    )))
                                            .then((value) {
                                          bankListApi();
                                        });
                                      },
                                      child: Icon(
                                        Icons.edit_note_rounded,
                                        color: Colors.black,
                                        size: !myBankList[index].isDefault
                                            ? size.width * numD08
                                            : 0,
                                      ),
                                    )
                                  : Container(),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              !myBankList[index].isDefault
                                  ? InkWell(
                                      onTap: () {
                                        debugPrint("Tapped");
                                        deleteBankApi(myBankList[index].id);
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.all(size.width * numD01),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.black,
                                          size: size.width * numD08,
                                        ),
                                      ),
                                    )
                                  : Container(),
                              myBankList[index].isDefault
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * numD03,
                                          vertical: size.width * 0.008),
                                      decoration: BoxDecoration(
                                          color: colorThemePink,
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD03)),
                                      child: Text(
                                        defaultText,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD028,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: size.width * numD04,
                      );
                    },
                    itemCount: myBankList.length))
          ],
        ),
      ),
    );
  }

  ///ApisSection------------

  void bankListApi() {
    try {
      NetworkClass(bankListUrl, this, bankListUrlRequest)
          .callRequestServiceHeader(true, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void deleteBankApi(String id) {
    try {
      NetworkClass("$deleteBankUrl$id", this, deleteBankUrlRequest)
          .callRequestServiceHeader(true, "delete", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case bankListUrlRequest:
          var map = jsonDecode(response);
          debugPrint("BankListError:$map");
          break;

        case deleteBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("DeleteBankError:$map");
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
        case bankListUrlRequest:
          var map = jsonDecode(response);
          debugPrint("CheckUserNameResponse:$map");
          if (map["code"] == 200) {
            var list = map["bankList"] as List;
            myBankList = list.map((e) => MyBankData.fromJson(e)).toList();
          }
          setState(() {});
          break;
        case deleteBankUrlRequest:
          var map = jsonDecode(response);
          if (map["code"] == 200) {
            myBankList.clear();
            bankListApi();
          }
          setState(() {});
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  ///
}

class MyBankData {
  String id = "";
  String bankName = "";
  String bankImage = "";
  String bankLocation = "";
  bool isDefault = false;
  String accountHolderName = "";
  String sortCode = "";
  String accountNumber = "";

  MyBankData.fromJson(json) {
    id = json["_id"];
    bankName = json["bank_name"];
    isDefault = json["is_default"];
    bankImage = "${dummyImagePath}bank1.png";
    bankLocation = "Mayfair, London";
    accountHolderName = json["acc_holder_name"];
    sortCode = json["sort_code"];
    accountNumber = json["acc_number"].toString();
  }
}
