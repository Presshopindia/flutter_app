import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/menuScreen/MyContentDetailScreen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../utils/networkOperations/NetworkClass.dart';
import '../dashboard/Dashboard.dart';
import '../myEarning/MyEarningScreen.dart';
import '../publishContentScreen/HashTagSearchScreen.dart';
import '../publishContentScreen/TutorialsScreen.dart';
import 'MyDraftScreen.dart';

class MyContentScreen extends StatefulWidget {
  bool hideLeading = false;

  MyContentScreen({super.key, required this.hideLeading});

  @override
  State<StatefulWidget> createState() {
    return MyContentScreenState();
  }
}

class MyContentScreenState extends State<MyContentScreen>
    implements NetworkResponse {
  late Size size;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<MyContentData> myContentList = [];
  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];

  String selectedSellType = sharedText;
  ScrollController listController = ScrollController();
  int limit = 10, offset = 0;

  bool showData = false;

  @override
  void initState() {
    super.initState();
    initializeFilter();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => myContentApi());
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: widget.hideLeading,
        title: Padding(
          padding: EdgeInsets.only(
              left: widget.hideLeading ? size.width * numD04 : 0),
          child: Text(
            myContentText.toTitleCase(),
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: size.width * appBarHeadingFontSize),
          ),
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
          ),
          SizedBox(
            width: size.width * numD02,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Dashboard(
                            initialPosition: 2,
                          )),
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
          child: myContentList.isNotEmpty
              ? SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  footer: const CustomFooter(builder: commonRefresherFooter),
                  child: GridView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD04,
                          vertical: size.width * numD04),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.82,
                        mainAxisSpacing: size.width * numD04,
                        crossAxisSpacing: size.width * numD04,
                      ),
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) =>
                                          MyContentDetailScreen(
                                            paymentStatus:
                                                myContentList[index].status,
                                            exclusive:
                                                myContentList[index].exclusive,
                                            contentId: myContentList[index].id, offerCount: myContentList[index].offerCount,
                                          )))
                                  .then((value) => myContentApi());
                            },
                            child: contentWidget(myContentList[index]));
                      },
                      itemCount: myContentList.length),
                )
              : showData
                  ? errorMessageWidget("No Content Published")
                  : Container()),
    );
  }

  /// Content
  Widget contentWidget(MyContentData item) {
    return Container(
      padding: EdgeInsets.only(
          left: size.width * numD03,
          right: size.width * numD03,
          top: size.width * numD03),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade200, spreadRadius: 2, blurRadius: 1)
          ],
          borderRadius: BorderRadius.circular(size.width * numD04)),
      child: Column(
        children: [
          showMediaWidget(item),
          SizedBox(
            height: size.width * numD02,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title.toTitleCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD03,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                width: size.width * numD01,
              ),
              Image.asset(
                item.exclusive
                    ? "${iconsPath}ic_exclusive.png"
                    : "${iconsPath}ic_share.png",
                height:
                    item.exclusive ? size.width * numD03 : size.width * numD04,
                color: colorTextFieldIcon,
              )
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.exclusive
                        ? item.contentType.toCapitalized()
                        : multipleText.toUpperCase(),
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD026,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ImageIcon(const AssetImage("${iconsPath}ic_view.png"),
                          color: (item.paidStatus == paidText &&
                                      item.offerCount == 1) ||
                                  item.offerCount == 0
                              ? Colors.grey
                              : colorThemePink,
                          size: size.width * numD04),
                      SizedBox(width: size.width * numD015),
                      Text(
                 '${item.offerCount.toString()} ${item.offerCount > 1 ? '${offerText}s':offerText}',
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD026,
                            color: (item.paidStatus == paidText &&
                                        item.offerCount == 1) ||
                                    item.offerCount == 0
                                ? Colors.grey
                                : colorThemePink,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                height: size.width * numD08,
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * numD015,
                    vertical: size.width * numD01),
                decoration: BoxDecoration(
                    color: item.paidStatus == unPaidText
                        ? colorThemePink
                        : /*item.paidStatus == paidText &&
                                item.isPaidStatusToHopper
                            ?*/ colorLightGrey
                           /* : colorThemePink*/,
                    borderRadius: BorderRadius.circular(size.width * numD015)),
                child: Column(
                  children: [
                    Padding(
                      padding: item.paidStatus == paidText &&
                              !item.isPaidStatusToHopper
                          ? EdgeInsets.symmetric(
                              horizontal: size.width * numD028)
                          : EdgeInsets.zero,
                      child: Text(
                        item.paidStatus == unPaidText
                            ? item.status.toCapitalized()
                            : item.paidStatus == paidText &&
                                    item.isPaidStatusToHopper
                                ? "Received"
                                : "Sold",
                        textAlign: TextAlign.center,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD022,
                            color: item.paidStatus == unPaidText
                                ? Colors.white
                                : /*item.paidStatus == paidText &&
                                        item.isPaidStatusToHopper
                                    ?*/ Colors.black
                                    /*: Colors.white*/,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    Text(
                      "$euroUniqueCode${amountFormat(item.amount)}",
                      textAlign: TextAlign.center,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD022,
                          color: item.paidStatus == unPaidText
                              ? Colors.white
                              : /*item.paidStatus == paidText &&
                                      item.isPaidStatusToHopper
                                  ?*/ Colors.black
                                  /*: Colors.white*/,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: size.width * numD02,
          ),
        ],
      ),
    );
  }

  Widget showMediaWidget(MyContentData item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size.width * numD04),
      child: Stack(
        children: [

          item.contentMediaList.isNotEmpty
              ? showImage(
                  item.contentMediaList.first.mediaType,
                  item.contentMediaList.first.mediaType == "video"
                      ? item.contentMediaList.first.thumbNail
                      : item.contentMediaList.first.media,
                )
              : Container(
                  decoration: const BoxDecoration(color: colorLightGrey),
                  padding: EdgeInsets.all(size.width * numD06),
                  child: Image.asset(
                    "${commonImagePath}rabbitLogo.png",
                  ),
                ),
          item.contentMediaList.isNotEmpty
              ? Image.asset(
            "${commonImagePath}watermark1.png",
                height: size.width * numD29,
                width: size.width,
            fit: BoxFit.cover,
          )
              : Container(),

          Positioned(
            right: size.width * numD02,
            top: size.width * numD02,
            child: Container(
                width: size.width * numD06,
                height: size.width * numD06,
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * numD01,
                    vertical: size.width * 0.002),
                decoration: BoxDecoration(
                    color: colorLightGreen.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(size.width * numD015)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: item.contentMediaList.first.mediaType ==
                                  "video" ||
                              item.contentMediaList.first.mediaType == "audio"
                          ? 0
                          : size.width * 0.005,
                      vertical: item.contentMediaList.first.mediaType == "video"
                          ? size.width * 0.005
                          : item.contentMediaList.first.mediaType == "audio"
                              ? size.width * 0.009
                              : size.width * 0.01),
                  child: Image.asset(
                    item.contentMediaList.first.mediaType == "image"
                        ? "${iconsPath}ic_camera_publish.png"
                        : item.contentMediaList.first.mediaType == "video"
                            ? "${iconsPath}ic_v_cam.png"
                            : item.contentMediaList.first.mediaType == "audio"
                        ? "${iconsPath}ic_mic.png"
                        : "${iconsPath}doc_icon.png",
                    color: Colors.white,
                    height: item.contentMediaList.first.mediaType == "video"
                        ? size.width * numD09
                        : item.contentMediaList.first.mediaType == "image"
                            ? size.width * numD05
                            : item.contentMediaList.first.mediaType == "audio"
                        ? size.width * numD08
                        : size.width * numD1,
                  ),
                )),
          ),

          Positioned(
            right: size.width * numD02,
            bottom: size.width * numD02,
            child: Visibility(
              visible: item.contentMediaList.length > 1,
              child: Text(
                "+${item.contentMediaList.length - 1}",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD04,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showImage(String type, String url) {
    return type == "audio"
        ? Container(
      height: size.width * numD30,
      width: size.width,
      padding: EdgeInsets.all(size.width * numD04),
      decoration: BoxDecoration(
        border: Border.all(color: colorHint),
        borderRadius: BorderRadius.circular(size.width * numD04),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size.width * numD04),
        child: Padding(
          padding: EdgeInsets.all(size.width * numD03),
          child: Image.asset(
            "${iconsPath}ic_sound.png",
            width: size.width * numD03,
            height: size.height * numD03,
          ),
        ),
      ),
    ):type == "pdf"?
    Container(
      height: size.width * numD30,
      width: size.width,
      padding: EdgeInsets.all(size.width * numD04),
      decoration: BoxDecoration(
        border: Border.all(color: colorHint),
        borderRadius: BorderRadius.circular(size.width * numD04),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size.width * numD04),
        child: Padding(
          padding: EdgeInsets.all(size.width * numD03),
          child: Image.asset(
            "${dummyImagePath}pngImage.png",
            width: size.width * numD03,
            height: size.height * numD03,
          ),
        ),
      ),
    ):type == "doc"?
    Container(
      height: size.width * numD30,
      width: size.width,
      padding: EdgeInsets.all(size.width * numD04),
      decoration: BoxDecoration(
        border: Border.all(color: colorHint),
        borderRadius: BorderRadius.circular(size.width * numD04),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size.width * numD04),
        child: Padding(
          padding: EdgeInsets.all(size.width * numD03),
          child: Image.asset(
            "${dummyImagePath}doc_black_icon.png",
            width: size.width * numD03,
            height: size.height * numD03,
          ),
        ),
      ),
    )
        : Image.network(
            "$contentImageUrl$url",
            height: size.width * numD30,
            width: size.width,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Padding(
                padding: EdgeInsets.all(size.width * numD07),
                child: Image.asset(
                  "${commonImagePath}rabbitLogo.png",
                ),
              );
            },
            errorBuilder: (context, exception, stackTrace) {
              return Padding(
                padding: EdgeInsets.all(size.width * numD07),
                child: Image.asset(
                  "${commonImagePath}rabbitLogo.png",
                ),
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
                        offset = 0;
                        setState(() {});
                        Navigator.pop(context);
                        myContentApi();
                      }),
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget filterListWidget(List<FilterModel> list, StateSetter stateSetter, Size size, bool isSort) {
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
            }else{
              int pos = list.indexWhere((element) => element.isSelected);
              if (pos != -1) {
                list[pos].isSelected = false;
              }
            }
            item.isSelected= !item.isSelected;
            stateSetter(() {});
            setState(() {});
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

  /// Load Filter And Sort
  void initializeFilter() {
    sortList.addAll([
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
          name: soldContentText, icon: "ic_sold.png", isSelected: false),
      FilterModel(
          name: liveContentText,
          icon: "ic_live_content.png",
          isSelected: false),
      FilterModel(
          name: paymentsReceivedText,
          icon: "ic_payment_reviced.png",
          isSelected: false),
      FilterModel(
          name: pendingPaymentsText, icon: "ic_pending.png", isSelected: false),
      FilterModel(
          name: allExclusiveContentText,
          icon: "ic_exclusive.png",
          isSelected: false),
      FilterModel(
          name: allSharedContentText, icon: "ic_share.png", isSelected: false),
    ]);
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      showData = false;
      offset = 0;
      myContentList.clear();
      myContentApi();
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
      offset += 10;
      myContentApi();
    setState(() {});
    _refreshController.loadComplete();
  }

  ///--------Apis Section------------

  void myContentApi() {
    Map<String, String> params = {
      "limit": limit.toString(),
      "offset": offset.toString()
    };

    int pos = sortList.indexWhere((element) => element.isSelected);

    if (pos != -1) {
      if (sortList[pos].name == filterDateText) {
        params["startdate"] =  DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.parse(sortList[pos].fromDate!));
        params["endDate"] = DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.parse(sortList[pos].toDate!));

      } else if (sortList[pos].name == viewMonthlyText) {
        params["posted_date"] = "31";
      } else if (sortList[pos].name == viewYearlyText) {
        params["posted_date"] = "365";
      }
    }

    for (var element in filterList) {
      if (element.isSelected) {
        switch (element.name) {
          case soldContentText:
            params["sale_status"] = "sold";
            break;

          case liveContentText:
            params["livecontent"] = "un_paid";

            break;

          case paymentsReceivedText:
             params["recieved"] = "recieved";
            break;

          case pendingPaymentsText:
            params["payment_pending"] = "true";
            break;

          case allSharedContentText:
            params["sharedtype"] = "shared";
            break;

          case allExclusiveContentText:
            params["type"] = "exclusive";
            break;
        }
      }
    }
    NetworkClass(myContentUrl, this, myContentUrlRequest)
        .callRequestServiceHeader(true, "get", params);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case myContentUrlRequest:
          debugPrint("myContentError: $response");
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
        case myContentUrlRequest:
          var map = jsonDecode(response);
          debugPrint("myContentResponse: $response");
          if (map["code"] == 200) {
            var listModel = map["contentList"] as List;
            var list = listModel.map((e) => MyContentData.fromJson(e)).toList();

            if (list.isNotEmpty) {
              _refreshController.loadComplete();
            } else if (list.isEmpty) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadFailed();
            }

            if (offset == 0) {
              myContentList.clear();
            }

            myContentList.addAll(list);
          }
          showData = true;
          setState(() {});
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}

