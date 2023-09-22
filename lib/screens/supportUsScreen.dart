import 'package:oman_trippoint/helpers/adHelper.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SupportUsScreen extends StatefulWidget {
  static String router = "/support_us";

  const SupportUsScreen({super.key});

  @override
  State<SupportUsScreen> createState() => _SupportUsScreenState();
}

class _SupportUsScreenState extends State<SupportUsScreen> {
  RewardedAd? _rewardedAd;
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _rewardedAd?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeScreen(
        padding: 0,
        child: Column(children: [
          AppBarWidget(title: "Support Us"),
          Expanded(
              child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                const SizedBox(
                  height: 30,
                ),
                Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Text(AppHelper.returnText(
                            context,
                            "You can support us by sharing our apps in different social media platforms and then we will appreciate your effort.",
                            "يمكنك دعمنا من خلال مشاركة تطبيقاتنا في منصات وسائط اجتماعية مختلفة ومن ثم سنقدر جهودك.")),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton.icon(
                            onPressed: () async {
                              await _rewardedAd?.show(
                                onUserEarnedReward: (ad, reward) {},
                              );
                              EasyLoading.show();
                              String url = await AppHelper.buildDynamicLink(
                                  title: 'Trippoint Oman || عمان', Id: "app");
                              await FlutterShare.share(
                                title: 'Trippoint Oman || عمان',
                                // text: args.title,
                                linkUrl: url,
                              );

                              EasyLoading.dismiss();
                            },
                            icon: const Icon(Icons.emoji_events),
                            label: Text(AppHelper.returnText(
                                context, "Share our app", "شارك تطبيقنا"))),
                        const SizedBox(
                          height: 20,
                        ),
                        //^---------------------- adverticment -----------------------

                        //^----------------------------------------------------------
                      ],
                    ))
              ]))
        ]));
  }
}
