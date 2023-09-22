import 'dart:io';

import 'package:oman_trippoint/helpers/adHelper.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/settingsProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/screens/activityDetailsScreen.dart';
import 'package:oman_trippoint/screens/bookingScreen.dart';
import 'package:oman_trippoint/screens/chatScreen.dart';
import 'package:oman_trippoint/screens/discoverScreen.dart';
import 'package:oman_trippoint/screens/getStartedScreen.dart';
import 'package:oman_trippoint/screens/notificationSceen.dart';
import 'package:oman_trippoint/screens/overViewScreen.dart';
import 'package:oman_trippoint/screens/ownerActivitiesScreen.dart';
import 'package:oman_trippoint/screens/profileScreen.dart';
import 'package:oman_trippoint/screens/wishlistScreen.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/activityCardWidget.dart';
import 'package:oman_trippoint/widgets/categoryCardWidget.dart';
import 'package:oman_trippoint/widgets/loadingWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import "package:flutter/material.dart";
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import "package:firebase_core/firebase_core.dart";
import 'package:badges/badges.dart' as badges;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:upgrader/upgrader.dart';

class HomeScreen extends StatefulWidget {
  static String router = "/";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  int _currentTab = 0;
  bool _isLoading = true;
  PageController _pageController = PageController(initialPage: 0);

  void autoSignin(context) async {
    // EasyLoading.show(status: "Loading")
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.credentialUser != null) {
      print("saveSignInUserData");
      await userProvider.saveSignInUserData(
          context, userProvider.credentialUser!,
          sginup: false);
    }
    if (userProvider.credentialUser == null ||
        (userProvider.credentialUser != null &&
            userProvider.currentUser != null)) {
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  Future signout(UserProvider userProvider) async {
    await userProvider.signout(context);

    Navigator.pushNamedAndRemoveUntil(
        context, OverviewScreen.router, (route) => false);
  }

  Future getNofitication() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    await userProvider.fetchNotifications();
  }

  void initDynamicLink() async {
    FirebaseDynamicLinks.instance.onLink.listen((event) {
      if (event.link.path.isNotEmpty) {
        // * link navigator
        linkNavigator(event.link.path);
      }
    }).onError((err) {
      print(err);
    });
  }

  Future linkNavigator(String path) async {
    EasyLoading.show();
    try {
      print(path);
      final activityProvider =
          Provider.of<ActivityProvider>(context, listen: false);

      if (path.startsWith("/post")) {
        ActivitySchema activitySchema =
            await activityProvider.fetchActivityWStore(path.split("/post")[1]);
        Navigator.pushNamed(context, ActivityDetailsScreen.router,
            arguments: activitySchema);
      }
    } catch (err) {
      print(err);
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    EasyLoading.dismiss();
  }

  void first(context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool("first") == null ||
        sharedPreferences.getBool("first") != false) {
      await sharedPreferences.setBool("first", false);
      Navigator.pushNamedAndRemoveUntil(
          context, OverviewScreen.router, (route) => false);
    }
  }

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _interstitialAd?.dispose();

    _loadInterstitialAd();

    Future.delayed(const Duration(seconds: 5), () {
      //   int index = ModalRoute.of(context)!.settings.arguments as int;
      //   setState(() {
      //     _currentTab = index;
      //   });

      getNofitication();
    });

    initDynamicLink();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   print("SchedulerBinding");
    //   Future.delayed(Duration(seconds: 1), () => pageController.animateToPage(
    //     _currentTab,
    //     duration: const Duration(milliseconds: 500),
    //     curve: Curves.ease,
    //   ));
    // //   pageController.animateToPage(
    // //     _currentTab,
    // //     duration: const Duration(milliseconds: 500),
    // //     curve: Curves.ease,
    // //   );
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _interstitialAd?.dispose();

