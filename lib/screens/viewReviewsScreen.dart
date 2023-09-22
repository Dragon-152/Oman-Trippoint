import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/schemas/userSchema.dart';
import 'package:oman_trippoint/screens/sendReviewScreen.dart';
import 'package:oman_trippoint/widgets/AdContainerWidget.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:oman_trippoint/widgets/ratingBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class ViewReviewScreen extends StatefulWidget {
  static String router = "viewReview";

  const ViewReviewScreen({super.key});

  @override
  State<ViewReviewScreen> createState() => _ViewReviewScreenState();
}

class _ViewReviewScreenState extends State<ViewReviewScreen> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);

    ActivitySchema activitySchema =
        ModalRoute.of(context)?.settings.arguments as ActivitySchema;

    return SafeScreen(
      padding: 0,
      child: Column(children: [
        AppBarWidget(title: "Reviews".tr()),
        Expanded(
          child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Container(
                  height: 150,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        activityProvider
                            .previewMark(activitySchema.reviews)
                            .toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      RatingBarWidget(
                        // init: ,
                        onRated: (val) {
                          print(val);
                          Navigator.pushReplacementNamed(
                              context, SendReviewScreen.router,
                              arguments: activitySchema);
                        },
                        size: 30,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        activitySchema.reviews.length.toString() +
                            AppHelper.returnText(context, " review", " مراجعة"),
                        // style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Adcontainer(),
                const Divider(
                  thickness: 2,
                ),
                Container(
                    height: MediaQuery.of(context).size.height - 300,
                    child: ListView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: activitySchema.reviews.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder(
                              future: userProvider.fetchUserData(
                                  userId: activitySchema.reviews[index]
                                      ["userId"]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    !snapshot.hasData) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        leading: const CircleAvatar(
                                          radius: 25,
                                        ),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "... ...",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            RatingBarIndicator(
                                              itemBuilder: (context, index) {
                                                return const Icon(
                                                  Icons.star_rate_rounded,
                                                  color: Colors.amber,
                                                );
                                              },
                                              rating: double.parse(
                                                  activitySchema.reviews[index]
                                                          ["rating"]
                                                      .toString()),
                                              itemSize: 18,
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              activitySchema.reviews[index]
                                                      ["review"]
                                                  .toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              DateFormat('MM/dd/yyyy, hh:mm a')
                                                  .format(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          activitySchema
                                                                      .reviews[
                                                                  index]
                                                              ["createdAt"])),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      color: Colors.grey[600]),
                                            )
                                          ],
                                        ),
                                      ),
                                      const Divider(
                                        thickness: 2,
                                      ),
                                    ],
                                  );
                                  //   ListTile(
                                  //     shape: Border.all(width: 2),
                                  //     leading: const CircleAvatar(
                                  //       radius: 25,
                                  //     ),
                                  //     title: const Text('... ...'),
                                  //     subtitle: Column(
                                  //       crossAxisAlignment: CrossAxisAlignment.start,
                                  //       children: [
                                  //         RatingBarIndicator(
                                  //           itemBuilder: (context, index) {
                                  //             return const Icon(
                                  //               Icons.star_rate_rounded,
                                  //               color: Colors.amber,
                                  //             );
                                  //           },
                                  //           rating: activitySchema.reviews[index]
                                  //               ["rating"],
                                  //           itemSize: 18,
                                  //         ),
                                  //         const SizedBox(
                                  //           height: 10,
                                  //         ),
                                  //         Text(
                                  //           activitySchema.reviews[index]["review"]
                                  //               .toString(),
                                  //           style:
                                  //               Theme.of(context).textTheme.bodySmall,
                                  //         ),
                                  //         const SizedBox(
                                  //           height: 5,
                                  //         ),
                                  //         Text(
                                  //           DateFormat('MM/dd/yyyy, hh:mm a').format(
                                  //               DateTime.fromMillisecondsSinceEpoch(
                                  //                   activitySchema.reviews[index]
                                  //                       ["createdAt"])),
                                  //           style: Theme.of(context)
                                  //               .textTheme
                                  //               .bodySmall
                                  //               ?.copyWith(color: Colors.grey[600]),
                                  //         )
                                  //       ],
                                  //     ),
                                  //   );
                                }

                                UserSchema userData =
                                    snapshot.data as UserSchema;

                                print("JJJJJJJJJJJJJ");
                                print(userData.Id);
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            userData.profileColor != null
                                                ? Color(userData.profileColor!)
                                                : null,
                                        backgroundImage:
                                            userData.profileImagePath != null
                                                ? NetworkImage(
                                                    userData.profileImagePath!)
                                                : null,
                                        radius: 25,
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            userData.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          RatingBarIndicator(
                                            itemBuilder: (context, index) {
                                              return const Icon(
                                                Icons.star_rate_rounded,
                                                color: Colors.amber,
                                              );
                                            },
                                            rating: double.parse(activitySchema
                                                .reviews[index]["rating"]
                                                .toString()),
                                            itemSize: 18,
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            activitySchema.reviews[index]
                                                    ["review"]
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            DateFormat('MM/dd/yyyy, hh:mm a')
                                                .format(DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        activitySchema
                                                                .reviews[index]
                                                            ["createdAt"])),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: Colors.grey[600]),
                                          )
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 2,
                                    ),
                                  ],
                                );
                              });
                        })),
              ]),
        )
      ]),
    );
  }
}
