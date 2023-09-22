import 'package:oman_trippoint/constants/constants.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/schemas/activityStatisticsSchema.dart';
import 'package:oman_trippoint/schemas/reviewSchema.dart';
import 'package:oman_trippoint/widgets/snakbarWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' show cos, sqrt, asin;

class ActivityProvider with ChangeNotifier {
  Map<String, ActivitySchema> activities = {};
  Map<String, ActivitySchema> topActivitiesList = {};
  static String collection = CollectionsConstants.activities;
  static final auth = FirebaseAuth.instance;
  static final store = FirebaseFirestore.instance;
  static final storage = FirebaseStorage.instance;

String formatTimeAgo(int millisecondsSinceEpoch) {
  final currentTime = DateTime.now();
  final targetTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

  final timeDifference = currentTime.difference(targetTime);

  if (timeDifference.inSeconds < 60) {
    return 'Just now';
  } else if (timeDifference.inMinutes < 60) {
    return '${timeDifference.inMinutes} minutes ago';
  } else if (timeDifference.inHours < 24) {
    return '${timeDifference.inHours} hours ago';
  } else if (timeDifference.inDays < 7) {
    return '${timeDifference.inDays} days ago';
  } else {
    final formatter = DateFormat('MMM d, y');
    return formatter.format(targetTime);
  }
}
  Future<List<ActivitySchema>> fetchAllActivites() async {
  
    activities = {};
    QuerySnapshot<Map<String, dynamic>> verifiedDocsQuerySnapshot = await store
        .collection(collection)
        .where("disabled", isEqualTo: false)
        .where("isActive", isEqualTo: true)
        .where('verified', isEqualTo: true)
        .orderBy('likesCount', descending: true)
        .orderBy('viewsCount', descending: true)
        .get();

    for (var doc in verifiedDocsQuerySnapshot.docs) {
      Map a = doc.data();

      a["storeId"] = doc.id;
      activities[a["Id"]] = ActivitySchema.toSchema(a);
    }
    QuerySnapshot<Map<String, dynamic>> nonVerifiedDocsQuerySnapshot =
        await store
            .collection(collection)
            .where("disabled", isEqualTo: false)
            .where("isActive", isEqualTo: true)
            .where('verified', isEqualTo: false)
            .orderBy('likesCount', descending: true)
            .orderBy('viewsCount', descending: true)
            .get();

    print(nonVerifiedDocsQuerySnapshot.docs);

    for (var doc in nonVerifiedDocsQuerySnapshot.docs) {
      Map a = doc.data();
      a["storeId"] = doc.id;
      activities[a["Id"]] = ActivitySchema.toSchema(a);
    }

    return activities.values.toList();
  }

  Future<ActivityStatisticsSchema?> fetchActivityStatistics(activityId) async {
  // * rtjhjhjh
  }

  Future openActivity(activityStoreId, activityId) async {
    try {
      if (activityStoreId == null) {
        throw "Null is not sub type of String";

        // return;
      }
      HttpsCallableResult response = await FirebaseFunctions.instance
          .httpsCallable("increaseCountersActivities")
          .call({
        "doc": activityStoreId,
        "field": "viewsCount",
      });

      activities[activityId]!.viewsCount = response.data;
    } catch (err) {
      print(err);
    }
    //   await activityQuery.docs.single.reference.update({
    //     "viewsCount":
    //         int.parse(activityQuery.docs.single.data()["viewCount"]) + 1,
    //   });
    //   activities[activityId]!.viewsCount =
    //       int.parse(activityQuery.docs.single.data()["viewCount"]) + 1;
  }

