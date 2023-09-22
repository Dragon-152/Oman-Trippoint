import 'dart:async';
import 'dart:io';

import 'package:oman_trippoint/constants/constants.dart';
import 'package:oman_trippoint/helpers/adHelper.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/chatProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/schemas/userSchema.dart';
import 'package:oman_trippoint/screens/ContactOwnerScreen.dart';
import 'package:oman_trippoint/screens/mapScreen.dart';
import 'package:oman_trippoint/screens/massagesScreen.dart';
import 'package:oman_trippoint/screens/reportActivityScreen.dart';
import 'package:oman_trippoint/screens/sendReviewScreen.dart';
import 'package:oman_trippoint/screens/viewImagesScreen.dart';
import 'package:oman_trippoint/screens/viewReviewsScreen.dart';
import 'package:oman_trippoint/widgets/AdContainerWidget.dart';
import 'package:oman_trippoint/widgets/DiologsWidgets.dart';
import 'package:oman_trippoint/widgets/LinkWidget.dart';
import 'package:oman_trippoint/widgets/activity/reviewsTextActivity.dart';
import 'package:oman_trippoint/widgets/activity/startFromPriceTextActivity.dart';
import 'package:oman_trippoint/widgets/dividerWidget.dart';
import 'package:oman_trippoint/widgets/googlemapDescWidget.dart';
import 'package:oman_trippoint/widgets/orginizerActivityBoxWidget.dart';
import 'package:oman_trippoint/widgets/ratingBarWidget.dart';
import 'package:oman_trippoint/widgets/textBoxActWidget.dart';
import 'package:oman_trippoint/widgets/textCardWidget.dart';
import 'package:oman_trippoint/widgets/textIocnActWidget.dart';
import 'package:oman_trippoint/widgets/wishlistIconButtonWidget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:easy_localization/easy_localization.dart';

const s =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

class ActivityDetailsScreen extends StatefulWidget {
  static String router = "/activity_details";
  const ActivityDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  final store = FirebaseStorage.instance;
  bool init = false;
  PageController pageViewController = PageController(initialPage: 0);

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

