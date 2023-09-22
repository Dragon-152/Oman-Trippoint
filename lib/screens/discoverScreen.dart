import 'dart:math';

import 'package:loading_indicator/loading_indicator.dart';
import 'package:oman_trippoint/helpers/adHelper.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/schemas/appStatisticsSchema.dart';
import 'package:oman_trippoint/screens/activityDetailsScreen.dart';
import 'package:oman_trippoint/screens/addActivityScreen.dart';
import 'package:oman_trippoint/screens/overViewScreen.dart';
import 'package:oman_trippoint/screens/searchScreen.dart';
import 'package:oman_trippoint/screens/viewEventsScreen.dart';
import 'package:oman_trippoint/widgets/AdContainerWidget.dart';
import 'package:oman_trippoint/widgets/DiologsWidgets.dart';
import 'package:oman_trippoint/widgets/activityCardWidget.dart';
import 'package:oman_trippoint/widgets/categoryCardWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import "package:flutter/material.dart";
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_connect/sockets/src/sockets_io.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:oman_trippoint/widgets/loadingWidget.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class DiscoverScreen extends StatefulWidget {
  static String router = "/discover";
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final functions = FirebaseFunctions.instance;
  PageController pageViewController = PageController(initialPage: 0);
  TextEditingController textController = TextEditingController();

  // List<Widget> activitesCards = [
  //   const SizedBox(),
  // ];
  List newsList = [];
  BannerAd? _bannerAd;
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

  Future<List<Widget>> loadActivites() async {
    List<Widget> activitesCards = [];
    ActivityProvider activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);

    HttpsCallableResult response = await FirebaseFunctions.instance
        .httpsCallable("Top10Activities")
        .call();

    for (var aData in response.data) {
      print("HHHHHHHHHHHHHHHHHHHHh i");
      print(aData);
      ActivitySchema activitySchema = ActivitySchema.toSchema(aData);

      activityProvider.activities[activitySchema.Id] = activitySchema;
      activityProvider.topActivitiesList[activitySchema.Id] = activitySchema;

      activitesCards.add(ActivityCardWidget(
          activity: activitySchema,
          onPressed: () {
            Navigator.pushNamed(
              context,
              ActivityDetailsScreen.router,
              arguments: activitySchema,
            );
          }));
    }

    // setState(() {
    //   activitesCards =activitesCards;
    // });

    return activitesCards;

    // await activityProvider.topActivitesFillter().then((snapshot) {
    //   List<ActivitySchema> data = snapshot as List<ActivitySchema>;

    //   setState(() {
    //   activitesCards.addAll(data.map((d) {
    //     return ActivityCardWidget(
    //         activity: d,
    //         onPressed: () {
    //           Navigator.pushNamed(
    //             context,
    //             ActivityDetailsScreen.router,
    //             arguments: d,
    //           );
    //         });
    //   }).toList());
    // });
    // });
  }

  @override
  void initState() {
    // TODO: implement initState<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>

    super.initState();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    // _loadInterstitialAd();

    // Future.delayed(Duration.zero, () async {
    //   loadActivites();
    // });

    Future.delayed(Duration.zero, () async {
      QuerySnapshot<Map<String, dynamic>> query1 =
          await FirebaseFirestore.instance.collection("news").get();
      for (var doc in query1.docs) {
        newsList.add({
          "image": doc["image"],
          "url": doc["url"],
        });
      }

      setState(() {
        newsList = newsList;
      });

      int pagesCount = newsList.length + 1;

      for (int currentPage = 1; currentPage < pagesCount; currentPage++) {
        await Future.delayed(Duration(milliseconds: 2000), () {
          // currentPage += 1;

          pageViewController.animateToPage(
            currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );

          // if (pagesCount == currentPage) {
          //   currentPage = 1;
          // }
        });
      }
    });

   
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bannerAd?.dispose();
    _interstitialAd?.dispose();

    super.dispose();
  }

  Map data = {
    "usersCount": 0,
    "activitiesCount": 0,
  };
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);


    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [


        Container(
          width: MediaQuery.of(context).size.width,
          height: 250,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  //   boxShadow: const [
                  //     BoxShadow(
                  //       blurRadius: 4,
                  //       color: Color(0x33000000),
                  //       offset: Offset(0, 2),
                  //     )
                  //   ],
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Stack(
                  children: [
                    PageView(
                      controller: pageViewController,
                      scrollDirection: Axis.horizontal,
                      children: [
                        Image.asset(
                          'assets/images/categories/discover_all.jpg',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        ...newsList
                            .map((e) => InkWell(
                                  onTap: () {
                                    final Uri _url = Uri.parse(e["url"]);
                                    launchUrl(_url,
                                        mode: LaunchMode
                                            .externalNonBrowserApplication);
                                  },
                                  child: Image.network(
                                    e["image"],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ))
                            .toList(),
  
                      ],
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0, 1),
                      child: Container(
                        height: 120,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
    
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton.icon(
                                      style: Theme.of(context)
                                          .elevatedButtonTheme
                                          .style
                                          ?.copyWith(),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, SearchScreen.router);
                                      },
                                      icon: const Icon(
                                          Icons.local_activity_rounded),
                                      label: Text(AppHelper.returnText(
                                          context, "Activities", "الأنشطة"))),
                                  ElevatedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.home_filled),
                                      label: Text(AppHelper.returnText(
                                          context, "Chalets", "الإستراحات"))),
                                ],
                              )
                            ]),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(.8, -.9),
                      child: SmoothPageIndicator(
                        controller: pageViewController,
                        count: newsList.length + 1,
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
                  ],
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, 1),
                child: Container(
                  width: 300,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 6,
                        color: Color(0x33000000),
                        offset: Offset(1, 1),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.white,
                    child: InkWell(
                      overlayColor: MaterialStateProperty.all(
                          ColorsHelper.whiteBlue.withOpacity(0.5)),
                      splashColor: Colors.white12,
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          SearchScreen.router,
                        );
                      },
                      //   focusColor: Colors.white12,
                      child: Hero(
                        tag: "search_box1",
                        child: Container(
                          // height: 50,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black45, width: 1),
                            borderRadius: BorderRadius.circular(16),
                            // color: Colors.white,
                          ),
                          child: Row(children: [
                            const Icon(
                              Icons.search_rounded,
                              size: 30,
                              color: Colors.black45,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                                AppHelper.returnText(
                                    context, "Where to go?", "إلى اين اذهب؟"),
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  // child: TextFormField(
                  //   controller: textController,
                  //   obscureText: false,
                  //   decoration: InputDecoration(
                  //     hintText: 'Where to go?',
                  //     fillColor: Colors.white,
                  //     enabledBorder: UnderlineInputBorder(
                  //       borderSide: BorderSide(
                  //         color: Colors.black45,
                  //         width: 1,
                  //       ),
                  //       borderRadius: BorderRadius.circular(24),
                  //     ),
                  //     focusedBorder: UnderlineInputBorder(
                  //       borderSide: BorderSide(
                  //         color: Colors.black45,
                  //         width: 1,
                  //       ),
                  //       borderRadius: BorderRadius.circular(24),
                  //     ),
                  //     filled: true,
                  //     prefixIcon: Icon(
                  //       size: 30,
                  //       Icons.search,
                  //     ),
                  //   ),
                  // ),
                ),
              ),
            ],
          ),
        ),

        // ElevatedButton(
        //     onPressed: () {
        //       signout(userProvider);
        //     },
        //     child: Text("sign out")),
        // ElevatedButton(
        //     onPressed: () {
        //       Navigator.pushNamedAndRemoveUntil(
        //           context, OverviewScreen.router, (route) => false);
        //     },
        //     child: Text("sign in")),

        //^---------------------- adverticment -----------------------

        // if (_bannerAd != null)
        //   Container(
        //     margin: const EdgeInsets.symmetric(vertical: 20),
        //     width: _bannerAd?.size.width.toDouble(),
        //     height: _bannerAd?.size.height.toDouble(),
        //     child: AdWidget(ad: _bannerAd!),
        //   ),
        const Adcontainer(),

        //^----------------------------------------------------------

        //    if (_bannerAd != null)

        const SizedBox(
          height: 30,
        ),

        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("appStatistics")
              .where("year", isEqualTo: AppHelper.currentYear)
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData ||
                snapshot.data?.docs.isEmpty == true) {
              return Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: data["usersCount"].toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              children: <InlineSpan>[
                                TextSpan(
                                  text: AppHelper.returnText(
                                      context, "  User", "  مستخدم"),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              text: data["activitiesCount"].toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              children: <InlineSpan>[
                                TextSpan(
                                  text: AppHelper.returnText(
                                      context, "  Activity", "  نشاط"),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      //   Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: Text(
                      //       AppHelper.returnText(
                      //           context, "  In 2023  ", "   2023 في   "),
                      //       style: Theme.of(context).textTheme.bodySmall,
                      //     ),
                      //   ),
                    ]),
              );
            }
            AppStatisticsSchecma appStatisticsSchecma =
                AppStatisticsSchecma.toSchema(
                    snapshot.data!.docs.single.data());
            data["usersCount"] = NumberFormat.compact(locale: "en")
                .format(appStatisticsSchecma.usersCount)
                .toString();

            data["activitiesCount"] = NumberFormat.compact(locale: "en")
                .format(appStatisticsSchecma.activitiesCount)
                .toString();
            return Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: data["usersCount"],
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                            children: <InlineSpan>[
                              TextSpan(
                                text: AppHelper.returnText(
                                    context, "  User", "  مستخدم"),
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text: data["activitiesCount"],
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                            children: <InlineSpan>[
                              TextSpan(
                                text: AppHelper.returnText(
                                    context, "  Activity", "  نشاط"),
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    // Center(
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Text(
                    //       AppHelper.returnText(
                    //           context, "  2023  ", "   2023   "),
                    //       style: Theme.of(context).textTheme.displaySmall,
                    //     ),
                    //   ),
                    // ),
                  ]),
            );
          },
        ),
        // NumberFormat.compact().
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: Text(AppHelper.returnText(
                    context, "Add Activity", "إضافة نشاط")),
                onPressed: () async {
                  EasyLoading.show();
                  await userProvider.refreshUserData();
                  EasyLoading.dismiss();

                  if (!userProvider.islogin()) {
                    DialogWidgets.mustSginin(context);
                    return;
                  }
                  if (userProvider.islogin() &&
                      userProvider.currentUser!.isProAccount == true) {
                    if (userProvider.proCurrentUser?.verified != true ||
                        userProvider.proCurrentUser?.activationStatus != true) {
                      if (userProvider.proCurrentUser?.verified == true &&
                          userProvider.proCurrentUser?.activationStatus !=
                              true) {
                        DialogWidgets.nonActivatedProAccount(context);
                        return;
                      }

                      DialogWidgets.mustProHaveVerified(context);
                      return;
                    }
                    Navigator.pushNamed(context, AddActivityScreen.router);
                  } else {
                    DialogWidgets.mustSwitchtoPro(context);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            AppHelper.returnText(context, "Categories", "التصنيفات"),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: AppHelper.categories.map((e) {
                return CategoryCardWidget(
                    imagePath: e["imagepath"],
                    title: e["title"].toString().tr(),
                    onPressed: () async {
                      EasyLoading.show();
                      try {
                        // HttpsCallableResult r = await FirebaseFunctions.instance
                        //     .httpsCallable("SearchForActivityByCategory")
                        //     .call(e["title"].toString());
                        List<ActivitySchema> activitiesList =
                            await activityProvider.searchForActivityByCategory(
                                e["title"].toString());

                        // List<ActivitySchema> activitiesList = [];
                        // for (var activityMap in r.data) {
                        //   activitiesList
                        //       .add(ActivitySchema.toSchema(activityMap));
                        // }

                        Navigator.pushNamed(context, SearchScreen.router,
                            arguments: activitiesList);
                      } catch (err) {
                        print(err);
                      }
                      EasyLoading.dismiss();
                    });
              }).toList(),
            ),
          ),
        ),
        // adContainer,
        const SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            AppHelper.returnText(
                context, 'Top things to do', "أهم الأشياء للقيام بها"),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(
          height: 10,
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ElevatedButton(
            //   style: ButtonStyle(
            //       padding: MaterialStateProperty.all(EdgeInsets.all(15)),
            //       shape: MaterialStateProperty.all(
            //         RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(4),
            //         ),
            //       )),
            //   onPressed: () {},
            // child: Text(AppHelper.returnText(
            //     context, "Most Vital Events", "أهم الاحداث")),
            // ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                  color: ColorsHelper.whiteCard,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      overlayColor: ColorsHelper.cardOverlayColor,
                      splashColor: ColorsHelper.cardSplashColor,
                      onTap: () {
                        Navigator.pushNamed(context, ViewEventsScreen.router);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(AppHelper.returnText(
                            context, "Most Vital Events", "أهم الاحداث")),
                      ),
                    ),
                  )),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
              future: loadActivites(),
              builder: (context, future) {
                if (future.connectionState != ConnectionState.done ||
                    future.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Column(
                  children: [
                    ...future.data!,
                  ],
                );
              }),
        ),

        // ActivityCardWidget(
        //     activity: AppHelper.Activities[0],
        //     onPressed: () {
        //       Navigator.pushNamed(
        //         context,
        //         ActivityDetailsScreen.router,
        //         arguments: AppHelper.Activities[0],
        //       );
        //     }),

        const SizedBox(
          height: 20,
        ),

        // //^---------------------- adverticment -----------------------

        // if (_bannersAd != null)
        //   Container(
        //     width: _bannersAd[1]!.size.width.toDouble(),
        //     height: _bannersAd[1]!.size.height.toDouble(),
        //     child: AdWidget(ad: _bannersAd[1]!),
        //   ),

        // //^----------------------------------------------------------

        // const SizedBox(
        //   height: 30,
        // ),
      ],
    );
  }
}