    super.dispose();
    // _interstitialAd?.dispose();
  }

  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    userProvider.credentialUser = auth.currentUser;

    //
    return Builder(builder: (context) {
      first(context);
      if (userProvider.currentUser != null) {
        userProvider.updateUserSoreddata(context);
      }
      if ((userProvider.currentUser == null &&
          userProvider.credentialUser != null)) {
        autoSignin(context);
      } else {
        _isLoading = false;
      }

      if (_isLoading) {
        return const LoadingWidget();
      }

      return UpgradeAlert(
        // upgrader: Upgrader(
        //     dialogStyle: Platform.isAndroid
        //         ? UpgradeDialogStyle.material
        //         : UpgradeDialogStyle.cupertino,
        //     minAppVersion: "1.0.0"),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            leading: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, NotificationScreen.router);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: badges.Badge(
                badgeContent: const Text(''),
                badgeColor: ColorsHelper.orange,
                elevation: 1,
                child: const Icon(
                  FontAwesomeIcons.bell,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
            title: Text(
              "Oman Trippoint",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, ProfileScreen.router);
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
                child: badges.Badge(
                  badgeContent: userProvider.islogin() &&
                          auth.currentUser?.emailVerified == true
                      ? null
                      : const Icon(
                          Icons.error_outline_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        
                  badgeColor: ColorsHelper.orange,
                  elevation: 1,
                  child: const Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ),
            ],
            centerTitle: true,
            elevation: 0,
          ),
          body: Container(
            color: Colors.white,
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) {
                FocusScope.of(context).unfocus();
                setState(() {
                  _currentTab = i;
                });
              },
              children: [
                const DiscoverScreen(),
                const ChatScreen(),
                const BookingScreen(),
                if (userProvider.currentUser != null)
                  if (userProvider.currentUser!.isProAccount == true)
                    const OwnerActivitesScreen(),
                const WishlistScreen(),
              ],
            ),
          ),

          // ? Floating Button
          //   floatingActionButton: FloatingActionButton(
          //     backgroundColor: Colors.grey[100],
          //     onPressed: () async {
          //       if (_interstitialAd != null) {
          //         _interstitialAd?.show();
          //       }

          //       EasyLoading.show();
          //       String url = await AppHelper.buildDynamicLink(
          //           title: 'Oman Trippoint || عمان', Id: "app");
          //       await FlutterShare.share(
          //         title: 'Oman Trippoint  || عمان',
          //         // text: args.title,
          //         linkUrl: url,
          //       );

          //       EasyLoading.dismiss();
          //     },
          //     child: const SizedBox(
          //       width: 60,
          //       height: 60,
          //       child: Icon(
          //         Icons.share_rounded,
          //         size: 30,
          //       ),
          //     ),
          //   ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: const Icon(Icons.search),
                  label: AppHelper.returnText(context, "Discover", "إكتشف")),
              BottomNavigationBarItem(
                icon: const Icon(Icons.chat_rounded),
                label: AppHelper.returnText(context, "chat", "محادثة"),
              ),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.shopping_cart),
                  label: AppHelper.returnText(context, "Booking", "الحجوزات")),
              if (userProvider.currentUser != null)
                if (userProvider.currentUser!.isProAccount == true)
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.assessment_rounded),
                      label: AppHelper.returnText(context, "Ads", "إعلاناتي")),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bookmark_added_rounded),
                label: AppHelper.returnText(context, "Wishlist", "المفضلات"),
              ),
            ],
            currentIndex: _currentTab,
            onTap: (int i) {
              setState(() {
                _currentTab = i;
              });

              _pageController.jumpToPage(i);
              // pageController.animateToPage(
              //   i,
              //   duration: const Duration(milliseconds: 500),
              //   curve: Curves.ease,
              // );
            },
            showUnselectedLabels: true,
            selectedFontSize: 15,
            unselectedFontSize: 14,
            backgroundColor: Colors.white,
            unselectedItemColor: Colors.black45,
            selectedItemColor: Colors.black,

            //             showUnselectedLabels: true,
            //   selectedFontSize: 14,
            //   unselectedFontSize: 14,
            //   backgroundColor: Colors.white,
            //   unselectedItemColor: Colors.black54,
            //   selectedItemColor: Color(0xFFE4605E),
          ),
        ),
      );
    });
  }
}
