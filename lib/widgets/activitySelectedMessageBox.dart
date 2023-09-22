import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/screens/activityDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class ActivitySelectedMessageBox extends StatelessWidget {
  String text;
  String url;
  int date;
  ActivitySelectedMessageBox(
      {super.key, required this.text, required this.date, required this.url});

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);
    String activityId = url.split("|||")[1];
    String activityTitle = url.split("|||")[0];
    print(url);
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: ColorsHelper.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: ColorsHelper.cardSplash2Color,
          onTap: () async {
            EasyLoading.show();
            ActivitySchema activitySchema =
                await activityProvider.fetchActivityWStore(activityId);
            Navigator.pushNamed(context, ActivityDetailsScreen.router,
                arguments: activitySchema);
            // await Future.delayed(Duration(milliseconds: 1000));
            EasyLoading.dismiss();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    // Note: Styles for TextSpans must be explicitly defined.
                    // Child text spans will inherit styles from parent
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: text.trim().tr(),
                      ),
                      TextSpan(
                          onEnter: (event) {},
                          text: ' "${activityTitle}."  ',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: DateFormat('dd/MM/yyyy')
                              .format(DateTime.fromMillisecondsSinceEpoch(date))
                              .toString(),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(Icons.arrow_forward_rounded)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
