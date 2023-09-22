import 'package:flutter/cupertino.dart';

class NotificationPieceSchema {
  int createdAt;
  String title;
  String text;
  String? notificationId;
  Map data;

  NotificationPieceSchema(
      {required this.createdAt,
      required this.title,
      required this.text,
      this.notificationId,
      required this.data});

  static NotificationPieceSchema toSchema(Map data) {
    return NotificationPieceSchema(
      createdAt: data["createdAt"],
      title: data["title"],
      text: data["text"],
      notificationId: data["notificationId"],
      data: data["data"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "createdAt": createdAt,
      "title": title,
      "text": text,
      "notificationId": notificationId,
      "data": data,
    };
  }
}
