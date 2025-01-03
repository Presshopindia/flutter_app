import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';

import '../../utils/Common.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import 'ContentSubmittedScreen.dart';

class HashTagSearchScreen extends StatefulWidget {
  String country = "";
  String countryTagId = "";
  List<HashTagData> tagData = [];

  HashTagSearchScreen(
      {super.key,
      required this.country,
      required this.tagData,
      required this.countryTagId});

  @override
  State<StatefulWidget> createState() {
    return HashTagSearchScreenState();
  }
}

class HashTagSearchScreenState extends State<HashTagSearchScreen>
    implements NetworkResponse {
  TextEditingController hashTagController = TextEditingController();
  List<HashTagData> hashtagList = [];
  List<HashTagData> hashtagSearchList = [];
  bool addNew = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getHashTagsApi(widget.country, widget.countryTagId, true);
    });
    addHashTagListener();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        leadingWidth: 0,
        title: Container(
          margin: EdgeInsets.only(top: size.width * numD04),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  "${iconsPath}ic_arrow_left.png",
                  width: size.width * numD07,
                ),
              ),
              SizedBox(
                width: size.width * numD04,
              ),
              Expanded(
                child: TextField(
                  controller: hashTagController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: colorLightGrey,
                      hintText: "#Add more hashtags",
                      hintStyle: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: colorHint,
                          fontWeight: FontWeight.normal),
                      disabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD08),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          )),
                      focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD08),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          )),
                      enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD08),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          )),
                      errorBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD08),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          )),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD08),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          )),
                      contentPadding:
                          EdgeInsets.only(left: size.width * numD06)),
                ),
              ),
              SizedBox(
                width: addNew ? size.width * numD04 : 0,
              ),
              addNew
                  ? commonElevatedButton(
                      "Add New",
                      size,
                      commonTextStyle(
                          size: size,
                          fontSize: size.width * numD025,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                      commonButtonStyle(size, colorThemePink), () {
                      addHashTagsApi();
                    })
                  : Container()
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * numD06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * numD08,
              ),
              Wrap(
                spacing: size.width * numD02,
                children: List.generate(hashtagList.length, (index) {
                  return Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          hashtagList[index].selected =
                              !hashtagList[index].selected;
                          setState(() {});
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: size.width * numD03),
                          child: Chip(
                            label: Text(
                              "#${hashtagList[index].name}",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD03,
                                  color: hashtagList[index].selected
                                      ? Colors.white
                                      : colorHint,
                                  fontWeight: FontWeight.normal),
                            ),
                            backgroundColor: hashtagList[index].selected
                                ? Colors.black
                                : colorLightGrey,
                          ),
                        ),
                      ),
                      hashtagList[index].selected
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () {
                                  int pos = hashtagSearchList.indexWhere(
                                      (element) =>
                                          element.id == hashtagList[index].id);

                                  if (pos >= 0) {
                                    hashtagList.removeAt(index);
                                    hashtagSearchList[pos].selected = false;
                                  }
                                  hashtagSearchList[pos].selected = true;
                                  setState(() {});
                                },
                                child: Container(
                                  padding: EdgeInsets.all(size.width * numD01),
                                  child: Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.black,
                                    size: size.width * numD04,
                                  ),
                                ),
                              ))
                          : Container(
                              width: 0,
                            )
                    ],
                  );
                }),
              ),
              SizedBox(
                height: size.width * numD08,
              ),
              Flexible(
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            int pos = hashtagList.indexWhere((element) =>
                                element.id == hashtagSearchList[index].id);

                            if (pos < 0) {
                              hashtagSearchList[index].selected = true;
                              hashtagList.add(hashtagSearchList[index]);
                            }
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: colorLightGrey,
                                borderRadius:
                                    BorderRadius.circular(size.width * numD02)),
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * numD02,
                                horizontal: size.width * numD02),
                            child: Row(
                              children: [
                                Text(
                                  "#${hashtagSearchList[index].name}",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700),
                                ),
                                const Spacer(),
                                hashtagSearchList[index].selected
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.black,
                                        size: size.width * numD06,
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: size.width * numD02,
                        );
                      },
                      itemCount: hashtagSearchList.length)),
              SizedBox(
                height: size.width * numD11,
                width: size.width,
                child: commonElevatedButton(
                    submitText,
                    size,
                    commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                    commonButtonStyle(size, colorThemePink), () {
                  List<HashTagData> list = [];

                  for (var element in hashtagList) {
                    if (element.selected) {
                      list.add(element);
                    }
                  }

                  Navigator.pop(context, list);
                }),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addHashTagListener() {
    hashTagController.addListener(() {
      if (hashTagController.text.trim().isNotEmpty) {
        searchHashTagsApi(hashTagController.text.trim());
      } else {
        addNew = false;
        setState(() {});
      }
    });
  }

  ///--------Apis Section------------

  void getHashTagsApi(String searchParam, String tagId, bool showLoader) {
    Map<String, String> params = {};
    if (searchParam.trim().isNotEmpty) {
      params["tagName"] = searchParam;
      params["type"] = "hopper";
      params["tag_id"] = tagId;
      debugPrint("GetHashTagsQueryParams: $params");
    }

    NetworkClass(getHashTagsUrl, this, getHashTagsUrlRequest)
        .callRequestServiceHeader(
            showLoader, "get", searchParam.trim().isNotEmpty ? params : null);
  }

  void searchHashTagsApi(String searchParam) {
    Map<String, String> params = {};
    if (searchParam.trim().isNotEmpty) {
      params["tagName"] = searchParam;
      params["type"] = "hopper";
      //params["tag_id"] = ;
      debugPrint("GetHashTagsQueryParams: $params");
    }

    NetworkClass(getHashTagsUrl, this, searchHashTagsUrlRequest)
        .callRequestServiceHeader(
            false, "get", searchParam.trim().isNotEmpty ? params : null);
  }

  void addHashTagsApi() {
    Map<String, String> params = {"name": hashTagController.text.trim()};
    debugPrint("AddHashTagsParams: $params");

    NetworkClass.fromNetworkClass(
            addHashTagsUrl, this, addHashTagsUrlRequest, params)
        .callRequestServiceHeader(true, "post", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case getHashTagsUrlRequest:
          debugPrint("getHashTagsUrlRequestError: $response");
          break;
        case searchHashTagsUrlRequest:
          debugPrint("searchHashTagsUrlRequestError: $response");
          break;
        case addHashTagsUrlRequest:
          debugPrint("AddHashTagError: $response");
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
        case getHashTagsUrlRequest:
          var map = jsonDecode(response);
          debugPrint("GetHashTags: $response");
          if (map["code"] == 200) {
            var list = map["tags"] as List;
            hashtagList = list.map((e) => HashTagData.fromJson(e)).toList();
          }
          var tageName = hashtagList.first.name;
          for (var element in widget.tagData) {
            if (element.name == tageName) {
            } else {
              hashtagList.add(HashTagData(
                  id: element.id, name: element.name, selected: false));
            }
          }
          setState(() {});

          break;

        case searchHashTagsUrlRequest:
          var map = jsonDecode(response);
          debugPrint("SearchHashTags: $response");
          if (map["code"] == 200) {
            var list = map["tags"] as List;
            hashtagSearchList =
                list.map((e) => HashTagData.fromJson(e)).toList();
          }

          if (hashtagSearchList.isEmpty &&
              hashTagController.text.trim().isNotEmpty) {
            addNew = true;
          } else {
            addNew = false;
          }
          if (mounted) {
            setState(() {});
          }

          break;
        case addHashTagsUrlRequest:
          debugPrint("AddHashTagResponse: $response");
          var map = jsonDecode(response);
          if (map["code"] == 200) {
            hashTagController.clear();
            hashtagList.add(HashTagData(
                id: map['tag']["_id"] ?? '',
                name: map['tag']['name'],
                selected: true));
          }
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}

class HashTagData {
  String id = "";
  String name = "";
  bool selected = false;

  HashTagData({
    required this.id,
    required this.name,
    required this.selected,
  });

  factory HashTagData.fromJson(Map<String, dynamic> json) {
    return HashTagData(
        id: json["_id"] ?? '',
        name: json["name"] ?? '',
        selected: false);
  }
}