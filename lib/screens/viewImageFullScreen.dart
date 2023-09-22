import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ViewImageFullScreen extends StatelessWidget {
  static String router = "view_image_full";
  String image;
  ViewImageFullScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return SafeScreen(
        padding: 0,
        child: Column(children: [
          AppBarWidget(title: AppHelper.returnText(context, "View", "عرض")),
          Expanded(
              child: Image.network(
            image,
            fit: BoxFit.fitWidth,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
          ))
        ]));
  }
}
