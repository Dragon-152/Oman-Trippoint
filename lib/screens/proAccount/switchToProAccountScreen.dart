import 'package:oman_trippoint/constants/constants.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/settingsProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/proUserSchema.dart';
import 'package:oman_trippoint/screens/getStartedScreen.dart';
import 'package:oman_trippoint/screens/homeScreen.dart';
import 'package:oman_trippoint/screens/policyAndPrivacyScreen.dart';
import 'package:oman_trippoint/screens/profileScreen.dart';
import 'package:oman_trippoint/screens/termsAndConditionsScreen.dart';
import 'package:oman_trippoint/widgets/LinkWidget.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:oman_trippoint/widgets/checkboxWidget.dart';
import 'package:oman_trippoint/widgets/inputTextFieldWidget.dart';
import 'package:oman_trippoint/widgets/snakBarWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:phone_number/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:easy_localization/easy_localization.dart' as localized;

class SwitchToProAccountScreen extends StatefulWidget {
  static String router = "switch_to_pro_account";
  int once = 0;
  SwitchToProAccountScreen({super.key});

  @override
  State<SwitchToProAccountScreen> createState() =>
      _SwitchToProAccountScreenState();
}

class _SwitchToProAccountScreenState extends State<SwitchToProAccountScreen> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  TextEditingController _nameInput = TextEditingController();
  TextEditingController _emailInput = TextEditingController();
  TextEditingController _phoneNumberInput = TextEditingController();
  TextEditingController _cityInput = TextEditingController();
  TextEditingController _instagramInput = TextEditingController();

  TextEditingController _publicEmailInput = TextEditingController();
  TextEditingController _publicPhoneNumber = TextEditingController();
  Map data = {};

  int indexOverView = 0;
