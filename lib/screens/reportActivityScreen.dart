import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/providers/settingsProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/ReportSchema.dart';
import 'package:oman_trippoint/screens/getStartedScreen.dart';
import 'package:oman_trippoint/widgets/AdContainerWidget.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:oman_trippoint/widgets/inputTextFieldWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import "package:easy_localization/easy_localization.dart";

class ReportActivityScreen extends StatefulWidget {
  static String router = "reportActivity";
  const ReportActivityScreen({super.key});

  @override
  State<ReportActivityScreen> createState() => _ReportActivityScreenState();
}

class _ReportActivityScreenState extends State<ReportActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  Map data = {};
  bool isLoading = false;

  Future _submit(context, String activityId) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      SettingsProvider settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      bool validation = _formKey.currentState!.validate();

      if (validation && userProvider.islogin()) {
        _formKey.currentState?.save();

        setState(() {
          isLoading = true;
        });

        ReportSchema reportSchema = ReportSchema(
            Id: const Uuid().v4(),
            activityId: activityId,
            userId: userProvider.currentUser!.Id,
            phoneNumber: data["phoneNumber"],
            report: data["report"],
            reportFor: "activity",
            createdAt: DateTime.now().millisecondsSinceEpoch);
        bool done = await settingsProvider.sendReport(reportSchema);

        setState(() {
          isLoading = false;
        });

        if (done == false) {
          throw 99;
        }

        EasyLoading.showSuccess('Saved');

        Navigator.pop(context);
      }
    } catch (err) {
      print(err);
      EasyLoading.showError(
          AppHelper.returnText(context, "Something wrong", "حدث خطأ ما"));
    }
    await Future.delayed(const Duration(milliseconds: 1500));
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    String activityId = ModalRoute.of(context)?.settings.arguments as String;

    // if (userProvider.islogin()) return SafeScreen(
    //   padding: 0);

    return SafeScreen(
      padding: 0,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Column(
          children: [
            AppBarWidget(
                title: AppHelper.returnText(context, "Report", "إبلاغ")),
            userProvider.islogin()
                ? Expanded(
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                InputTextFieldWidget(
                                  keyboardType: TextInputType.number,
                                  text: data["phoneNumber"],
                                  labelText: AppHelper.returnText(context,
                                      "Phone Number *", "رقم الهاتف *"),
                                  //   labelStyle:,
                                  validator: (val) {
                                    AppHelper.checkPhoneValidation(
                                        context, val);
                                    if (val?.length != 8) {
                                      return AppHelper.returnText(
                                          context,
                                          "Invalid phone number",
                                          "رقم الهاتف غير صحيح");
                                    }
                                  },
                                  onSaved: (val) {
                                    data["phoneNumber"] = val?.trim();
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                InputTextFieldWidget(
                                  text: data["report"],
                                  labelText: AppHelper.returnText(
                                      context, "Report", "البلاغ"),
                                  minLines: 4,
                                  textInputAction: TextInputAction.newline,
                                  keyboardType: TextInputType.multiline,
                                  helperText: AppHelper.returnText(
                                      context,
                                      "What do you want to report? Be honest",
                                      "ما الذي تريد الإبلاغ عنه؟ كن صادقًا"),
                                  validator: (val) {
                                    if (val == null) {
                                      return AppHelper.returnText(
                                          context,
                                          "Use 3 characters or more",
                                          "استخدم 3 أحرف أو أكثر");
                                    }
                                    if (val.trim() == "" || val.length < 2) {
                                      return AppHelper.returnText(
                                          context,
                                          "Use 3 characters or more",
                                          "استخدم 2 أحرف أو أكثر");
                                    }

                                    if (val.length > 800)
                                      return "Too long".tr();

                                    return null;
                                  },
                                  onSaved: (val) {
                                    data["report"] = val?.trim();
                                  },
                                ),
                                const Adcontainer(),
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await _submit(context, activityId);
                                  },
                                  child: Text("Send".tr()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: Column(
                    children: [
                      const SizedBox(
                        height: 100,
                      ),
                      Text(AppHelper.returnText(
                          context,
                          "You should login first",
                          "يجب عليك تسجيل الدخول أولا")),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, GetStartedScreen.router);
                          },
                          child: Text("Login".tr())),
                    ],
                  )),
          ],
        ),
      ),
    );
  }
}
