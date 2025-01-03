import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/menuScreen/ContactUsScreen.dart';
import 'package:presshop/view/menuScreen/FAQScreen.dart';
import 'package:presshop/view/myEarning/TransactionDetailScreen.dart';
import 'package:presshop/view/publishContentScreen/TutorialsScreen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../dashboard/Dashboard.dart';
import 'earningDataModel.dart';

class MyEarningScreen extends StatefulWidget {
  bool openDashboard = false;

  MyEarningScreen({super.key, required this.openDashboard});

  @override
  State<MyEarningScreen> createState() => _MyEarningScreenState();
}

class _MyEarningScreenState extends State<MyEarningScreen>
    implements NetworkResponse {
  late Size size;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];
  EarningProfileDataModel? earningData;
  List<EarningTransactionDetail> earningTransactionDataList = [];
  bool showData = false;
  bool isSorting = false;
  int limit = 10, offset = 0;
  final currencyFormat = NumberFormat("#,##0.00", "en_US");

  @override
  initState() {
    initializeFilter();

    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => callGEtEarningDataAPI());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => Dashboard(
                      initialPosition: 2,
                    )),
            (route) => false);

        return false;
      },
      child: Scaffold(
        appBar: CommonAppBar(
          elevation: 0,
          hideLeading: false,
          title: Text(
            myEarningsText,
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
            widget.openDashboard
                ? Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => Dashboard(
                              initialPosition: 0,
                            )),
                    (route) => false)
                : Navigator.pop(context);
          },
          actionWidget: [
            InkWell(
              onTap: () {
                showBottomSheet(size);
              },
              child: commonFilterIcon(size),
            ),
            SizedBox(
              width: size.width * numD02,
            ),
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
                        borderRadius:
                            BorderRadius.circular(size.width * numD05)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1.2, color: Colors.black),
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04)),
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
                                    "${dummyImagePath}dummy_earnings.png",
                                    fit: BoxFit.cover,
                                    height: size.width * numD32,
                                    width: size.width * numD35,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: size.width * numD06),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    youHaveEarnedText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD045,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: size.width * numD02,
                                  ),
                                  Text(
                                    earningData!.totalEarning.isNotEmpty
                                        ? "£${currencyFormat.format(double.parse(earningData!.totalEarning))}"
                                        : '£0',
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD075,
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
                        Row(
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
                                        sortList.isNotEmpty
                                            ? sortList.first.fromDate ??
                                                fromText
                                            : fromText,
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
                                    String? pickedDate = await commonDatePicker(
                                        date: sortList.first.toDate);

                                    if (pickedDate != null) {
                                      DateTime parseFromDate = DateTime.parse(
                                          sortList.first.fromDate!);
                                      DateTime parseToDate =
                                          DateTime.parse(pickedDate);

                                      debugPrint(
                                          "parseFromDate : $parseFromDate");
                                      debugPrint("parseToDate : $parseToDate");

                                      if (parseToDate.isAfter(parseFromDate) ||
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
                                        sortList.isNotEmpty
                                            ? sortList.first.toDate ?? toText
                                            : toText,
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
                    paymentReceivedText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD045,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),

                  SizedBox(
                    height: size.width * numD02,
                  ),

                  const Divider(
                    color: Color(0xFFD8D8D8),
                    thickness: 1.5,
                  ),

                  SizedBox(
                    height: size.width * numD04,
                  ),

                  /// Payment Receive
                  paymentReceivedWidget(),

                  SizedBox(
                    height: size.width * numD04,
                  ),

                  Text(
                    paymentPendingText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD045,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),

                  SizedBox(
                    height: size.width * numD02,
                  ),

                  const Divider(
                    color: Color(0xFFD8D8D8),
                    thickness: 1.5,
                  ),

                  SizedBox(
                    height: size.width * numD04,
                  ),

                  /// Payment Pending
                  paymentPendingWidget(),

                  Padding(
                    padding: EdgeInsets.only(
                        top: size.width * numD07, bottom: size.width * numD07),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                "If you have any questions regarding your earnings or pending payments, please ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                          WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const ContactUsScreen()));
                                },
                                child: Text(
                                  "${contactText.toLowerCase()} ",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: colorThemePink,
                                      fontWeight: FontWeight.w500),
                                ),
                              )),
                          TextSpan(
                            text:
                                "our helpful team who are available 24 x 7 to assist you. All communication, is completely discreet and secure. \n \n",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: "Also check our ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                          WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => FAQScreen(
                                            priceTipsSelected: false,
                                            type: 'faq',
                                          )));
                                },
                                child: Text(
                                  "$faqText ",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: colorThemePink,
                                      fontWeight: FontWeight.w500),
                                ),
                              )),
                          TextSpan(
                            text: "and ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                          WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => TutorialsScreen()));
                                },
                                child: Text(
                                  "${tutorialsText.toLowerCase()} ",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: colorThemePink,
                                      fontWeight: FontWeight.w500),
                                ),
                              )),
                          TextSpan(
                            text:
                                "for answers to common payment queries. Thank you ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: size.width * numD03,
                            fontWeight: FontWeight.w300,
                            height: 1.5),
                      ),
                    ),
                  )
                ],
              )
            : showData
                ? errorMessageWidget("Not Data Found!")
                : Container(),
      ),
    );
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      showData = false;
      offset += 10;
      callGetAllTransactionDetail();
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      showData = false;
      offset += 10;
      callGetAllTransactionDetail();
    });
    _refreshController.loadComplete();
  }

  void initializeFilter() {
    sortList.addAll([
      FilterModel(
          name: viewWeeklyText,
          icon: "ic_weekly_calendar.png",
          isSelected: false),
      FilterModel(
          name: viewMonthlyText,
          icon: "ic_monthly_calendar.png",
          isSelected: false),
      FilterModel(
          name: viewYearlyText,
          icon: "ic_yearly_calendar.png",
          isSelected: false),
      FilterModel(
          name: filterDateText, icon: "ic_eye_outlined.png", isSelected: false),
    ]);

    filterList.addAll([
      FilterModel(
          name: allContentsText, icon: "ic_square_play.png", isSelected: false),
      FilterModel(name: allTasksText, icon: "ic_task.png", isSelected: false),
      FilterModel(
          name: allExclusiveContentText,
          icon: "ic_exclusive.png",
          isSelected: false),
      FilterModel(
          name: allSharedContentText, icon: "ic_share.png", isSelected: false),
      FilterModel(
          name: paymentsReceivedText,
          icon: "ic_payment_reviced.png",
          isSelected: false),
      FilterModel(
          name: pendingPaymentsText, icon: "ic_pending.png", isSelected: false),
    ]);
  }

  Widget paymentReceivedWidget() {
    return earningTransactionDataList.isNotEmpty
        ? ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var item = earningTransactionDataList[index];
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
                                  item.amount.isNotEmpty
                                      ? "£${currencyFormat.format(double.parse(item.payableT0Hopper))}"
                                      : "",
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
                                    item.type == "shared"
                                        ? "${iconsPath}ic_share.png"
                                        : "${iconsPath}ic_exclusive.png",
                                    height: size.width * numD035,
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
                                  item.createdAT,
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
                                  dateTimeFormatter(dateTime: item.createdAT,time: true,format: "hh:mm a"),
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
                                            transactionData: earningTransactionDataList[index],
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
              var item = earningTransactionDataList[index];
              return item.paidStatus
                  ? SizedBox(
                      height: size.width * numD05,
                    )
                  : Container();
            },
            itemCount: earningTransactionDataList.length)
        : Container();
  }

  Widget paymentPendingWidget() {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          var item = earningTransactionDataList[index];
          return !item.paidStatus
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
                              item.amount.isNotEmpty
                                  ? "£${currencyFormat.format(double.parse(item.payableT0Hopper))}"
                                  : "",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD04,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Image.asset(
                                  item.type == "shared"
                                      ? "${iconsPath}ic_share.png"
                                      : "${iconsPath}ic_exclusive.png",
                                  width: size.width * numD06,
                                ),
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
                              item.amount.isNotEmpty ? "£${item.amount}" : "",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),

                      /// PressHop fees
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
                                  ? "£${double.parse(item.payableT0Hopper).toStringAsFixed(2)}"
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
                              item.dueDate,
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
                                            earningTransactionDataList[index],
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
          return !earningTransactionDataList[index].paidStatus
              ? SizedBox(
                  height: size.width * numD05,
                )
              : Container();
        },
        itemCount: earningTransactionDataList.length);
  }

  Widget filterListWidget(context, List<FilterModel> list,
      StateSetter stateSetter, Size size, bool isSort) {
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
            setState(() {});
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
            color: list[index].isSelected ? colorLightGrey : null,
            child: Row(
              children: [
                Image.asset(
                  "$iconsPath${list[index].icon}",
                  color: Colors.black,
                  height: list[index].name == soldContentText
                      ? size.width * numD06
                      : size.width * numD05,
                  width: list[index].name == soldContentText
                      ? size.width * numD06
                      : size.width * numD05,
                ),
                SizedBox(
                  width: size.width * numD03,
                ),
                list[index].name == filterDateText
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
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                top: size.width * numD01,
                                bottom: size.width * numD01,
                                left: size.width * numD03,
                                right: size.width * numD01,
                              ),
                              width: size.width * numD32,
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
                              stateSetter(() {});
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                top: size.width * numD01,
                                bottom: size.width * numD01,
                                left: size.width * numD03,
                                right: size.width * numD01,
                              ),
                              width: size.width * numD32,
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
                    : Text(list[index].name,
                        style: TextStyle(
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: "AirbnbCereal_W_Bk"))
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

  Future<void> showBottomSheet(Size size) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
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
              child: ListView(
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
                          filterList.clear();
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

                  filterListWidget(context, sortList, stateSetter, size, true),

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
                  filterListWidget(
                      context, filterList, stateSetter, size, false),

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
            );
          });
        });
  }

  /// Calender
  Future<String?> commonDatePicker({String? date}) async {
    DateTime defaultDate = DateTime.parse(date ?? DateTime.now().toString());
    final DateTime? pickedDate = await showDatePicker(
      context: navigatorKey.currentContext!,
      initialDate: defaultDate,
      firstDate: DateTime(1900, 01, 01),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
              colorScheme:
                  const ColorScheme.light().copyWith(primary: colorThemePink)),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final String formatted =
          dateTimeFormatter(dateTime: pickedDate.toString());
      debugPrint("formatted=======Date===Format====>$formatted");
      return formatted;
    } else {
      return date;
    }
  }

  /// API Section
  callGEtEarningDataAPI() {
    NetworkClass(getEarningDataAPI, this, reqGetEarningDataAPI)
        .callRequestServiceHeader(true, 'get', {});
  }

  callGetAllTransactionDetail() {
    Map<String, String> map = {
      "limit": limit.toString(),
      "offset": offset.toString()
    };
    int pos = sortList.indexWhere((element) => element.isSelected);

    if (pos != -1) {
      if (sortList[pos].name == filterDateText) {
        map["startdate"] = sortList[pos].fromDate!;
        map["endDate"] = sortList[pos].toDate!;
      } else if (sortList[pos].name == viewMonthlyText) {
        map["posted_date"] = "31";
      } else if (sortList[pos].name == viewYearlyText) {
        map["posted_date"] = "365";
      } else if (sortList[pos].name == viewWeeklyText) {
        map["posted_date"] = "7";
      }
    }

    for (var element in filterList) {
      if (element.isSelected) {
        switch (element.name) {
          case allExclusiveContentText:
            map["type"] = 'exclusive';
            break;

          case allSharedContentText:
            map["sharedtype"] = "shared";
            break;

          case paymentsReceivedText:
            map["paid_status"] = "paid";
            break;

          case allContentsText:
            map['allcontent'] = 'content';
            break;

          case allTasksText:
            map['alltask'] = 'task_content';
            break;

          case pendingPaymentsText:
            map["paid_status"] = "un_paid";
            break;
        }
      }
    }

    debugPrint('map value ==> $map');
    NetworkClass(
            getAllEarningTransactionAPI, this, reqGetAllEarningTransactionAPI)
        .callRequestServiceHeader(true, 'get', map);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqGetEarningDataAPI:
          debugPrint(
              "reqGetEarningDataAPI_ErrorResponse==> ${jsonDecode(response)}");
          break;
        case reqGetAllEarningTransactionAPI:
          debugPrint(
              "reqGetAllEarningTransactionAPI_ErrorResponse==> ${jsonDecode(response)}");
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
          callGetAllTransactionDetail();
          setState(() {});
          break;

        case reqGetAllEarningTransactionAPI:
          debugPrint(
              "reqGetAllEarningTransactionAPI_successResponse==> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var dataList = data['data'] as List;
          earningTransactionDataList = dataList
              .map((e) => EarningTransactionDetail.fromJson(e))
              .toList();
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

  FilterModel({
    required this.name,
    required this.icon,
    required this.isSelected,
    this.fromDate,
    this.toDate,
  });
}
