import 'package:oman_trippoint/helpers/adHelper.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/notificationPieceSchema.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:oman_trippoint/widgets/AdContainerWidget.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  static String router = "/notification";
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

int once = 0;

class _NotificationScreenState extends State<NotificationScreen> {
  List notificationList = [];
  InterstitialAd? _interstitialAd;
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              //   _moveToHome();
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  Future getNofitication() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    if (userProvider.notificationMap["events"] != null) {
      if (userProvider.notificationMap["events"]!.isNotEmpty) {
        setState(() {
          notificationList = userProvider.notificationMap["events"]!;
        });
        return;
      }
    }
    await userProvider.fetchNotifications().then((value) {
      print(value);
      setState(() {
        notificationList = value;
      });
    });

    once = 1;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _interstitialAd?.dispose();
    Future.delayed(Duration.zero, () => getNofitication());

    _loadInterstitialAd();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _interstitialAd?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    final auth = FirebaseAuth.instance;

    if (_interstitialAd != null) {
      _interstitialAd?.show();
    }

    return SafeScreen(
      padding: 0,
      child: Column(
        children: [
          AppBarWidget(
              title:
                  AppHelper.returnText(context, "Notification", "الإشعارات")),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: notificationList.length,
                  itemBuilder: (context, index) {
                    // if (index == 0) {
                    //   return const SizedBox(
                    //     height: 30,
                    //   );
                    // }

                    return Container(
                      decoration: const BoxDecoration(
                          border: Border.symmetric(
                              horizontal: BorderSide(
                                  color: Color.fromARGB(255, 228, 228, 228),
                                  width: 1))),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notificationList[index].title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              notificationList[index].text,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              DateFormat('MM/dd/yyyy, hh:mm a').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    notificationList[index].createdAt),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: ColorsHelper.grey),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
