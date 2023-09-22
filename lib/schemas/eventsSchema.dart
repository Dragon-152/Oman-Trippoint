import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventsSchema {
  int? createdAt;
  String image;
  String title;
  String text;
  String url;
  String? date;
 

  EventsSchema({
     this.createdAt,
    required this.image,
    required this.title,
    required this.text,
    required this.url,
   this.date
  });

  static EventsSchema toSchema(Map data) {
    return EventsSchema(
        createdAt: data["createdAt"],
        image: data["image"],
        title: data["title"],
        text: data["text"],
        url: data["url"],
        date: data["date"],
      
      );
  }

  Map<String, dynamic> toMap() {
    return {
      "createdAt": createdAt,
      "image": image,
      "title": title,
      "text": text,
      "url": url,
      "date": date,
     
    };
  }
}
