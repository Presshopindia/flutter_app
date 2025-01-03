import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:presshop/view/publishContentScreen/PublishContentScreen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import '../../utils/networkOperations/NetworkClass.dart';
import '../myEarning/MyEarningScreen.dart';
import '../publishContentScreen/HashTagSearchScreen.dart';
import '../publishContentScreen/TutorialsScreen.dart';
import 'MyContentScreen.dart';

class MyDraftScreen extends StatefulWidget {
  bool publishedContent = false;

  MyDraftScreen({super.key, required this.publishedContent});

  @override
  State<StatefulWidget> createState() {
    return MyDraftScreenState();
  }
}

class MyDraftScreenState extends State<MyDraftScreen>
    implements NetworkResponse {
  late Size size;
  List<MyContentData> myDraftList = [];
  String selectedSellType = sharedText;
  ScrollController listController = ScrollController();
  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];
  bool showData = false;
  int limit = 10, offset = 0;
  int draftIndex = 0;

  int selectedIndex = 0;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    initializeFilter();
    super.initState();

    Future.delayed(Duration.zero, () {
      myDraftApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (widget.publishedContent) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => Dashboard(initialPosition: 2)),
              (route) => false);
        } else {
          Navigator.pop(context);
        }

        return false;
      },
      child: Scaffold(
        appBar: CommonAppBar(
          elevation: 0,
          hideLeading: false,
          title: Text(
            myDraftText.toTitleCase(),
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
            if (widget.publishedContent) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)),
                  (route) => false);
            } else {
              Navigator.pop(context);
            }
          },
          actionWidget: [
            InkWell(
              onTap: () {
                showBottomSheet(size);
              },
              child: commonFilterIcon(size)
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
              width: size.width * numD04,
            )
          ],
        ),
        body: SafeArea(
          child: myDraftList.isNotEmpty
              ? SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  onLoading: _onLoading,
                  onRefresh: _onRefresh,
                  controller: _refreshController,
                  child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD04,
                          vertical: size.width * numD04),
                      itemBuilder: (context, index) {
                        double percentRange =
                            double.parse(myDraftList[index].completionPercent);
                        var item = myDraftList[index];
                        return InkWell(
                          onTap: () {

                            selectedIndex =  index;
                            updateDraftListAPI(myDraftList[index].id);
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: size.width * numD03,
                                right: size.width * numD03,
                                top: size.width * numD03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                mediaWidget(item),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                          myDraftList[index]
                                              .textValue
                                              .toCapitalized(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD035,
                                              color: Colors.black,
                                              lineHeight: 1.5,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    SizedBox(height: size.width * numD02),
                                    Image.asset(
                                      myDraftList[index].exclusive
                                          ? "${iconsPath}ic_exclusive.png"
                                          : "${iconsPath}ic_share.png",
                                      height: size.width * numD035,
                                      color: colorTextFieldIcon,
                                    ),
                                    SizedBox(
                                      width: size.width * numD02,
                                    ),
                                    Text(
                                      myDraftList[index].exclusive
                                          ? exclusiveText
                                          : sharedText,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD035,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    )
                                  ],
                                ),
                                /*  Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                          myDraftList[index]
                                              .textValue
                                              .toCapitalized(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD03,
                                              color: Colors.black,
                                              lineHeight: 1.5,
                                              fontWeight: FontWeight.normal)),
                                    ),
                                  SizedBox(
                                    height: size.width*numD01,
                                  ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          item.exclusive
                                              ? "${iconsPath}ic_exclusive.png"
                                              : "${iconsPath}ic_share.png",
                                          height: size.width * numD035,
                                        ),
                                        SizedBox(
                                          width: size.width * numD02,
                                        ),
                                        Text(
                                          myDraftList[index].exclusive
                                              ? exclusiveText
                                              : sharedText,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD03,
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    )
                                  ],
                                )*/
                                /*    SizedBox(
                                      height: size.width * numD02,
                                    ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          "${iconsPath}ic_clock.png",
                                          height: size.width * numD04,
                                          color: colorTextFieldIcon,
                                        ),
                                        SizedBox(
                                          width: size.width * numD01,
                                        ),
                                        Text(
                                          item.time,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD028,
                                              color: colorHint,
                                              fontWeight: FontWeight.normal),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.width * numD02,
                                    ),

                                    /// Location
                                    Row(
                                      children: [
                                        Image.asset(
                                          "${iconsPath}ic_location.png",
                                          height: size.width * numD045,
                                          color: colorTextFieldIcon,
                                        ),
                                        SizedBox(
                                          width: size.width * numD01,
                                        ),
                                        Expanded(
                                          child: Text(
                                            item.location,
                                            overflow: TextOverflow.ellipsis,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD028,
                                                color: colorHint,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        )
                                      ],
                                    ),*/
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      "${iconsPath}ic_clock.png",
                                      height: size.width * numD04,
                                      color: colorTextFieldIcon,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Text(
                                      item.time,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD028,
                                          color: colorHint,
                                          fontWeight: FontWeight.normal),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      "${iconsPath}ic_location.png",
                                      height: size.width * numD045,
                                      color: colorTextFieldIcon,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Expanded(
                                      child: Text(
                                        item.location,
                                        overflow: TextOverflow.ellipsis,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD028,
                                            color: colorHint,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                                Text(
                                  "${myDraftList[index].leftPercent}% left to complete",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: Colors.black,
                                      lineHeight: 1.5,
                                      fontWeight: FontWeight.normal),
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                                Container(
                                  color: Colors.green,
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 0.0,disabledThumbRadius:0.0),
                                     // thumbColor: Colors.transparent,
                                      trackHeight: size.width * numD025,
                                      rangeTrackShape:const RoundedRectRangeSliderTrackShape(),
                                      overlayShape: SliderComponentShape.noThumb,

                                    ),
                                    child: Slider(
                                      value: double.parse(myDraftList[index].completionPercent),
                                      onChanged: (value) {
                                      },
                                      inactiveColor: colorLightGrey,
                                      activeColor: colorThemePink,
                                      secondaryActiveColor: colorInactiveSlider,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          thickness: 1,
                          color: colorLightGrey,
                        );
                      },
                      itemCount: myDraftList.length),
                )
              : showData
                  ? errorMessageWidget("No Content Published")
                  : Container(),
        ),
      ),
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
      myDraftList.clear();
      myDraftApi();
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      offset += 10;
      myDraftApi();
    });
    _refreshController.loadComplete();
  }

  Widget mediaWidget(item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size.width * numD04),
      child: Stack(
        children: [
          showImage(
            item.contentMediaList.first.mediaType,
            item.contentMediaList.first.mediaType == "video"
                ? item.contentMediaList.first.thumbNail
                : item.contentMediaList.first.media,
          ),
          Positioned(
            right: size.width * numD02,
            top: size.width * numD02,
            child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * numD01,
                    vertical: size.width * 0.002),
                decoration: BoxDecoration(
                    color: colorLightGreen.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(size.width * numD015)),
                child:  (item.contentMediaList.first.mediaType=="doc" || item.contentMediaList.first.mediaType=="pdf") ?
                Padding(
                  padding:  EdgeInsets.symmetric(vertical: size.width*numD002),
                  child: Image.asset("${iconsPath}doc_icon.png",
                    height: size.width * numD04,
                    color: Colors.white,
                  ),
                ): Icon(
                  item.contentMediaList.first.mediaType == "video"
                      ? Icons.videocam_outlined
                      : item.contentMediaList.first.mediaType == "audio"
                          ? Icons.mic
                          : Icons.camera_alt,
                  size: size.width * numD04,
                  color: Colors.white,
                ),
            )
          ),
          Visibility(
            visible: item.contentMediaList.length > 1,
            child: Positioned(
              right: size.width * numD02,
              bottom: size.width * numD02,
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
          Visibility(
            visible: item.contentMediaList.first.mediaType != "audio",
            child: Image.asset(
              "${commonImagePath}watermark.png",
              height: size.width * numD50,
              width: size.width,
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }

  Widget showImage(String type, String url) {
    return type == "audio"
        ? Image.asset(
            "${iconsPath}ic_sound.png",
            height: size.width * numD50,
            width: size.width,
            fit: BoxFit.cover,
          ):type == "pdf"
        ? Image.asset(
      "${dummyImagePath}pngImage.png",
      fit: BoxFit.contain,
      height: size.width * numD50,
      width: size.width,
    ): type == "doc"
        ? Image.asset(
      "${dummyImagePath}doc_black_icon.png",
      height: size.width * numD50,
      fit: BoxFit.contain,
      width: size.width,
    ): Image.network(
      "$contentImageUrl$url",
      height: size.width * numD50,
      width: size.width,
      fit: BoxFit.cover,
    );
  }

/*  Future<void> showBottomSheet(Size size) async {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                            //initializeFilter();
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

                    filterListWidget(filterList, stateSetter, size, true),

                    /// Button
                    SizedBox(
                      height: size.width * numD06,
                    ),

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
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.only(
              top: item.name == filterDateText
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
                  height: item.name == soldContentText
                      ? size.width * numD06
                      : size.width * numD05,
                  width: item.name == soldContentText
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
                            fontSize: size.width * numD034,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: "AirbnbCereal_W_Bk")),
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
  }*/
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
                        myDraftApi();
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

  ///--------Apis Section------------

  void myDraftApi() {
    Map<String, String> params = {
      "limit": limit.toString(),
      "offset": offset.toString(),
      "is_draft": true.toString()
    };

    int pos = sortList.indexWhere((element) => element.isSelected);

    if (pos != -1) {
      if (sortList[pos].name == filterDateText) {
        params["startdate"] = sortList[pos].fromDate!;
        params["endDate"] = sortList[pos].toDate!;
      } else if (sortList[pos].name == viewMonthlyText) {
        params["posted_date"] = "31";
      } else if (sortList[pos].name == viewYearlyText) {
        params["posted_date"] = "365";
      }
    }

    for (var element in filterList) {
      if (element.isSelected) {
        switch (element.name) {
          case allSharedContentText:
            params["sharedtype"] = "shared";
            break;

          case allExclusiveContentText:
            params["type"] = "exclusive";
            break;
        }
      }
    }

    NetworkClass(myDraftUrl, this, myDraftUrlRequest)
        .callRequestServiceHeader(true, "get", params);
  }


  updateDraftListAPI(String contentId){
    Map<String,String> map = {
      'content_id':contentId,
    };

    NetworkClass.fromNetworkClass(
        removeFromDraftContentAPI, this, reqRemoveFromDraftContentAPI, map)
        .callRequestServiceHeader(true, "patch", null);
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
        case myDraftUrlRequest:
          var data = jsonDecode(response);
          debugPrint("mydraftResponse: $response");
          /* if (map["code"] == 200) {
            var list = map["contentList"] as List;
            myDraftList = list.map((e) => MyContentData.fromJson(e)).toList();
          }
          showData = true;
          setState(() {});*/

          if (data["code"] == 200) {
            var listModel = data["contentList"] as List;
            var list = listModel.map((e) => MyContentData.fromJson(e)).toList();

            if (list.isNotEmpty) {
              _refreshController.loadComplete();
            } else if (list.isEmpty) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadFailed();
            }

            if (offset == 0) {
              myDraftList.clear();
            }

            myDraftList.addAll(list);
          }
          showData = true;
          setState(() {});

          break;

        case reqRemoveFromDraftContentAPI:
          debugPrint("reqRemoveFromDraftContentAPI===> ${jsonDecode(response)}");
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PublishContentScreen(
                publishData: null,
                myContentData: myDraftList[selectedIndex],
                hideDraft: true,
              )));
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}

