import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/screens/editProfileScreen.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class UpdateProfileDataScreen extends StatefulWidget {
  static String router = "update_profile";
  UpdateProfileDataScreen({super.key});

  @override
  State<UpdateProfileDataScreen> createState() =>
      _UpdateProfileDataScreenState();
}

class _UpdateProfileDataScreenState extends State<UpdateProfileDataScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  Map<String, dynamic> data = {};

  TextEditingController _input = TextEditingController();

  Future _submit(BuildContext context, bool isEmail) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      bool done = false;

      bool validation = _formKey.currentState!.validate();
      if (validation) {
        _formKey.currentState!.save();
        setState(() {
          _loading = true;
        });
        if (isEmail) {
          if (userProvider.currentUser?.providerId == "password" &&
              userProvider.credentialUser!.providerData[0].providerId ==
                  "password") {
            done = await userProvider.updateEmail(context, data["email"]);
          }
        } else {
          done = await userProvider.updateUserInfo(context, data);
        }

        setState(() {
          _loading = false;
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
    final _isEmail = ModalRoute.of(context)!.settings.arguments as bool;
    UserProvider userProvider = Provider.of<UserProvider>(context);
    _input.text = (_isEmail == true
            ? userProvider.currentUser!.email
            : userProvider.currentUser!.phoneNumber) ??
        "";
    // bool _isEmail = args;
    return SafeScreen(
      padding: 0,
      child: AbsorbPointer(
        absorbing: _loading,
        child: Column(children: [
          AppBarWidget(
            title: AppHelper.returnText(
                context,
                "Update " + (_isEmail ? "Email" : "Phone Number"),
                "تحديث " + (_isEmail ? "البريد الإلكتروني" : "رقم الهاتف")),
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

                // Text(AppHelper.returnText(
                //     context,
                //     "We'll send an email to confirm your email address.",
                //     "سنرسل بريدًا إلكترونيًا لتأكيد عنوان بريدك الإلكتروني.")),
                const SizedBox(
                  height: 10,
                ),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _input,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    obscureText: false,
                    decoration: InputDecoration(
                      hintText: _isEmail
                          ? AppHelper.returnText(
                              context, "Email", "بريد إلكتروني")
                          : AppHelper.returnText(
                              context, "Phone Number", "رقم الهاتف"),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        _isEmail ? Icons.email_rounded : Icons.phone_rounded,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black45,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black45,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    validator: (val) {
                      if (_isEmail) {
                        if (val == null ||
                            !EmailValidator.validate(val.trim(), true)) {
                          return AppHelper.returnText(
                              context,
                              "Invalid email address",
                              "عنوان البريد الإلكتروني غير صالح");
                        }
                        return null;
                      } else {
                        AppHelper.checkPhoneValidation(context, val);
                        if (val?.length != 8) {
                          return AppHelper.returnText(
                              context,
                              "Invalid phone number, try again",
                              "رقم الهاتف غير صالح ، حاول مرة أخرى");
                        }
                        return null;
                      }
                    },
                    onSaved: (val) {
                      _isEmail
                          ? data["email"] = val?.trim()
                          : data["phoneNumber"] = val?.trim();
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () async {
                      await _submit(context, _isEmail);
                    },
                    child: Text("Save".tr()))
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
