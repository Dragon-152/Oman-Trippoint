import 'dart:ui';

import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/settingsProvider.dart';
import 'package:oman_trippoint/screens/getStartedScreen.dart';
import 'package:oman_trippoint/screens/signinScreen.dart';
import 'package:oman_trippoint/widgets/LinkWidget.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import "package:flutter/material.dart";
import "package:localization/localization.dart";
import 'package:provider/provider.dart';
import "package:easy_localization/easy_localization.dart";

class OverviewScreen extends StatefulWidget {
  static String router = "/overview";
  const OverviewScreen({Key? key}) : super(key: key);

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int indexOverView = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    List overViewDescription = [
      // 1
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppHelper.returnText(
                context, "Always enjoy your trip", "استمتع دائمًا برحلتك"),
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(
            height: 100,
          ),
          Text(
            AppHelper.returnText(
                context,
                "Easy book and find things to do around Oman",
                "حجز سهل والعثور على أشياء للقيام بها في جميع أنحاء عمان"),
            style: TextStyle(
              color: Colors.white,
              fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
            ),
          ),
        ],
      ),

      //2
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            AppHelper.returnText(
                context,
                "Easily add your activity to reach more people",
                "أضف نشاطك بسهولة للوصول إلى المزيد من الأشخاص"),
            style: TextStyle(
              color: Colors.white,
              fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            AppHelper.returnText(
                context,
                "Sign in and find things to do in Oman",
                "سجل الدخول واعثر على نشاطات لتقوم بها في عمان"),
            style: TextStyle(
              color: Colors.white,
              fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
            ),
          ),
        ],
      ),
    ];

    List imagesPath = [
      "assets/images/overview1.jpeg",
      "assets/images/overview2.jpeg",
      "assets/images/overview3.jpeg",
    ];

    print("build");

    return SafeScreen(
      padding: 0,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black38,
          image: DecorationImage(
            // opacity: 0.6,
            colorFilter:
                const ColorFilter.mode(Colors.black45, BlendMode.color),
            image: AssetImage(imagesPath[indexOverView]),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          settingsProvider.update(
                              "language", const Locale("en"));
                          context.setLocale(const Locale("en"));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: context.locale.toString() == "en"
                              ? const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(24),
                                    bottomRight: Radius.circular(0),
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(0),
                                  ),
                                )
                              : const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(24),
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                        ),
                        child: Text(AppHelper.returnText(
                            context, "English", "إنجليزي")),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          settingsProvider.update(
                              "language", const Locale("ar"));
                          context.setLocale(const Locale("ar"));
                        },
                        style: ElevatedButton.styleFrom(
                          primary: ColorsHelper.red,
                          shape: context.locale.toString() == "ar"
                              ? const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(24),
                                    bottomRight: Radius.circular(0),
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(0),
                                  ),
                                )
                              : const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(24),
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                        ),
                        child: Text(
                            AppHelper.returnText(context, "Arabic", "عربي")),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: AnimatedOpacity(
                        opacity: 1,
                        duration: const Duration(microseconds: 1000),
                        child: overViewDescription[indexOverView]),
                  )
                ],
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (indexOverView != 2) {
                      setState(() {
                        indexOverView += 1;
                      });
                    } else {
                      Navigator.of(context)
                          .pushReplacementNamed(GetStartedScreen.router);
                    }
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                    ),
                  ),
                  child: indexOverView == 2

                      /// !!!!!!!!!!!!!!!!!!!
                      ? Text(
                          AppHelper.returnText(context, "Get Started", "ابدء"),
                          style: TextStyle(fontSize: 18),
                        )
                      : Text(
                          AppHelper.returnText(context, "Next", "التالي"),
                          style: TextStyle(fontSize: 18),
                        ),
                ),
                LinkWidget(
                    color: Colors.white,
                    text: AppHelper.returnText(context, "sign up or login",
                        "الاشتراك أو تسجيل الدخول"),
                    onPressed: () {
                      Navigator.pushNamed(context, GetStartedScreen.router);
                    }),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
