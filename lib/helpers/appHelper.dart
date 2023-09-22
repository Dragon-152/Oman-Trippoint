import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/widgets/loadingWidget.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localization/colored_print/print_color.dart';
import 'package:phone_number/phone_number.dart';
import 'package:uuid/uuid.dart';
import "package:easy_localization/easy_localization.dart";
import "package:localization/localization.dart";
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';

class AppHelper {
  static String currentYear = DateTime.now().year.toString();
  static String placesApiKey = "AIzaSyAObSpxSFhX2z9CyxO2GZKcgmaJA5Pq_AM";

  static unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Future sendError(String ? errorCode, String? desc, pageId, listDocs) async {
       CollectionReference errorCollection = FirebaseFirestore.instance.collection("errors");
        await errorCollection.add({
          "error":
              "${errorCode ?? 404} {}",
          "page": pageId,
          "collections": listDocs,
          "date": DateTime.now().microsecondsSinceEpoch.toString(),
        });
  }

  static Future<bool> checkInternetConnection() async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        // I am connected to a mobile network.
        return true;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        // I am connected to a wifi network.
        return true;
      }
    } catch (err) {}
    return false;
  }

  static bool isNumeric(String s) {
    if (s == null || s.trim() == "") {
      return true;
    }
    return double.tryParse(s) == null;
  }

  static List weekDays = [
    "sunday",
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
  ];
  static List categories = [
    {
      "imagepath": "assets/images/categories/discover_all.jpg",
      "title": "Discover all",
      "key": "discover_all",
    },
    {
      "imagepath": "assets/images/categories/water_advanture.jpg",
      "title": "Water activities",
      "key": "water_activities",
    },
    {
      "imagepath": "assets/images/categories/outdoor_advanture.jpg",
      "title": "Outdoor adventures",
      "key": "outdoor_adventures",
    },
    {
      "imagepath": "assets/images/categories/sky_advanture.jpg",
      "title": "Sky adventures",
      "key": "sky_adventures",
    },
    {
      "imagepath": "assets/images/categories/animal_experience.jpg",
      "title": "Animal experience",
      "key": "animal_experience",
    },
    {
      "imagepath": "assets/images/categories/indoor_activity.jpg",
      "title": "Indoor Activities",
      "key": "indoor_activities",
    }
    //   {
    //   "imagepath": "assets/images/categories/indoor_activity.jpg",
    //   "title": "Others",
    //   "key": "others",
    // }
  ];

  static Map categoriesAaE = {
    "اكتشف الكل": "Discover all",
    "أنشطة مائية": "Water activities",
    "مغامرات خارجية": "Outdoor adventures",
    "مغامرة في السماء": "Sky adventures",
    "تجربة الحيوان": "Animal experience",
    "أنشطة داخلية": "Indoor Activities",
    "أخرى": "Others",
  };

  static Map activityMapData = {
    "chatT": "Trippoint Oman",
    "chatW": "Whatsapp",
    "chatC": "Call",
    "op_SFC": "the activity suitable for children",
    "op_GOA": "private group option available",
    "op_SCT": "activity requires some skills",
  };

  static Map wilayatsAaE = {
    "Muscat": "مسـقط",
    "Seeb": "السـيب",
    "Muttrah": "مـطرح",
    "Basher": "بوشـر",
    "Amerat": "العامـرات",
    "Qurayyat": "قريات",
    "Sohar": "صحار",
    "Shinas": "شناص",
    "Louie": "لوى",
    "Saham": "صحم",
    "Al-Khaboura": "الخابورة",
    "Suwaiq": "السويق",
    "Khasab": "خصب",
    "Bukha": "بخاء",
    "Dabba": "دبا",
    "Madha": "مدحاء",
    "Al Buraimi": "البريمي",
    "Mahdah": "محضة",
    "Al-Sunaina": "السنينة",
    "Hebrew": "عبري",
    "Yanqul": "ينقل",
    "Dhank": "ضنك",
    "Nizwa": "نزوى",
    "Samael": "سمائل",
    "Bahla": "بهلاء",
    "Adam": "أدم",
    "Al Hamra": "الحمراء",
    "Manah": "منح",
    "Izki": "إزكي",
    "badbed": "بدبد",
    "Jebel Akhdar": "الجبل الاخضر",
    "Ibra": "إبراء",
    "Bidiyah": "بدية",
    "Al Qabil": "القابل",
    "Al Mudaibi": "المضيبي",
    "Blood and Tayyin": "دماء والطائيين",
    "Wadi Bani Khalid": "وادي بني خالد",
    "Snow": "سناو",
    "haima": "هيماء",
    "Mahut": "محوت",
    "Duqm": "الدقم",
    "Al Jazir": "الجازر",
    "Salalah": "صلالة",
    "Thumrait": "ثـمـريت",
    "Taqah": "طاقة",
    "Mirbat": "مرباط",
    "Sadah": "سدح",
    "Rakhiot": "رخيوت",
    "Dhalkoot": "ضلكوت",
    "Moqshin": "مقشن",
    "Shaleem and the Hallaniyat Islands": "شليم وجزر الحلانيات",
    "Al Mazyouna": "المزيونة",
    "Rustaq": "الرستاق",
    "Nakhl": "نخل",
    "Awabi": "وادي المعاول",
    "Al Awabi": "العوابي",
    "Al Masnaah": "المصنعة",
    "Barka": "بركاء",
    "Sur": "صور",
    "Al Kamil Wal Wafi": "الكامل والوافي",
    "Jalan Bani Bu Ali": "جعلان بني بو علي",
    "Ja'lan Bani Bu Hassan": "جعلان بني بو حسن",
    "Masirah Island": "مصيرة",
  };

  static Map wilayats = {
    "محافظة مسقط": [
      "مسـقط",
      "السـيب",
      "مـطرح",
      "بوشـر",
      "العامـرات",
      "قريات",
    ],
    "محافظة شمال الباطنه": [
      "صحار",
      "شناص",
      "لوى",
      "صحم",
      "الخابورة",
      "السويق",
    ],
    "محافظة مسندم": [
      "خصب",
      "بخاء",
      "دبا",
      "مدحاء",
    ],
    "محافظة البريمي": [
      "البريمي",
      "محضة",
      "السنينة",
    ],
    "محافظة الظاهرة": [
      "عبري",
      "ينقل",
      "ضنك",
    ],
    "محافظة الدخلية": [
      "نزوى",
      "سمائل",
      "بهلاء",
      "أدم",
      "الحمراء",
      "منح",
      "إزكي",
      "بدبد",
      "الجبل الاخضر",
    ],
    "محافظة شمال الشرقية": [
      "إبراء",
      "بدية",
      "القابل",
      "المضيبي",
      "دماء والطائيين",
      "وادي بني خالد",
      "سناو",
    ],
    "محافظة الوسطى": [
      "هيماء",
      "محوت",
      "الدقم",
      "الجازر",
    ],
    "محافظة ظفار": [
      "صلالة",
      "ثـمـريت",
      "طاقة",
      "مرباط",
      "سدح",
      "رخيوت",
      "ضلكوت",
      "مقشن",
      "شليم وجزر الحلانيات",
      "المزيونة",
    ],
    "محافظة جنوب الباطنه": [
      "الرستاق",
      "نخل",
      "وادي المعاول",
      "العوابي",
      "المصنعة",
      "بركاء",
    ],
    "محافظة جنوب الشرقيه": [
      "صور",
      "الكامل والوافي",
      "جعلان بني بو علي",
      "جعلان بني بو حسن",
      "مصيرة",
    ]
  };

