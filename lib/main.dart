import 'dart:io';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/helpers/placesProvider.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/chatProvider.dart';
import 'package:oman_trippoint/providers/settingsProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/userSchema.dart';
import 'package:oman_trippoint/screens/ContactOwnerScreen.dart';
import 'package:oman_trippoint/screens/ContactUsScreen.dart';
import 'package:oman_trippoint/screens/VertifyEmailScreen.dart';
import 'package:oman_trippoint/screens/accountCreatedScreen.dart';
import 'package:oman_trippoint/screens/accountDeletedScreen.dart';
import 'package:oman_trippoint/screens/activityCreatedScreen.dart';
import 'package:oman_trippoint/screens/activityDetailsScreen.dart';
import 'package:oman_trippoint/screens/activityStatisticsScreen.dart';
import 'package:oman_trippoint/screens/addActivityScreen.dart';
import 'package:oman_trippoint/screens/changeLanguageScreen.dart';
import 'package:oman_trippoint/screens/deleteAccountScreen.dart';
import 'package:oman_trippoint/screens/editActivityScreen.dart';
import 'package:oman_trippoint/screens/editProfileScreen.dart';
import 'package:oman_trippoint/screens/forgotPasswordScreen.dart';
import 'package:oman_trippoint/screens/getStartedScreen.dart';
import 'package:oman_trippoint/screens/homeScreen.dart';
import 'package:oman_trippoint/screens/mapScreen.dart';
import 'package:oman_trippoint/screens/massagesScreen.dart';
import 'package:oman_trippoint/screens/notificationSceen.dart';
import 'package:oman_trippoint/screens/overViewScreen.dart';
import 'package:oman_trippoint/screens/overviewAddActivityScreen.dart';
import 'package:oman_trippoint/screens/ownerActivitiesScreen.dart';
import 'package:oman_trippoint/screens/pickLocationScreen.dart';
import 'package:oman_trippoint/screens/policyAndPrivacyScreen.dart';
import 'package:oman_trippoint/screens/previewNewActivityScreen.dart';
import 'package:oman_trippoint/screens/proAccount/switchToProAccountScreen.dart';
import 'package:oman_trippoint/screens/profileScreen.dart';
import 'package:oman_trippoint/screens/reportActivityScreen.dart';
import 'package:oman_trippoint/screens/searchScreen.dart';
import 'package:oman_trippoint/screens/sendReviewScreen.dart';
import 'package:oman_trippoint/screens/signinPhoneNumberScreen.dart';
import 'package:oman_trippoint/screens/signinScreen.dart';
import 'package:oman_trippoint/screens/supportUsScreen.dart';
import 'package:oman_trippoint/screens/termsAndConditionsScreen.dart';
import 'package:oman_trippoint/screens/updateProfileDataScreen.dart';
import 'package:oman_trippoint/screens/viewEventsScreen.dart';
import 'package:oman_trippoint/screens/viewReviewsScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localization/localization.dart';
import 'package:oman_trippoint/widgets/loadingWidget.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import "package:firebase_core/firebase_core.dart";
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future load() async {
//   await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.white));
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();

  await MobileAds.instance.initialize();

//   FirebaseAppCheck firebaseAppCheck = FirebaseAppCheck.getInstance();
//         firebaseAppCheck.installAppCheckProviderFactory(
//         SafetyNetAppCheckProviderFactory.getInstance());

//   FlutterNativeSplash.remove();

//   load();

//   print(Intl.);
//   print(DateTime.now().millisecondsSinceEpoch);
//   print(DateFormat('MM/dd/yyyy, hh:mm a').format(
//       DateTime.fromMillisecondsSinceEpoch(
//           DateTime.now().millisecondsSinceEpoch)));

  runApp(const MainApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print(context.locale.toString());
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: SettingsProvider()),
        ChangeNotifierProvider.value(value: PlaceApiProvider()),
        ChangeNotifierProvider.value(value: UserProvider()),
        ChangeNotifierProvider.value(value: ChatProvider()),
        ChangeNotifierProvider.value(value: ActivityProvider()),
      ],
      child: const MApp(),
      // child: FutureBuilder(
      //     future: Firebase.initializeApp(),
      //     builder: (context, snapshot) {
      //       // Once complete, show your application
      //       if (snapshot.connectionState == ConnectionState.done) {
      //         return const MApp();
      //       }

      //       return const MMLoading();
      //       //   return const LoadingWidget();
      //     })

      //   AnimatedSplashScreen(splash: const MaterialApp(
      //         debugShowCheckedModeBanner: false,
      //         home: Scaffold(
      //           body: SafeArea(
      //             child: Center(
      //               child: CircularProgressIndicator(),
      //             ),
      //           ),
      //         ),
      //       ), nextScreen: const MApp(),),
    );
  }
}

