import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/providers/settingsProvider.dart';
import 'package:oman_trippoint/widgets/AdContainerWidget.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import "package:easy_localization/easy_localization.dart";
import "package:localization/localization.dart";

class ChangeLanguageScreen extends StatefulWidget {
  static String router = "change_language";
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  List<String> languagesList = ["ar", "en"];
  List<String> languagesListc = ["Arabic", "English"];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SafeScreen(
        padding: 0,
        child: Column(children: [
          AppBarWidget(
              title: AppHelper.returnText(context, "Language", "اللغة")),
          Expanded(
              child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                const SizedBox(
                  height: 30,
                ),
                const Adcontainer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: DropdownButton<String>(
                    icon: const Icon(Icons.language_rounded),
                    items: languagesList.map((String value) {
                      print(context.locale.toString());
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value == "ar"
                            ? AppHelper.returnText(context,
                                "Arabic            ", "عربي            ")
                            : AppHelper.returnText(context,
                                "English           ", "إنجليزي           ")),
                      );
                    }).toList(),
                    value: context.locale.toString(),
                    onChanged: (_) async {
                      if (_ != null) {
                        EasyLoading.show(maskType: EasyLoadingMaskType.black);
                        context.setLocale(Locale(_));
                        await Future.delayed(
                            const Duration(milliseconds: 1500));
                        EasyLoading.dismiss();
                      }
                    },
                  ),
                )
              ])),
        ]));
  }
}
