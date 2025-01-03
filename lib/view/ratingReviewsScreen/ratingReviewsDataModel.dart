
import 'package:intl/intl.dart';

import '../../utils/Common.dart';

class RatingReviewData {
  String newsName = "";
  String newsMessage = "";
  String image = "";
  String dateTime = "";
  String ratingValue = '0.0';
  String id;
  String from;
  String to;
  String rating = "";
  String senderType;

  // DateTime createdAt;
  // DateTime updatedAt;

  RatingReviewData({
    required this.newsName,
    required this.newsMessage,
    required this.image,
    required this.dateTime,
    required this.ratingValue,
    required this.senderType,
    //  required this.createdAt,
    // required this.updatedAt,
    required this.id,
    required this.from,
    required this.to,
    required this.rating,
  });

  factory RatingReviewData.fromJson(Map<String, dynamic> json) {
    return RatingReviewData(
      newsName: json['mediahouse_details'] != null
          ? json['mediahouse_details']['company_name']
          : '',
      newsMessage: json['review'] ?? "",
      image: json['mediahouse_details'] != null
          ? json['mediahouse_details']['profile_image']
          : '',
      dateTime: DateFormat(" HH:mm a,  yyyy-MM-dd ").format(DateTime.parse(json['createdAt'])),
      ratingValue: json["rating"] != null? json['rating'].toString() : "0.0",
      id: json["_id"] ?? "",
      from: json["from"] ?? "",
      to: json["to"] ?? "",
      rating: json["rating"].toString() ?? '',
      senderType: json["sender_type"] ?? "",
      //  updatedAT: dateTimeFormatter(dateTime: json['updatedAt']),
    );
  }
}

class FilterRatingData {
  double ratingValue = 0;
  bool selected = false;

  FilterRatingData({required this.ratingValue, required this.selected});
}
