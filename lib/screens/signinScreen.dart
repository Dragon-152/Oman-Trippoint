import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/screens/accountCreatedScreen.dart';
import 'package:oman_trippoint/screens/forgotPasswordScreen.dart';
import 'package:oman_trippoint/screens/homeScreen.dart';
import 'package:oman_trippoint/screens/policyAndPrivacyScreen.dart';
import 'package:oman_trippoint/screens/termsAndConditionsScreen.dart';
import 'package:oman_trippoint/widgets/LinkWidget.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:oman_trippoint/widgets/inputTextFieldWidget.dart';
import 'package:oman_trippoint/widgets/textButtonWidget.dart';
import 'package:email_validator/email_validator.dart';
import "package:flutter/material.dart";
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import "package:easy_localization/easy_localization.dart";

class SigninScreen extends StatefulWidget {
  static String router = "/signin";

  const SigninScreen({Key? key}) : super(key: key);

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();

  final Map data = {};

  bool _islogin = true;
  bool isLoading = false;

  void _submit(context) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      bool validation = _formKey.currentState!.validate();
      bool done = false;

      if (validation) {
        _formKey.currentState!.save();
        setState(() {
          isLoading = true;
        });
        if (data != {}) {
          if (_islogin) {
            done = await userProvider.login(
              context,
              email: data["email"],
              password: data["password1"],
            );
          } else {
            if (data["password1"] != data["password2"]) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Theme.of(context).errorColor,
                content: Text(AppHelper.returnText(
                    context,
                    "Those passwords didn't match. Try again.",
                    "كلمات المرور هذه غير متطابقة. حاول مرة أخرى.")),
              ));
              return;
            }
            done = await userProvider.signup(
              context,
              email: data["email"],
              password: data["password1"],
              name: "${data["name1"]} ${data["name2"]}",
            );
          }

          setState(() {
            isLoading = false;
          });
          if (done == false) {
            throw 99;
          }

          EasyLoading.showSuccess('Saved');

          Navigator.pushNamedAndRemoveUntil(context, HomeScreen.router,
              (route) {
            return false;
          });
        }
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeScreen(
        padding: 0,
        child: AbsorbPointer(
          absorbing: isLoading,
          child: Column(
            children: [
              AppBarWidget(title: _islogin ? "Login".tr() : "Sign up".tr()),
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      // height: MediaQuery.of(context).size.height - 20,
                      child: Column(children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        image:
                                            AssetImage("assets/icons/icon.png"),
                                        fit: BoxFit.fill)),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (!_islogin)
                                Row(
                                  children: [
                                    Expanded(
                                      child: InputTextFieldWidget(
                                        labelText: AppHelper.returnText(context,
                                            "First Name *", "الاسم الاول *"),
                                        prefixIcon: Icons.person,
                                        validator: (val) {
                                          if (val == null) {
                                            return AppHelper.returnText(
                                                context,
                                                "Use 3 characters or more for your name",
                                                "استخدم 3 أحرف أو أكثر لاسمك");
                                          }
                                          if (val.trim() == "" ||
                                              val.length < 3) {
                                            return AppHelper.returnText(
                                                context,
                                                "Use 3 characters or more for your name",
                                                "استخدم 3 أحرف أو أكثر لاسمك");
                                          }
                                          //   if (val.contains(r'[A-Za-z]')) {
                                          //     return "The name should only consist of letters";
                                          //   }
                                          return null;
                                        },
                                        onSaved: (val) {
                                          data["name1"] = val?.trim();
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: InputTextFieldWidget(
                                        keyboardType: TextInputType.name,
                                        labelText: AppHelper.returnText(context,
                                            "Second Name *", "الاسم الثاني *"),
                                        prefixIcon: Icons.person,
                                        validator: (val) {
                                          if (val == null) {
                                            return AppHelper.returnText(
                                                context,
                                                "Use 3 characters or more for your name",
                                                "استخدم 3 أحرف أو أكثر لاسمك");
                                          }
                                          if (val.trim() == "" ||
                                              val.length < 3) {
                                            return AppHelper.returnText(
                                                context,
                                                "Use 3 characters or more for your name",
                                                "استخدم 3 أحرف أو أكثر لاسمك");
                                          }
                                          //   if (!val.contains(r'^[A-Za-z]+$')) {
                                          //     return "The name should only consist of letters";
                                          //   }
                                          return null;
                                        },
                                        onSaved: (val) {
                                          data["name2"] = val?.trim();
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              //     SizedBox(
                              //     height: 20,
                              //   ),
                              const SizedBox(
                                height: 15,
                              ),
                              InputTextFieldWidget(
                                labelText: AppHelper.returnText(
                                    context, "Email *", "البريد الإلكتروني *"),
                                prefixIcon: Icons.email_rounded,
                                validator: (val) {
                                  if (val == null ||
                                      !EmailValidator.validate(
                                          val.trim(), true)) {
                                    return AppHelper.returnText(
                                        context,
                                        "Invalid email address",
                                        "عنوان البريد الإلكتروني غير صالح");
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  data["email"] = val?.trim();
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              InputTextFieldWidget(
                                labelText: AppHelper.returnText(
                                    context, "Password *", "كلمة المرور *"),
                                prefixIcon: Icons.key_rounded,
                                validator: (val) {
                                  if (val == null) {
                                    return AppHelper.returnText(
                                        context,
                                        "Use 6 characters or more for your password",
                                        "استخدم 6 أحرف أو أكثر لكلمة المرور الخاصة بك");
                                  }
                                  if (val.trim() == "" || val.length < 6) {
                                    return AppHelper.returnText(
                                        context,
                                        "Use 6 characters or more for your password",
                                        "استخدم 6 أحرف أو أكثر لكلمة المرور الخاصة بك");
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  data["password1"] = val.trim();
                                },
                                onSaved: (val) {
                                  data["password1"] = val?.trim();
                                },
                              ),
                              if (_islogin) ...[
                                const SizedBox(
                                  height: 0,
                                ),
                                LinkWidget(
                                    text: AppHelper.returnText(
                                        context,
                                        "Forgot Password?",
                                        "هل نسيت كلمة السر؟"),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, ForgotPasswordScreen.router);
                                    })
                                //   TextButtonWidget(
                                //       text: AppHelper.returnText(context, "Forgot Password?", "هل نسيت كلمة السر؟"),
                                //       onPressed: () {
                                //         Navigator.pushNamed(
                                //             context, ForgotPasswordScreen.router);
                                //       }),
                              ],

                              if (!_islogin) ...[
                                const SizedBox(
                                  height: 15,
                                ),
                                InputTextFieldWidget(
                                  labelText: AppHelper.returnText(
                                      context,
                                      "Confirm Password *",
                                      "تأكيد كلمة المرور *"),
                                  prefixIcon: Icons.key_rounded,
                                  validator: (val) {
                                    if (val == null) {
                                      return AppHelper.returnText(
                                          context,
                                          "Use 6 characters or more for your password",
                                          "استخدم 6 أحرف أو أكثر لكلمة المرور الخاصة بك");
                                    }
                                    if (val.trim() == "" || val.length < 6) {
                                      return AppHelper.returnText(
                                          context,
                                          "Use 6 characters or more for your password",
                                          "استخدم 6 أحرف أو أكثر لكلمة المرور الخاصة بك");
                                    }
                                    if (data["password1"].toString().trim() !=
                                        val.trim()) {
                                      return AppHelper.returnText(
                                          context,
                                          "Those passwords didn't match. Try again.",
                                          "كلمات المرور هذه غير متطابقة. حاول مرة أخرى.");
                                    }
                                    return null;
                                  },
                                  onSaved: (val) {
                                    data["password2"] = val?.trim();
                                  },
                                )
                              ],
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: 200,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _submit(context);
                                  },
                                  icon: const Icon(
                                      Icons.keyboard_backspace_rounded),
                                  label: Text(
                                      _islogin ? "Login".tr() : "Sign up".tr()),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),

                              Text(
                                !_islogin
                                    ? AppHelper.returnText(context,
                                        "Have an account?", "هل لديك حساب؟")
                                    : AppHelper.returnText(
                                        context,
                                        "Don't have an account?",
                                        "ليس لديك حساب؟"),
                                // style: Theme.of(context).textTheme.bodyLarge,
                              ),

                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: 200,
                                child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _islogin = !_islogin;
                                      });
                                    },
                                    child: Text(!_islogin
                                        ? "Login".tr()
                                        : "Sign up".tr())),
                              ),
                              // LinkWidget(
                              //     text: _islogin ? "Login" : "Sign up",
                              //     onPressed: () {
                              //       setState(() {
                              //         _islogin = !_islogin;
                              //       });
                              //     })

                              const SizedBox(
                                height: 40,
                              ),
                            ],
                          ),
                        ),
                        if (!_islogin)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                AppHelper.returnText(
                                    context,
                                    "By clicking Sign up you agree to our ",
                                    "بالنقر فوق تسجيل ، فإنك توافق على "),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LinkWidget(
                                      color: ColorsHelper.purple,
                                      onPressed: () {
                                        Navigator.pushNamed(context,
                                            TermsAndConditionsScreen.router);
                                      },
                                      text: "Terms and conditions".tr()),
                                  Text(
                                    "and".tr(),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  LinkWidget(
                                      color: ColorsHelper.purple,
                                      onPressed: () {
                                        Navigator.pushNamed(context,
                                            PolicyAndPrivacyScreen.router);
                                      },
                                      text: "Privacy Policy".tr()),
                                ],
                              )
                            ],
                          ),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
