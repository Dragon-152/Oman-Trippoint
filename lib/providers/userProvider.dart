import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oman_trippoint/constants/constants.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/errorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/schemas/notificationPieceSchema.dart';
import 'package:oman_trippoint/schemas/proUserSchema.dart';
import 'package:oman_trippoint/schemas/userSchema.dart';
import 'package:oman_trippoint/screens/accountCreatedScreen.dart';
import 'package:oman_trippoint/widgets/snakbarWidgets.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider with ChangeNotifier {
  User? credentialUser;
  UserSchema? currentUser;
  Map<String, UserSchema> users = {};
  Map<String, List<NotificationPieceSchema>> notificationMap = {};

  ProUserSchema? proCurrentUser;
  static String collection = CollectionsConstants.users;
  static final auth = FirebaseAuth.instance;
  static final store = FirebaseFirestore.instance;
  static final storage = FirebaseStorage.instance;

  final googleSignin = GoogleSignIn();

  static List fields = [
    "email",
    "name",
    "lastLogin",
    "createdAt",
    "Id",
    "phoneNumber",
    "deviceInfo",
    "displaySizes",
    "age",
    "gender",
    "ip",
  ];

  bool islogin() {
    try {
      if (credentialUser != null &&
          currentUser != null &&
          credentialUser!.uid != null &&
          currentUser!.Id != null &&
          credentialUser!.uid != "" &&
          currentUser!.Id != "" &&
          auth.currentUser != null &&
          auth.currentUser!.uid != "") {
        return true;
      }
      return false;
    } catch (err) {
      print("Have Not Login !!!!!!! ");
      return false;
    }
  }

  Future<UserSchema?> refreshUserData() async {
    try {
      QuerySnapshot<Object?> query = await FirebaseFirestore.instance
          .collection(collection)
          .where("Id", isEqualTo: currentUser!.Id)
          .get();

      Map userQueryData = query.docs.single.data() as Map;

      currentUser = UserSchema(
        wishlist: userQueryData["wishlist"],
        storeId: query.docs.single.reference.id,
        email: userQueryData["email"],
        name: userQueryData["name"],
        lastLogin: userQueryData["lastLogin"],
        createdAt: userQueryData["createdAt"],
        Id: userQueryData["Id"],
        providerId: userQueryData["providerId"],
        phoneNumber: userQueryData["phoneNumber"],
        deviceInfo: userQueryData["deviceInfo"],
        displaySizes: userQueryData["displaySizes"],
        dateOfBirth: userQueryData["dateOfBirth"],
        proAccount: userQueryData["proAccount"],
        isProAccount: userQueryData["isProAccount"],
        gender: userQueryData["gender"],
        chatList: userQueryData["chatList"],
        ip: userQueryData["ip"],
        city: userQueryData["city"],
        profileColor: userQueryData["profileColor"],
        profileImagePath: userQueryData["profileImagePath"],
      );

      if (currentUser!.isProAccount == true &&
          currentUser!.proAccount != null) {
        Map proUserQueryData = currentUser!.proAccount!;
        proCurrentUser = ProUserSchema(
          likes: proUserQueryData["likes"],
          instagram: proUserQueryData["instagram"],
          createdAt: proUserQueryData["createdAt"],
          userId: proUserQueryData["userId"],
          publicPhoneNumber: proUserQueryData["publicPhoneNumber"],
          publicEmail: proUserQueryData["publicEmail"],
          activationStatus: proUserQueryData["activationStatus"],
          verified: proUserQueryData["verified"],
        );
      }

      currentUser!.lastLogin = DateTime.now().millisecondsSinceEpoch;
    } catch (err) {
      print(err);
    }
  }

  Future<UserSchema?> fetchUserData({required String userId}) async {
    if (users[userId] == null) {
      QuerySnapshot<Map<String, dynamic>> u = await store
          .collection(UserProvider.collection)
          .where("Id", isEqualTo: userId.trim())
          .get();

      Map<String, dynamic> user = u.docs.single.data();

      Map? proAccount = user["proAccount"];
      ProUserSchema? proUserSchema;

      if (proAccount != null && user["isProAccount"]) {
        proUserSchema = ProUserSchema(
          createdAt: proAccount["createdAt"],
          userId: proAccount["userId"],
          publicPhoneNumber: proAccount["publicPhoneNumber"],
          instagram: proAccount["instagram"],
          publicEmail: proAccount["publicEmail"],
        );
      }
      //   print(proUserSchema?.toMap());
      users[userId] = UserSchema(
        // wishlist: ,
        proAccount: proUserSchema != null ? proUserSchema.toMap() : {},
        name: user["name"],
        Id: user["Id"],
        ip: user["ip"],
        profileColor: user["profileColor"],
        profileImagePath: user["profileImagePath"],
        isProAccount: user["isProAccount"],
      );
    }

    return users[userId];
  }

  Future<bool> checkEmailused(String email) async {
    bool isEmailUsed = true;
    await store
        .collection(collection)
        .where("email", isEqualTo: email.trim())
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        isEmailUsed = false;
      }
    }, onError: (err) {});

    return isEmailUsed;
  }

  Future<bool> signInWithApple(BuildContext context) async {
    try {
      // final appleIdCredential = await TheAppleSignIn.performRequests([
      //   AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      // ]);

      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleIdCredential != null) {
        // final AppleIdCredential idCredential = appleIdCredential!;

        if (appleIdCredential.email != null &&
            appleIdCredential.givenName != "") {
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: appleIdCredential.identityToken!,
            accessToken: appleIdCredential.authorizationCode,
          );
          // final userCredential =
          //     await _firebaseAuth.signInWithCredential(credential);

          UserCredential _credentialUser =
              await auth.signInWithCredential(credential);
          credentialUser = _credentialUser.user;

          if (_credentialUser.user != null) {
            await saveSignInUserData(
              context,
              _credentialUser.user!,
              sginup: false,
              sginupWithGoogle: true,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Theme.of(context).errorColor,
              content: const Text("You have problem when sign in, try agian"),
            ));
            return false;
          }

          return true;
        } else if (appleIdCredential.email == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Theme.of(context).errorColor,
            content: Text(AppHelper.returnText(
                context,
                "Email address not recognized. Try again",
                "لم يتم التعرف على عنوان البريد الإلكتروني. حاول ثانية")),
          ));
          final storage = FlutterSecureStorage();
          await storage.deleteAll();
        }
      }
      return false;
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).errorColor,
        content: Text(err.toString()),
      ));
    }
    return false;
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));
        // throw 404;
        return false;
      }

      final GoogleSignInAccount? googleUser = await googleSignin.signIn();

      if (googleUser != null) {
        // bool _usedEmail = await checkEmailNotused(googleUser.email);

        // if (_usedEmail) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        UserCredential _credentialUser =
            await auth.signInWithCredential(credential);
        credentialUser = _credentialUser.user;

        if (_credentialUser.user != null) {
          await saveSignInUserData(
            context,
            _credentialUser.user!,
            sginup: false,
            sginupWithGoogle: true,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Theme.of(context).errorColor,
            content: const Text("You have problem when sign in, try agian"),
          ));
        }

        return true;

        // }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).errorColor,
          content: const Text("You haven't signed in google"),
        ));
        return false;
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).errorColor,
        content: Text(err.toString()),
      ));
      return false;
    }
  }

  Future userManagerFirestore(
      String docConstant, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection(CollectionsConstants.manage_users)
        .doc(docConstant)
        .collection(AppHelper.currentYear.toString())
        .doc()
        .set(data);
  }

  Future switchToProAccount({
    required BuildContext context,
    required ProUserSchema proUserData,
    required String city,
    required int dateOfBirth,
    required String name,
  }) async {
    if (currentUser != null && credentialUser != null && islogin()) {
      try {
        if (currentUser == null) {
          throw 99;
        }
        // CollectionReference pro_usersCollection =
        //     store.collection(CollectionsConstants.pro_users);
        CollectionReference usersCollection =
            store.collection(CollectionsConstants.users);

        // pro_usersCollection.add(proUserData.toMap());

        QuerySnapshot<Object?> query =
            await usersCollection.where("Id", isEqualTo: currentUser!.Id).get();

        Map<String, Object?> userData = {
          "dateOfBirth": dateOfBirth,
          "name": name,
          "isProAccount": true,
          "city": city,
          "proAccount": proUserData.toMap(),
        };

        if (query.docs.length != 1) {
          throw 99;
        }
        print(userData);
        if (currentUser!.isProAccount == false) {
          await userManagerFirestore(DocConstants.switchToProAccount, {
            "userId": currentUser?.Id,
            "createdAt": DateTime.now().millisecondsSinceEpoch,
            "email": currentUser?.email,
            "phone": currentUser?.phoneNumber,
          });
          FirebaseFunctions.instance
              .httpsCallable("increaseCountersAppStatistics")
              .call({
            "year": AppHelper.currentYear,
            "field": "proUsersCount",
          });
        } else {
          await userManagerFirestore(DocConstants.editProAccount, {
            "userId": currentUser?.Id,
            "createdAt": DateTime.now().millisecondsSinceEpoch,
            "email": currentUser?.email,
            "phone": currentUser?.phoneNumber,
          });
          FirebaseFunctions.instance
              .httpsCallable("increaseCountersAppStatistics")
              .call({
            "year": AppHelper.currentYear,
            "field": "editProUsersCount",
          });
        }
        await query.docs.single.reference.update(userData);

        currentUser!.isProAccount = true;
        currentUser!.proAccount = proUserData.toMap();
        proCurrentUser = proUserData;

        //   updateUserSoreddata(context);

        notifyListeners();

        return true;
      } catch (err) {
        print(err);
        return false;
      }
    }
    return false;
  }

  Future<bool> addToWishlist(
      activityStoreId, activityId, ActivityProvider activityProvider) async {
    if (currentUser!.wishlist != null) {
      await store.collection(collection).doc(currentUser!.storeId).update({
        "wishlist": [...currentUser!.wishlist!, activityId]
      });

      await activityProvider.likeActivity(activityStoreId, activityId);

      // await query.reference.update({
      //   "wishlist": [...query.data()?["wishlist"], activityId]
      // });

      currentUser?.wishlist = [...currentUser!.wishlist!, activityId];

      return true;
    }
    return false; // !!!!!!
  }

  Future removeFromWishlist(activityId) async {
    if (currentUser!.wishlist != null) {
      await store.collection(collection).doc(currentUser!.storeId).update({
        "wishlist": [
          ...currentUser!.wishlist!.where((e) => e != activityId).toList()
        ]
      });

      // await query.reference.update({
      //   "wishlist": [...query.data()?["wishlist"], activityId]
      // });

      currentUser?.wishlist =
          currentUser!.wishlist!.where((e) => e != activityId).toList();
    }
  }

  void dTime(startTime) {
    final checkConnectionTime = DateTime.now();
    final checkConnectionDuration = checkConnectionTime.difference(startTime);
    print(' Time: ${checkConnectionDuration.inMilliseconds}ms');
  }

  Future<bool> saveSignInUserData(
    BuildContext context,
    User userData, {
    bool sginup = true,
    bool sginupWithGoogle = false,
    String name = "",
    bool signinWithPhoneNumber = false,
  }) async {
    try {
      final startTime1 = DateTime.now();

      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      dTime(startTime1);
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));

        return false;
      }
      final startTime2 = DateTime.now();

      CollectionReference usersCollection =
          store.collection(UserProvider.collection);
      QuerySnapshot<Object?> query;
      if (signinWithPhoneNumber) {
        query = await usersCollection
            .where("phoneNumber", isEqualTo: userData.phoneNumber)
            .get();
      } else {
        query = await usersCollection
            .where("email", isEqualTo: userData.email)
            .get();
      }
      dTime(startTime2);

      if (query.docs.isEmpty && (sginup || sginupWithGoogle)) {
        final startTime3 = DateTime.now();

        final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        BaseDeviceInfo deviceInfo = await deviceInfoPlugin.deviceInfo;

        dTime(startTime3);

        final startTime4 = DateTime.now();

        final ipv4 = "";
        // final ipv4 = await Ipify.ipv4();
        dTime(startTime4);

        currentUser = UserSchema(
            // storeId: ,
            wishlist: [],
            email: userData.email,
            name: userData.displayName ?? name,
            lastLogin: DateTime.now().millisecondsSinceEpoch,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            Id: userData.uid,
            providerId: userData.providerData[0].providerId,
            phoneNumber: userData.phoneNumber,
            deviceInfo: deviceInfo.toMap(),
            proAccount: null,
            displaySizes:
                "${MediaQuery.of(context).size.width} ${MediaQuery.of(context).size.height}",
            dateOfBirth: null,
            gender: null,
            chatList: [],
            ip: ipv4,
            profileImagePath: userData.photoURL);

        final startTime5 = DateTime.now();

        DocumentReference<Object?> queryCurrentUserDoc =
            await usersCollection.add(currentUser!.toMap());

        dTime(startTime5);

        currentUser?.storeId = queryCurrentUserDoc.id;

        final startTime6 = DateTime.now();

        FirebaseFunctions.instance
            .httpsCallable("increaseCountersAppStatistics")
            .call({
          "year": AppHelper.currentYear,
          "field": "usersCount",
        });
        dTime(startTime6);

        notifyListeners();
      } else if (query.docs.length > 1) {
        print("ERROR");
        await AppHelper.sendError(
            ErrorsHelper.errMultiEmailes,
            "multi users with same email or phone number",
            saveSignInUserData.toString(),
            query.docs.map((e) => e.data()).toList());
      } else if ((query.docs[0]["email"] == userData.email ||
              query.docs[0]["phoneNumber"] == userData.phoneNumber) &&
          query.docs[0]["Id"] == userData.uid &&
          (!sginup || sginupWithGoogle)) {
        await query.docs.single.reference
            .update({"lastLogin": DateTime.now().millisecondsSinceEpoch});

        Map userQueryData = query.docs.single.data() as Map;

        print(userQueryData);
        print(userQueryData["city"]);

        /// ! check user id equal for it in authntication.

        currentUser = UserSchema(
          wishlist: userQueryData["wishlist"],
          storeId: query.docs.single.reference.id,
          email: userQueryData["email"],
          name: userQueryData["name"],
          lastLogin: userQueryData["lastLogin"],
          createdAt: userQueryData["createdAt"],
          Id: userQueryData["Id"],
          providerId: userQueryData["providerId"],
          phoneNumber: userQueryData["phoneNumber"],
          deviceInfo: userQueryData["deviceInfo"],
          displaySizes: userQueryData["displaySizes"],
          dateOfBirth: userQueryData["dateOfBirth"],
          proAccount: userQueryData["proAccount"],
          isProAccount: userQueryData["isProAccount"],
          gender: userQueryData["gender"],
          chatList: userQueryData["chatList"],
          ip: userQueryData["ip"],
          city: userQueryData["city"],
          profileColor: userQueryData["profileColor"],
          profileImagePath: userQueryData["profileImagePath"],
        );

        if (currentUser!.isProAccount == true &&
            currentUser!.proAccount != null) {
          Map proUserQueryData = currentUser!.proAccount!;
          proCurrentUser = ProUserSchema(
            likes: proUserQueryData["likes"],
            instagram: proUserQueryData["instagram"],
            createdAt: proUserQueryData["createdAt"],
            userId: proUserQueryData["userId"],
            publicPhoneNumber: proUserQueryData["publicPhoneNumber"],
            publicEmail: proUserQueryData["publicEmail"],
            activationStatus: proUserQueryData["activationStatus"],
            verified: proUserQueryData["verified"],
          );
        }

        currentUser!.lastLogin = DateTime.now().millisecondsSinceEpoch;

        notifyListeners();
      }
      return true;
    } catch (err) {
      SnakbarWidgets.error(context, err.toString());
    }
    return false;
  }

  Future updateUserSoreddata(context) async {
    try {
      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));
        return false;
      }
      if (currentUser != null) {
        CollectionReference usersCollection =
            store.collection(UserProvider.collection);
        DocumentSnapshot<Object?> query =
            await usersCollection.doc(currentUser!.storeId!).get();

        Map userQueryData = query.data() as Map;
        if ((userQueryData["email"] == credentialUser!.email ||
                userQueryData["phoneNumber"] == credentialUser!.phoneNumber) &&
            userQueryData["Id"] == credentialUser!.uid) {
          print(userQueryData);
          print(userQueryData["city"]);

          /// ! check user id equal for it in authntication.

          currentUser = UserSchema(
            wishlist: userQueryData["wishlist"],
            storeId: query.reference.id,
            email: userQueryData["email"],
            name: userQueryData["name"],
            lastLogin: userQueryData["lastLogin"],
            createdAt: userQueryData["createdAt"],
            Id: userQueryData["Id"],
            providerId: userQueryData["providerId"],
            phoneNumber: userQueryData["phoneNumber"],
            deviceInfo: userQueryData["deviceInfo"],
            displaySizes: userQueryData["displaySizes"],
            dateOfBirth: userQueryData["dateOfBirth"],
            proAccount: userQueryData["proAccount"],
            isProAccount: userQueryData["isProAccount"],
            gender: userQueryData["gender"],
            chatList: userQueryData["chatList"],
            ip: userQueryData["ip"],
            city: userQueryData["city"],
            profileColor: userQueryData["profileColor"],
            profileImagePath: userQueryData["profileImagePath"],
          );

          if (currentUser!.isProAccount == true &&
              currentUser!.proAccount != null) {
            Map proUserQueryData = currentUser!.proAccount!;
            proCurrentUser = ProUserSchema(
              likes: proUserQueryData["likes"],
              instagram: proUserQueryData["instagram"],
              createdAt: proUserQueryData["createdAt"],
              userId: proUserQueryData["userId"],
              publicPhoneNumber: proUserQueryData["publicPhoneNumber"],
              publicEmail: proUserQueryData["publicEmail"],
              activationStatus: proUserQueryData["activationStatus"],
              verified: proUserQueryData["verified"],
            );
          }
        }
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> deleteAccount(
    BuildContext context,
  ) async {
    try {
      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));
        return false;
      }
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      ActivityProvider activityProvider =
          Provider.of<ActivityProvider>(context, listen: false);

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await store
          .collection(collection)
          .where("Id", isEqualTo: currentUser!.Id)
          .get();

      List<ActivitySchema>? userActivities = await activityProvider
          .fetchUserActivities(context, userProvider.currentUser?.Id);

      if (userActivities != null) {
        for (ActivitySchema activity in userActivities) {
          await activityProvider.deleteActivity(context, activity.storeId!);
        }
      }

      if (querySnapshot.docs.length > 1) {
        // !!!!!!!!!!
        print("more Than one");
        return false;
      }

      if (userProvider.currentUser!.providerId == "google.com") {
        GoogleSignInAccount? googleUser = await googleSignin.signInSilently();
        GoogleSignInAuthentication googleAuth =
            await googleUser!.authentication;
        AuthCredential _credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        if (_credential != null) {
          await credentialUser!.reauthenticateWithCredential(_credential);
        }
      }

      await credentialUser!.delete();

      if (querySnapshot.docs.length == 1) {
        await googleSignin.currentUser!.clearAuthCache();

        querySnapshot.docs[0].reference.delete();
      }

      await signout(context);
      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  // signUp
  Future signup(BuildContext context, {email, password, name}) async {
    // currentUser
    try {
      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));
        return false;
      }
      UserCredential _credentialUser = await auth
          .createUserWithEmailAndPassword(email: email, password: password);

      credentialUser = _credentialUser.user;

      if (_credentialUser.user != null) {
        await saveSignInUserData(
          context,
          _credentialUser.user!,
          sginup: true,
          name: name,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).errorColor,
          content:
              const Text("You have problem when create account, try agian"),
        ));
        return false;
      }
    } on FirebaseAuthException catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).errorColor,
        content: Text(err.message.toString()),
      ));
      return false;
    } catch (err) {
      print(err);
      return false;
    }
    return true;
  }

  Future<bool> signout(BuildContext context) async {
    try {
      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      print(checkInternetConnection);
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));
        return false;
      }
      await googleSignin.disconnect();
      print("disconnect");
      await googleSignin.signOut();
      await auth.signOut();
      print("signout");
      credentialUser = null;
      currentUser = null;

      notifyListeners();
    } catch (err) {
      return false;
    }
    return true;
  }

  // signUp
  Future login(BuildContext context, {email, password}) async {
    // currentUser
    try {
      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));
        return false;
      }

      UserCredential _credentialUser = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      credentialUser = _credentialUser.user;

      if (_credentialUser.user != null) {
        await saveSignInUserData(
          context,
          _credentialUser.user!,
          sginup: false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).errorColor,
          content:
              const Text("You have problem when login to account, try agian"),
        ));
        return false;
      }
    } on FirebaseAuthException catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).errorColor,
        content: Text(err.message.toString()),
      ));
      return false;
    } catch (err) {
      return false;
    }
    return true;
  }

