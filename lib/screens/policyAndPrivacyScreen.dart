import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PolicyAndPrivacyScreen extends StatelessWidget {
  static String router = "/policy_privacy";
  const PolicyAndPrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeScreen(
      padding: 0,
      child: Column(children: [
        AppBarWidget(title: "Privacy Policy".tr()),
        Expanded(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: const [
              SizedBox(
                height: 30,
              ),
              Card(
                  child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(""" 
تطبيق  Oman Trippoint يركز على جزء من الترويج السياحي في عمان و يسعى لتطوير ذلك من خلال الاعلان عنها مجانا (لفترة محدودة) في منصة واحدة, المنصة تعمل كوسيط بين المستخدم و صاحب النشاط السياحي , ويمكن لأي مستخدم من مختلف دول العالم التسجيل في هذه المنصة للتعرف على الأنشطة السياحية في عمان.

توضح سياسة الخصوصية هذه كيف تعالج منصة Oman Trippoint المعلومات الشخصية المتعلقة باستخدام المنصة. اعتمادًا على ما تفعله على منصة.

المعلومات التي تجمع عند التسجيل كمستخدم عادي:

- الايميل: تسجل المنصة الايميل الخاص بك لكي تستطيع الرجوع لحسابك و الاحتفاظ ببيانات حسابك بأمان.
- الـ IP أو عنوانك في الشبكة : يجمع كبيانات احتياطية تؤدي لمعرفة الموقع بشكل دولي.
- معلومات عن الجهاز : يجمع كبيانات احتياطية بغرض تحسين المنصة, مثل: 
1. نوع الجهاز و إصداره 
2. قياسات الشاشة
3. إصدار أندرويد

المعلومات التي تدخل من قبل المستخدم عادي:
- العمر : تدخل لتعرف على مستخدمين المنصة 
- المدينة او الولاية: تدخل لتعرف على مستخدمين المنصة 
- رقم الهاتف: للتواصل مع المستخدم في حالة الضرورة

المعلومات التي تدخل من قبل صاحب النشاط: 
- حساب الانستجرام: إضافة حساب الانستجرام يقربك من عملائك ليتعرفوا على نشاطك السياحي اكثر و يثقوا بك. 
- الايميل العام: اذا ادخلته عند انشائك لحساب احترافي سيتم ملؤه تلقائيا عند انشائك لنشاط سياحي كطريقة للتواصل مع عملائك أو مع المنصة للموافقة على حسابك.
- الرقم العام: اذا ادخلته عند انشائك لحساب احترافي سيتم ملؤه تلقائيا عند انشائك لنشاط سياحي كطريقة للتواصل مع عملائك أو مع المنصة للموافقة على حسابك.


                    """),
              )),
            ],
          ),
        ),
      ]),

      //     child: Center(
      //   child: Text(
      //     "Policy Privacy".tr(),
      //     style: Theme.of(context).textTheme.titleLarge,
      //   ),
      // ),
    );
  }
}
