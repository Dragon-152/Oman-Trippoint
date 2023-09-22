import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/screens/addActivityScreen.dart';
import 'package:oman_trippoint/screens/profileScreen.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:video_player/video_player.dart';

class OverViewAddActivityScreen extends StatefulWidget {
  static String router = "overview_add_activity";
  const OverViewAddActivityScreen({super.key});

  @override
  State<OverViewAddActivityScreen> createState() =>
      _OverViewAddActivityScreenState();
}

class _OverViewAddActivityScreenState extends State<OverViewAddActivityScreen> {
  Map<int, VideoPlayerController> _controllers = {};
  Map<int, Future<void>> _initializeVideoPlayersFuture = {};
  int indexOverView = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controllers[1] = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    );

    _initializeVideoPlayersFuture[1] = _controllers[1]!.initialize();
    if (_controllers[1] != null) {
      _controllers[1]!.setLooping(true);

      _controllers[1]!.play();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    for (var c in _controllers.values) {
      c.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    List overViewDescription = [
      // 1
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 100,
          ),
          Text(
            AppHelper.returnText(context, "Add Activity", "إضافة نشاط"),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 20,
          ),
          FutureBuilder(
            future: _initializeVideoPlayersFuture[1],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  _controllers[1] != null) {
                return AspectRatio(
                  aspectRatio: _controllers[1]!.value.aspectRatio,
                  child: VideoPlayer(_controllers[1]!),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            AppHelper.returnText(
                context,
                "Enjoy adding promotional activities and interaction benefits to the platform.",
                "استمتع بإضافة الأنشطة الترويجية ومزايا التفاعل إلى المنصة."),
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      ),

      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 100,
          ),
          Text(
            AppHelper.returnText(context, "Reaching Many Users",
                "الوصول إلى العديد من المستخدمين"),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            AppHelper.returnText(
                context,
                "Add your social media accounts to reach a big number of customers.",
                "أضف حسابات وسائل التواصل الاجتماعي الخاصة بك للوصول إلى عدد كبير من العملاء."),
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 100,
          ),
          Text(
            AppHelper.returnText(
                context, "Follow Statistics", "متابعة الإحصائيات"),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            AppHelper.returnText(
                context,
                "Try to improve your reaching your activities pages.",
                "حاول تحسين وصولك إلى صفحات الأنشطة الخاصة بك."),
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      ),
    ];

    return SafeScreen(
      padding: 0,
      child: Column(
        children: [
          AppBarWidget(
              title:
                  AppHelper.returnText(context, "Add Activity", "إضافة نشاط")),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: overViewDescription[indexOverView]),
                Container(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      indexOverView > 0
                          ? ElevatedButton(
                              onPressed: () {
                                if (indexOverView > 0) {
                                  //!!!!!!!!!
                                  setState(() {
                                    indexOverView -= 1;
                                  });
                                }
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 60, vertical: 20),
                                ),
                              ),
                              child: Text(AppHelper.returnText(
                                  context, "Back", "رجوع")),
                            )
                          : const SizedBox(),
                      ElevatedButton(
                        onPressed: () async {
                          if (indexOverView < 2) {
                            //!!!!!!!!!

                            setState(() {
                              indexOverView += 1;
                            });
                          } else if (indexOverView == 2) {
                            Navigator.pushReplacementNamed(
                                context, AddActivityScreen.router);
                          }
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 20),
                          ),
                        ),
                        child: Text(
                            AppHelper.returnText(context, "Next", "التالي")),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
