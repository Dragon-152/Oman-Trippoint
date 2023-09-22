import 'package:oman_trippoint/helpers/adHelper.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/screens/ContactUsScreen.dart';
import 'package:oman_trippoint/screens/VertifyEmailScreen.dart';
import 'package:oman_trippoint/screens/changeLanguageScreen.dart';
import 'package:oman_trippoint/screens/deleteAccountScreen.dart';
import 'package:oman_trippoint/screens/editProfileScreen.dart';
import 'package:oman_trippoint/screens/forgotPasswordScreen.dart';
import 'package:oman_trippoint/screens/getStartedScreen.dart';
import 'package:oman_trippoint/screens/notificationSceen.dart';
import 'package:oman_trippoint/screens/overViewScreen.dart';
import 'package:oman_trippoint/screens/ownerActivitiesScreen.dart';
import 'package:oman_trippoint/screens/policyAndPrivacyScreen.dart';
import 'package:oman_trippoint/screens/proAccount/switchToProAccountScreen.dart';
import 'package:oman_trippoint/screens/supportUsScreen.dart';
import 'package:oman_trippoint/screens/termsAndConditionsScreen.dart';
import 'package:oman_trippoint/widgets/AdContainerWidget.dart';
import 'package:oman_trippoint/widgets/DiologsWidgets.dart';
import 'package:oman_trippoint/widgets/LinkWidget.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:oman_trippoint/widgets/listTitleWidget.dart';
import 'package:oman_trippoint/widgets/profileAvatarWidget.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import "package:easy_localization/easy_localization.dart";

class ProfileScreen extends StatefulWidget {
  static String router = "/profile";
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  bool isLoading = false;
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