  void _gotoChat({
    required BuildContext context,
    required UserProvider userProvider,
    required String userId,
    required String activityId,
  }) async {
    if (userProvider.islogin()) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // final userProvider = Provider.of<UserProvider>(context, listen: false);

      await chatProvider.addChat(
          context: context, userId: userId, activityId: activityId);
      if (chatProvider.chat != null) {
        if (chatProvider.chat!.users.contains(userId) &&
            chatProvider.chat!.users.contains(userProvider.currentUser!.Id)) {
          await Navigator.pushNamed(context, MassagesScreen.router,
              arguments: chatProvider.chat);
        }
      }
    }
  }

  Map<int, BannerAd> _bannersAd = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _interstitialAd?.dispose();

    _loadInterstitialAd();
    _bannersAd[0]?.dispose();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _interstitialAd?.dispose();

    _bannersAd[0]?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);
    ActivitySchema args =
        ModalRoute.of(context)?.settings.arguments as ActivitySchema;
    print(args.storeId);

    Future.delayed(Duration.zero,
        () async => await activityProvider.openActivity(args.storeId, args.Id));

    List images = [...args.images];
    List dates = [...args.dates];
    images.removeWhere((e) => e == null || e.toString().trim() == "");
    dates.removeWhere((e) => e == null || e == "" || e.runtimeType == String);

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Container(
                child: Container(
                  height: 320,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Hero(
                        tag: images,
                        child: Container(
                          margin: EdgeInsets.only(top: 40),
                          child: PageView(
                            controller: pageViewController,
                            children: images.map((e) {
                              return Image.network(
                                e,
                                height: 300,
                                fit: BoxFit.cover,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(.7, .9),
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
                          effect: const ExpandingDotsEffect(
                            expansionFactor: 1.5,
                            spacing: 6,
                            radius: 16,
                            dotWidth: 12,
                            dotHeight: 12,
                            dotColor: Color(0xFF9E9E9E),
                            activeDotColor: Color(0xFF3F51B5),
                            paintStyle: PaintingStyle.fill,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(-.9, .9),
                        
                        child: IconButton(onPressed: () {
                            Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            ViewImagesScreen(images: args.images),
                      ),
                    );
                        }, icon: Icon(Icons.open_in_full_rounded, size: 30,))
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0, -1),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          width: MediaQuery.of(context).size.width,
                          //   padding: EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  color: Color(0x33000000),
                                  offset: Offset(0, 2),
                                )
                              ],
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20)),
                              //   borderRadius: BorderRadius.circular(50),
                              color: Colors.white),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, size: 28),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.share, size: 28),
                                    onPressed: () async {
                                      //   Navigator.pop(context);share
                                      EasyLoading.show();
                                      try {
                                      if (_interstitialAd != null) {
                                        _interstitialAd?.show();
                                      }
                                      String url =
                                          await AppHelper.buildDynamicLink(
                                              title: args.title, Id: args.Id);
                                      await FlutterShare.share(
                                        title: 'Trippoint Oman || عمان',
                                        text: args.title,
                                        linkUrl: url,
                                      );
                                      activityProvider.addSharesCountActivity(
                                          args.storeId, args.Id);

                                          

                                      }catch (err) {

                                      }
                                      EasyLoading.dismiss();
                                    },
                                  ),
                                  WishlistIconButtonWidget(
                                    activityId: args.Id,
                                    activityStoreId: args.storeId!,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      args.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextIconInfoActWidget(
                              text: args.address.toString().tr(),
                              icon: Icons.location_on_rounded,
                              //  style: Theme.of(context).textTheme.bodySmall,
                            ),
                            TextIconInfoActWidget(
                              text: activityProvider.formatTimeAgo(args.createdAt),
                              icon: Icons.timelapse_outlined        ,
                              //  style: Theme.of(context).textTheme.bodySmall,
                            ),
                            ReviewsTextActivity(activitySchema: args),
                          ],
                        ),
                        StartFromPriceTextActivity(activitySchema: args),
                      ],
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     StartFromPriceTextActivity(activitySchema: args),
                    //   ],
                    // ),
                  ],
                ),
              ),

              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      if (args.genderSuitability["woman"] == true &&
                          (args.genderSuitability["man"] == false ||
                              args.genderSuitability["man"] == null))
                        TextBoxActWidget(
                          text: AppHelper.returnText(
                              context, "Women only", "للنساء فقط"),
                        ),
                      if (args.suitableAges["min"] != null &&
                          args.suitableAges["min"].toString().trim() != "")
                        TextBoxActWidget(
                          text: AppHelper.returnText(context, "Over", "فوق") +
                              " " +
                              args.suitableAges["min"].toString() +
                              " " +
                              AppHelper.returnText(context, "", "سنة"),
                        ),
                      if (args.op_GOA == true)
                        TextBoxActWidget(
                          text: AppHelper.returnText(
                              context, "Private group", "متاح للعوائل"),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),
              Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (dates.isNotEmpty)
                              Text(AppHelper.returnText(context,
                                  "Avaliable Dates : ", "التواريخ المتاحة:")),
                            if (dates.isNotEmpty)
                              SizedBox(
                                height: 10,
                              ),
                            if (dates.isNotEmpty)
                              Column(
                                children: dates.map((e) {
                                  if (e != null &&
                                      e != "" &&
                                      e.runtimeType != String) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          primary: Colors.black87,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                          side: const BorderSide(width: 1),
                                        ),
                                        child: Text(
                                          DateFormat('MM/dd/yyyy, hh:mm a')
                                              .format(DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      e)),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                }).toList(),
                              ),
                            if (args.availableDays.isNotEmpty)
                              Text(AppHelper.returnText(context,
                                  "Avaliable days : ", "الأيام المتوفرة:")),
                            if (dates.isNotEmpty)
                              SizedBox(
                                height: 10,
                              ),
                            if (args.availableDays.isNotEmpty)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    if (args.availableDays.length ==
                                        AppHelper.weekDays.length)
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: OutlinedButton(
                                          onPressed: () {},
                                          style: OutlinedButton.styleFrom(
                                            primary: Colors.black87,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                            side: const BorderSide(width: 1),
                                          ),
                                          child: Text(
                                            AppHelper.returnText(context,
                                                "All days", "كل الأيام"),
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    if (args.availableDays.length !=
                                        AppHelper.weekDays.length)
                                      ...args.availableDays.map((e) {
                                        if (e != null) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: OutlinedButton(
                                              onPressed: () {},
                                              style: OutlinedButton.styleFrom(
                                                primary: Colors.black87,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 8),
                                                side:
                                                    const BorderSide(width: 1),
                                              ),
                                              child: Text(
                                                e.toString().tr(),
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      }).toList(),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ])),
              //   if (_bannersAd[0] != null)
              //     const SizedBox(
              //       height: 20,
              //     ),

              //^---------------------- adverticment -----------------------

              //   if (_bannersAd[0] != null)
              //     Container(
              //       width: _bannersAd[0]!.size.width.toDouble(),
              //       height: _bannersAd[0]!.size.height.toDouble(),
              //       child: AdWidget(ad: _bannersAd[0]!),
              //     ),

              const Adcontainer(),
              //^----------------------------------------------------------
              //   if (_bannersAd[0] != null)
              //     const SizedBox(
              //       height: 20,
              //     ),

              const Divider(
                thickness: 2,
                // color: ColorsHelper.blue.shade400,
              ),
              OriginizerActivityBoxWidget(
                activitySchema: args,
              ),
              const Divider(
                thickness: 2,
                // color: ColorsHelper.blue.shade400,
              ),

              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppHelper.returnText(context, 'Prices', "الأسعار"),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ...args.prices
                        .asMap()
                        .map((k, e) {
                          if (e["price"] != null &&
                              e["price"].toString().trim() != "") {
                            return MapEntry(
                                k,
                                Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          height: 60,
                                          padding: const EdgeInsets.all(7),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: ColorsHelper.grey,
                                                width: 1),
                                            //   borderRadius:
                                            //       BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(e["price"].toString()),
                                              Text(
                                                " OMR",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(fontSize: 10),
                                              )
                                            ],
                                          ),
                                        ),
                                        // Icon(Icons.compare_arrows, size: 35, color:ColorsHelper.grey ,),

                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            height: 60,
                                            padding: const EdgeInsets.all(7),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: ColorsHelper.grey,
                                                  width: 1),
                                              // borderRadius:
                                              //     BorderRadius.circular(10),
                                            ),
                                            child: Align(
                                              alignment:
                                                  context.locale.languageCode ==
                                                          "ar"
                                                      ? Alignment.centerRight
                                                      : Alignment.centerLeft,
                                              child: Text(
                                                e["des"].toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // if (k != args.prices.length - 1 &&
                                    //     (args.prices[k + 1]["price"] != "" &&
                                    //         args.prices[k + 1]["price"] !=
                                    //             null))
                                    //   DividerWidget(),
                                  ],
                                ));
                          }
                          return MapEntry(k, const SizedBox());
                        })
                        .values
                        .toList(),
                    //   Text(args.prices),

                    const SizedBox(
                      height: 15,
                    ),
                      TextCardWidget(
                      title: AppHelper.returnText(
                          context, "Price notes", "ملاحظات السعر"),
                      text: args.priceNote,
                    ),
                    TextCardWidget(
                      title: AppHelper.returnText(
                          context, "Activity description", "وصف النشاط"),
                      text: args.description,
                    ),
                    TextCardWidget(
                      title: AppHelper.returnText(
                          context, "Important information", "معلومات مهمة"),
                      text: args.importantInformation,
                    ),
                  ],
                ),
              ),

              Divider(
                thickness: 2,
                // color: ColorsHelper.blue.shade400,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              AppHelper.returnText(
                                  context, 'Location', 'الموقع'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  5, 0, 0, 0),
                              child: Text(
                                args.address.tr(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            EasyLoading.show();

                            MapsLauncher.launchCoordinates(
                              args.lat,
                              args.lng,
                            );
                            EasyLoading.dismiss();
                          },
                          label: Text(
                            AppHelper.returnText(
                                context, "Google Map", "خرائط جوجل"),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          icon: Icon(
                            Icons.assistant_navigation,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),

              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  child: GooglemapDescWidget(
                    latlan: LatLng(args.lat, args.lng),
                    activitySchema: args,
                    onChanged: () {
                      Navigator.pushNamed(context, MapScreen.router,
                          arguments: args);
                    },
                  )),

              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppHelper.returnText(context, 'Reviews', "التعليقات"),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                          child: Text(
                            activityProvider
                                .previewMark(args.reviews)
                                .toString(),
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        RatingBarWidget(
                          onRated: (val) {
                            print(val);
                            if (userProvider.islogin()) {
                              Navigator.pushNamed(
                                  context, SendReviewScreen.router,
                                  arguments: args);
                            } else {
                              DialogWidgets.mustSginin(context);
                            }
                          },
                          size: 30,
                        ),
                        Text(
                          args.reviews.length.toString() +
                              AppHelper.returnText(
                                  context, ' reviews', "تقييمات"),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                      child: OutlinedButton(
                        onPressed: () {
                          print('Button pressed ...');
                          Navigator.pushNamed(context, ViewReviewScreen.router,
                              arguments: args);
                        },
                        style: OutlinedButton.styleFrom(),
                        child: Text(AppHelper.returnText(
                            context, 'see reviews', "التقيمات")),
                      ),
                    ),
                  ],
                ),
              ),

              LinkWidget(
                  text: AppHelper.returnText(context, "! Report this listing ",
                      "! أبلاغ عن هذه القائمة"),
                  onPressed: () {
                    Navigator.pushNamed(context, ReportActivityScreen.router,
                        arguments: args.Id);
                  }),

              const SizedBox(
                height: 80,
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.white38,
        child: Padding(
          padding:  EdgeInsets.only(left: 8, top: 8, bottom: Platform.isIOS ? 30 : 8, right: 8),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, ContactOwnerScreen.router,
                  arguments: args);
            },
            child: Text(
                AppHelper.returnText(context, "Contact", "تواصل مع المالك")),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class MapSample extends StatefulWidget {
  double latitude;
  double longitude;
  String address;
  String description;

  MapSample(
      {Key? key,
      required this.address,
      required this.description,
      required this.latitude,
      required this.longitude})
      : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();

  CameraPosition initialCameraPosition =
      const CameraPosition(target: LatLng(22.665964, 59.403076), zoom: 30);

  final Marker _marker = Marker(
    markerId: const MarkerId("smail"),
    infoWindow: const InfoWindow(
      title: "samli lo",
      snippet:
          "New York City is a global cultural, financial, and media center with a significant",
    ),
    position: const LatLng(22.665964, 59.403076),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  );
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: initialCameraPosition,
      onMapCreated: (controller) {
        _controller.complete(controller);
      },
      markers: {
        _marker,
      },
    );
  }
}

class P_ExpandableView extends StatelessWidget {
  String title;
  String text;
  int? maxLines = 2;
  P_ExpandableView(
      {Key? key, required this.title, required this.text, this.maxLines})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: ScrollOnExpand(
          child: ExpandablePanel(
            header: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                )),
            collapsed: Text(
              text,
              softWrap: true,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
            expanded: Text(
              text,
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
            builder: (_, collapsed, expanded) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Expandable(
                  collapsed: collapsed,
                  expanded: expanded,
                  theme: const ExpandableThemeData(crossFadePoint: 0),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
