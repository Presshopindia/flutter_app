import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/view/menuScreen/TaskDeatilScreen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../utils/CommonModel.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import '../dashboard/Dashboard.dart';
import '../myEarning/MyEarningScreen.dart';

class MyTaskScreen extends StatefulWidget {
  bool hideLeading = false;

  MyTaskScreen({super.key, required this.hideLeading});

  @override
  State<StatefulWidget> createState() {
    return MyTaskScreenState();
  }
}

class MyTaskScreenState extends State<MyTaskScreen> implements NetworkResponse {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late Size size;

  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];

  List<MyTaskModel> taskList = [];

  bool _showData = false;

  int _offset = 0;

  String selectedSellType = sharedText;
  ScrollController listController = ScrollController();
  DateTime nowDate = DateTime.now();

  @override
  void initState() {
    initializeFilter();
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => callAllGetTaskApi());
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
            "$myText ${taskText}s",
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
            width: size.width * numD01,
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
            width: size.width * numD04,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: taskList.isNotEmpty
                  ? showDataWidget()
                  : _showData
                      ? errorMessageWidget("No Tasks")
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  /*Widget oldData(){
    return GridView.builder(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * numD04,
            vertical: size.width * numD04),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          mainAxisSpacing: size.width * numD04,
          crossAxisSpacing: size.width * numD04,
        ),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(
                    taskStatus: myTaskList[index].taskStatus,taskId: "",)));
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD04,
                  vertical: size.width * numD02),
              decoration: BoxDecoration(
                  border: Border.all(color: colorGoogleButtonBorder),
                  borderRadius:
                  BorderRadius.circular(size.width * numD04)),
              child: Column(
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  InkWell(
                    onTap: () {
                      broadcastDialog(
                          "REUTERS",
                          "${dummyImagePath}news.png",
                          "Vivamus sit amet commodo risus. Ut dictum rutrum lacinia. Ut at nunc a mi facilisis ornare...",
                          "3 miles away",
                          "2h:30m:00s",
                          "${euroUniqueCode}150 to ${euroUniqueCode}500",
                          size,
                              () {},"");
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 1, horizontal: 1),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              size.width * numD04),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 1,
                                spreadRadius: 2)
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            size.width * numD04),
                        child: Image.asset(
                          myTaskList[index].image,
                          height: size.width * numD20,
                          width: size.width,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  Text(
                    myTaskList[index].textValue,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD03,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "${iconsPath}ic_clock.png",
                        height: size.width * numD03,
                      ),
                      SizedBox(
                        width: size.width * numD01,
                      ),
                      Text(
                        myTaskList[index].time,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD025,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        myTaskList[index].status,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD025,
                            color: myTaskList[index].status ==
                                "Accepted" ||
                                myTaskList[index].status ==
                                    "Completed"
                                ? colorThemePink
                                : Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      myTaskList[index].status == "Accepted" ||
                          myTaskList[index].status == "Completed"
                          ? Container(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                            myTaskList[index].taskStatus ==
                                "Live"
                                ? size.width * numD03
                                : size.width * numD01,
                            vertical: size.width * numD01),
                        decoration: BoxDecoration(
                            color:
                            myTaskList[index].taskStatus ==
                                "Live"
                                ? colorThemePink
                                : colorLightGrey,
                            borderRadius: BorderRadius.circular(
                                size.width * numD015)),
                        child: Text(
                          myTaskList[index].taskStatus == "Live"
                              ? myTaskList[index].taskStatus
                              : "$euroUniqueCode${myTaskList[index].amountStatus} ${receivedText.toTitleCase()}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD025,
                              color: myTaskList[index]
                                  .taskStatus ==
                                  "Live"
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                          : Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * numD05,
                            vertical: size.width * numD01),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(
                                size.width * numD015)),
                        child: Text(
                          "$euroUniqueCode${myTaskList[index].amountStatus}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD025,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
        itemCount: myTaskList.length);
  }*/

  /// Load Filter And Sort
  void initializeFilter() {
    sortList.addAll([
      FilterModel(
          name: viewWeeklyText,
          icon: "ic_weekly_calendar.png",
          isSelected: false),
      FilterModel(
          name: viewMonthlyText,
          icon: "ic_monthly_calendar.png",
          isSelected: true),
      FilterModel(
          name: viewYearlyText,
          icon: "ic_yearly_calendar.png",
          isSelected: false),
      FilterModel(
          name: filterDateText, icon: "ic_eye_outlined.png", isSelected: false),
      FilterModel(
          name: "View highest payment received",
          icon: "ic_graph_up.png",
          isSelected: false),
      FilterModel(
          name: "View lowest payment received",
          icon: "ic_graph_down.png",
          isSelected: false),
    ]);

    filterList.addAll([
      FilterModel(
          name: liveContentText, icon: "ic_live_content.png", isSelected: true),
      FilterModel(
          name: paymentsReceivedText,
          icon: "ic_payment_reviced.png",
          isSelected: false),
      FilterModel(
          name: pendingPaymentsText, icon: "ic_pending.png", isSelected: false),
    ]);
  }

  Widget showDataWidget() {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      footer: const CustomFooter(builder: commonRefresherFooter),
      child: GridView.builder(
        itemCount: taskList.length,
        padding: EdgeInsets.symmetric(
            horizontal: size.width * numD04, vertical: size.width * numD04),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          mainAxisSpacing: size.width * numD04,
          crossAxisSpacing: size.width * numD04,
        ),
        itemBuilder: (context, index) {
          var item = taskList[index];
          return InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(
                            taskStatus: item.status,
                            taskId: item.taskDetail!.id,
                            totalEarning:item.totalAmount
                          )))
                  .then((value) => callAllGetTaskApi());
            },
            child: Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Image
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(size.width * numD04),
                          child: Image.network(
                            item.taskDetail!.mediaHouseImage,
                            height: size.width * numD29,
                            width: size.width ,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: const BoxDecoration(color: colorLightGrey),
                                padding: EdgeInsets.all(size.width * numD06),
                                child: Image.asset(
                                  "${commonImagePath}rabbitLogo.png",
                                ),
                              );
                            },
                            errorBuilder: (context, exception, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(color: colorLightGrey),
                                padding: EdgeInsets.all(size.width * numD06),
                                child: Image.asset(
                                  "${commonImagePath}rabbitLogo.png",
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),


                    /// Title
                    Text(
                      item.taskDetail!.description.toCapitalized(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD03,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),

                    /// Dead Line
                    Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Image.asset(
                          "${iconsPath}ic_clock.png",
                          height: size.width * numD03,
                        ),
                        SizedBox(
                          width: size.width * numD01,
                        ),
                        Text(
                          dateTimeFormatter(
                              dateTime: item.taskDetail!.deadLine.toString(),
                              format: "HH:mm, dd.MM.yyyy",
                              time: true),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD024,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(   item.totalAmount == "0" && item.status == "accepted"?item.status.toUpperCase():"RECEIVED",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD025,
                                color: item.status == "accepted" ||
                                        item.status == "completed"
                                    ? colorThemePink
                                    : Colors.black,
                                fontWeight: FontWeight.normal)),
                        item.status == "accepted"
                            ? Container(
                                height: size.width * numD08,
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04,
                                    vertical: size.width * numD01),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: item.status == "accepted" && item.totalAmount == "0"
                                        ? colorThemePink
                                        : colorLightGrey,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD015)),
                                child: Text(
                                  item.status == "accepted" && item.totalAmount == "0"
                                      ? "Live"
                                      : "$euroUniqueCode${item.totalAmount}",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD025,
                                      color: item.status == "accepted" && item.totalAmount == "0"
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            : Container(
                                alignment: Alignment.center,
                                height: size.width * numD08,
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD05,
                                    vertical: size.width * numD01),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD015)),
                                child: Text(
                                  "$euroUniqueCode${item.totalAmount}",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD025,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                      ],
                    ),

                    SizedBox(
                      height: size.width * numD01,
                    )
                  ],
                ),
              ),
          );
        },
      ),
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
                        Navigator.pop(context);
                        callAllGetTaskApi();
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

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _showData = false;
      _offset = 0;
      taskList.clear();
      callAllGetTaskApi();
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _offset += 10;
      callAllGetTaskApi();
    });
    _refreshController.loadComplete();
  }

  void callAllGetTaskApi() {
    Map<String, String> params = {"limit": "10", "offset": _offset.toString()};

    int pos = sortList.indexWhere((element) => element.isSelected);

    if (pos != -1) {
      if (sortList[pos].name == filterDateText) {
        params["startdate"] = sortList[pos].fromDate!;
        params["endDate"] = sortList[pos].toDate!;
      } else if (sortList[pos].name == viewMonthlyText) {
        params["posted_date"] = "31";
      } else if (sortList[pos].name == viewYearlyText) {
        params["posted_date"] = "365";
      } else if (sortList[pos].name == viewWeeklyText) {
        params["posted_date"] = "7";
      } else if (sortList[pos].name == "View highest payment received") {
        params["hightolow"] = "-1";
      } else if (sortList[pos].name == "View lowest payment received") {
        params["lowtohigh"] = "-1";
      }
    }

    for (var element in filterList) {
      if (element.isSelected) {
        switch (element.name) {
          case paymentsReceivedText:
            params["paid_status"] = "paid";
            break;

          case liveTaskText:
            params["status"] = "live";
            break;

          case pendingPaymentsText:
            params["paid_status"] = "un_paid";
            break;
        }
      }
    }

    NetworkClass(getAllMyTaskUrl, this, getAllMyTaskReq)
        .callRequestServiceHeader(_offset == 0, "get", params);
  }

  @override
  void onError({required int requestCode, required String response}) {
    switch (requestCode) {
      case getAllMyTaskReq:
        {
          var data = jsonDecode(response);
          debugPrint("getAllMyTaskReq Error : $data");
          break;
        }
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    switch (requestCode) {
      case getAllMyTaskReq:
        {
          var data = jsonDecode(response);
          debugPrint("getAllMyTaskReq Success : $data");

          var dataModel = data["data"] as List;
          var list = dataModel.map((e) => MyTaskModel.fromJson(e)).toList();

          if (list.isNotEmpty) {
            _refreshController.loadComplete();
          } else if (list.isEmpty) {
            _refreshController.loadNoData();
          } else {
            _refreshController.loadFailed();
          }

          if (_offset == 0) {
            taskList.clear();
          }

          taskList.addAll(list);
          debugPrint("taskList Length : ${taskList.length}");
          _showData = true;

          if (mounted) {
            setState(() {});
          }
          break;
        }
    }
  }
}

class MyTaskModel {
  TaskDetailModel? taskDetail;
  String status = "";
  String totalAmount = "";
  MyTaskModel.fromJson(Map<String, dynamic> json) {
    taskDetail = TaskDetailModel.fromJson(json["task_id"] ?? {});
    status = (json["task_status"] ?? "").toString();
    totalAmount = json['total_payment'].toString() ?? '0';
  }
}