//   bool isCheckedCheckbox = false;
  PhoneNumberUtil _phoneNumber = PhoneNumberUtil();

  final isCheckedCheckbox = ValueNotifier<bool>(false);

  RegionInfo region = const RegionInfo(name: "Oman", code: "OM", prefix: 968);

  Future _checkPhoneValidation(BuildContext context, val) async {
    bool isValid = await _phoneNumber.validate(val, region.code);

    if (!isValid) {
      SnakbarWidgets.error(
          context,
          AppHelper.returnText(
              context,
              "Invalid phone number,try again, only +968",
              "رقم غير صالح, حاول مجددا, 968+ فقط"));
    }
  }

  Future _submit(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.currentUser!.isProAccount == false) {
        await userProvider
            .userManagerFirestore(DocConstants.try_toSwitchToProAccount, {
          "userId": userProvider.currentUser?.Id,
          "createdAt": DateTime.now().millisecondsSinceEpoch,
          "email": userProvider.currentUser?.email,
          "phone": userProvider.currentUser?.phoneNumber,
        });
      }
      bool validation = _formKey1.currentState!.validate();

      //   bool done = false;
      if (validation) {
        _formKey1.currentState!.save();
        // if (data["publicPhoneNumber"].length != 0) {
        //   bool phoneNumberCheck =
        //       await _checkPhoneValidation(context, data["publicPhoneNumber"]);
        // }
        //   phoneBumberCheck
        EasyLoading.show(maskType: EasyLoadingMaskType.black);

        ProUserSchema proUserData = ProUserSchema(
            verified: userProvider.proCurrentUser != null
                ? (userProvider.proCurrentUser!.verified)
                : false,
            activationStatus: userProvider.proCurrentUser != null
                ? (userProvider.proCurrentUser!.activationStatus)
                : false,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            userId: userProvider.currentUser!.Id,
            publicPhoneNumber: data["publicPhoneNumber"],
            publicEmail: data["publicEmail"],
            instagram: data["instagram"]);
        print(proUserData.toMap());
        bool done = await userProvider.switchToProAccount(
          context: context,
          proUserData: proUserData,
          city: data["city"],
          dateOfBirth: data["dateOfBirth"],
          name: data["name"],
        );

        if (done == false) {
          throw 99;
        }

        EasyLoading.showSuccess('Saved');

        //   Navigator.pushNamed(context, ProfileScreen.router);

        setState(() {
          indexOverView += 1;
        });
        print(indexOverView);
      }
    } catch (err) {
      print(err);
      EasyLoading.showError(
          AppHelper.returnText(context, "Something wrong", "حدث خطأ ما"));

      EasyLoading.dismiss();
    }
    EasyLoading.dismiss();
  }

  List wilaayatsAndRegion = [];
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);
    _nameInput.text = userProvider.currentUser!.name ?? data["name"] ?? "";
    if (data["instagram"] == null) {
      data["instagram"] = userProvider.proCurrentUser?.instagram ?? "";
    }

    _emailInput.text = userProvider.proCurrentUser?.publicEmail ??
        (data["email"] != null &&
                userProvider.proCurrentUser?.publicEmail != data["email"]
            ? data["email"]
            : null) ??
        "";
    _phoneNumberInput.text = userProvider.proCurrentUser?.publicPhoneNumber ??
        data["phoneNumber"] ??
        "";
    // _cityInput.text = userProvider.currentUser!.city ?? data["city"] ?? "";

    data["city"] = userProvider.currentUser!.city ?? data["city"] ?? "";
    print(data["city"]);
    print(userProvider.currentUser!.city);
    // List _citiesOfOman = ["muscate", "smail", "nazwa"];

    for (var r in AppHelper.wilayats.keys.toList()) {
      wilaayatsAndRegion.addAll([r, ...AppHelper.wilayats[r]]);
    }
    wilaayatsAndRegion.add("");

    if (widget.once == 0) {
      if (userProvider.currentUser?.isProAccount == true) {
        indexOverView = 1;
      }
      widget.once = 1;
    }

    List overViewDescription = [
      // 1
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 100,
          ),
          Text(
            AppHelper.returnText(
                context, "Professional Account", "حساب إحترافي"),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            AppHelper.returnText(
                context,
                "Enjoy adding promotional activities and interaction benefits to the platform",
                "استمتع بإضافة أنشطة ترويجية ومزايا تفاعلية إلى المنصة"),
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      ),

      //2
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  AppHelper.returnText(context, "Update Your Information \n",
                      "تحديث معلوماتك \n"),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(AppHelper.returnText(
                    context,
                    " Make sure that the information is correct and not all of them must be fill in, and if you don't enter it correctly, the application will be rejected",
                    "تأكد من أن المعلومات صحيحة ولا يجب ملؤها كلها ، وإذا لم تدخلها بشكل صحيح ، فسيتم رفض الطلب")),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Form(
            key: _formKey1,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextFormField(
                          textDirection: context.locale.languageCode == "ar" ? TextDirection.rtl : TextDirection.ltr ,

                    controller: _nameInput,
                    keyboardType: TextInputType.name,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText:
                          AppHelper.returnText(context, "Name *", "الاسم *"),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.person,
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
                      if (val == null) {
                        return AppHelper.returnText(
                            context,
                            "Use 3 characters or more for your name",
                            "استخدم 3 أحرف أو أكثر لاسمك");
                      }
                      if (val.trim() == "" || val.length < 3) {
                        return AppHelper.returnText(
                            context,
                            "Use 3 characters or more for your name",
                            "استخدم 3 أحرف أو أكثر لاسمك");
                      }
                      if (val.split(" ").length < 2) {
                        return AppHelper.returnText(
                            context,
                            "Please write your full name",
                            "الرجاء كتابة اسمك الكامل");
                      }
                      //   if (val.contains(r'[A-Za-z]')) {
                      //     return "The name should only consist of letters";
                      //   }
                      return null;
                    },
                    onSaved: (val) {
                      data["name"] = val?.trim();
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  DateTimeFormField(
                    // initialDate: DateTime.fromMillisecondsSinceEpoch(userProvider.currentUser!.dateOfBirth ?? DateTime.now().millisecondsSinceEpoch),
                    initialValue: DateTime.fromMillisecondsSinceEpoch(
                        userProvider.currentUser!.dateOfBirth ??
                            DateTime.now().millisecondsSinceEpoch),
                    decoration: InputDecoration(
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
                      contentPadding: const EdgeInsets.all(20),
                      suffixIcon: const Icon(Icons.event_note),
                      labelText: AppHelper.returnText(
                          context, "Date of Birth *", "تاريخ الميلاد *"),
                    ),
                    mode: DateTimeFieldPickerMode.date,
                    // autovalidateMode: AutovalidateMode.always,
                    validator: (value) {
                      if (value == null) {
                        return "";
                      }
                      if (value.year < (DateTime.now().year - 18)) {
                        print(value);
                      } else {
                        return AppHelper.returnText(
                            context, "You are under 18", "عمرك أقل من 18");
                      }
                    },
                    onSaved: (value) {
                      print(value);
                      data["dateOfBirth"] = value?.millisecondsSinceEpoch;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),

                  SearchField(
                    suggestions: wilaayatsAndRegion.map((wr) {
                      return SearchFieldListItem(
                        wr.toString().trim().tr(),
                        item: wr.toString().trim(),
                      );
                    }).toList(),
                    // controller: _cityInput,
                    suggestionState: Suggestion.expand,
                    hint: AppHelper.returnText(
                        context, 'Choose Wilaya *', "اختر الولاية *"),
                    hasOverlay: true,
                    searchStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    validator: (x) {
                      String? wialya =
                          AppHelper.wilayatsAaE[x.toString().trim()];

                      if (!wilaayatsAndRegion.contains(x) || x!.isEmpty) {
                        if (wialya != null) {
                          data["city"] = wialya.toString().trim();
                          return null;
                        }

                        return AppHelper.returnText(
                            context,
                            'Please enter address from the list',
                            "الرجاء إدخال ولاية من القائمة");
                      }

                      data["city"] = x.toString().trim();
                    },
                    onSubmit: (p0) {
                      print(p0);
                    },
                    searchInputDecoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black45,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black45),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    maxSuggestionsInViewPort: 6,
                    itemHeight: 40,
                    initialValue: data["city"] == null
                        ? null
                        : SearchFieldListItem(
                            data["city"].toString().trim().tr(),
                            item: data["city"].toString().trim()),
                    onSuggestionTap: (x) {
                      print(x.item);
                      data["city"] = x.item.toString().trim();
                    },
                  ),

                  //   SearchField(
                  //     suggestions: wilaayatsAndRegion.map((wr) {
                  //       return SearchFieldListItem(
                  //         wr.toString().trim().tr(),
                  //         item: wr.toString().trim(),
                  //       );
                  //     }).toList(),
                  //     suggestionState: Suggestion.expand,
                  //     textInputAction: TextInputAction.next,
                  //     hint: AppHelper.returnText(context,
                  //         'Choose Wilaya *', "اختر الولاية *"),
                  //     hasOverlay: true,
                  //     searchStyle: const TextStyle(
                  //       fontSize: 18,
                  //       color: Colors.black,
                  //     ),
                  //     validator: (x) {
                  //       //   print();
                  //       String? wialya = AppHelper
                  //           .wilayatsAaE[x.toString().trim()];
                  //       if (!wilaayatsAndRegion.contains(x) ||
                  //           x!.isEmpty) {
                  //         if (wialya != null) {
                  //           data["address"] =
                  //               wialya.toString().trim();
                  //           return null;
                  //         }
                  //         return AppHelper.returnText(
                  //             context,
                  //             'Please enter address from the list',
                  //             "الرجاء إدخال ولاية من القائمة");
                  //       }
                  //       data["address"] = x.toString().trim();
                  //     },
                  //     onSubmit: (p0) {
                  //       print(p0);
                  //     },
                  //     searchInputDecoration: InputDecoration(
                  //       focusedBorder: OutlineInputBorder(
                  //         borderSide: const BorderSide(
                  //           color: Colors.black45,
                  //         ),
                  //         borderRadius: BorderRadius.circular(16),
                  //       ),
                  //       border: OutlineInputBorder(
                  //         borderSide:
                  //             const BorderSide(color: Colors.black45),
                  //         borderRadius: BorderRadius.circular(16),
                  //       ),
                  //     ),
                  //     maxSuggestionsInViewPort: 6,
                  //     itemHeight: 40,
                  //     initialValue: data["address"] == null
                  //         ? null
                  //         : SearchFieldListItem(
                  //             data["address"].toString().trim().tr(),
                  //             item:
                  //                 data["address"].toString().trim()),
                  //     onSuggestionTap: (x) {
                  //       data["address"] = x.item.toString().trim();
                  //     },
                  //   ),

                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                          textDirection: context.locale.languageCode == "ar" ? TextDirection.rtl : TextDirection.ltr ,

                    controller: _emailInput,
                    keyboardType: TextInputType.name,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: AppHelper.returnText(
                          context, "Public Email ", "البريد إلكتروني العام "),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.person,
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
                      //
                      //
                      //   if (val == null ||
                      //       !EmailValidator.validate(val.trim(), true)) {
                      //     return "invalid email address";
                      //   }
                      //   return null;
                    },
                    onSaved: (val) {
                      data["publicEmail"] = val?.trim();
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                          textDirection: context.locale.languageCode == "ar" ? TextDirection.rtl : TextDirection.ltr ,

                    controller: _phoneNumberInput,
                    keyboardType: TextInputType.name,
                    obscureText: false,
                    decoration: InputDecoration(
                      //   suffixText: ,
                      labelText: AppHelper.returnText(
                          context, "Public Phone Number ", "رقم الهاتف العام "),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.person,
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
                      //   _checkPhoneValidation(context, val);
                      if (val?.trim().length != 8 && val?.trim().length != 0) {
                        return AppHelper.returnText(context,
                            "Invalid phone number", "رقم الهاتف غير صحيح");
                      }

                      return null;
                    },
                    onSaved: (val) async {
                      data["publicPhoneNumber"] = val?.trim();
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InputTextFieldWidget(
                    text: data["instagram"],
                    labelText: AppHelper.returnText(
                        context, "Instagram Account ", "حساب الانستجرام "),
                    helperText: "",
                    onSaved: (val) {
                      data["instagram"] = val?.trim();
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  //   Row(
                  //     children: [
                  //       CheckboxWidget(
                  //         label: AppHelper.returnText(
                  //             context,
                  //             "I Agree to terms and conditions",
                  //             "الموافقة على الشروط والأحكام "),
                  //         isCheck: isCheckedCheckbox.value,
                  //         onChanged: (bool? value) {
                  //           isCheckedCheckbox.value = value!;
                  //         },
                  //       ),
                  //       LinkWidget(text: "Terms and Conditions", onPressed: () {})
                  //     ],
                  //   ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppHelper.returnText(
                            context,
                            "By clicking submit you agree to our ",
                            "بالنقر على إرسال ، فإنك توافق على "),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LinkWidget(
                              color: ColorsHelper.purple,
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, TermsAndConditionsScreen.router);
                              },
                              text: "Terms and conditions".tr()),
                          Text(
                            "and".tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          LinkWidget(
                              color: ColorsHelper.purple,
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, PolicyAndPrivacyScreen.router);
                              },
                              text: "Privacy Policy".tr()),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Icon(
            Icons.done_all_rounded,
            size: 100,
            color: ColorsHelper.green,
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                if (userProvider.proCurrentUser != null)
                  if (userProvider.proCurrentUser!.verified == true)
                    Text(
                      AppHelper.returnText(context, "Saved successfully \n",
                          "Saved successfully \n"),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                if (userProvider.proCurrentUser == null ||
                    userProvider.proCurrentUser?.verified == false)
                  Text(
                    AppHelper.returnText(context, "We almost we Done \n",
                        "لقد انتهينا تقريبًا \n"),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                if (userProvider.proCurrentUser == null ||
                    userProvider.proCurrentUser?.verified == false)
                  Text(AppHelper.returnText(
                      context,
                      "Please wait 6 hours to verify your information, until further notice. After that, you will be able to publish your tourist activity ads in the application.",
                      "يرجى الانتظار 6 ساعات للتحقق من معلوماتك ،حتى اشعار اخر. بعدها ستتمكن من نشر اعلانات انشتطك السياحية في التطبيق")),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      )
    ];

    return SafeScreen(
      padding: 0,
      child: Column(
        children: [
          AppBarWidget(
              title: AppHelper.returnText(
                  context, "Professional Account", "حساب إحترافي")),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: overViewDescription[indexOverView]),
                Container(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (indexOverView > 0 &&
                                  userProvider.proCurrentUser == null) ||
                              indexOverView == 2
                          ? ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();

                                if (indexOverView > 0) {
                                  //!!!!!!!!!
                                  setState(() {
                                    indexOverView -= 1;
                                  });
                                }
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 60, vertical: 20),
                                ),
                              ),
                              child: Text(AppHelper.returnText(
                                  context, "Back", "رجوع")),
                            )
                          : const SizedBox(),
                      ValueListenableBuilder(
                          valueListenable: isCheckedCheckbox,
                          builder: (context, value, child) {
                            return ElevatedButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                if (indexOverView == 0) {
                                  //!!!!!!!!!

                                  setState(() {
                                    indexOverView += 1;
                                  });
                                } else if (indexOverView == 2) {
                                  Navigator.pop(context);
                                } else {
                                  await _submit(context);
                                }
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 60, vertical: 20),
                                ),
                              ),
                              child: indexOverView != 2
                                  ? (indexOverView == 1
                                      ? Text(AppHelper.returnText(
                                          context, "Submit", "إرسال"))
                                      : Text(AppHelper.returnText(
                                          context, "Next", "التالي")))
                                  : Text(AppHelper.returnText(
                                      context, "Done", "تم")),
                            );
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
