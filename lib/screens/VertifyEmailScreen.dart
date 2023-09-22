import 'dart:async';

import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class VertifyEmailScreen extends StatefulWidget {
  static String router = "vertify_email";
  const VertifyEmailScreen({super.key});

  @override
  State<VertifyEmailScreen> createState() => _VertifyEmailScreenState();
}

class _VertifyEmailScreenState extends State<VertifyEmailScreen> {
  final auth = FirebaseAuth.instance;
  bool _Enabled = true;
  bool isEmailVertified = FirebaseAuth.instance.currentUser!.emailVerified;
  Timer? timer;
  Duration _duration = const Duration(minutes: 5);
  final int reduceSecondsBy = 3;

  String strDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  Future _checkEmailVertified() async {
    await auth.currentUser?.reload();
    // if (isEmailVertified != fa;)
    setState(() {
      isEmailVertified = auth.currentUser!.emailVerified;
    });
  }

  Future _sendVertificationEmail() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);

    try {
      await auth.currentUser!.sendEmailVerification().then((value) =>
          EasyLoading.showSuccess(AppHelper.returnText(
              context, "Check Your Email", "تحقق من بريدك الالكتروني")));
      //   await auth.applyActionCode("1312");

      timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        setCountDown();
        _checkEmailVertified();
      });
    } catch (err) {
      print("error");
      print(err);
      EasyLoading.showError(
          AppHelper.returnText(context, "Something wrong", "حدث خطأ ما"));
    }
    await Future.delayed(const Duration(milliseconds: 1500));

    EasyLoading.dismiss();
  }

  void setCountDown() {
    setState(() {
      final seconds = _duration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        _Enabled = true;
        timer!.cancel();
        _duration = const Duration(minutes: 5);
      } else {
        _duration = Duration(seconds: seconds);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer?.cancel();

    // bool isEmailVertified = auth.currentUser!.emailVerified;

    // if (!isEmailVertified) {
    //   _sendVertificationEmail();
    //   //   timerCountdown = Timer.periodic(Duration(seconds: 1), callback)

    // }
  }

  @override
  void dispose() {
    // TODO: implement dispose

    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;

    final minutes = strDigits(_duration.inMinutes.remainder(60));
    final seconds = strDigits(_duration.inSeconds.remainder(60));

    print(isEmailVertified);

    return SafeScreen(
      padding: 0,
      child: Column(
        children: [
          AppBarWidget(
            title: AppHelper.returnText(
                context, "Verify  Email", "التحقق من البريد الإلكتروني"),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 100,
                    color: isEmailVertified
                        ? ColorsHelper.green
                        : ColorsHelper.orange,
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  isEmailVertified
                      ? Text(
                          AppHelper.returnText(
                              context,
                              "Your account verified successfully.",
                              "تم التحقق من حسابك بنجاح."),
                        )
                      : Text(
                          AppHelper.returnText(
                              context,
                              "Click verify and check you email. ",
                              "انقر التحقق وتحقق من بريدك الإلكتروني."),
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: !isEmailVertified
                        ? (_Enabled
                            ? () {
                                //
                                _sendVertificationEmail();
                                setState(() {
                                  _Enabled = false;
                                });
                              }
                            : null)
                        : null,
                    child:
                        Text(AppHelper.returnText(context, "Verify", "تحقق")),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "$minutes:$seconds",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
