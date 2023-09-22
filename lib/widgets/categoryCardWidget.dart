import 'package:oman_trippoint/helpers/colorsHelper.dart';
import "package:flutter/material.dart";

class CategoryCardWidget extends StatelessWidget {
  String imagePath;
  String title;
  Function() onPressed;
  CategoryCardWidget(
      {Key? key,
      required this.imagePath,
      required this.title,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 160,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 3,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            overlayColor: ColorsHelper.cardOverlay2Color,
            splashColor: ColorsHelper.cardSplash2Color,
            onTap: onPressed,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.asset(
                  imagePath,
                  width: 160,
                  height: 80,
                  fit: BoxFit.fitWidth,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
