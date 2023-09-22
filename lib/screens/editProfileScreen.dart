import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/screens/updateProfileDataScreen.dart';
import 'package:oman_trippoint/widgets/LinkWidget.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:oman_trippoint/widgets/inputTextFieldWidget.dart';
import 'package:oman_trippoint/widgets/profileAvatarWidget.dart';
import 'package:date_field/date_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  static String router = "/edit_profile";

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  TextEditingController _firstNameInput = TextEditingController();
  TextEditingController _secondNameInput = TextEditingController();
  TextEditingController _emailInput = TextEditingController();
  DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final Map<String, dynamic> data = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future changeProfileImage() async {
    EasyLoading.show();
    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        bool done = await userProvider.changeProfileImage(context, image.path);
        if (!done) {
          throw 99;
        }
      }
      setState(() {
        userProvider.currentUser?.profileImagePath =
            userProvider.currentUser?.profileImagePath;
      });
      
      EasyLoading.showSuccess('Saved');
    } catch (err) {
      EasyLoading.showError(
          AppHelper.returnText(context, "Something wrong", "حدث خطأ ما"));
    }
    await Future.delayed(Duration(milliseconds: 1000), () {});
    EasyLoading.dismiss();
  }

  Future removeProfileImage() async {
    EasyLoading.show();
    try {
      UserProvider userProvider = Provider.of<UserProvider>(context);
      bool done = await userProvider.removeProfileImage(context);

      if (!done) {
        throw 99;
      }

      setState(() {
     
      });
      EasyLoading.showSuccess('Saved');
    } catch (err) {
      EasyLoading.showError(
          AppHelper.returnText(context, "Something wrong", "حدث خطأ ما"));
    }
    await Future.delayed(Duration(milliseconds: 1000), () {});

    EasyLoading.dismiss();
  }

  Future _submit() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      bool validation = _formKey.currentState!.validate();

      if (validation) {
        _formKey.currentState!.save();

        setState(() {
          _loading = true;
        });

        print(data);

        userProvider.currentUser?.name = data["name"];
        userProvider.currentUser?.dateOfBirth = data["dateOfBirth"];

        bool done = await userProvider.updateUserInfo(context, data);

        setState(() {
          _loading = false;
        });

        if (done == false) {
          throw 99;
        }

        userProvider.notifyListeners();

        EasyLoading.showSuccess('Saved');
        print("Good ! we will work in this later");
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
    for (var i in userProvider.currentUser!.name.split(" ")) {}
    List fullName = userProvider.currentUser!.name.split(" ");

    if (fullName.isNotEmpty) {
      _firstNameInput.text = userProvider.currentUser!.name.split(" ")[0];
    }
    if (fullName.length >= 2) {
      _secondNameInput.text = userProvider.currentUser!.name.split(" ")[1];
    }
    _emailInput.text = userProvider.currentUser!.email!;

    return SafeScreen(
      padding: 0,
      child: AbsorbPointer(
        absorbing: _loading,
        child: Column(
          children: [
            AppBarWidget(
                title: AppHelper.returnText(
                    context, "Edit Profile", "تعديل الملف الشخصي")),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          //   changeProfileImage();
                          showDialog(
                            context: context,
                            builder: (context) => SimpleDialog(
                              //   title: const Text(''),
                              children: <Widget>[
                                SimpleDialogOption(
                                  onPressed: () async {
                                    await changeProfileImage();
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                  child: Text(AppHelper.returnText(
                                      context,
                                      'Change profile picture',
                                      "تغيير صورة الملف الشخصي")),
                                ),
                                SimpleDialogOption(
                                  onPressed: () async {
                                    await userProvider.removeProfileImage(context);
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                  child: Text(AppHelper.returnText(
                                      context,
                                      'Delete profile picture',
                                      "حذف صورة الملف الشخصي")),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    //       CircleAvatar(
                                    //   child: ClipOval(
                                    //     child: userProvider.currentUser!.profileImagePath?.trim() == "" ||
                                    //             userProvider.currentUser!.profileImagePath == null
                                    //         ? Container(
                                    //             color: Color(userProvider.currentUser!.profileColor ??
                                    //                 Colors.grey.shade400.value))
                                    //         : Image.network(
                                    //             userProvider.currentUser!.profileImagePath!,
                                    //             fit: BoxFit.cover,
                                    //           ),
                                    //   ),
                                    //   maxRadius: 40,
                                    // ),

                                    ProfileAvatarWidget(
                                      profileColor: userProvider
                                          .currentUser?.profileColor,
                                      profileImagePath: userProvider
                                          .currentUser?.profileImagePath,
                                    ),

                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: 80,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Colors.white60,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(100),
                                              bottomRight:
                                                  Radius.circular(100)),
                                        ),
                                        child:
                                            const Center(child: Text("Edit")),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: SizedBox.expand(
                            child: Column(
                              children: [
                                InputTextFieldWidget(
                                  text: userProvider.currentUser!.name,
                                  keyboardType: TextInputType.name,
                                  labelText: AppHelper.returnText(
                                      context, "Name *", "الاسم *"),
                                  prefixIcon: Icons.person,
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
                                  height: 20,
                                ),
                                DateTimeFormField(
                                  // initialDate: DateTime.fromMillisecondsSinceEpoch(userProvider.currentUser!.dateOfBirth ?? DateTime.now().millisecondsSinceEpoch),
                                  initialValue:
                                      DateTime.fromMillisecondsSinceEpoch(
                                          userProvider
                                                  .currentUser!.dateOfBirth ??
                                              DateTime.now()
                                                  .millisecondsSinceEpoch),
                                  decoration: InputDecoration(
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black45,
                                        width: 1,
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                    ),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black45,
                                        width: 1,
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                    ),
                                    contentPadding: const EdgeInsets.all(20),
                                    suffixIcon: const Icon(Icons.event_note),
                                    labelText: AppHelper.returnText(context,
                                        "Date of Birth *", "تاريخ الميلاد *"),
                                  ),
                                  mode: DateTimeFieldPickerMode.date,
                                  // autovalidateMode: AutovalidateMode.always,
                                  validator: (value) {
                                    if (value == null) {
                                      return "";
                                    }
                                    if (value.year <
                                        (DateTime.now().year - 18)) {
                                      print(value);
                                    } else {
                                      // return AppHelper.returnText(context,
                                      //     "You are under 18", "عمرك أقل من 18");
                                    }
                                  },
                                  onSaved: (value) {
                                    print(value);
                                    data["dateOfBirth"] =
                                        value?.millisecondsSinceEpoch;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        // border: ,
                        ),
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      child:
                          Text(AppHelper.returnText(context, "Save", "تأكيد")),
                      onPressed: () async {
                        await _submit();
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  ListTile(
                    title: Text(AppHelper.returnText(
                        context, "Email", "البريد الإلكتروني")),
                    subtitle: Text(userProvider.currentUser!.email ?? ""),
                    trailing: userProvider.currentUser!.providerId ==
                                "password" &&
                            userProvider.credentialUser!.providerData[0]
                                    .providerId ==
                                "password"
                        ? LinkWidget(
                            text: userProvider.currentUser!.email == null ||
                                    userProvider.currentUser!.email == ""
                                ? AppHelper.returnText(context, "Add", "أضف")
                                : AppHelper.returnText(
                                    context, "Edit", "تعديل"),
                            onPressed: () {},
                          )
                        : null,
                    onTap: userProvider.currentUser!.providerId == "password" &&
                            userProvider.credentialUser!.providerData[0]
                                    .providerId ==
                                "password"
                        ? () {
                            Navigator.pushNamed(
                                context, UpdateProfileDataScreen.router,
                                arguments: true);
                          }
                        : null,
                  ),
                  const Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  ListTile(
                    title: Text(AppHelper.returnText(
                        context, "Phone Number", "رقم الهاتف")),
                    subtitle: Text(userProvider.currentUser!.phoneNumber ?? ""),
                    trailing: LinkWidget(
                      text: userProvider.currentUser!.phoneNumber == null
                          ? AppHelper.returnText(context, "Add", "أضف")
                          : AppHelper.returnText(context, "Edit", "تعديل"),
                      onPressed: () {},
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                          context, UpdateProfileDataScreen.router,
                          arguments: false);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Divider(
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DraggableScrollableSheet(
//     controller: _draggableScrollableController,
//     initialChildSize: 0.1,
//     maxChildSize: 0.9,
//     minChildSize: 0.1,
//     snapSizes: [0.1, 0.9],
//     snap: true,
//     builder: (context, scrollController) {
//       return ListView(controller: scrollController, children: [
//         Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(16),
//               topRight: Radius.circular(16),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 blurRadius: 8,
//                 color: Colors.black12,
//                 spreadRadius: .6,
//                 offset: Offset(0, -8),
//               )
//             ],
//           ),
//           margin: EdgeInsets.only(top: 30),
//           padding:
//               EdgeInsets.symmetric(vertical: 20, horizontal: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       scrollController.animateTo(
//                         0,
//                         duration: Duration(milliseconds: 400),
//                         curve: Curves.easeInOut,
//                       );
//                     },
//                     icon: Icon(
//                       Icons.close_rounded,
//                       size: 20,
//                     ),
//                   ),
//                   Text("Update Email"),
//                 ],
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                 ),
//                 child: Center(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: 20),
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(50),
//                         color: ColorsHelper.grey),
//                     width: 70,
//                     height: 6,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           color: Colors.white,
//           child: SingleChildScrollView(
//             child: Container(
//               padding: EdgeInsets.all(10),
//               height: MediaQuery.of(context).size.height,
//               child: Column(
//                 children: [
//                   Text(
//                       "We'll send an email to confirm your email address."),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   TextFormField(
//                     controller: _emailInput,
//                     keyboardType: TextInputType.emailAddress,
//                     autofocus: true,
//                     obscureText: false,
//                     decoration: const InputDecoration(
//                       hintText: "Email",
//                       filled: true,
//                       fillColor: Colors.white,
//                       prefixIcon: Icon(
//                         Icons.email_rounded,
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.black45,
//                           width: 1,
//                         ),
//                         borderRadius:
//                             BorderRadius.all(Radius.circular(16)),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.black45,
//                           width: 1,
//                         ),
//                         borderRadius:
//                             BorderRadius.all(Radius.circular(16)),
//                       ),
//                     ),
//                     validator: (val) {
//                       if (val == null ||
//                           !EmailValidator.validate(
//                               val.trim(), true)) {
//                         return "invalid email address";
//                       }
//                       return null;
//                     },
//                     onSaved: (val) {
//                       data["email"] = val?.trim();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ]);
//     }),
