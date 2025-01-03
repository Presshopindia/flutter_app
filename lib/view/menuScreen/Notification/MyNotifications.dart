import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../utils/Common.dart';
import '../../../utils/CommonAppBar.dart';
import '../../../utils/CommonWigdets.dart';
import '../../../utils/networkOperations/NetworkClass.dart';
import '../../../utils/networkOperations/NetworkResponse.dart';
import '../../dashboard/Dashboard.dart';
import 'notiticationDataModel.dart';

class MyNotificationScreen extends StatefulWidget {
  int count = 0;

  MyNotificationScreen({Key? key, required this.count}) : super(key: key);

  @override
  State<MyNotificationScreen> createState() => _MyNotificationScreenState();
}

class _MyNotificationScreenState extends State<MyNotificationScreen>
    implements NetworkResponse {
  late Size size;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<NotificationData> notificationList = [];
  int limit = 10, offset = 0;
  bool showData = false, isLoading = false;
  bool uploadFirst =false,uploadSecond = false,showThird = false;
  int counting = 0;

  @override
  void initState() {
    debugPrint('class:::::::: $runtimeType');
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => callNotificationList());

    Future.delayed(const Duration(seconds: 5), () {
      callUpdateNotification();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        title: Text(
          notificationText,
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
            child: Container(
              width: size.width * numD075,
              height: size.width * numD075,
              margin: EdgeInsets.only(top: size.width * numD02),
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: size.width * numD06,
                    width: size.width * numD06,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade800, width: 2),
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(size.width * 0.002),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            Icons.circle,
                            color: colorThemePink,
                            size: size.width * numD04,
                          ),
                        ),
                        Text(
                          widget.count != 0
                              ? widget.count.toString()
                              : counting.toString(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD025,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            width: size.width * numD04,
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
        hideLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD05),
              child: Divider(
                color: Colors.grey.shade200,
                thickness: 1.5,
              ),
            ),
            Flexible(
              child: notificationList.isNotEmpty
                  ? SmartRefresher(
                      controller: _refreshController,
                      enablePullDown: true,
                      enablePullUp: true,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      footer:
                      const CustomFooter(builder: commonRefresherFooter),
                      child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsets.all(size.width * numD05),
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.only(
                                  top: size.width * numD03,
                                  left: size.width * numD03,
                                  right: size.width * numD03),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(size.width * numD03),
                                  topRight:
                                      Radius.circular(size.width * numD03),
                                ),
                                color: notificationList[index].unread
                                    ? Colors.white
                                    : colorLightGrey,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.all(size.width * numD01),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD04),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.shade200,
                                              spreadRadius: 2,
                                              blurRadius: 2)
                                        ]),
                                    child: Image.asset(
                                      "${dummyImagePath}news.png",
                                      height: size.width * numD12,
                                      width: size.width * numD12,
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * numD025,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                             notificationList[index].title,
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize:
                                                      size.width * numD035,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const Spacer(),
                                            Text(
                                              formatMessageTimestamp(
                                                  DateTime.parse(
                                                      notificationList[index]
                                                          .time)),
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize:
                                                      size.width * numD025,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: size.width * numD02,
                                        ),
                                        Text(
                                          notificationList[index].description,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD03,
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal),
                                          maxLines: 5,
                                        ),
                                        SizedBox(
                                          height: size.width * numD040,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Column(
                              children: [
                                Container(
                                  height: size.width * numD004,
                                  color: Colors.grey.shade200,
                                ),
                                SizedBox(
                                  height: size.width * numD038,
                                ),
                              ],
                            );
                          },
                          itemCount: notificationList.length),
                    )
                  : showData
                      ? errorMessageWidget("Data Not Available")
                      : Container(),
            ),
          ],
        ),
      ),
    );
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      offset = 0;
      showData = false;
      notificationList.clear();
      callNotificationList();
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      offset += 10;
      callNotificationList();
    });
    _refreshController.loadComplete();
  }

  /// Api Section
  callNotificationList() {
    NetworkClass("$notificationListAPI?limit=10&offset=$offset", this,
            reqNotificationListAPI)
        .callRequestServiceHeader(isLoading ? false : true, 'get', null);
  }

  callUpdateNotification() {
    NetworkClass(notificationReadAPI, this, reqNotificationReadAPI)
        .callRequestServiceHeader(false, 'patch', null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      debugPrint("Error response===> ${jsonDecode(response)}");
    } on Exception catch (e) {
      debugPrint('exception catch====> $e');
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqNotificationListAPI:
          debugPrint("success response===> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var dataList = data['data'] as List;
          counting = data['unreadCount'];
          widget.count = 0;

          var list = dataList.map((e) => NotificationData.fromJson(e)).toList();
          if (list.isNotEmpty) {
            _refreshController.loadComplete();
          } else if (list.isEmpty) {
            _refreshController.loadNoData();
          } else {
            _refreshController.loadFailed();
          }
          if (offset == 0) {
            notificationList.clear();
          }

          notificationList.addAll(list);
          debugPrint("notificationList length::::: ${notificationList.length}");
          showData = true;
          isLoading = true;
          setState(() {});

          break;
        case reqNotificationReadAPI:
          debugPrint("success response===> ${jsonDecode(response)}");
          callNotificationList();
      }
    } on Exception catch (e) {
      debugPrint('exception catch====> $e');
    }
  }
}
