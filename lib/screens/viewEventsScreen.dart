import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/schemas/eventsSchema.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:oman_trippoint/widgets/eventsCardWidget.dart';

class ViewEventsScreen extends StatefulWidget {
  static String router = "view_events";

  ViewEventsScreen({super.key});

  @override
  State<ViewEventsScreen> createState() => _ViewEventsScreenState();
}

class _ViewEventsScreenState extends State<ViewEventsScreen> {
  List<EventsSchema> events = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration.zero, () async {
      EasyLoading.show();
      QuerySnapshot<Map<String, dynamic>> query1 =
          await FirebaseFirestore.instance.collection("news").get();
      for (var doc in query1.docs) {
        events.add(EventsSchema(
            createdAt: doc.data()["createdAt"],
            image: doc.data()["image"],
            title: doc.data()["title"],
            text: doc.data()["text"],
            url: doc.data()["url"]));
      }

setState(() {
  
});
      EasyLoading.dismiss();

    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeScreen(
        padding: 0,
        child: Column(children: [
          AppBarWidget(
              title: AppHelper.returnText(context, "Event", "الاحداث")),
          Expanded(
            child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (contetxt, index) {
                  return EventsCardWidget(
                    eventsSchema: events[index],
                    onPressed: () {},
                  );
                }),
          )
        ]));
  }
}