class MyContentData {
  String id = "";
  String title = "";
  String textValue = "";
  String time = "";
  String location = "";
  String latitude = "";
  String longitude = "";
  String amount = "";
  String status = "";
  String soldStatus = "";
  String paidStatus = "";
  String contentType = "";
  String dateTime = "";
  bool isPaidStatusToHopper = false;
  bool exclusive = false;
  bool showVideo = false;
  List<ContentMediaData> contentMediaList = [];
  List<HashTagData> hashTagList = [];
  CategoryDataModel? categoryData;
  String completionPercent = "";
  int leftPercent = 0;
  int offerCount = 0;
  String mediaHouseName = '';

  MyContentData.fromJson(json) {
    debugPrint("MyContentData: $json");
    id = json["_id"];
    exclusive = json["type"] == "shared" ? false : true;
    /* time = changeDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", json["timestamp"],
        "HH:mm, dd MMM, yyyy");*/
    dateTime = json["timestamp"].toString();
    time = DateFormat("HH:mm, dd MMM yyyy")
        .format(DateTime.parse(json["timestamp"].toString()));
    title = json["heading"] ?? "";
    textValue = json["description"];
    location = json["location"];
    latitude = json["latitude"].toString();
    longitude = json["longitude"].toString();
    amount = json["ask_price"] != null? json["ask_price"].toString():"0";
    status = json["status"].toString();
    soldStatus = json["sale_status"] ?? '';
    paidStatus = json["paid_status"].toString();
    isPaidStatusToHopper = json["paid_status_to_hopper"] ?? false;
    contentType = json['type'] ?? '';
    offerCount = json['offer_content_size'] ?? 0;


    mediaHouseName = json['purchased_publication_details'] != null
        ? json['purchased_publication_details']['company_name']
        : "";
    if (json["content"] != null) {
      var contentList = json["content"] as List;
      contentMediaList =
          contentList.map((e) => ContentMediaData.fromJson(e)).toList();
    }

    if (json["tagData"] != null) {
      var tagList = json["tagData"] as List;
      hashTagList = tagList.map((e) => HashTagData.fromJson(e)).toList();
    }
    if (json["categoryData"] != null) {
      categoryData = CategoryDataModel.fromJson(json["categoryData"]);
    }

    int count = 0;

    if (textValue.trim().isNotEmpty) {
      count += 1;
    }
    if (time.trim().isNotEmpty) {
      count += 1;
    }

    if (location.trim().isNotEmpty) {
      count += 1;
    }

    if (amount.trim().isNotEmpty) {
      count += 1;
    }

    if (contentMediaList.isNotEmpty) {
      count += 1;
    }

    if (hashTagList.isNotEmpty) {
      count += 1;
    }

    if (categoryData != null) {
      count += 1;
    }

    debugPrint("Count: $count");
    completionPercent = ((count * 14.286) / 100).round().toString();
    leftPercent = ((7 - count) * 14.286).round();
  }
}
