import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/screens/homeScreen.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:oman_trippoint/widgets/inputTextFieldWidget.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static String router = "forgot_password";
  ForgotPasswordScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  Map data = {};

  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Next Step'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Check your email.'),
                Text('We send link to reset the password'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                    context, HomeScreen.router, (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  Future _submit(context) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);

    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      bool validation = _formKey.currentState!.validate();
      if (validation) {
        _formKey.currentState!.save();

        bool done = await userProvider.forgotPassword(
            context: context, email: data["email"]);

        if (done == false) {
          throw 99;
        }

        _showSuccessDialog(context);
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
    return SafeScreen(
      padding: 0,
      child: Column(children: [
        AppBarWidget(
          title: AppHelper.returnText(
              context, "Reset Password", "إعادة تعيين كلمة المرور"),
        ),
        const SizedBox(
          height: 30,
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(AppHelper.returnText(
                  context,
                  "We'll send an email to reset the password.",
                  "سنرسل بريدًا إلكترونيًا لإعادة تعيين كلمة المرور.")),
              const SizedBox(
                height: 10,
              ),
              Form(
                key: _formKey,
                child: InputTextFieldWidget(
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  obscureText: false,
                  hintText: AppHelper.returnText(
                      context, "Email", "البريد الإلكتروني"),
                  prefixIcon: Icons.email_rounded,
                  validator: (val) {
                    if (val == null ||
                        !EmailValidator.validate(val.trim(), true)) {
                      return AppHelper.returnText(
                          context,
                          "Invalid email address",
                          "عنوان البريد الإلكتروني غير صالح");
                    }
                  },
                  onSaved: (val) {
                    data["email"] = val?.trim();
                  },
                ),
              ),
            ],
          ),
        ),
        Center(
          child: ElevatedButton(
            child: Text(AppHelper.returnText(context, "Send", "إرسال")),
            onPressed: () async {
              await _submit(context);
            },
          ),
        ),
      ]),
    );
  }
}
