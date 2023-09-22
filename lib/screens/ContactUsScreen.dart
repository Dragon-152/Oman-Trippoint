import 'package:oman_trippoint/helpers/adHelper.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/widgets/AdContainerWidget.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  static String router = "contact_us";
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _rewardedAd?.dispose();

    _interstitialAd?.dispose();

    _loadInterstitialAd();
    _bannerAd?.dispose();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bannerAd?.dispose();
    _rewardedAd?.dispose();

    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_interstitialAd != null) {
      _interstitialAd?.show();
    }
    return SafeScreen(
        padding: 0,
        child: Column(children: [
          AppBarWidget(
              title: AppHelper.returnText(context, "Contact Us", "اتصل بنا")),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppHelper.returnText(context, "Follow Us", "تابعنا"),
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                         IconButton(
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.pink),
                            onPressed: () async {
                              final Uri _url =
                                  Uri.parse('https://instagram.com/omantrippoint');
                              if (await canLaunchUrl(_url)) {
                                await launchUrl(_url,
                                    mode: LaunchMode
                                        .externalNonBrowserApplication);
                              } else {
                                throw 'Could not launch $_url';
                              }
                            },
                            icon: const Icon(FontAwesomeIcons.instagram)),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                       
                    //     IconButton(
                    //         style: IconButton.styleFrom(
                    //             backgroundColor: Colors.blue),
                    //         onPressed: () {},
                    //         icon: const Icon(Icons.web_stories_outlined)),
                    //     IconButton(
                    //         style: IconButton.styleFrom(
                    //             backgroundColor: Colors.blue),
                    //         onPressed: () {},
                    //         icon: const Icon(FontAwesomeIcons.twitter)),
                    //   ],
                    // ),

                    const Divider(
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ListTile(
                      onTap: () {},
                      title: Text(AppHelper.returnText(
                          context, "Customers service", "خدمة العملاء")),
                      trailing: const Icon(FontAwesomeIcons.whatsapp),
                    ),
                    ListTile(
                      onTap: () {},
                      title: Text(AppHelper.returnText(
                          context, "Technical support", "دعم فني")),
                      trailing: const Icon(FontAwesomeIcons.whatsapp),
                    ),
                    ListTile(
                      onTap: () {},
                      title: Text(AppHelper.returnText(context,
                          "Complaints and suggestions", "الشكاوى والاقتراحات")),
                      trailing: const Icon(FontAwesomeIcons.whatsapp),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    //^---------------------- adverticment -----------------------

                    // if (_bannerAd != null)
                    //   Container(
                    //     margin: EdgeInsets.symmetric(vertical: 20),
                    //     width: _bannerAd!.size.width.toDouble(),
                    //     height: _bannerAd!.size.height.toDouble(),
                    //     child: AdWidget(ad: _bannerAd!),
                    //   ),
                    const Adcontainer(),

                    //^----------------------------------------------------------
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    ElevatedButton(
                      onPressed: () async {
                        await _rewardedAd?.show(
                          onUserEarnedReward: (ad, reward) {},
                        );
                        final Uri _url = Uri.parse("https://wa.me/+96878411108");
                        // ' https://wa.me/${activitySchema.phoneNumberWhatsapp}?text=Hello');
                        launchUrl(_url,
                            mode: LaunchMode.externalNonBrowserApplication);
                      },
                      style: ElevatedButton.styleFrom(
                        // primary: ColorsHelper.yellow,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      child: SizedBox(
                        //   width: 200,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                // Icons.whatsapp_rounded,
                                                    FontAwesomeIcons.whatsapp,

                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                AppHelper.returnText(
                                    context, " Whatsapp ", "  واتساب "),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ]),
                      ),
                    ),
                  ]),
            ),
          )
        ]));
  }
}
