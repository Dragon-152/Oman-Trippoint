import 'package:oman_trippoint/helpers/appHelper.dart';
import "package:flutter/material.dart";

class BookingScreen extends StatelessWidget {
  static String router = "/booking";
  const BookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Text(
            AppHelper.returnText(context, "Booking", "حجز"),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(
            height: 100,
          ),
          const Center(
            child: Text("Coming soon"),
          )
        ],
      ),
    );
  }
}