//   Future verifyPhoneNumber(String phoneNumber) async {
//   }

//    // signUp
//   Future sgininWithPhoneNumber(BuildContext context, {email, password}) async {
//     // currentUser
//     try {
//       UserCredential _credentialUser = await auth.signInWithPhoneNumber(
//           email: email, password: password);

//       credentialUser = _credentialUser.user;

//       if (_credentialUser.user != null) {
//         await saveSignInUserData(context, _credentialUser.user!, sginup: false,);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           backgroundColor: Theme.of(context).errorColor,
//           content:
//               const Text("You have problem when login to account, try agian"),
//         ));
//         return false;
//       }
//     } on FirebaseAuthException catch (err) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         backgroundColor: Theme.of(context).errorColor,
//         content: Text(err.message.toString()),
//       ));
//       return false;
//     } catch (err) {
//       return false;
//     }
//     return true;
//   }

  Future<bool> updateEmail(context, String newEmail) async {
    try {
      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));
        return false;
      }
      if (newEmail != null) {
        QuerySnapshot<Map<String, dynamic>> query2 = await store
            .collection(collection)
            .where("email", isEqualTo: newEmail)
            .get();
        if (query2.docs.length > 1) {
          SnakbarWidgets.error(
              context,
              AppHelper.returnText(context, "Another user with same email",
                  "مستخدم أخر مسجل بنفس البريد الإلكتروني"));
          throw 99;
        }
      }

      await credentialUser!.updateEmail(newEmail);
      await store.collection(collection).doc(currentUser!.storeId).update({
        "email": newEmail,
      });

      currentUser!.email = newEmail;
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> updateUserInfo(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));
        return false;
      }

      Map<String, dynamic> updatedData = {};

      data.map((key, value) {
        if (["name", "phoneNumber", "dateOfBirth"].contains(key.trim())) {
          updatedData[key] = value;
        }
        return MapEntry(key, value);
      });

      if (updatedData["phoneNumber"] != null) {
        QuerySnapshot<Map<String, dynamic>> query2 = await store
            .collection(collection)
            .where("phoneNumber", isEqualTo: updatedData["phoneNumber"])
            .get();
        if (query2.docs.length > 1) {
          SnakbarWidgets.error(
              context,
              AppHelper.returnText(
                  context,
                  "Another user with same phone number",
                  "مستخدم أخر مسجل بنفس رقم الهاتف"));
          throw 99;
        }
      }

      await store
          .collection(collection)
          .doc(currentUser?.storeId)
          .update(updatedData);

      for (String k in data.keys) {
        if (k == "phoneNumber") {
          currentUser!.phoneNumber = data[k];
        }
        if (k == "name") {
          currentUser!.name = data[k];
        }
        if (k == "dateOfBirth") {
          currentUser!.dateOfBirth = data[k];
        }
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> forgotPassword(
      {required BuildContext context, required String email}) async {
    try {
      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));
        return false;
      }
      await auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).errorColor,
        content: Text(err.message.toString()),
      ));
      return false;
    } catch (err) {
      return false;
    }
  }

  Future<bool> changeProfileImage(BuildContext context, String filePath) async {
    try {
      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));
        return false;
      }

      File file = File(filePath);

      if ((currentUser!.profileImagePath!
                      .split("users/${currentUser!.Id}/profileImage/")
                      .length ==
                  2 ||
              currentUser!.profileImagePath!
                      .split("users%2F${currentUser!.Id}%2FprofileImage%2F")
                      .length ==
                  2) &&
          currentUser!.profileImagePath! != "") {
        String imageName = currentUser!.profileImagePath!
                    .split("users/${currentUser!.Id}/profileImage/")
                    .length ==
                1
            ? currentUser!.profileImagePath!
                .split("users%2F${currentUser!.Id}%2FprofileImage%2F")[1]
                .split(".jpg")[0]
            : currentUser!.profileImagePath!
                .split("users/${currentUser!.Id}/profileImage/")[1]
                .split(".jpg")[0];
        Reference ref = storage
            .ref("users/${currentUser!.Id}/profileImage/${imageName}.jpg");

        await ref.delete();
      }

      Reference ref = storage.ref(
          "users/${currentUser!.Id}/profileImage/${const Uuid().v4()}.jpg");
      ref.putFile(file).then((taskSnapshot) async {
        String imageDownloadPath = await taskSnapshot.ref.getDownloadURL();

        await store.collection(collection).doc(currentUser!.storeId).update({
          "profileImagePath": imageDownloadPath,
        });

        currentUser!.profileImagePath = imageDownloadPath;
      });

      print("notifyListeners");
      notifyListeners();

      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> removeProfileImage(BuildContext context) async {
    try {
      bool checkInternetConnection = await AppHelper.checkInternetConnection();
      if (!checkInternetConnection) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "There is no network connection",
                "لا يوجد اتصال بالشبكة"));
        return false;
      }

      if ((currentUser!.profileImagePath!
                      .split("users/${currentUser!.Id}/profileImage/")
                      .length ==
                  2 ||
              currentUser!.profileImagePath!
                      .split("users%2F${currentUser!.Id}%2FprofileImage%2F")
                      .length ==
                  2) &&
          currentUser!.profileImagePath! != "") {
        String imageName = currentUser!.profileImagePath!
                    .split("users/${currentUser!.Id}/profileImage/")
                    .length ==
                1
            ? currentUser!.profileImagePath!
                .split("users%2F${currentUser!.Id}%2FprofileImage%2F")[1]
                .split(".jpg")[0]
            : currentUser!.profileImagePath!
                .split("users/${currentUser!.Id}/profileImage/")[1]
                .split(".jpg")[0];
        Reference ref = storage
            .ref("users/${currentUser!.Id}/profileImage/${imageName}.jpg");

        await ref.delete();
      }

      currentUser!.profileImagePath = "";

      await store
          .collection(collection)
          .doc(currentUser?.storeId)
          .update({"profileImagePath": ""});
      print("notifyListeners");

      notifyListeners();

      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<List> fetchNotifications() async {
    try {
      if (currentUser?.Id == null) {
        throw 99;
      }
      QuerySnapshot<Map<String, dynamic>> query1 =
          await store.collection(CollectionsConstants.events).get();

      notificationMap["events"] ?? (notificationMap["events"] = []);
      for (var doc in query1.docs) {
        print(doc.data());
        List checkList = notificationMap["events"]!
            .where((element) =>
                element.notificationId == doc.data()["notificationId"])
            .toList();
        if (checkList.isEmpty) {
          notificationMap["events"]
              ?.add(NotificationPieceSchema.toSchema(doc.data()));
        }
      }

      return notificationMap["events"] as List;
    } catch (err) {
      return [];
    }
  }
}
