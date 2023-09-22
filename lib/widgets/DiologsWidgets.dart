import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/screens/getStartedScreen.dart';
import 'package:oman_trippoint/screens/proAccount/switchToProAccountScreen.dart';
import 'package:flutter/material.dart';

class DialogWidgets {
  static void mustSginin(BuildContext context) {
    showDialog<void>(
      context: context,
      //   barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppHelper.returnText(
              context, 'You Havn\'t Sgin in', 'لم تقم بتسجيل الدخول')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppHelper.returnText(
                    context,
                    'You must sgin in first. Do this with easy steps.',
                    "يجب عليك تسجيل الدخول أولاً. قم بذلك بخطوات سهلة.")),
                // Text(''),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                  AppHelper.returnText(context, 'Sgin in', 'تسجيل الدخول')),
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, GetStartedScreen.router);
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void nonActivatedProAccount(BuildContext context) {
    showDialog<void>(
      context: context,
      //   barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppHelper.returnText(
              context, "Your account has been suspended", "تم ايقاف حسابك")),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppHelper.returnText(
                    context,
                    "We have suspended your account for violating the terms and conditions, you cannot post on this platform. Contact us to unblock the account",
                    "لقد قمنا بإيقاف حسابك بسبب مخالفة الشروط والاحكام، لا يمكنك النشر في هذه المنصة. تواصل معنا لالغاء حظر الحساب")),
                // Text(''),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppHelper.returnText(context, 'Ok', "حسنا")),
              onPressed: () {
                // Navigator.pushReplacementNamed(
                //     context, GetStartedScreen.router);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void mustProHaveVerified(BuildContext context) {
    showDialog<void>(
      context: context,
      //   barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppHelper.returnText(
              context, 'You must wait', "يجب عليك الانتظار")),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppHelper.returnText(
                    context,
                    'We will verify your account before you can post your tourism activity. it may up to 6 hours.',
                    "سوف نتحقق من حسابك قبل أن تتمكن من نشر نشاطك السياحي. قد يصل إلى 6 ساعات.")),
                // Text(''),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppHelper.returnText(context, 'Ok', "حسنا")),
              onPressed: () {
                // Navigator.pushReplacementNamed(
                //     context, GetStartedScreen.router);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void mustSwitchtoPro(BuildContext context) {
    showDialog<void>(
      context: context,
      //   barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppHelper.returnText(
              context, 'You Havn\'t Pro Account', "ليس لديك حساب احترافي")),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppHelper.returnText(
                    context,
                    'You must switch to profisional account, then you can create your own ads',
                    "يجب عليك التبديل إلى حساب احترافي ، وبعد ذلك يمكنك إنشاء إعلاناتك الخاصة")),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppHelper.returnText(
                  context, 'Switch to Pro', "التبديل إلى حساب احترافي")),
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, SwitchToProAccountScreen.router);
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  static void unsave(BuildContext context) {
      showDialog<void>(
      context: context,
      builder: (context) =>  AlertDialog(
        title:  Text(AppHelper.returnText(context,  'Are you sure?', "هل أنت متأكد؟")),
        content:   Text(AppHelper.returnText(context, 'Unsaved data will be lost.', 'سيتم فقد البيانات غير المحفوظة.') ),
        actions: <Widget>[
           ElevatedButton(
            onPressed: () => Navigator.pop(context), // Closes the dialog
            child:  Text(AppHelper.returnText(context, 'No', 'لا')),
          ),
           OutlinedButton(
            onPressed: () {
               Navigator.pop(context); // Closes the dialog
               Navigator.pop(context); // Closes the dialog
            },
            child:  Text(AppHelper.returnText(context, 'Yes', 'نعم')),
          ),
        ],
      ),
    );
  }
}
