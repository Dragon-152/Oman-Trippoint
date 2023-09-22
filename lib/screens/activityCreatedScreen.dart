import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/screens/getStartedScreen.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityCreatedScreen extends StatelessWidget {
  const ActivityCreatedScreen({super.key});
  static String router = "activity_created";

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return SafeScreen(
        padding: 0,
        child: Column(children: [
          AppBarWidget(title: "Activity Created"),
          Expanded(
              child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                const SizedBox(
                  height: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/success.png",
                      width: 100,
                      height: 100,
                    ),
                    const Text("activity has been created successflly .."),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context,
                              GetStartedScreen.router, (route) => false);
                        },
                        child: const Text("Next"))
                  ],
                )
              ])),
        ]));
  }
}
