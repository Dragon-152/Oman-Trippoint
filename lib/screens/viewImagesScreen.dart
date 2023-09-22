import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ViewImagesScreen extends StatelessWidget {
  static String router = "view_list_images";
  List images;
  ViewImagesScreen({super.key, required this.images});
  @override
  Widget build(BuildContext context) {
    PageController pageViewController = PageController();

    return SafeScreen(
        padding: 0,
        child: Column(children: [
          AppBarWidget(title: AppHelper.returnText(context, "View", "عرض")),
          Expanded(
            child: Stack(
              children: [PageView(
                  controller: pageViewController,
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...images
                        .map((e) => Image.network(
                              e,
                              fit: BoxFit.fitWidth,
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                            ))
                        .toList(),
                  ]),
                  
                  Align(
                      alignment: const AlignmentDirectional(0, .9),
                      child: SmoothPageIndicator(
                        controller: pageViewController,
                        count: images.length,
                        axisDirection: Axis.horizontal,
                        onDotClicked: (i) {
                          pageViewController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        effect: ExpandingDotsEffect(
                          expansionFactor: 1.5,
                          spacing: 6,
                          radius: 16,
                          dotWidth: 12,
                          dotHeight: 12,
                          dotColor: ColorsHelper.whiteBlue,
                          activeDotColor: ColorsHelper.green,
                          paintStyle: PaintingStyle.fill,
                        ),
                      ),
                    ),
                  
                  ]
            ),
          )
        ]));
  }
}
