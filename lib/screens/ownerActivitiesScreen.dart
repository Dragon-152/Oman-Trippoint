import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/screens/activityStatisticsScreen.dart';
import 'package:oman_trippoint/screens/addActivityScreen.dart';
import 'package:oman_trippoint/screens/editActivityScreen.dart';
import 'package:oman_trippoint/widgets/AdContainerWidget.dart';
import 'package:oman_trippoint/widgets/DiologsWidgets.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OwnerActivitesScreen extends StatefulWidget {
  static String router = "owner_activites";
  const OwnerActivitesScreen({super.key});

  @override
  State<OwnerActivitesScreen> createState() => _OwnerActivitesScreenState();
}

class _OwnerActivitesScreenState extends State<OwnerActivitesScreen> {
  Future deleteActivity(String activityStoreId) async {
    ActivityProvider activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppHelper.returnText(
                    context,
                    'Are you sure do you want to delete this activity for ever!',
                    "هل أنت متأكد أنك تريد حذف هذا النشاط إلى الأبد!")),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppHelper.returnText(context, 'Close', 'اغلاق')),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(AppHelper.returnText(context, 'Yes', 'نعم')),
              onPressed: () async {
                EasyLoading.show(maskType: EasyLoadingMaskType.black);
                try {
                  bool done = await activityProvider.deleteActivity(
                      context, activityStoreId);

                  if (done == false) {
                    throw 99;
                  }

                  EasyLoading.showSuccess('Saved');

                  Navigator.of(context).pop();
                } catch (err) {
                  print("Error!!!!!!!!!!!!!!!");
                  print(err);
                  EasyLoading.showError(AppHelper.returnText(
                      context, "Something wrong", "حدث خطأ ما"));
                }

                await Future.delayed(const Duration(milliseconds: 1500));

                EasyLoading.dismiss();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppHelper.returnText(context, "My Activities", "نشاطاتي"),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 30,
            ),
            FutureBuilder(
                future: activityProvider.fetchUserActivities(
                    context, userProvider.currentUser?.Id),
                builder: (context, snapshot) {
                  print("owner screen");
                  print(!snapshot.hasData);
                  print(snapshot.connectionState == ConnectionState.waiting);
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List<ActivitySchema> activityListSchema =
                      snapshot.data as List<ActivitySchema>;

                  print(activityListSchema);

                  return Expanded(
                      child: ListView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          children: [
                        const SizedBox(
                          height: 10,
                        ),
                        const Adcontainer(),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add_rounded),
                          label: Text(AppHelper.returnText(
                              context, "Add Activity", "إضافة نشاط")),
                          onPressed: () async {
                            if (!userProvider.islogin()) {
                              DialogWidgets.mustSginin(context);
                              return;
                            }
                            if (userProvider.islogin() &&
                                userProvider.currentUser!.isProAccount ==
                                    true) {
                              if (userProvider.proCurrentUser?.verified !=
                                      true ||
                                  userProvider
                                          .proCurrentUser?.activationStatus !=
                                      true) {
                                if (userProvider.proCurrentUser?.verified ==
                                        true &&
                                    userProvider
                                            .proCurrentUser?.activationStatus !=
                                        true) {
                                  DialogWidgets.nonActivatedProAccount(context);
                                  return;
                                }

                                DialogWidgets.mustProHaveVerified(context);
                                return;
                              }
                              Navigator.pushNamed(
                                  context, AddActivityScreen.router);
                            } else {
                              DialogWidgets.mustSwitchtoPro(context);
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (userProvider.proCurrentUser?.verified == true &&
                            userProvider.proCurrentUser?.activationStatus !=
                                true)
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: ColorsHelper.red),
                            child: Text(
                              AppHelper.returnText(
                                  context,
                                  "We have suspended your account for violating the terms and conditions, you cannot post on this platform. Contact us to unblock the account.",
                                  "لقد قمنا بإيقاف حسابك بسبب مخالفة الشروط والاحكام، لا يمكنك النشر في هذه المنصة. تواصل معنا لالغاء حظر الحساب."),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        if (userProvider.proCurrentUser?.verified == true &&
                            userProvider.proCurrentUser?.activationStatus ==
                                true)
                          ...activityListSchema.map((a) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              elevation: 3,
                              color: ColorsHelper.whiteCard,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  overlayColor: ColorsHelper.cardOverlayColor,
                                  splashColor: ColorsHelper.cardSplashColor,
                                  onTap: () {},
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: ColorsHelper.grey),
                                              width: 100,
                                              height: 160,
                                              child: Image.network(
                                                activityProvider
                                                    .mainDisplayImage(a.images),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      100 -
                                                      50,
                                                  child: Text(
                                                    a.title,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(AppHelper.returnText(
                                                        context,
                                                        "Status : ",
                                                        "الحالة : ") +
                                                    (a.isActive == true
                                                        ? AppHelper.returnText(
                                                            context,
                                                            "active",
                                                            "فعال")
                                                        : AppHelper.returnText(
                                                            context,
                                                            "not active",
                                                            "غير فعال"))),
                                                Text(AppHelper.returnText(
                                                        context,
                                                        "Publish date : ",
                                                        "تاريخ النشر : ") +
                                                    DateFormat('MM/dd/yyyy')
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                                a.createdAt))
                                                        .toString()),
                                              ],
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              RoundedButton(
                                                icon: Icons.edit_rounded,
                                                text: AppHelper.returnText(
                                                    context, "Edit", "تعديل"),
                                                color: Colors.black45,
                                                onPressed: () async {
                                                  EasyLoading.show();
                                                  Navigator.pushNamed(context,
                                                      EditActivityScreen.router,
                                                      arguments: a);
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 1000));
                                                  EasyLoading.dismiss();
                                                },
                                              ),

                                              RoundedButton(
                                                icon:
                                                    Icons.insert_chart_rounded,
                                                text: AppHelper.returnText(
                                                    context,
                                                    "Statistics",
                                                    "إحصائيات"),
                                                color: Colors.black45,
                                                onPressed: () async {
                                                  EasyLoading.show();
                                                  Navigator.pushNamed(
                                                      context,
                                                      ActivityStatisticsScreen
                                                          .router,
                                                      arguments: a);
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 1000));
                                                  EasyLoading.dismiss();
                                                },
                                              ),
                                              RoundedButton(
                                                icon: Icons.stop_circle_sharp,
                                                text: a.isActive
                                                    ? AppHelper.returnText(
                                                        context,
                                                        "Freeze",
                                                        "تجميد")
                                                    : AppHelper.returnText(
                                                        context,
                                                        "Activate",
                                                        "تفعيل"),
                                                color: Colors.black45,
                                                onPressed: () async {
                                                  EasyLoading.show(
                                                      maskType:
                                                          EasyLoadingMaskType
                                                              .black);

                                                  if (a.isActive) {
                                                    await activityProvider
                                                        .freezeActivity(context,
                                                            a.storeId!);
                                                  } else {
                                                    await activityProvider
                                                        .activateActivity(
                                                            context,
                                                            a.storeId!);
                                                  }

                                                  setState(() {});
                                                  EasyLoading.dismiss();
                                                },
                                              ),
                                              //   T
                                              RoundedButton(
                                                icon: Icons.delete_rounded,
                                                text: AppHelper.returnText(
                                                    context, "Delete", "حذف"),
                                                color: ColorsHelper.red,
                                                onPressed: () async {
                                                  deleteActivity(a.storeId!);
                                                },
                                              ),
                                              //   T
                                            ],
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            );
                          }).toList(),
                        const SizedBox(
                          height: 40,
                        ),
                      ]));
                }),
          ],
        ));
  }
}

class RoundedButton extends StatelessWidget {
  IconData icon;
  Color color;
  String text;
  Function onPressed;
  RoundedButton(
      {super.key,
      required this.icon,
      required this.onPressed,
      required this.color,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        child: Column(
          children: [
            IconButton(
              onPressed: () {
                onPressed();
              },
              icon: Icon(icon),
              padding: const EdgeInsets.all(0),
              iconSize: 30,
              //   highlightColor: color,
              color: color,
            ),
            Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: color))
          ],
        ),
      ),
    );
  }
}
