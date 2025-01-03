import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/view/ratingReviewsScreen/ratingReviewsDataModel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../utils/CommonModel.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import '../dashboard/Dashboard.dart';
import '../menuScreen/PublicationListScreen.dart';
import '../publishContentScreen/TutorialsScreen.dart';

class RatingReviewScreen extends StatefulWidget {
  const RatingReviewScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return RatingReviewScreenState();
  }
}

class RatingReviewScreenState extends State<RatingReviewScreen>
    implements NetworkResponse {
  ScrollController listController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  int _offset = 0;
  String selectedType = receivedText;
  bool showData = false;

  List<CategoryDataModel> priceTipsCategoryList = [];
  List<RatingReviewData> ratingReviewList = [];
  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];
  List<FilterRatingData> filterRatingList = [];

  @override
  void initState() {
    initializeFilter();
    super.initState();
    priceTipsCategoryList.add(CategoryDataModel(
        name: receivedText, selected: true, id: '', type: '', percentage: ''));
    priceTipsCategoryList.add(CategoryDataModel(
        name: givenText, selected: false, id: '', type: '', percentage: ''));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      callGetAllRatingReview('');
      callMediaHouseList();
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
          "$ratingText & $reviewText",
          style: TextStyle(
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
            SizedBox(
              height: size.width * numD15,
              child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: listController,
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        int pos = priceTipsCategoryList
                            .indexWhere((element) => element.selected);
                        if (pos >= 0) {
                          priceTipsCategoryList[pos].selected = false;
                        }
                        priceTipsCategoryList[index].selected =
                            !priceTipsCategoryList[index].selected;
                        if (priceTipsCategoryList[index].selected) {
                          if (priceTipsCategoryList[index].name == givenText) {
                            selectedType = "given";
                            callGetAllRatingReview('given');
                          } else {
                            selectedType = "received";
                            callGetAllRatingReview('received');
                          }
                        }

                        listController.animateTo(index * 100,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.ease);

                        setState(() {});
                      },
                      child: Chip(
                        backgroundColor: priceTipsCategoryList[index].selected
                            ? Colors.black
                            : colorLightGrey,
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * numD04,
                            vertical: size.width * numD02),
                        label: Text(
                          priceTipsCategoryList[index].name,
                          style: TextStyle(
                              color: priceTipsCategoryList[index].selected
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: size.width * numD036,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      width: size.width * numD04,
                    );
                  },
                  itemCount: priceTipsCategoryList.length),
            ),
            SizedBox(
              height: size.width * numD04,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
              child: Row(
                children: [
                  Text(
                    "$ratingText & $reviewText $selectedType".toUpperCase(),
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD036,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      showBottomSheet(size);
                    },
                    child:Container(
                        padding: EdgeInsets.all(size.width * numD04),
                        child: Image.asset(
                          "${iconsPath}ic_filter.png",
                          height: size.width * numD05,
                        ))
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.width * numD04,
            ),
            Flexible(
              child: ratingReviewList.isNotEmpty
                  ? SmartRefresher(
                      controller: _refreshController,
                      enablePullDown: true,
                      enablePullUp: true,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      child: ListView.separated(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04,
                              vertical: size.width * numD02),
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * numD03,
                                  vertical: size.width * numD04),
                              decoration: BoxDecoration(
                                  color: colorLightGrey,
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04)),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 1, horizontal: 1),
                                    height: size.width * numD20,
                                    width: size.width * numD20,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD04),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade200,
                                            blurRadius: 1,
                                          )
                                        ]),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD04),
                                      child: CachedNetworkImage(
                                          imageUrl:
                                              ratingReviewList[index].image,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                                "${dummyImagePath}news.png",
                                                height: size.width * numD20,
                                                width: size.width * numD20,
                                              )),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * numD04,
                                  ),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            ratingReviewList[index].newsName,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: size.width * numD02,
                                                vertical: size.width * numD02),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD025)),
                                            child: Row(
                                              children: [
                                                Text(
                                                  ratingReviewList[index]
                                                      .ratingValue
                                                      .toString(),
                                                  style: commonTextStyle(
                                                      size: size,
                                                      fontSize:
                                                          size.width * numD03,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  width: size.width * numD01,
                                                ),
                                                RatingBar(
                                                  ratingWidget: RatingWidget(
                                                    empty: Image.asset(
                                                        "${iconsPath}ic_empty_star.png"),
                                                    full: Image.asset(
                                                        "${iconsPath}ic_full_star.png"),
                                                    half: Image.asset(
                                                        "${iconsPath}ic_half_star.png"),
                                                  ),
                                                  onRatingUpdate: (value) {},
                                                  itemSize: size.width * numD04,
                                                  ignoreGestures: true,
                                                  itemCount: 5,
                                                  initialRating:
                                                      ratingReviewList[index]
                                                              .ratingValue
                                                              .isNotEmpty
                                                          ? double.parse(
                                                              ratingReviewList[
                                                                      index]
                                                                  .ratingValue
                                                                  .toString())
                                                          : 0.0,
                                                  allowHalfRating: true,
                                                  itemPadding: EdgeInsets.only(
                                                      left: size.width * 0.003),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.width * numD02,
                                      ),
                                      Text(
                                        ratingReviewList[index].newsMessage,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD03,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: size.width * numD02,
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            "${iconsPath}ic_clock.png",
                                            height: size.width * numD04,
                                          ),
                                          SizedBox(
                                            width: size.width * numD02,
                                          ),
                                          Text(
                                            ratingReviewList[index].dateTime,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: colorHint,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    ],
                                  ))
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: size.width * numD06,
                            );
                          },
                          itemCount: ratingReviewList.length),
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
      _offset = 0;
      showData = false;
      ratingReviewList.clear();
      callGetAllRatingReview(selectedType);
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _offset += 10;
      callGetAllRatingReview(selectedType);
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
    filterRatingList.addAll([
      FilterRatingData(ratingValue: 5.0, selected: false),
      FilterRatingData(ratingValue: 4.0, selected: false),
      FilterRatingData(ratingValue: 3.0, selected: false),
      FilterRatingData(ratingValue: 2.0, selected: false),
      FilterRatingData(ratingValue: 1.0, selected: false),
    ]);
    /*filterList.addAll([
            FilterModel(name: "Reuters", icon: "ic_sold.png", isSelected: false),
            FilterModel(
                name: "Daily Mail", icon: "ic_live_content.png", isSelected: false),
            FilterModel(
                name: "Daily Mirror",
                icon: "ic_payment_reviced.png",
                isSelected: false),
            FilterModel(name: "The Sun", icon: "ic_pending.png", isSelected: false),
            FilterModel(
                name: "The Times", icon: "ic_exclusive.png", isSelected: false),
          ]);*/
  }

  Future<void> showBottomSheet(size) async {
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
                          sortList.clear();
                          //filterList.clear();
                          filterRatingList.clear();
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
                  SizedBox(
                    height: size.width * numD05,
                  ),

                  Text(
                    "$average $ratingText",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD05,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),

                  ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            int pos = filterRatingList
                                .indexWhere((element) => element.selected);

                            if (pos >= 0) {
                              filterRatingList[pos].selected = false;
                            }

                            filterRatingList[index].selected = true;
                            stateSetter(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * numD02,
                                horizontal: size.width * numD01),
                            decoration: BoxDecoration(
                                color: filterRatingList[index].selected
                                    ? colorLightGrey
                                    : Colors.transparent),
                            child: Row(
                              children: [
                                RatingBar(
                                  ratingWidget: RatingWidget(
                                    empty: Image.asset(
                                        "${iconsPath}ic_empty_star.png"),
                                    full: Image.asset(
                                        "${iconsPath}ic_full_star.png"),
                                    half: Image.asset(
                                        "${iconsPath}ic_half_star.png"),
                                  ),
                                  onRatingUpdate: (value) {},
                                  itemSize: size.width * numD04,
                                  itemCount: 5,
                                  ignoreGestures: true,
                                  initialRating:
                                      filterRatingList[index].ratingValue,
                                  allowHalfRating: true,
                                  itemPadding:
                                      EdgeInsets.only(left: size.width * 0.008),
                                ),
                                SizedBox(
                                  width: size.width * numD02,
                                ),
                                Text(
                                  "$andText up",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD04,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                )
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
                      itemCount: 5),

                  /// Filter
                  SizedBox(
                    height: size.width * numD05,
                  ),

                  /// Filter Heading
                  Text(
                    "$filterText $publicationsText",
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
                      callGetAllRatingReview(selectedType);
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

  Widget filterListWidget(BuildContext context, List<FilterModel> list,
      StateSetter stateSetter, size, bool isSort) {
    return ListView.separated(
      padding: EdgeInsets.only(top: size.width * numD02),
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
            color: list[index].isSelected ? colorLightGrey : null,
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
                list[index].icon.isNotEmpty?  SizedBox(
                  width: size.width * numD03,
                ):Container(),
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
                                        fontSize: size.width * numD035,
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
                                        fontSize: size.width * numD035,
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
                            fontSize: size.width * numD037,
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
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

  /// API Section
  callGetAllRatingReview(String ratingType) {
    debugPrint("ratingType =====> $ratingType");
    Map<String, String> map = {
      "limit": "10",
      "offset": _offset.toString(),
      "type": ratingType,
    };

    /// Short
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

    /// Filter
    for (var element in filterList) {
      if (element.isSelected) {
        map['publication'] = element.id ?? "";
      }
    }

    for (var element in filterRatingList) {
      if (element.selected) {
        switch (element.ratingValue.toString()) {
          case '5.0':
            map["rating"] = '5';
            break;

          case '4.0':
            map["startrating"] = '4';
            map["endrating"] = '5';
            break;

          case '3.0':
            map["startrating"] = '3';
            map["endrating"] = '4';
            break;
          case '2.0':
            map["startrating"] = '2';
            map["endrating"] = '3';
            break;
          case '1.0':
            map["startrating"] = '1';
            map["endrating"] = '2';
            break;
        }
      }
    }

    NetworkClass(getAllRatingAPI, this, reqGetAllRatingAPI)
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
        case reqGetAllRatingAPI:
          debugPrint(
              "reqGetAllRatingAPI_errorResponse===> ${jsonDecode(response)}");
          break;
        case reqGetMediaHouseDetailAPI:
          debugPrint("Error response===> ${jsonDecode(response)}");
      }
    } on Exception catch (e) {
      debugPrint("error Exception==> $e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqGetAllRatingAPI:
          debugPrint(
              "reqGetAllRatingAPI_successResponse===> ${jsonDecode(response)}");
          var data = jsonDecode(response);

          var listModel = data["resp"] as List;
          ratingReviewList =
              listModel.map((e) => RatingReviewData.fromJson(e)).toList();

          /*       if (list.isNotEmpty) {
              _refreshController.loadComplete();
            } else if (list.isEmpty) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadFailed();
            }

            if (_offset == 0) {
              ratingReviewList.clear();
            }
*/

          showData = true;
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
                  ? element.companyName.toCapitalized()
                  : element.publicationName,
              icon: "",
              id: element.id,
              isSelected: false,
            ));
          }
          setState(() {});
      }
    } on Exception catch (e) {
      debugPrint("error Exception==> $e");
    }
  }
}