class MyDraftData {
  String textValue = "";
  String time = "";
  String location = "";
  String latitude = "";
  String longitude = "";
  String amount = "";
  bool exclusive = false;
  bool showVideo = false;
  List<ContentMediaData> contentMediaList = [];
  List<HashTagData> hashTagList = [];
  CategoryDataModel? categoryData;
  String completionPercent = "";
  int leftPercent = 0;

  MyDraftData.fromJson(json) {
    exclusive = json["type"] == "shared" ? false : true;
    time = changeDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", json["timestamp"],
        "HH:mm, dd MMM, yyyy");
    textValue = json["description"];
    location = json["location"];
    latitude = json["latitude"].toString();
    longitude = json["longitude"].toString();
    amount = json["ask_price"].toString();

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

class ContentMediaData {
  String id = "";
  String media = "";
  String mediaType = "";
  String thumbNail = "";
  String waterMark = "";

  ContentMediaData.fromJson(json) {
    id = json["_id"];
    media = json["media"];
    mediaType = json["media_type"] ?? "";
    thumbNail = (json["thumbnail"] ?? "").toString();
    waterMark = (json["watermark"] ?? "").toString();
    /*if (mediaType == "video") {
      getVideoThumbNail("$contentImageUrl$media").then((value) {
        debugPrint("TValue: $value");

        thumbNail = value;

      });
    }*/
  }

  Future<String> getVideoThumbNail(String path) async {
    debugPrint("MediaIsss: $path");
    final thumbnail = await vt.VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: vt.ImageFormat.PNG,
      maxHeight: 500,
      quality: 100,
    );
    return thumbnail ?? "";
  }
}