  Future signout(UserProvider userProvider) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);

    bool done = await userProvider.signout(context);
    if (done) {
       FirebaseFunctions.instance
          .httpsCallable("increaseCountersAppStatistics")
          .call({
        "year": AppHelper.currentYear,
        "field": "usersLogOutCount",
      });

      Navigator.pushNamedAndRemoveUntil(
          context, OverviewScreen.router, (route) => false);
    }

    EasyLoading.dismiss();
  }

  void disposeAds() {
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    disposeAds();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    disposeAds();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    final auth = FirebaseAuth.instance;

    if (_interstitialAd != null) {
      _interstitialAd?.show();
    }

    print(auth.currentUser?.emailVerified);
    return SafeScreen(
        padding: 0,
        child: AbsorbPointer(
          absorbing: isLoading,
          child: Column(
            children: [
              AppBarWidget(
                  title:
                      AppHelper.returnText(context, "Profile", "الملف الشخصي")),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProfileAvatarWidget(
                                profileColor:
                                    userProvider.currentUser?.profileColor,
                                profileImagePath:
                                    userProvider.currentUser?.profileImagePath,
                              ),

                              // CircleAvatar(
                              //   child: Icon(
                              //     Icons.person,
                              //     size: 50,
                              //   ),
                              //   backgroundColor: Color(
                              //       userProvider.currentUser?.profileColor ??
                              //           0xFFFFE082),
                              //   radius: 40,
                              // ),
                              const SizedBox(
                                height: 10,
                              ),
                              userProvider.islogin()
                                  ? Text(
                                      userProvider.currentUser?.name ?? "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          userProvider.islogin()
                              ? LinkWidget(
                                  text: AppHelper.returnText(context,
                                      "Edit profile", "تعديل الملف الشخصي"),
                                  onPressed: () {
                                    disposeAds();

                                    Navigator.pushNamed(
                                        context, EditProfileScreen.router);
                                  })
                              : ElevatedButton(
                                  onPressed: () {
                                    disposeAds();

                                    Navigator.pushNamed(
                                        context, GetStartedScreen.router);
                                  },
                                  child: Text(AppHelper.returnText(
                                      context, "Login", "تسجيل الدخول"))),
                        ],
                      ),
                    ),

                    //   if (_bannerAd != null)
                    //     const SizedBox(
                    //       height: 20,
                    //     ),

                    //^---------------------- adverticment -----------------------

                    //   if (_bannerAd != null)
                    //     Container(
                    //       key: Key(const Uuid().v4()),
                    //       width: _bannerAd!.size.width.toDouble(),
                    //       height: _bannerAd!.size.height.toDouble(),
                    //       child: AdWidget(ad: _bannerAd!),
                    //     ),

                    const Adcontainer(),

                    //^----------------------------------------------------------

                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        AppHelper.returnText(
                            context, "Account Settings", "إعدادت الحساب"),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (userProvider.proCurrentUser != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                userProvider.currentUser?.isProAccount == true
                                    ? ColorsHelper.green
                                    : ColorsHelper.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(10),
                          child: userProvider.currentUser?.isProAccount == true
                              ? Text(AppHelper.returnText(
                                  context,
                                  "You can now publish tourist activities and chalets in the application. If you need any service, please contact customer service.",
                                  "يمكنك الان نشر الانشطة السياحية والشاليهات في التطبيق. اذا احتجت اي خدمة الرجاء التواصل مع خدمة العملاء."),
                                   style: TextStyle(
                                      color: Colors.white,
                                      decorationColor: Colors.white),
                                  )
                              : Text(
                                  AppHelper.returnText(
                                      context,
                                      "Wait six hours for approval from Trippoint team. Contact customer service if you encounter any problem",
                                      "انتظر ست ساعات حتى تتم الموافقة من فريق العمل. تواصل مع خدمة العملاء اذا واجهت اي مشكلة"),
                                  style: TextStyle(
                                      color: Colors.white,
                                      decorationColor: Colors.white),
                                ),
                        ),
                      ),
                    if (userProvider.proCurrentUser != null)
                      const SizedBox(
                        height: 10,
                      ),
                    if (userProvider.islogin() &&
                        auth.currentUser?.emailVerified == false &&
                        userProvider.currentUser?.email != null &&
                        userProvider.currentUser?.email != "")
                      ListTitleWidget(
                        title: AppHelper.returnText(context, "Verify Email",
                            "التحقق من البريد الإلكتروني"),
                        icon: Icons.verified,
                        onTap: () {
                          disposeAds();

                          Navigator.pushNamed(
                            context,
                            VertifyEmailScreen.router,
                          );
                        },
                      ),
                    // if (_isLogin)
                    //                     ListTitleWidget(
                    //                       title: "My Activities",
                    //                       icon: Icons.verified,
                    //                       onTap: () {
                    //                         Navigator.pushNamed(
                    //                           context,
                    //                           OwnerActivitesScreen.router,
                    //                         );
                    //                       },
                    //                     ),

                    if (userProvider.islogin())
                      (userProvider.currentUser?.isProAccount == false &&
                              userProvider.proCurrentUser == null
                          ? ListTitleWidget(
                              title: AppHelper.returnText(
                                  context,
                                  "Switch to Professional Account",
                                  "حول لحساب احترافي"),
                              icon: Icons.local_police_rounded,
                              onTap: () {
                                if (userProvider.proCurrentUser?.verified ==
                                        true &&
                                    userProvider
                                            .proCurrentUser?.activationStatus !=
                                        true) {
                                  DialogWidgets.nonActivatedProAccount(context);
                                  return;
                                }
                                disposeAds();

                                Navigator.pushNamed(
                                    context, SwitchToProAccountScreen.router);
                              },
                            )
                          : ListTitleWidget(
                              title: AppHelper.returnText(
                                  context,
                                  "Edit Your Professional Account",
                                  "تعديل الحساب الاحترافي"),
                              icon: Icons.local_police_rounded,
                              onTap: () {
                                if (userProvider.proCurrentUser?.verified ==
                                        true &&
                                    userProvider
                                            .proCurrentUser?.activationStatus !=
                                        true) {
                                  DialogWidgets.nonActivatedProAccount(context);
                                  return;
                                }
                                disposeAds();

                                Navigator.pushNamed(
                                    context, SwitchToProAccountScreen.router);
                              },
                            )),
                    if (userProvider.islogin() &&
                        userProvider.currentUser?.providerId == "password" &&
                        userProvider
                                .credentialUser!.providerData[0].providerId ==
                            "password")
                      ListTitleWidget(
                        title: AppHelper.returnText(context, "Reset Password",
                            "إعادة تعيين كلمة المرور"),
                        icon: Icons.vpn_key_rounded,
                        onTap: () {
                          disposeAds();

                          Navigator.pushNamed(
                              context, ForgotPasswordScreen.router);
                        },
                      ),
                    ListTitleWidget(
                      title:
                          AppHelper.returnText(context, "Support us", "ادعمنا"),
                      icon: Icons.attach_money_rounded,
                      onTap: () {
                        //   _showRewardedAd();
                        //
                        disposeAds();

                        Navigator.pushNamed(context, SupportUsScreen.router);
                      },
                    ),
                    ListTitleWidget(
                      title: AppHelper.returnText(context, "Language", "اللغة"),
                      icon: Icons.language,
                      onTap: () {
                        disposeAds();

                        Navigator.pushNamed(
                            context, ChangeLanguageScreen.router);
                      },
                    ),
                    ListTitleWidget(
                      title: AppHelper.returnText(
                          context, "Notification", "إشعار"),
                      icon: Icons.notifications_active_outlined,
                      onTap: () {
                        disposeAds();

                        Navigator.pushNamed(context, NotificationScreen.router);
                      },
                    ),

                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        AppHelper.returnText(context, "Support", "الدعم"),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTitleWidget(
                        title: AppHelper.returnText(
                            context,
                            "How Oman Trippoint works",
                            "كيف يعمل Trippoint عمان"),
                        icon: Icons.work_outline_rounded,
                        onTap: () {}),
                    // ListTitleWidget(
                    //     title: AppHelper.returnText(
                    //         context, "Get Help", "احصل على مساعدة"),
                    //     icon: Icons.help_outline_rounded,
                    //     onTap: () {}),
                    ListTitleWidget(
                        title: AppHelper.returnText(
                            context, "Contact us", "تواصل بنا"),
                        icon: Icons.contact_support_outlined,
                        onTap: () {
                          disposeAds();

                          Navigator.pushNamed(context, ContactUsScreen.router);
                        }),

                    //   if (_bannersAd[2] != null)
                    //     const SizedBox(
                    //       height: 20,
                    //     ),

                    //   //^---------------------- adverticment -----------------------

                    //   if (_bannersAd[2] != null)
                    //     Container(
                    //       key: Key(const Uuid().v4()),
                    //       width: _bannersAd[2]!.size.width.toDouble(),
                    //       height: _bannersAd[2]!.size.height.toDouble(),
                    //       child: AdWidget(ad: _bannersAd[2]!),
                    //     ),

                    //   //^----------------------------------------------------------
                    const SizedBox(
                      height: 30,
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        AppHelper.returnText(context, "Legal", "قانوني"),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTitleWidget(
                        title: "Privacy Policy".tr(),
                        icon: Icons.privacy_tip_outlined,
                        onTap: () {
                          disposeAds();

                          Navigator.pushNamed(
                              context, PolicyAndPrivacyScreen.router);
                        }),
                    ListTitleWidget(
                        title: "Terms and conditions".tr(),
                        icon: Icons.playlist_add_check_circle_outlined,
                        onTap: () {
                          disposeAds();

                          Navigator.pushNamed(
                              context, TermsAndConditionsScreen.router);
                        }),

                    const SizedBox(
                      height: 20,
                    ),
                    const Adcontainer(),
                    const SizedBox(
                      height: 20,
                    ),

                    if (userProvider.islogin())
                      ListTitleWidget(
                        title: AppHelper.returnText(
                            context, "Delete Account", "حذف الحساب"),
                        icon: Icons.delete_forever_rounded,
                        dang: true,
                        onTap: () {
                          disposeAds();

                          Navigator.pushNamed(
                              context, DeleteAccountScreen.router);
                        },
                      ),
                    const SizedBox(
                      height: 40,
                    ),
                    if (userProvider.currentUser != null)
                      LinkWidget(
                        text: "Log out".tr(),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          signout(userProvider);
                          setState(() {
                            isLoading = false;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
