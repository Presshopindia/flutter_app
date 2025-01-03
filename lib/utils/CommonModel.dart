import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';

class TaskVideoModel {
  String id = "";
  String type = "";
  String thumbnail = "";
  String imageVideoUrl = "";
  bool paidStatus = false;
  String amount = "";
  bool paidStatusToHopper = false;
  String paidAmount = "";
  String payableAmount ="";
  String commitionAmount = "";

  TaskVideoModel({
    this.id = "",
    this.type = "",
    this.thumbnail = "",
    this.imageVideoUrl = "",
    this.paidStatus = false,
    this.amount = "",
    this. paidStatusToHopper = false,
    this. paidAmount = "",
    this. payableAmount ="",
    this. commitionAmount = "",
  });

  TaskVideoModel.fromJson(Map<String, dynamic> json) {
    id = (json["_id"] ?? "").toString();
    type = (json["type"] ?? "").toString();
    thumbnail = json["videothubnail"] ?? "";
    imageVideoUrl = json["imageAndVideo"] ?? "";
    paidStatus = json["paid_status"] ?? false;
    amount = json["amount_paid"].toString() ?? "";
    paidStatusToHopper = json["paid_status_to_hopper"] ?? false;
    paidAmount =json["amount_paid_to_hopper"].toString() ?? "";
    payableAmount =json["amount_payable_to_hopper"] ?? "";
    commitionAmount = json["commition_to_payable"].toString() ?? "";
  }
}

class TaskDetailModel {
  String id = "";
  bool isNeedPhoto = false;
  bool isNeedVideo = false;
  bool isNeedInterview = false;
  String mode = "";
  String type = "";
  String status = "";
  String paidStatus = "";
  DateTime deadLine = DateTime.now();
  String mediaHouseId = "";
  String mediaHouseImage = "";
  String mediaHouseName = "";
  String title = "";
  String description = "";
  String specialReq = "";
  String location = "";
  dynamic photoPrice = 0;
  dynamic videoPrice = 0;
  dynamic interviewPrice = 0;
  dynamic receivedAmount = 0;
  double latitude = 0.0;
  double longitude = 0.0;
  String role = "";
  String categoryId = "";
  String userId = "";
  List<TaskVideoModel> mediaList = [];



  TaskDetailModel.fromJson(Map<String, dynamic> json) {
    id = (json["_id"] ?? "").toString();
    isNeedPhoto =
        (json["need_photos"] ?? "").toString().toLowerCase() == "true";
    isNeedVideo =
        (json["need_videos"] ?? "").toString().toLowerCase() == "true";
    isNeedInterview =
        (json["need_interview"] ?? "").toString().toLowerCase() == "true";
    mode = (json["mode"] ?? "").toString();
    type = (json["type"] ?? "").toString();
    status = (json["status"] ?? "").toString();
    paidStatus = (json["paid_status"] ?? "").toString();
    deadLine = DateTime.parse(dateTimeFormatter(
        dateTime: (json["deadline_date"] ?? "2022-12-01 06:00:00").toString(),
        format: "yyyy-MM-dd HH:mm:ss",
        time: true));

    Map<String, dynamic> mediaHouseDetailMap = json["mediahouse_id"] ?? {};

    mediaHouseId = (mediaHouseDetailMap["_id"] ?? "").toString();
    mediaHouseName = (mediaHouseDetailMap["full_name"] ?? "").toString();
    mediaHouseImage = (mediaHouseDetailMap["profile_image"] ?? "").toString();

    title = (json["heading"] ?? "").toString();
    description = (json["task_description"] ?? "").toString();
    specialReq = (json["any_spcl_req"] ?? "").toString();
    location = (json["location"] ?? "").toString();
    photoPrice = numberFormatting((json["photo_price"] ?? "").toString());
    videoPrice = numberFormatting((json["videos_price"] ?? "").toString());
    interviewPrice =
        numberFormatting((json["interview_price"] ?? "").toString());
    receivedAmount =
        numberFormatting((json["received_amount"] ?? "").toString());
    role = (json["role"] ?? "").toString();
    categoryId = (json["category_id"] ?? "").toString();
    userId = (json["user_id"] ?? "").toString();

    if (json["uploaded_content"] != null) {
      var uploadedMedia = json["uploaded_content"] as List;
      mediaList = uploadedMedia.map((e) => TaskVideoModel.fromJson(e)).toList();
      debugPrint("mediaList Length : ${mediaList.length}");
    }

    if (json["address_location"] != null) {
      if (json["address_location"]["coordinates"] != null) {
        var coordinator = json["address_location"]["coordinates"] as List;

        if (coordinator.isNotEmpty) {
          latitude =
              double.parse(numberFormatting(coordinator.first).toString());
          longitude =
              double.parse(numberFormatting(coordinator.last).toString());
        }
      }
    }
  }
}

