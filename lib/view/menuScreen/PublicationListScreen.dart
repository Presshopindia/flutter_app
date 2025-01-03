import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presshop/view/myEarning/TransactionDetailScreen.dart';

import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonModel.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import '../myEarning/earningDataModel.dart';

class PublicationListScreen extends StatefulWidget {
  String contentId = "";
  String contentType = "";
  String publicationCount = "";

  PublicationListScreen(
      {super.key,
      required this.contentId,
      required this.publicationCount,
      required this.contentType});

  @override
  State<PublicationListScreen> createState() => _PublicationListScreenState();
}

class _PublicationListScreenState extends State<PublicationListScreen>
    implements NetworkResponse {
  late Size size;

  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];
  List<EarningTransactionDetail> publicationTransactionList = [];
  EarningProfileDataModel? earningData;

  @override
  void initState() {
    initializeFilter();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      callGEtEarningDataAPI();
      callMediaHouseList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          publicationsListText,
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
          Navigator.pop(context);
        },
        actionWidget: [
          InkWell(
            onTap: () {
              showBottomSheet(size);
            },
            child: commonFilterIcon(size),
          )
        ],
      ),
      body: earningData != null
          ? ListView(
              padding: EdgeInsets.only(
                left: size.width * numD06,
                right: size.width * numD06,
              ),
              children: [
                /// My Earnings
                Container(
                  padding: EdgeInsets.all(size.width * numD05),
                  decoration: BoxDecoration(
                      color: colorLightGrey,
                      borderRadius: BorderRadius.circular(size.width * numD05)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1.2, color: Colors.black),
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04)),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      avatarImageUrl + earningData!.avatar,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    height: size.width * numD32,
                                    width: size.width * numD35,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    "${dummyImagePath}walk1.png",
                                    fit: BoxFit.cover,
                                    height: size.width * numD32,
                                    width: size.width * numD35,
                                  ),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: size.width * numD06),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  publicationsText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  widget.publicationCount,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD08,
                                      color: colorThemePink,
                                      fontWeight: FontWeight.w800),
                                ),
                                SizedBox(
                                  height: size.width * numD01,
                                ),
                                Text(
                                  youHaveEarnedText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  earningData!.totalEarning.isNotEmpty
                                      ? "£${earningData!.totalEarning}"
                                      : '£0',
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD08,
                                      color: colorThemePink,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: size.width * numD03,
                      ),
                      widget.contentType == "exclusive"
                          ? Container()
                          : Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      sortList.first.fromDate =
                                          await commonDatePicker(
                                              date: sortList.first.fromDate);
                                      sortList.first.toDate = null;
                                      int pos = sortList.indexWhere(
                                          (element) => element.isSelected);
                                      if (pos != -1) {
                                        sortList[pos].isSelected = false;
                                      }
                                      sortList.first.isSelected =
                                          !sortList.first.isSelected;
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: size.width * numD02,
                                        horizontal: size.width * numD02,
                                      ),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1.2, color: Colors.black),
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD02)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            sortList.first.fromDate ?? fromText,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD035,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          const Icon(
                                            Icons.arrow_drop_down_sharp,
                                            color: Colors.black,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * numD06,
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      if (sortList.first.fromDate != null) {
                                        String? pickedDate =
                                            await commonDatePicker(
                                                date: sortList.first.toDate);

                                        if (pickedDate != null) {
                                          DateTime parseFromDate =
                                              DateTime.parse(
                                                  sortList.first.fromDate!);
                                          DateTime parseToDate =
                                              DateTime.parse(pickedDate);

                                          debugPrint(
                                              "parseFromDate : $parseFromDate");
                                          debugPrint(
                                              "parseToDate : $parseToDate");

                                          if (parseToDate
                                                  .isAfter(parseFromDate) ||
                                              parseToDate.isAtSameMomentAs(
                                                  parseFromDate)) {
                                            sortList.first.toDate = pickedDate;
                                            callGetAllTransactionDetail();
                                          } else {
                                            showSnackBar(
                                                "Date Error",
                                                "Please select to date above from date",
                                                Colors.red);
                                          }
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: size.width * numD02,
                                        horizontal: size.width * numD02,
                                      ),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1.2, color: Colors.black),
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD02)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            sortList.first.toDate ?? toText,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD035,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          const Icon(
                                            Icons.arrow_drop_down_sharp,
                                            color: Colors.black,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                    ],
                  ),
                ),

                SizedBox(
                  height: size.width * numD04,
                ),

                Text(
                  publicationsListHeadingText,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),

                SizedBox(
                  height: size.width * numD02,
                ),

                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1.5,
                ),

                SizedBox(
                  height: size.width * numD04,
                ),

                paymentReceivedWidget(),

                SizedBox(
                  height: size.width * numD04,
                ),
              ],
            )
          : Container(),
    );
  }

  /*Widget paymentReceivedWidget() {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(
              top: size.width * numD05,
              bottom: size.width * numD025,
              left: size.width * numD05,
              right: size.width * numD05,
            ),
            decoration: BoxDecoration(
                color: colorLightGrey,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 0,
                      spreadRadius: 0.5)
                ],
                borderRadius: BorderRadius.circular(size.width * numD02)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: size.width * numD025,
                        bottom: size.width * numD02,
                      ),
                      width: size.width * numD25,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: colorThemePink,
                          borderRadius:
                              BorderRadius.circular(size.width * numD015)),
                      child: Text(
                        "£350",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD04,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(size.width * numD025),
                      child: Image.asset(
                        "${dummyImagePath}news.png",
                        width: size.width * numD11,
                      ),
                    ),
                  ],
                ),

                /// Payment Detail
                Padding(
                  padding: EdgeInsets.only(top: size.width * numD04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        paymentDetailText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "23 December, 2022",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),

                /// Payment made time
                Padding(
                  padding: EdgeInsets.only(top: size.width * numD02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        paymentMadeTimeText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "10:20 AM",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),

                /// Transaction ID
                Padding(
                  padding: EdgeInsets.only(top: size.width * numD02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transactionIdText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "NND9788979",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),

                /// Divider
                Padding(
                  padding: EdgeInsets.only(
                    top: size.width * numD01,
                  ),
                  child: const Divider(
                    color: Colors.white,
                    thickness: 1.5,
                  ),
                ),

                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TransactionDetailScreen(
                              type: "received",
                              transactionData: null,
                            )));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        viewDetailsText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD036,
                            color: colorThemePink,
                            fontWeight: FontWeight.w500),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.black,
                        size: size.width * numD045,
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: size.width * numD05,
          );
        },
        itemCount: 5);
  }

  Widget paymentPendingWidget() {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(
              top: size.width * numD05,
              bottom: size.width * numD025,
              left: size.width * numD05,
              right: size.width * numD05,
            ),
            decoration: BoxDecoration(
                color: colorLightGrey,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 0,
                      spreadRadius: 0.5)
                ],
                borderRadius: BorderRadius.circular(size.width * numD02)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: size.width * numD025,
                        bottom: size.width * numD02,
                      ),
                      width: size.width * numD25,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(size.width * numD015),
                          border:
                              Border.all(color: Color(0xFFAEB4B3), width: 1)),
                      child: Text(
                        "£350",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD04,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "${iconsPath}ic_share.png",
                          width: size.width * numD08,
                        ),
                        SizedBox(
                          width: size.width * numD03,
                        ),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(size.width * numD025),
                          child: Image.asset(
                            "${dummyImagePath}news.png",
                            width: size.width * numD11,
                          ),
                        )
                      ],
                    ),
                  ],
                ),

                /// Your earnings
                Padding(
                  padding: EdgeInsets.only(top: size.width * numD04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        yourEarningsText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "£350",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),

                /// Presshop fees
                Padding(
                  padding: EdgeInsets.only(top: size.width * numD02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        presshopFeesText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "£520",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),

                /// Amount pending
                Padding(
                  padding: EdgeInsets.only(top: size.width * numD02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        amountPendingText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "£2,080",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),

                /// Payment due date
                Padding(
                  padding: EdgeInsets.only(top: size.width * numD02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        paymentDueDateText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "23 December, 2022",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),

                /// Divider
                Padding(
                  padding: EdgeInsets.only(
                    top: size.width * numD01,
                  ),
                  child: const Divider(
                    color: Colors.white,
                    thickness: 1.5,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      viewDetailsText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD036,
                          color: colorThemePink,
                          fontWeight: FontWeight.w500),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.black,
                      size: size.width * numD045,
                    )
                  ],
                )
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: size.width * numD05,
          );
        },
        itemCount: 2);
  }*/

  Widget paymentReceivedWidget() {
    return /*publicationTransactionList.isNotEmpty
        ?*/
        ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var item = publicationTransactionList[index];
              return item.paidStatus
                  ? Container(
                      padding: EdgeInsets.only(
                        top: size.width * numD05,
                        bottom: size.width * numD025,
                        left: size.width * numD05,
                        right: size.width * numD05,
                      ),
                      decoration: BoxDecoration(
                          color: colorLightGrey,
                          borderRadius:
                              BorderRadius.circular(size.width * numD02)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.width * numD01,
                                    horizontal: size.width * numD04),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD015),
                                    border: Border.all(
                                        color: colorGrey3, width: 1)),
                                child: Text(
                                  "£${item.payableT0Hopper}",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD04,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "${iconsPath}ic_exclusive.png",
                                    width: size.width * numD06,
                                  ),
                                  SizedBox(
                                    width: size.width * numD03,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD025),
                                    child: Image.asset(
                                      "${dummyImagePath}news.png",
                                      width: size.width * numD07,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),

                          /// Payment Detail
                          Padding(
                            padding: EdgeInsets.only(top: size.width * numD04),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  paymentDetailText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  item.createdAT.isNotEmpty
                                      ? DateFormat('dd MMMM yyyy').format(
                                          DateTime.parse(item.createdAT))
                                      : '',
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),

                          /// Payment made time
                          Padding(
                            padding: EdgeInsets.only(top: size.width * numD02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  paymentMadeTimeText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  item.createdAT.isNotEmpty
                                      ? DateFormat('hh:mm a').format(
                                          DateTime.parse(item.createdAT))
                                      : '',
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),

                          /// Transaction ID
                          Padding(
                            padding: EdgeInsets.only(top: size.width * numD02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  transactionIdText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  item.id,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),

                          /// Divider
                          Padding(
                            padding: EdgeInsets.only(
                              top: size.width * numD01,
                            ),
                            child: const Divider(
                              color: Colors.white,
                              thickness: 1.5,
                            ),
                          ),

                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionDetailScreen(
                                            type: "received",
                                            transactionData:
                                                publicationTransactionList[
                                                    index],
                                          )));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  viewDetailsText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: colorThemePink,
                                      fontWeight: FontWeight.w700),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                  size: size.width * numD045,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : Container();
            },
            separatorBuilder: (context, index) {
              var item = publicationTransactionList[index];
              return item.paidStatus
                  ? SizedBox(
                      height: size.width * numD05,
                    )
                  : Container();
            },
            itemCount: publicationTransactionList.length);
    /*: Container();*/
  }

  Widget paymentPendingWidget() {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          var item = publicationTransactionList[index];
          return item.paidStatus
              ? Container(
                  padding: EdgeInsets.only(
                    top: size.width * numD05,
                    bottom: size.width * numD025,
                    left: size.width * numD05,
                    right: size.width * numD05,
                  ),
                  decoration: BoxDecoration(
                      color: colorLightGrey,
                      borderRadius: BorderRadius.circular(size.width * numD02)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * numD01,
                                horizontal: size.width * numD04),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colorThemePink,
                              borderRadius:
                                  BorderRadius.circular(size.width * numD015),
                            ),
                            child: Text(
                              "£${item.payableT0Hopper}",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD04,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Row(
                            children: [
                              Image.asset(
                                "${iconsPath}ic_share.png",
                                width: size.width * numD06,
                              ),
                              SizedBox(
                                width: size.width * numD03,
                              ),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD025),
                                child: Image.asset(
                                  "${dummyImagePath}news.png",
                                  width: size.width * numD08,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),

                      /// Your earnings
                      Padding(
                        padding: EdgeInsets.only(top: size.width * numD04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              yourEarningsText,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              "£350",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),

                      /// Presshop fees
                      Padding(
                        padding: EdgeInsets.only(top: size.width * numD02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              presshopFeesText,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              item.payableCommission.isNotEmpty
                                  ? "£${item.payableCommission}"
                                  : "",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),

                      /// Amount pending
                      Padding(
                        padding: EdgeInsets.only(top: size.width * numD02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              amountPendingText,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              item.payableT0Hopper.isNotEmpty
                                  ? "£${item.payableT0Hopper}"
                                  : "",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),

                      /// Payment due date
                      Padding(
                        padding: EdgeInsets.only(top: size.width * numD02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              paymentDueDateText,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              item.createdAT.isNotEmpty
                                  ? DateFormat('dd MMMM yyyy')
                                      .format(DateTime.parse(item.createdAT))
                                  : '',
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),

                      /// Divider
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.width * numD01,
                        ),
                        child: const Divider(
                          color: Colors.white,
                          thickness: 1.5,
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TransactionDetailScreen(
                                        type: "pending",
                                        transactionData:
                                            publicationTransactionList[index],
                                      )));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              viewDetailsText,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: colorThemePink,
                                  fontWeight: FontWeight.w700),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.black,
                              size: size.width * numD045,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : Container();
        },
        separatorBuilder: (context, index) {
          return !publicationTransactionList[index].paidStatus
              ? SizedBox(
                  height: size.width * numD05,
                )
              : Container();
        },
        itemCount: publicationTransactionList.length);
  }

  initializeFilter() {
    sortList.addAll([
      FilterModel(
          name: "View first payment received",
          icon: "ic_up.png",
          isSelected: true),
      FilterModel(
          name: "View last payment received",
          icon: "ic_down.png",
          isSelected: false),
      FilterModel(
          name: "View highest payment received",
          icon: "ic_graph_up.png",
          isSelected: false),
      FilterModel(
          name: "View lowest payment received",
          icon: "ic_graph_down.png",
          isSelected: false),
      FilterModel(
          name: filterDateText, icon: "ic_eye_outlined.png", isSelected: false),
    ]);

    /*filterList.addAll([
      FilterModel(name: "Reuters", icon: "ic_exclusive.png", isSelected: true),
      FilterModel(
          name: "Daily Mail", icon: "ic_exclusive.png", isSelected: false),
      FilterModel(name: "Tribune", icon: "ic_exclusive.png", isSelected: false),
      FilterModel(
          name: "Daily Mirror", icon: "ic_exclusive.png", isSelected: false),
      FilterModel(name: "The Sun", icon: "ic_exclusive.png", isSelected: false),
      FilterModel(
          name: "The Time", icon: "ic_exclusive.png", isSelected: false),
      FilterModel(
          name: "Telegraph", icon: "ic_exclusive.png", isSelected: false),
    ]);*/
  }

  Future<void> showBottomSheet(Size size) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * numD085),
          topRight: Radius.circular(size.width * numD085),
        )),
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter stateSetter) {
            return Padding(
              padding: EdgeInsets.only(
                top: size.width * numD06,
                left: size.width * numD05,
                right: size.width * numD05,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          splashRadius: size.width * numD07,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: size.width * numD07,
                          ),
                        ),
                        Text(
                          "Sort and Filter",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * appBarHeadingFontSizeNew,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            // filterList.clear();
                            sortList.clear();
                            initializeFilter();
                            stateSetter(() {});
                          },
                          child: Text(
                            "Clear all",
                            style: TextStyle(
                                color: colorThemePink,
                                fontWeight: FontWeight.w400,
                                fontSize: size.width * numD035),
                          ),
                        ),
                      ],
                    ),

                    /// Sort
                    SizedBox(
                      height: size.width * numD085,
                    ),

                    /// Sort Heading
                    Text(
                      sortText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD05,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),

                    filterListWidget(sortList, stateSetter, size, true),

                    /// Filter
                    SizedBox(
                      height: size.width * numD05,
                    ),

                    /// Filter Heading
                    Text(
                      filterText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD05,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),

                    filterListWidget(filterList, stateSetter, size, false),
                    SizedBox(
                      height: size.width * numD06,
                    ),

                    /// Button
                    Container(
                      width: size.width,
                      height: size.width * numD13,
                      margin:
                          EdgeInsets.symmetric(horizontal: size.width * numD04),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                      ),
                      child: commonElevatedButton(
                          applyText,
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, colorThemePink), () {
                        Navigator.pop(context);
                        callGetAllTransactionDetail();
                      }),
                    ),
                    SizedBox(
                      height: size.width * numD04,
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget filterListWidget(
      List<FilterModel> list, StateSetter stateSetter, Size size, bool isSort) {
    return ListView.separated(
      padding: EdgeInsets.only(top: size.width * numD03),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        var item = list[index];
        return InkWell(
          onTap: () {
            if (isSort) {
              int pos = list.indexWhere((element) => element.isSelected);
              if (pos != -1) {
                list[pos].isSelected = false;
                list[pos].fromDate = null;
                list[pos].toDate = null;
              }
            }

            item.isSelected = !item.isSelected;
            stateSetter(() {});
          },
          child: Container(
            padding: EdgeInsets.only(
              top: list[index].name == filterDateText
                  ? size.width * 0
                  : size.width * numD025,
              bottom: list[index].name == filterDateText
                  ? size.width * 0
                  : size.width * numD025,
              left: size.width * numD02,
              right: size.width * numD02,
            ),
            color: item.isSelected ? colorLightGrey : null,
            child: Row(
              children: [
                list[index].icon.isNotEmpty
                    ? Image.asset(
                        "$iconsPath${list[index].icon}",
                        color: Colors.black,
                        height: list[index].name == soldContentText
                            ? size.width * numD06
                            : size.width * numD05,
                        width: list[index].name == soldContentText
                            ? size.width * numD06
                            : size.width * numD05,
                      )
                    : Container(),
                SizedBox(
                  width: size.width * numD03,
                ),
                item.name == filterDateText
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              item.fromDate =
                                  await commonDatePicker(date: item.fromDate);
                              item.toDate = null;
                              int pos = list
                                  .indexWhere((element) => element.isSelected);
                              if (pos != -1) {
                                list[pos].isSelected = false;
                              }
                              item.isSelected = !item.isSelected;
                              stateSetter(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                top: size.width * numD01,
                                bottom: size.width * numD01,
                                left: size.width * numD03,
                                right: size.width * numD01,
                              ),
                              width: size.width * numD35,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                border: Border.all(
                                    width: 1, color: Color(0xFFDEE7E6)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.fromDate ?? fromText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD032,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    width: size.width * numD015,
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down_sharp,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * numD03,
                          ),
                          InkWell(
                            onTap: () async {
                              if (item.fromDate != null) {
                                String? pickedDate =
                                    await commonDatePicker(date: item.toDate);

                                if (pickedDate != null) {
                                  DateTime parseFromDate =
                                      DateTime.parse(item.fromDate!);
                                  DateTime parseToDate =
                                      DateTime.parse(pickedDate);

                                  debugPrint("parseFromDate : $parseFromDate");
                                  debugPrint("parseToDate : $parseToDate");

                                  if (parseToDate.isAfter(parseFromDate) ||
                                      parseToDate
                                          .isAtSameMomentAs(parseFromDate)) {
                                    item.toDate = pickedDate;
                                  } else {
                                    showSnackBar(
                                        "Date Error",
                                        "Please select to date above from date",
                                        Colors.red);
                                  }
                                }
                              }
                              setState(() {});
                              stateSetter(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                top: size.width * numD01,
                                bottom: size.width * numD01,
                                left: size.width * numD03,
                                right: size.width * numD01,
                              ),
                              width: size.width * numD35,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                border: Border.all(
                                    width: 1, color: const Color(0xFFDEE7E6)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.toDate ?? toText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD032,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    width: size.width * numD02,
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down_sharp,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(item.name,
                        style: TextStyle(
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ))
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: size.width * numD01,
        );
      },
    );
  }

  /// API Section

  /// API Section
  callGEtEarningDataAPI() {
    Map<String, String> map = {
      'limit': '10',
      'offset': '0',
      'type': 'publication'
    };
    NetworkClass(getEarningDataAPI, this, reqGetEarningDataAPI)
        .callRequestServiceHeader(true, 'get', map);
  }

  callGetAllTransactionDetail() {
    Map<String, String> map = {
      "content_id": widget.contentId,
/*      "limit": limit.toString(),
      "offset": offset.toString()*/
    };
    int pos = sortList.indexWhere((element) => element.isSelected);

    if (pos != -1) {
      if (sortList[pos].name == filterDateText) {
        map["startdate"] = sortList[pos].fromDate!;
        map["endDate"] = sortList[pos].toDate!;
      } else if (sortList[pos].name == 'View first payment received') {
        map["firstpaymentrecived"] = 'true';
      } else if (sortList[pos].name == 'View last payment received') {
        map["firstpaymentrecived"] = 'false';
      } else if (sortList[pos].name == 'View highest payment received') {
        map["highpaymentrecived"] = 'true';
      } else if (sortList[pos].name == 'View lowest payment received') {
        map["highpaymentrecived"] = 'false';
      }
    }

    /// Filter
    for (var element in filterList) {
      if (element.isSelected) {
        map['publication'] = element.id ?? "";
      }
    }

    debugPrint('map value ==> $map');
    NetworkClass(
            getPublicationTransactionAPI, this, reqGetPublicationTransactionAPI)
        .callRequestServiceHeader(true, 'get', map);
  }

  /// Media House
  callMediaHouseList() {
    NetworkClass(getMediaHouseDetailAPI, this, reqGetMediaHouseDetailAPI)
        .callRequestServiceHeader(true, 'get', {});
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqGetEarningDataAPI:
          debugPrint(
              "reqGetEarningDataAPI_ErrorResponse==> ${jsonDecode(response)}");
          break;
        case reqGetPublicationTransactionAPI:
          debugPrint(
              "reqGetPublicationTransactionAPI_ErrorResponse==> ${jsonDecode(response)}");
          break;

        case reqGetMediaHouseDetailAPI:
          debugPrint("Error response===> ${jsonDecode(response)}");
      }
    } on Exception catch (e) {
      debugPrint("Exception catch======> $e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqGetEarningDataAPI:
          debugPrint(
              "reqGetEarningDataAPI_SuccessResponse==> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var dataList = data['resp'];
          earningData = EarningProfileDataModel.fromJson(dataList);
          setState(() {});
          callGetAllTransactionDetail();
          break;

        case reqGetPublicationTransactionAPI:
          debugPrint(
              "reqGetPublicationTransactionAPI_successResponse==> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var dataList = data['data'] as List;
          publicationTransactionList = dataList
              .map((e) => EarningTransactionDetail.fromJson(e))
              .toList();
          debugPrint('publicationTransactionList length::::: ${publicationTransactionList.length}');
          setState(() {});
          break;
        case reqGetMediaHouseDetailAPI:
          debugPrint("success response===> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var dataList = data['response'] as List;
          var mediaHouseDataList =
              dataList.map((e) => PublicationDataModel.fromJson(e)).toList();
          for (var element in mediaHouseDataList) {
            filterList.add(FilterModel(
              name: element.companyName.isNotEmpty
                  ? element.companyName
                  : element.publicationName,
              icon: "",
              id: element.id,
              isSelected: false,
            ));
          }
          setState(() {});
      }
    } on Exception catch (e) {
      debugPrint("Exception catch======> $e");
    }
  }
}

class FilterModel {
  String name = "";
  String icon = "";
  String? fromDate;
  String? toDate;
  bool isSelected = false;
  String? id = "";

  FilterModel({
    this.fromDate,
    this.toDate,
    this.id,
    required this.name,
    required this.icon,
    required this.isSelected,
  });
}
