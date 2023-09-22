import 'dart:io';

import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/screens/accountCreatedScreen.dart';
import 'package:oman_trippoint/screens/homeScreen.dart';
import 'package:oman_trippoint/screens/policyAndPrivacyScreen.dart';
import 'package:oman_trippoint/screens/signinPhoneNumberScreen.dart';
import 'package:oman_trippoint/screens/signinScreen.dart';
import 'package:oman_trippoint/screens/termsAndConditionsScreen.dart';
import 'package:oman_trippoint/widgets/LinkWidget.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import "package:easy_localization/easy_localization.dart";
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class GetStartedScreen extends StatefulWidget {
  static String router = "/getStarted";
  const GetStartedScreen({Key? key}) : super(key: key);

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  bool isLoading = false;
//   void loginWithGoogle() async {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return SafeScreen(
        child: AbsorbPointer(
            absorbing: isLoading,
            child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
            height: 30,
                    ),
                    Align(
            alignment: Alignment.center,
            child: Container(
              height: 200,
              width: 300,
              decoration: const BoxDecoration(
                //   color: Colors.grey,
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/categories/final logo 2.png",
                  ),
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
                    ),
                    Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Welcome !".tr(),
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppHelper.returnText(
                              context,
                              "By clicking Sign up you agree to our",
                              "بالنقر فوق تسجيل ، فإنك توافق على"),
                          // style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LinkWidget(
                              color: ColorsHelper.purple,
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, TermsAndConditionsScreen.router);
                              },
                              text: "Terms and conditions".tr(),
                            ),
                            Text(
                              "and".tr(),
                              // style: Theme.of(context).textTheme.bodySmall,
                            ),
                            LinkWidget(
                                color: ColorsHelper.purple,
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, PolicyAndPrivacyScreen.router);
                                },
                                text: "Privacy Policy".tr())
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                                if (Platform.isIOS) 
                                ElevatedButton(
                                onPressed:
                                
                                () async {
                                  EasyLoading.show(
                                      maskType: EasyLoadingMaskType.black);
                                  try {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    var validation = await userProvider
                                        .signInWithApple(context);
                  
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (validation == false) {
                                      throw 99;
                                    }
                  
                                    EasyLoading.showSuccess('Saved');
                  
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, HomeScreen.router, (route) {
                                      return false;
                                    });
                                  } catch (err) {
                                    print(err);
                                    EasyLoading.showError(AppHelper.returnText(
                                        context,
                                        "Something wrong",
                                        "حدث خطأ ما"));
                                  }
                                  // await Navigator.pushReplacementNamed(
                                  //     context, HomeScreen.router);
                                  await Future.delayed(
                                      const Duration(milliseconds: 500));
                  
                                  EasyLoading.dismiss();
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: ColorsHelper.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50)),
                                ),
                                child: SizedBox(
                                  //   width: 200,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          FontAwesomeIcons.apple,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          AppHelper.returnText(
                                              context,
                                              " Continue With Apple ",
                                              " متابعة من خلال أبل "),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ]),
                                ),
                              ),
                              if (Platform.isIOS) 
                              const SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  EasyLoading.show(
                                      maskType: EasyLoadingMaskType.black);
                                  try {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    var validation = await userProvider
                                        .signInWithGoogle(context);
                  
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (validation == false) {
                                      throw 99;
                                    }
                  
                                    EasyLoading.showSuccess('Saved');
                  
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, HomeScreen.router, (route) {
                                      return false;
                                    });
                                  } catch (err) {
                                    print(err);
                                    EasyLoading.showError(AppHelper.returnText(
                                        context,
                                        "Something wrong",
                                        "حدث خطأ ما"));
                                  }
                                  // await Navigator.pushReplacementNamed(
                                  //     context, HomeScreen.router);
                                  await Future.delayed(
                                      const Duration(milliseconds: 500));
                  
                                  EasyLoading.dismiss();
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: ColorsHelper.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50)),
                                ),
                                child: SizedBox(
                                  //   width: 200,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          FontAwesomeIcons.google,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          AppHelper.returnText(
                                              context,
                                              " Continue With Google ",
                                              " متابعة من خلال جوجل "),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ]),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, SigninScreen.router);
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: ColorsHelper.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50)),
                                ),
                                child: SizedBox(
                                  //   width: 200,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.email,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          AppHelper.returnText(
                                              context,
                                              " Continue With Email ",
                                              " متابعة بالبريد الإلكتروني "),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                  
                        const SizedBox(
                          height: 10,
                        ),
                  
                        //   OutlinedButton(
                        //     onPressed: () {
                        //       Navigator.pushNamed(context, SigninPhoneNumberScreen.router);
                        //     },
                        //     style: OutlinedButton.styleFrom(
                        //       primary: Colors.black87,
                        //       padding:
                        //           const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        //       side: const BorderSide(width: 2),
                        //     ),
                        //     child: const Text("Continue With Phone Number"),
                        //   ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
                    ),
                    LinkWidget(
              text: AppHelper.returnText(
                  context, "Join as Guest", "الانضمام كضيف"),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, HomeScreen.router,
                    (route) {
                  return false;
                });
              }),
                  ],
            ),
          ));
  }
}
