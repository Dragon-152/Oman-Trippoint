import 'package:firebase_auth/firebase_auth.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/screens/accountDeletedScreen.dart';
import 'package:oman_trippoint/screens/getStartedScreen.dart';
import 'package:oman_trippoint/screens/homeScreen.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:oman_trippoint/widgets/inputTextFieldWidget.dart';
import 'package:oman_trippoint/widgets/textButtonWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  static String router = "delete_account";
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final Map data = {};

  Future<bool> _submit(context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool validation = _formKey.currentState!.validate();
    bool done = false;

    if (validation) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      if (data != {}) {
        // done = await userProvider.login(
        //   context,
        //   email: userProvider.currentUser!.email,
        //   password: data["password1"],
        // );
        
      UserCredential _credentialUser = await UserProvider.auth.signInWithEmailAndPassword(
          email:  userProvider.currentUser!.email!, password: data["password1"]);
if (_credentialUser.credential != null) {

          await userProvider.credentialUser!.reauthenticateWithCredential(_credentialUser.credential!);
}
      }
    }

    return done;
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return SafeScreen(
        child: AbsorbPointer(
      absorbing: isLoading,
      child: Column(
        children: [
          AppBarWidget(
              title: AppHelper.returnText(
                  context, "Delete Your Account", "حذف  الحساب")),
          Expanded(
              child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const SizedBox(
                height: 30,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (userProvider.currentUser?.providerId == "password" &&
                        userProvider
                                .credentialUser?.providerData[0].providerId ==
                            "password")
                      Column(
                        children: [
                          InputTextFieldWidget(
                            //   obscureText: true,
                            labelText: "Password",
                            prefixIcon: Icons.key_rounded,
                            validator: (val) {
                              if (val == null)
                                return AppHelper.returnText(
                                    context,
                                    "Use 6 characters or more for your password",
                                    "إستخدم 6 حروف أو أكثر");
                              if (val.trim() == "" || val.length < 6) // mono
                                return AppHelper.returnText(
                                    context,
                                    "Use 6 characters or more for your password",
                                    "إستخدم 6 حروف أو أكثر");

                              return null;
                            },
                            onChanged: (val) {
                              data["password1"] = val.trim();
                            },
                            onSaved: (val) {
                              data["password1"] = val?.trim();
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextButtonWidget(
                              text: AppHelper.returnText(context,
                                  "forget password?", "نسيت كلمة المرور"),
                              onPressed: () {
                                print("yes ...............");
                              }),
                        ],
                      ),
                    Text(AppHelper.returnText(
                        context,
                        "Your account will be deleted. you cannot restore your account.",
                        "سيتم حذف حسابك. لن تتمكن من إستعادة حسابك لاحقا")),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: ColorsHelper.orange),
                        onPressed: () async {
                          EasyLoading.show();
                          try {
                            bool islogin = false;
                            if (userProvider.currentUser?.providerId ==
                                "password") {
                              islogin = await _submit(context);
                            } else {
                              islogin = true;
                            }
                            if (islogin) {
                              setState(() {
                                isLoading = true;
                              });
                              print(islogin);
                              bool done =
                                  await userProvider.deleteAccount(context);

                              setState(() {
                                isLoading = false;
                              });
                              if (done == false) {
                                throw 99;
                              }
                              // Navigator.pushNamedAndRemoveUntil(context,
                              //     GetStartedScreen.router, (route) => false);
                              //   Navigator.pushReplacementNamed(context, AccountDeletedScreen.router);
                              EasyLoading.showSuccess('Saved');
                              Navigator.pushNamedAndRemoveUntil(
                                  context, AccountDeletedScreen.router,
                                  (route) {
                                return false;
                              });
                            }
                          } catch (err) {
                            print(err);
                            EasyLoading.showError(AppHelper.returnText(
                                context, "Something wrong", "حدث خطأ ما"));
                          }
                          await Future.delayed(
                              const Duration(milliseconds: 1500));
                          EasyLoading.dismiss();
                        },
                        icon: const Icon(Icons.delete),
                        label: Text(AppHelper.returnText(
                            context, "Delete Account", "حذف الحساب"))),
                  ],
                ),
              ),
            ],
          ))
        ],
      ),
    ));
  }
}