  Future<bool> likeActivity(activityStoreId, activityId) async {
    try {
      if (activityStoreId == null) {
        throw "Null is not sub type of String";

        // return false;
      }
      HttpsCallableResult response = await FirebaseFunctions.instance
          .httpsCallable("increaseCountersActivities")
          .call({
        "doc": activityStoreId,
        "field": "likesCount",
      });

      activities[activityId]!.likesCount = response.data;
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> addCallsCountActivity(activityStoreId, activityId) async {
    try {
      if (activityStoreId == null) {
        throw "Null is not sub type of String";
      }
      HttpsCallableResult response = await FirebaseFunctions.instance
          .httpsCallable("increaseCountersActivities")
          .call({
        "doc": activityStoreId,
        "field": "callsCount",
      });

      activities[activityId]?.callsCount = response.data;
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> addChatsCountActivity(activityStoreId, activityId) async {
    try {
      if (activityStoreId == null) {
        throw "Null is not sub type of String";
      }
      HttpsCallableResult response = await FirebaseFunctions.instance
          .httpsCallable("increaseCountersActivities")
          .call({
        "doc": activityStoreId,
        "field": "chatsCount",
      });

      activities[activityId]?.chatsCount = response.data;
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> addSharesCountActivity(activityStoreId, activityId) async {
    try {
      if (activityStoreId == null) {
        throw "Null is not sub type of String";
      }
      HttpsCallableResult response = await FirebaseFunctions.instance
          .httpsCallable("increaseCountersActivities")
          .call({
        "doc": activityStoreId,
        "field": "sharesCount",
      });

      activities[activityId]?.sharesCount = response.data;
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

//   Future<bool> addWhatsappCountActivity(activityStoreId, activityId) async {
//      try {
//       assert(activityStoreId != null);
//       HttpsCallableResult response = await FirebaseFunctions.instance
//           .httpsCallable("increaseCountersActivities")
//           .call({
//         "doc": activityStoreId,
//         "field": "sharesCount",
//       });

//       activities[activityId]?.whatsappCount = response.data;
//             return true;

//     } catch (err) {
//       print(err);
//       return false;
//     }
//   }

//   Future<bool> addInstagramCountActivity(activityId) async {
//     QuerySnapshot<Map<String, dynamic>> activityQuery = await store
//         .collection(collection)
//         .where("ActivityId", isEqualTo: activityId)
//         .get();

//     if (activityQuery.docs.isNotEmpty) {
//       await activityQuery.docs.single.reference.update({
//         "InstagramCount":
//             int.parse(activityQuery.docs.single.data()["InstagramCount"]) + 1,
//       });
//     }

//     return true;
//   }

  int? startFromPrice(List prices) {
    int? lessPrice;
    int i = 0;
    prices.forEach((e) {
      if (e["price"] != null && e["price"].toString().trim() != "") {
        int n = int.parse(e["price"]);

        if (lessPrice != null) {
          if (lessPrice! > n) {
            lessPrice = n;
          }

          //   if (i == prices.length - 1 && lessPrice! < n) {
          //     return lessPrice;
          //   } else if (i == prices.length - 1 && lessPrice! > n) {
          //     return n;
          //   }
        } else {
          lessPrice = n;
        }
      }
      i += 1;
    });

    return lessPrice;
  }

  Future<String?> imageUrl(String path) async {
    // Points to the root reference

    // Reference storageRef = FirebaseStorage.instance.ref(path);
    //   print(await storageRef.getDownloadURL());
    return await storage.ref(path).getDownloadURL();
  }

  double previewMark(List previews) {
    double total = 0;
    if (previews.length != 0) {
      previews.forEach((e) {
        if (e["rating"] != null && e["rating"].toString().trim() != "") {
          total += e["rating"];
        }
      });

      double d = total / previews.length;
      String inString = d.toStringAsFixed(1);
      double inDouble = double.parse(inString);
      return inDouble;
    } else {
      return 0.0;
    }
  }

  Future<ActivitySchema> fetchActivityWStore(String activityId) async {
    if (activities[activityId] != null) {
      return activities[activityId]!;
    }
    if (topActivitiesList[activityId] != null) {
      activities[activityId] = topActivitiesList[activityId]!;
      return topActivitiesList[activityId]!;
    }

    QuerySnapshot<Map<String, dynamic>> queryActivity = await store
        .collection(collection)
        .where("Id", isEqualTo: activityId)
        .get();

    Map<String, dynamic> act = queryActivity.docs.single.data();
    activities[activityId] = ActivitySchema(
      storeId: queryActivity.docs.single.reference.id,
      isActive: act["isActive"],
      disabled: act["disabled"],
      verified: act["verified"],
      createdAt: act["createdAt"],
      lastUpdate: act["lastUpdate"],
      userId: act["userId"],
      likesCount: act["likesCount"],
      viewsCount: act["viewsCount"],
      callsCount: act["callsCount"],
      sharesCount: act["sharesCount"],
      chatsCount: act["chatsCount"],
      Id: act["Id"],
      lat: act["lat"],
      lng: act["lng"],
      address: act["address"],
      phoneNumberWhatsapp: act["phoneNumberWhatsapp"],
      phoneNumberCall: act["phoneNumberCall"],
      description: act["description"],
      images: act["images"],
      importantInformation: act["importantInformation"],
      availableDays: act["availableDays"],
      cTrippointChat: act["cTrippointChat"],
      category: act["category"],
      priceNote: act["priceNote"],
      prices: act["prices"],
      op_GOA: act["op_GOA"],
      dates: act["dates"],
      reviews: act["reviews"],
      suitableAges: act["suitableAges"],
      genderSuitability: act["genderSuitability"],
      title: act["title"],
      tags: act["tags"],
    );

    return activities[activityId]!;
  }

  Future<List<ActivitySchema>?> fetchUserActivities(
      BuildContext context, userId) async {
    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      QuerySnapshot<Map<String, dynamic>> userActivitiesQuery = await store
          .collection(CollectionsConstants.activities)
          .where("userId", isEqualTo: userId)
          .get();

      List<ActivitySchema> activityList = [];

      await userProvider.fetchUserData(userId: userId);

      for (var element in userActivitiesQuery.docs) {
        Map<String, dynamic> act = element.data();

        activities[act["Id"]] = ActivitySchema(
          storeId: element.id,
          isActive: act["isActive"],
          createdAt: act["createdAt"],
          disabled: act["disabled"],
          verified: act["verified"],
          lastUpdate: act["lastUpdate"],
          userId: act["userId"],
          likesCount: act["likesCount"],
          viewsCount: act["viewsCount"],
          callsCount: act["callsCount"],
          sharesCount: act["sharesCount"],
          chatsCount: act["chatsCount"],
          Id: act["Id"],
          lat: act["lat"],
          lng: act["lng"],
          address: act["address"],
          phoneNumberWhatsapp: act["phoneNumberWhatsapp"],
          phoneNumberCall: act["phoneNumberCall"],
          description: act["description"],
          images: act["images"],
          importantInformation: act["importantInformation"],
          availableDays: act["availableDays"],
          cTrippointChat: act["cTrippointChat"],
          category: act["category"],
          priceNote: act["priceNote"],
          prices: act["prices"],
          op_GOA: act["op_GOA"],
          dates: act["dates"],
          reviews: act["reviews"],
          suitableAges: act["suitableAges"],
          genderSuitability: act["genderSuitability"],
          title: act["title"],
          tags: act["tags"],
        );

        print(activities[act["Id"]]);
        print("1");

        if (activities[act["Id"]] != null) {
          activityList.add(activities[act["Id"]]!);
        }
      }
      // userActivitiesQuery.docs.forEach((element) {

      // });

      return activityList;
    } catch (err) {
      SnakbarWidgets.error(context,
          AppHelper.returnText(context, "Something is wrong", "هناك خطأ ما"));
      return [];
    }
  }

  Future sendReview(
      ReviewSchecma reviewSchecma, String storeId, String activityId) async {
    DocumentSnapshot<Map<String, dynamic>> activityQuery =
        await store.collection(collection).doc(storeId).get();

    await activityQuery.reference.update({
      "reviews": [
        ...activityQuery.data()?["reviews"],
        reviewSchecma.toMap(),
      ]
    });

    topActivitiesList[activityId]?.reviews.add(reviewSchecma.toMap());
    activities[activityId]?.reviews.add(reviewSchecma.toMap());
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<List<ActivitySchema>> fetchActivitiesNearLocation(
      LatLng latLng) async {
    List<ActivitySchema> activitiesList = [];

    double lessKmY = ((110.574 * latLng.latitude) - 30) / 110.574;
    double greaterKmY = ((110.574 * latLng.latitude) + 30) / 110.574;
    double lessKmX =
        ((111.320 * cos(latLng.latitude) * latLng.longitude) + 30) /
            111.320 *
            cos(latLng.latitude);
    double greaterKmX =
        ((111.320 * cos(latLng.latitude) * latLng.longitude) + 30) /
            111.320 *
            cos(latLng.latitude);

    QuerySnapshot<Map<String, dynamic>> activitiesQuery = await store
        .collection(collection)
        .where("lat",
            isLessThanOrEqualTo: lessKmY, isGreaterThanOrEqualTo: greaterKmY)
        .where(
          "lng",
          isLessThanOrEqualTo: lessKmX,
          isGreaterThanOrEqualTo: greaterKmX,
        )
        .get();

    activitiesQuery.docs.map((act) {
      activitiesList.add(ActivitySchema(
          storeId: act.reference.id,
          isActive: act["isActive"],
          disabled: act["disabled"],
          verified: act["verified"],
          createdAt: act["createdAt"],
          lastUpdate: act["lastUpdate"],
          userId: act["userId"],
          likesCount: act["likeCount"],
          viewsCount: act["viewsCount"],
          callsCount: act["callsCount"],
          sharesCount: act["sharesCount"],
          chatsCount: act["chatsCount"],
          Id: act["Id"],
          lat: act["lat"],
          lng: act["lng"],
          address: act["address"],
          phoneNumberWhatsapp: act["phoneNumberWhatsapp"],
          phoneNumberCall: act["phoneNumberCall"],
          description: act["description"],
          images: act["images"],
          importantInformation: act["importantInformation"],
          availableDays: act["availableDays"],
          cTrippointChat: act["cTrippointChat"],
          category: act["category"],
          priceNote: act["priceNote"],
          prices: act["price"],
          op_GOA: act["op_GOA"],
          dates: act["dates"],
          reviews: act["reviews"],
          suitableAges: act["suitableAges"],
          genderSuitability: act["genderSuitability"],
          title: act["title"],
          tags: act["tags"]));
    });

    return activitiesList;
    // print(activitiesQuery);
    // double distance = calculateDistance(latLng.)
  }

  Future<String> createActivity(
      BuildContext context, ActivitySchema activityData) async {
    try {
      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));
        return "";
      }

      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);

      if (userProvider.islogin() == false ||
          userProvider.currentUser!.isProAccount == false ||
          userProvider.proCurrentUser == null ||
          userProvider.proCurrentUser!.activationStatus == false) {
        throw 99;
      }

      CollectionReference activityCollection = store.collection(collection);

      DocumentReference<Object?> query2 =
          await activityCollection.add(activityData.toMap());

      ActivityStatisticsSchema activityStatisticsSchema =
          ActivityStatisticsSchema(
              createdAt: DateTime.now().millisecondsSinceEpoch,
              Id: const Uuid().v4(),
              activityId: activityData.Id,
              callsCount: 0,
              chatsCount: 0,
              sharesCount: 0,
              instsgramCount: 0,
              likesCount: 0,
              viewsCount: 1,
              whatsappCount: 0);

      await userProvider.userManagerFirestore(DocConstants.addActivity, {
        "userId": userProvider.currentUser?.Id,
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "email": userProvider.currentUser?.email,
        "phone": userProvider.currentUser?.phoneNumber,
      });

      await store
          .collection(CollectionsConstants.activityStatistics)
          .add(activityStatisticsSchema.toMap());

      activities[activityData.Id] = activityData;

      return query2.id;
    } catch (err) {
      print(err);
      return "";
    }
  }

  Future<ActivitySchema?> updateActivityWStore(String activityStoreId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> queryActivity =
          await store.collection(collection).doc(activityStoreId).get();

      Map<String, dynamic>? act = queryActivity.data();
      if (act == null) {
        throw 99;
      }
      ActivitySchema activitySchema = ActivitySchema.toSchema(act!);
      activitySchema.storeId = queryActivity.reference.id;
      activities[act["Id"]] = activitySchema;

      if (topActivitiesList[act["Id"]] != null) {
        topActivitiesList[act["Id"]] = activitySchema;
      }

      return activities[act["Id"]];
    } catch (err) {
      print(err);
    }
  }

  Future<bool> updateActivityData(
      {required BuildContext context,
      required Map<String, dynamic> data,
      required String activityStoreId}) async {
    try {
      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));
        return false;
      }
      data.remove("userId");
      data.remove("reviews");
      data.remove("Id");
      await store.collection(collection).doc(activityStoreId).update(data);
      await updateActivityWStore(activityStoreId);
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> deleteActivity(
      BuildContext context, String activityStoreId) async {
    bool checkInternetConnection = await AppHelper.checkInternetConnection();
    if (!checkInternetConnection) {
      SnakbarWidgets.error(
          context,
          AppHelper.returnText(context, "There is no network connection",
              "لا يوجد اتصال بالشبكة"));
      return false;
    }
    DocumentSnapshot<Map<String, dynamic>> activityQuery =
        await store.collection(collection).doc(activityStoreId).get();

    if (activityQuery.data()!["userId"] == auth.currentUser!.uid) {
      if (activities[activityQuery.data()!["Id"]] != null) {
        for (var image in activities[activityQuery.data()!["Id"]]!.images) {
          print("DELete !!!!!!!!!!!!!");
          print(image);

          String imageName = image
                      .split(
                          "activites/${activityQuery.data()!['Id']}/displayImages/")
                      .length ==
                  1
              ? image
                  .split("activites%2F${activityQuery.data()!['Id']}%2FdisplayImages%2F")[
                      1]
                  .split(".jpg")[0]
              : image
                  .split(
                      "activites/${activityQuery.data()!['Id']}/displayImages/")[1]
                  .split(".jpg")[0];
          print(imageName);
          Reference ref = storage.ref(
              "activites/${activityQuery.data()!["Id"]}/displayImages/${imageName}.jpg");
          await ref.delete();
        }

        await activityQuery.reference.delete();

        activities[activityQuery.data()!["Id"]]!.isActive = false;
      }
      return true;
    }
    return false;
  }

  Future<bool> freezeActivity(
      BuildContext context, String activityStoreId) async {
    bool checkInternetConnection = await AppHelper.checkInternetConnection();
    if (!checkInternetConnection) {
      SnakbarWidgets.error(
          context,
          AppHelper.returnText(context, "There is no network connection",
              "لا يوجد اتصال بالشبكة"));
      return false;
    }

    DocumentSnapshot<Map<String, dynamic>> activityQuery =
        await store.collection(collection).doc(activityStoreId).get();

    if (activityQuery.data()!["userId"] == auth.currentUser!.uid) {
      await activityQuery.reference.update({
        "isActive": false,
      });

      return true;
    }
    return false;
  }

  Future<bool> activateActivity(
      BuildContext context, String activityStoreId) async {
    bool checkInternetConnection = await AppHelper.checkInternetConnection();
    if (!checkInternetConnection) {
      SnakbarWidgets.error(
          context,
          AppHelper.returnText(context, "There is no network connection",
              "لا يوجد اتصال بالشبكة"));
      return false;
    }

    DocumentSnapshot<Map<String, dynamic>> activityQuery =
        await store.collection(collection).doc(activityStoreId).get();

    if (activityQuery.data()!["userId"] == auth.currentUser!.uid) {
      await activityQuery.reference.update({
        "isActive": true,
      });

      return true;
    }
    return false;
  }

  String mainDisplayImage(List images) {
    String mainImage = "";

    if (images
            .where((element) => element.toString().contains("main"))
            .toList()
            .length !=
        0) {
      mainImage = images
          .where((element) => element.toString().contains("main"))
          .toList()[0];
    } else if (images
            .where((element) => element.toString().contains("regu"))
            .toList()
            .length !=
        0) {
      mainImage = images
          .where((element) => element.toString().contains("regu"))
          .toList()[0];
    } else {
      if (images.isNotEmpty) {
        mainImage = images[0];
      }
    }

    return mainImage;
  }

  // !!!!!!!!!! Search :

  Future<List<ActivitySchema>> searchForActivityByCategory(
      String searchKeys) async {
    print(searchKeys);
    List<ActivitySchema> topDocuments = [];
    try {
      if (searchKeys == "Discover all") {
        QuerySnapshot<Map<String, dynamic>> verifiedDocsQuerySnapshot =
            await store
                .collection(collection)
                .where("disabled", isEqualTo: false)
                .where("isActive", isEqualTo: true)
                .where('verified', isEqualTo: true)
                .orderBy('likesCount', descending: true)
                .orderBy('viewsCount', descending: true)
                .get();

        for (var doc in verifiedDocsQuerySnapshot.docs) {
          Map a = doc.data();

          a["storeId"] = doc.id;
          topDocuments.add(ActivitySchema.toSchema(a));
        }
        QuerySnapshot<Map<String, dynamic>> nonVerifiedDocsQuerySnapshot =
            await store
                .collection(collection)
                .where("disabled", isEqualTo: false)
                .where("isActive", isEqualTo: true)
                .where('verified', isEqualTo: false)
                .orderBy('likesCount', descending: true)
                .orderBy('viewsCount', descending: true)
                .get();

        for (var doc in nonVerifiedDocsQuerySnapshot.docs) {
          Map a = doc.data();
          a["storeId"] = doc.id;
          topDocuments.add(ActivitySchema.toSchema(a));
        }
      } else {
        QuerySnapshot<Map<String, dynamic>> verifiedDocsQuerySnapshot =
            await store
                .collection(collection)
                .where("disabled", isEqualTo: false)
                .where("category", isEqualTo: searchKeys)
                .where("isActive", isEqualTo: true)
                .where('verified', isEqualTo: true)
                .orderBy('likesCount', descending: true)
                .orderBy('viewsCount', descending: true)
                .get();

        for (var doc in verifiedDocsQuerySnapshot.docs) {
          Map a = doc.data();
          a["storeId"] = doc.id;
          topDocuments.add(ActivitySchema.toSchema(a));
        }

        QuerySnapshot<Map<String, dynamic>> nonVerifiedDocsQuerySnapshot =
            await store
                .collection(collection)
                .where("disabled", isEqualTo: false)
                .where("category", isEqualTo: searchKeys)
                .where("isActive", isEqualTo: true)
                .where('verified', isEqualTo: false)
                .orderBy('likesCount', descending: true)
                .orderBy('viewsCount', descending: true)
                .get();

        for (var doc in nonVerifiedDocsQuerySnapshot.docs) {
          Map a = doc.data();
          a["storeId"] = doc.id;
          topDocuments.add(ActivitySchema.toSchema(a));
        }
      }
      // topDocuments = [...verifiedDocs, ...nonVerifiedDocs];
    } catch (error) {
      print('Error getting top documents: $error');
    }

    return topDocuments;
  }
}