class MApp extends StatelessWidget {
  const MApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    PlaceApiProvider placeApiProvider = Provider.of(context);
    placeApiProvider.init();

    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path:
          'assets/translations', // <-- change the path of the translation files
      fallbackLocale: settingsProvider.setting["language"],
      child: StreamBuilder(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, future) => const MMApp(),
      ),
    );

  }
}

class MMApp extends StatefulWidget {
  const MMApp({Key? key}) : super(key: key);

  @override
  State<MMApp> createState() => _MMAppState();
}

class _MMAppState extends State<MMApp> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  Map? _fireMessageData;
  double _totalNotifications = 1;

  void onSelectNotification(details, context) async {
    EasyLoading.show();
    try {
      ChatProvider chatProvider =
          Provider.of<ChatProvider>(context, listen: false);
      if (details.payload != null) {
        List router = details.payload!.split("|||");
        if (router[0] == "chat") {
          QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore
              .instance
              .collection("chat")
              .where((e) => e["Id"] == router[1])
              .get();
          List chatsData =
              await chatProvider.getChats(query: query, context: context);
          chatProvider.chat = chatsData[0];
          Navigator.pushNamed(context, MassagesScreen.router,
              arguments: chatsData[0]);
        }
      }

      // Navigator.push(
      //                   context,
      //                   MaterialPageRoute<void>(
      //                     builder: (BuildContext context) =>
      //                         MassagesScreen(),
      //                         settings: RouteSettings(arguments: chatsData[0])
      //                   ),

      //                 );
    } catch (err) {}
    await Future.delayed(const Duration(milliseconds: 500), () {});

    EasyLoading.dismiss();
  }

  void NotificationPermission(BuildContext) async {
    const String chatGroupKey = 'com.app.example.CHAT';

    try {
      //   UserProvider userProvider =
      //       Provider.of<UserProvider>(context, listen: false);
      print(await FirebaseMessaging.instance.getToken());
      print(FirebaseAuth.instance.currentUser?.uid.toString());
      //   assert(FirebaseAuth.instance.currentUser != null);

      // 3. On iOS, this helps to take the user permissions

      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (FirebaseAuth.instance.currentUser != null) {
          await _messaging.subscribeToTopic(
              FirebaseAuth.instance.currentUser!.uid.toString());
          if (Platform.isAndroid) {
            await _messaging.subscribeToTopic("android");
          } else if (Platform.isIOS) {
            await _messaging.subscribeToTopic("ios");
          }
        }

        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: true, // Required to display a heads up notification
          badge: true,
          sound: true,
        );

        AndroidNotificationChannel channel = const AndroidNotificationChannel(
          'high_importance_channel', // id
          'High Importance Notifications', //name
          description: 'This channel is used for important notifications.',
          importance: Importance.max,
        );

        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();

        //         FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        // FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings("@mipmap/ic_launcher");
        const DarwinInitializationSettings initializationSettingsDarwin =
            DarwinInitializationSettings(
                // onDidReceiveLocalNotification: onDidReceiveLocalNotification,
                );

        const InitializationSettings initializationSettings =
            InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );
        await flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (details) {
            print(details.payload);
            onSelectNotification(details, context);
          },
        );

        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

        FirebaseMessaging.onMessage.listen((RemoteMessage m) async {
     
          RemoteNotification? notification = m.notification;
          print(m.data);
          AndroidNotification? androidNotification = m.notification?.android;
          print({
            notification?.title,
            notification?.body,
          });
          if (m.data["type"] != null) {
            if (m.data["type"] == "chat") {

           
            await flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification?.title,
              notification?.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  icon: androidNotification?.smallIcon,
                  groupKey: chatGroupKey,
                ),
              ),
              payload: m.data["type"] + "|||" + m.data["chatId"],
            );
             }
          } else {
            await flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification?.title,
              notification?.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  icon: androidNotification?.smallIcon,
                  groupKey: chatGroupKey,
                ),
              ),
              payload: "" + "|||" + "",
            );
          }
        });

        //   Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
        //     print("Handling a background message: ${message.messageId}");
        //   }

        //   FirebaseMessaging.onBackgroundMessage(
        //       _firebaseMessagingBackgroundHandler);

        // _messaging.subscribeToTopic("chat");
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (err) {
      print("Error Notification");
      print(err);
    }
  }

  checkForInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _fireMessageData = {
        "title": initialMessage.notification?.title,
        "body": initialMessage.notification?.body,
      };
      _totalNotifications++;

      showSimpleNotification(
        Text(_fireMessageData?["title"]),
        // leading: NotificationBadge(totalNotifications: _totalNotifications),
        subtitle: Text(_fireMessageData?["body"]),
        background: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void doLocationPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
    ].request();
  }

  ThemeData themeData(BuildContext context) {
    return ThemeData(
        fontFamily: AppHelper.returnText(context, "", "Vazirmatn"),
        primarySwatch: ColorsHelper.green,
      
        // colorScheme: const ColorScheme.light(
        //   secondary: Colors.amber,
        // ),

        //   colorScheme: ColorScheme(
        //     brightness: Brightness.light,
        //     primary: ColorsHelper.yellow,
        //     onPrimary: Colors.black,
        //     secondary: Colors.black,
        //     // secondary: ColorsHelper.green,
        //     onSecondary: Colors.black,
        //     error: ColorsHelper.red,
        //     onError: Colors.black,
        //     background: Colors.white,
        //     onBackground: Colors.black38,
        //     surface: Colors.white,
        //     onSurface: Colors.black54,
        //   ),

        colorScheme: ColorScheme(
          brightness: Brightness.light,
          // primary: Colors.black,
          primary: ColorsHelper.yellow,
          onPrimary: Colors.black,
          secondary: Colors.black,
          // secondary: ColorsHelper.green,
          onSecondary: Colors.black,
          error: ColorsHelper.red,
          onError: Colors.black,
          background: Colors.white,
          onBackground: const Color(0xEE000000),
          surface: Colors.white,
          onSurface: const Color(0xEE000000),
          
        ),
        backgroundColor: Theme.of(context).hintColor,
        //   textTheme: const TextTheme(
        //     displayLarge: TextStyle(
        //       fontSize: 45,
        //     ),
        //     displayMedium: TextStyle(
        //       fontSize: 35,
        //     ),
        //     displaySmall: TextStyle(
        //       fontSize: 30,
        //     ),
        //     headlineSmall: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       color: Colors.black87,
        //     ),
        //     headlineMedium: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       fontSize: 25,
        //       color: Colors.black87,
        //     ),
        //     headlineLarge: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       color: Colors.black87,
        //     ),
        //     bodyLarge: TextStyle(
        //       fontSize: 22,
        //       color: Color(0xFF424242),
        //     ),
        //     bodyMedium: TextStyle(
        //       fontSize: 16,
        //       color: Color(0xFF424242),
        //     ),
        //     bodySmall: TextStyle(
        //       fontSize: 12,
        //       color: Color(0xFF424242),
        //     ),
        //     titleLarge: TextStyle(
        //       fontSize: 25,
        //       color: Color(0xFF424242), // Colors.gray[800]
        //     ),
        //     titleMedium: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       fontSize: 20,
        //       color: Color(0xFF424242), // Colors.gray[800]
        //     ),
        //     titleSmall: TextStyle(
        //       fontSize: 18,
        //       color: Color(0xFF424242), // Colors.gray[800]
        //     ),
        //   ),

        /*

      buttons: 
      font: 14, 18

      link:
      font: 16, underline

       */
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 34,
            //   fontWeight:
          ),
          displayMedium: TextStyle(
            fontSize: 28,
          ),
          displaySmall: TextStyle(
            fontSize: 20,
          ),
          headlineSmall: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xEE000000),
          ),
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xEE000000),
          ),
          headlineLarge: TextStyle(
            //   fontWeight: FontWeight.bold,
            color: Color(0xEE000000),
          ),
          bodyLarge: TextStyle(
            fontSize: 20,
            color: Colors.black, // Colors.gray[800]
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.black, // Colors.gray[800]
          ),
          bodySmall: TextStyle(
            //   fontSize: 12,
            fontSize: 13,
            color: Colors.black, // Colors.gray[800]
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            color: Colors.black, // Colors.gray[800]
          ),
          titleMedium: TextStyle(
            //   fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black, // Colors.gray[800]
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            color: Colors.black, // Colors.gray[800]
          ),
        ),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                // foregroundColor: Colors.black, // !!!!!!!!!
                textStyle: TextStyle(
                  fontFamily: AppHelper.returnText(context, "", "Vazirmatn"),
                  fontSize: 16,
                ))
            // style: ButtonStyle(
            //   elevation: MaterialStateProperty.all(0),
            //   textStyle: MaterialStateProperty.all(
            //     const TextStyle(
            //       fontSize: 18,
            //     ),

            ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            //   padding: MaterialStateProperty.all(
            //       EdgeInsets.symmetric(vertical: 10, horizontal: 30)),
            elevation: MaterialStateProperty.all(0),
            textStyle: MaterialStateProperty.all(TextStyle(
              fontFamily: AppHelper.returnText(context, "", "Vazirmatn"),
              fontSize: 16,
            )),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            //   padding:
            //       EdgeInsets.symmetric(vertical: 10, horizontal: 40),
            elevation: 0,
            foregroundColor: Colors.black,
            textStyle: TextStyle(
              fontFamily: AppHelper.returnText(context, "", "Vazirmatn"),
              color: Colors.black87,
              fontSize: 16,
              // fontWeight: FontWeight.bold,
            ),
            side: BorderSide(width: 2, color: Colors.black54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              // side: BorderSide(color: Colors.black54, width: 2),
            ),
          ),
        ),

      );
  }

  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

        var mySystemTheme = SystemUiOverlayStyle.light
 .copyWith(systemNavigationBarColor: Colors.white, statusBarColor: Colors.white, statusBarBrightness: Brightness.dark);
    SystemChrome.setSystemUIOverlayStyle(mySystemTheme);
    // doLocationPermission();
    // NotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    List p = [
      const Color(0xff6200ee), // primary
      const Color(0xff03dac6), // secondary
      const Color(0xffb00020), // error

      Colors.white, // background
      Colors.black, //onBackground
      Colors.white, // surface
      Colors.black, // onSurface

      const Color(0xff3700b3), // primaryVariant
      const Color(0xff018786), // secondaryVariant
    ];
    print("@@@ init main");
    NotificationPermission(context);



    return MaterialApp(
      title: 'Trippoint', // !
      theme: themeData(context),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: HomeScreen.router, 
      builder: EasyLoading.init(),
      routes: {
        HomeScreen.router: (_) =>   const HomeScreen(),
        OverviewScreen.router: (_) =>   const OverviewScreen(),
        GetStartedScreen.router: (_) =>   const GetStartedScreen(),
        SigninScreen.router: (_) =>   const SigninScreen(),
        PolicyAndPrivacyScreen.router: (_) =>   const PolicyAndPrivacyScreen(),
        TermsAndConditionsScreen.router: (_) =>
              const TermsAndConditionsScreen(),
        ContactUsScreen.router: (context) =>   const ContactUsScreen(),
        ActivityDetailsScreen.router: (_) =>   const ActivityDetailsScreen(),
        SigninPhoneNumberScreen.router: (context) =>
              const SigninPhoneNumberScreen(),
        MassagesScreen.router: (context) =>   const MassagesScreen(),
        SearchScreen.router: (context) =>   const SearchScreen(),
        ProfileScreen.router: (context) =>   const ProfileScreen(),
        EditProfileScreen.router: (context) =>   const EditProfileScreen(),
        UpdateProfileDataScreen.router: (context) =>   UpdateProfileDataScreen(),
        SwitchToProAccountScreen.router: (context) =>
              SwitchToProAccountScreen(),
        AddActivityScreen.router: (context) =>   const AddActivityScreen(),
        PickLocationSceen.router: (context) =>   const PickLocationSceen(),
        VertifyEmailScreen.router: (context) =>   const VertifyEmailScreen(),
        DeleteAccountScreen.router: (context) =>   const DeleteAccountScreen(),
        SendReviewScreen.router: (context) =>   SendReviewScreen(),
        ViewReviewScreen.router: (context) =>   const ViewReviewScreen(),
        ContactOwnerScreen.router: (context) =>   const ContactOwnerScreen(),
        ReportActivityScreen.router: (context) =>   const ReportActivityScreen(),
        MapScreen.router: (context) =>   const MapScreen(),
        ForgotPasswordScreen.router: (context) =>   ForgotPasswordScreen(),
        OwnerActivitesScreen.router: (context) =>   const OwnerActivitesScreen(),
        ActivityStatisticsScreen.router: (context) =>
              const ActivityStatisticsScreen(),
        EditActivityScreen.router: (context) =>   const EditActivityScreen(),
        ChangeLanguageScreen.router: (context) =>   const ChangeLanguageScreen(),
        AccountCreatedScreen.router: (context) =>   const AccountCreatedScreen(),
        AccountDeletedScreen.router: (context) =>   const AccountDeletedScreen(),
        ActivityCreatedScreen.router: (context) =>
              const ActivityCreatedScreen(),
        NotificationScreen.router: (context) =>   const NotificationScreen(),
        SupportUsScreen.router: (context) =>   const SupportUsScreen(),
        OverViewAddActivityScreen.router: (context) =>
              const OverViewAddActivityScreen(),
        PreviewNewActivityScreen.router: (context) =>
              const PreviewNewActivityScreen(),
              ViewEventsScreen.router: (_) =>  ViewEventsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MMLoading extends StatelessWidget {
  const MMLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Trippoint', // !
      home: LoadingWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}