//   static List<ActivitySchema> Activities = [
//     ActivitySchema(
//         Id: Uuid().v4(),
//         reviews: [],
//         lat: 23.244037241974922,
//         lng: 58.091192746314015,
//         tags: [],
//         userId: "mw1nzK98cHUm14emdFoWsoRlVPD2",
//         address: "smail, adldakilia",
//         phoneNumberWhatsapp: "7937714",
//         phoneNumberCall: "79377174",
//         description:
//             "new activity, for drop from sky with beutifil view you havn't seen before",
//         images: ["assets/images/categories/discover_all.jpg"],
//         importantInformation: "this is importaint information to read",
//         cTrippointChat: true,
//         availableDays: ["thursday",],
//         category: categories[1]["title"],
//         priceNote: "price description 1\$ for every children",
//         prices: [],
//         op_GOA: true,
//         genderSuitability: {},
//         suitableAges: {},
//         dates: [],
//         isActive: true,
//         lastUpdate: DateTime.now().millisecondsSinceEpoch,
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//     //  likesCount: act["likeCount"],
//     //   viewsCount: act["viewCount"],
//     //   callsCount: act["callsCount"],
//     //   sharesCount: act["sharesCount"],
//         title: "Dolphin watching and snorking Muscat",
//         ),
//   ];

  static final PhoneNumberUtil phoneNumber = PhoneNumberUtil();
  static RegionInfo region =
      const RegionInfo(name: "Oman", code: "OM", prefix: 968);

  static checkPhoneValidation(BuildContext context, val) async {
    bool isValid = await phoneNumber.validate(val, region.code);

    if (!isValid) {
      print("invalid phone number");
    }
  }

  static List showOverlay(BuildContext context, Widget widget) {
    OverlayState? overlayState = Overlay.of(context);

    OverlayEntry overlayEntry = OverlayEntry(
        opaque: true,
        builder: (context) {
          return widget;
        });

    overlayState?.insert(overlayEntry);

    return [overlayState, overlayEntry];
  }

  static Future<String> buildDynamicLink(
      {required String title, required String Id}) async {
    String uriPrefix = "https://trippoint.page.link";
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("${uriPrefix}/post${Id}"),
      uriPrefix: uriPrefix,
      androidParameters: const AndroidParameters(
        packageName: "com.s3qTeam.omanTrippoint",
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: "com.s3qTeam.omanTrippoint",
        appStoreId: "123456789",
        minimumVersion: "1.0.1",
      ),
//   googleAnalyticsParameters: const GoogleAnalyticsParameters(
//     source: "twitter",
//     medium: "social",
//     campaign: "example-promo",
//   ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: title,
        imageUrl: Uri.parse(
            "https://raw.githubusercontent.com/s3q/app/main/assets/icons/launch_image.png"),
        // !!!!!!!!!!!!!
      ),
    );
    ShortDynamicLink dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    return dynamicLink.shortUrl.toString();
  }

//   static textDirction(context) {
//       context.locale.languageCode == "ar"
//                                         ? TextDirection.rtl
//                                         : TextDirection.ltr,
//   }

  static String returnText(BuildContext context, String en, String ar) {
    if (context.locale.languageCode.toString() == "ar") {
      return ar;
    }

    return en;
  }
}
