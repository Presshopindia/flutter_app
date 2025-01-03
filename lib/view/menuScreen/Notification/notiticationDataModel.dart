import 'package:presshop/utils/Common.dart';

class NotificationData {
  String id = "";
  String title = "";
  String description = "";
  String time = "";
  String senderImage = "";
  String senderId = "";
  bool unread = false;

  NotificationData(
      {required this.title,
        required this.id,
        required this.description,
        required this.time,
        required this.senderImage,
        required this.senderId,
        required this.unread});

  factory NotificationData.fromJson(Map<String,dynamic>  json){
    return NotificationData(
        title: json['title'] ?? "",
        id: json['_id'] ?? "",
        description:json['body'] ?? "",
        time:json['createdAt'] ?? "",
        senderImage: json['sender_id']!= null ? json['sender_id']['admin_detail']!=null?json['sender_id']['admin_detail']['admin_profile'].toString() :"":"",
        senderId: json['sender_id']!= null?json['sender_id']['_id']:'',
        unread: json['is_read'] ?? false);
  }


}