class AdminDetailModel {
  String id = "";
  String name = "";
  String profilePic = "";
  String lastMessageTime = "";
  String lastMessage = "";
  String roomId = "";
  String senderId = "";
  String receiverId = "";
  String roomType = "";

  AdminDetailModel({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.roomId,
    required this.senderId,
    required this.receiverId,
    required this.roomType,
  });

  AdminDetailModel.fromJson(Map<String, dynamic> json) {
    id = (json["_id"] ?? "").toString();
    name = (json["name"] ?? "").toString();
    profilePic = (json["profile_image"] ?? "").toString();
    lastMessageTime = '';
    lastMessage = '';
    roomId =
        json["room_details"] != null ? json["room_details"]['room_id'] : '';
    senderId =
        json["room_details"] != null ? json["room_details"]['sender_id'] : '';
    receiverId =
        json["room_details"] != null ? json["room_details"]['receiver_id'] : '';
    roomType =
        json["room_details"] != null ? json["room_details"]['room_type'] : '';
  }

/* AdminDetailModel.copyWith({
    String? id,
    String? name,
    String? profilePic,
    String? lastMessageTime,
    String? lastMessage,
    String? roomId,
    String? senderId,
    String? receiverId,
  }) {
    AdminDetailModel(
        id: id ?? this.id,
        name: name ?? this.name,
        profilePic: profilePic ?? this.profilePic,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        lastMessage: lastMessage ?? this.lastMessage,
        roomId:roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.senderId


    );
  }*/
}

class ManageTaskChatModel {
  String id = "";
  bool paidStatus = false;
  TaskVideoModel? media;
  String messageType = "";
  String initialOfferAmount = "";
  String senderType = "";
  String finalCounterAmount = "";
  String amount = "";
  String requestStatus = "";
  bool isMakeCounterOffer = false;
  String mediaHouseImage = "";
  String mediaHouseName = "";
  String mediaHouseId = "";
  String createdAtTime = "";
  double rating = 0;
  String roomId = "";
  bool isRatingGiven = false;
  TextEditingController priceController = TextEditingController();
  TextEditingController ratingReviewController = TextEditingController();

  ManageTaskChatModel.fromJson(Map<String, dynamic> json) {
    id = (json["_id"] ?? "").toString();
    messageType = (json["message_type"] ?? "").toString();
    senderType = (json["sender_type"] ?? "").toString();
    amount = numberFormatting((json["amount"] ?? "")).toString();
    requestStatus = (json["request_status"] ?? "").toString();
    finalCounterAmount = (json["finaloffer_price"] ?? "").toString();
    initialOfferAmount = (json["initial_offer_price"] ?? "").toString();
    createdAtTime = (json["createdAt"] ?? "").toString();
    roomId = (json["room_id"] ?? "").toString();
    isMakeCounterOffer = (json["is_hide"] ?? "").toString() == "true";
    Map<String, dynamic> mediaMap = json["media"] ?? {};
    rating = double.parse(numberFormatting((json["rating"] ?? "")).toString());
    priceController = TextEditingController(
        text: (json["finaloffer_price"] ?? "").toString());
    ratingReviewController =
        TextEditingController(text: (json["review"] ?? "").toString());
    paidStatus = json['paid_status'] ?? false;
    isRatingGiven = json["review"] != null;

    media = TaskVideoModel(
      id: (mediaMap[""] ?? "").toString(),
      type: (mediaMap["mime"] ?? "").toString(),
      imageVideoUrl:
          (mediaMap["name"] != null ? taskMediaUrl + mediaMap["name"] : "")
              .toString(),
      thumbnail: (mediaMap["thumbnail_url"] != null
              ? taskMediaUrl + mediaMap['thumbnail_url']
              : "")
          .toString(),
    );

    if (senderType == "Mediahouse") {
      Map<String, dynamic> mediaHouseDetailMap = senderType == "Mediahouse"
          ? json["sender_id"] ?? {}
          : json["receiver_id"] ?? {};

      mediaHouseId = (mediaHouseDetailMap["_id"] ?? "").toString();
      mediaHouseName = (mediaHouseDetailMap["full_name"] ?? "").toString();
      mediaHouseImage = (mediaHouseDetailMap["profile_image"] ?? "").toString();
    }
  }
}

/// Publication List
class PublicationDataModel {
  String id = "";
  String publicationName = "";
  String companyName = "";
  String role = "";
  String status = "";

  PublicationDataModel.fromJson(Map<String, dynamic> json) {
    id = json["_id"] ?? "";
    companyName = json['company_name'] ?? '';
    publicationName = json["full_name"] ?? "";
    role = json["role"] ?? "";
    status = json["status"] ?? "";
  }
}
