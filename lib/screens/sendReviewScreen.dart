import 'dart:async';

import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/schemas/reviewSchema.dart';
import 'package:oman_trippoint/screens/viewReviewsScreen.dart';
import 'package:oman_trippoint/widgets/AdContainerWidget.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:oman_trippoint/widgets/inputTextFieldWidget.dart';
import 'package:oman_trippoint/widgets/ratingBarWidget.dart';
import 'package:oman_trippoint/widgets/snakbarWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

class SendReviewScreen extends StatefulWidget {
  static String router = "/sendReview";

  SendReviewScreen({super.key});

  @override
  State<SendReviewScreen> createState() => _SendReviewScreenState();
}

class _SendReviewScreenState extends State<SendReviewScreen> {
  final _formKey = GlobalKey<FormState>();

  Map data = {};

  bool _isLoading = false;

  Future _submit(context, ActivitySchema activitySchema) async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    ActivityProvider activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);
    bool validation = _formKey.currentState!.validate();
    if (validation && userProvider.islogin()) {
      EasyLoading.show(maskType: EasyLoadingMaskType.black);
      _formKey.currentState?.save();
      List totalUserReviews = activityProvider
              .activities[activitySchema.Id]?.reviews
              .where((r) => r["userId"] == userProvider.currentUser?.Id)
              .toList() ??
          [];
      if (
          userProvider.currentUser?.Id == activitySchema.userId) {
        await Future.delayed(Duration(milliseconds: 2000), () {});
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "You can't send review for yourself",
                "لا يمكنك إرسال مراجعة لنفسك"));
        EasyLoading.dismiss();
        return;
      }

      if (totalUserReviews.length >= 4 || activityProvider
              .activities[activitySchema.Id]!.reviews.length >= 100) {
 await Future.delayed(Duration(milliseconds: 2000), () {});
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "Reviews are turned off",
                "تم ايقاف المراجعات"));
        EasyLoading.dismiss();
        return;
      }
      setState(() {
        _isLoading = true;
      });
      ReviewSchecma reviewSchecma = ReviewSchecma(
        userId: userProvider.currentUser!.Id,
        Id: const Uuid().v4(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        rating: data["rating"],
        review: data["review"],
      );
      print(activitySchema.storeId);
      print(reviewSchecma.toMap());
      await activityProvider.sendReview(
          reviewSchecma, activitySchema.storeId!, activitySchema.Id);
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, ViewReviewScreen.router,
          arguments: activitySchema);
      await Future.delayed(Duration(milliseconds: 1000), () {});
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    ActivitySchema activitySchema =
        ModalRoute.of(context)?.settings.arguments as ActivitySchema;

    return SafeScreen(
      padding: 0,
      child: Column(children: [
        AppBarWidget(title: "Reviews".tr()),
        if (userProvider.islogin())
          Expanded(
            child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Reviews'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        RatingBarWidget(
                          init: (val) {
                            data["rating"] = val;
                          },
                          onRated: (val) {
                            data["rating"] = val;
                          },
                          size: 30,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: InputTextFieldWidget(
                            text: data["review"],
                            labelText: AppHelper.returnText(
                                context, "Review *", "مراجعة *"),
                            minLines: 4,
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,
                            helperText: AppHelper.returnText(
                                context,
                                "Review and support this activity",
                                "راجع ودعم هذا النشاط"),
                            validator: (val) {
                              if (val == null) {
                                return AppHelper.returnText(
                                    context,
                                    "Use 3 characters or more",
                                    "استخدم 3 أحرف أو أكثر");
                              }
                              if (val.trim() == "" || val.length < 3) {
                                return AppHelper.returnText(
                                    context,
                                    "Use 3 characters or more",
                                    "استخدم 3 أحرف أو أكثر");
                              }
                              if (val.length > 200) return "Too long".tr();
                              return null;
                            },
                            onSaved: (val) {
                              data["review"] = val?.trim();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Adcontainer(),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  await _submit(context, activitySchema);
                                },
                          child: Text(
                              AppHelper.returnText(context, "send", "إرسال")),
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
      ]),
    );
  }
}
