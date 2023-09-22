import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/widgets/activity/reviewsTextActivity.dart';
import 'package:oman_trippoint/widgets/activity/startFromPriceTextActivity.dart';
import 'package:oman_trippoint/widgets/textBoxActWidget.dart';
import 'package:oman_trippoint/widgets/textIocnActWidget.dart';
import 'package:oman_trippoint/widgets/wishlistIconButtonWidget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import "package:easy_localization/easy_localization.dart";

class ActivityCardWidget extends StatefulWidget {
  Function() onPressed;
  ActivitySchema activity;
  ActivityCardWidget(
      {Key? key, required this.activity, required this.onPressed})
      : super(key: key);

  @override
  State<ActivityCardWidget> createState() => _ActivityCardWidgetState();
}

class _ActivityCardWidgetState extends State<ActivityCardWidget> {
  List<bool> isSelected = [
    false,
  ];

//   Future loadimage() async {
//     String link = await FirebaseStorage.instance
//         .ref(widget.activity.images[0])
//         .getDownloadURL();
//     print(link);
//   }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Future.delayed(Duration.zero, () => loadimage());
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        children: [
          Card(
            color: ColorsHelper.whiteCard,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                overlayColor: ColorsHelper.cardOverlayColor,
                splashColor: ColorsHelper.cardSplashColor,
                onTap: widget.onPressed,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 170,
                      child: Stack(
                        children: [
                          Hero(
                            tag: activityProvider
                                .mainDisplayImage(widget.activity.images),
                            child: Image.network(
                              // "",
                              activityProvider
                                  .mainDisplayImage(widget.activity.images),
                              width: MediaQuery.of(context).size.width,
                              height: 170,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Align(
                            alignment: const Alignment(1, -1),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                              child: WishlistIconButtonWidget(
                                  activityStoreId: widget.activity.storeId!,
                                  activityId: widget.activity.Id),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.activity.title,
                            textAlign: TextAlign.center,
                            //   textAlign: context.locale == "ar" ? TextAlign.right : TextAlign.left,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 15,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextIconInfoActWidget(
                                    text:
                                        widget.activity.address.toString().tr(),
                                    icon: Icons.location_on_rounded,
                                    //  style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                    TextIconInfoActWidget(
                              text: activityProvider.formatTimeAgo(widget.activity.createdAt),
                              icon: Icons.timelapse_outlined        ,
                              //  style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 10,),
                                  ReviewsTextActivity(
                                      activitySchema: widget.activity),
                                ],
                              ),
                              StartFromPriceTextActivity(
                                  activitySchema: widget.activity)
                            ],
                          ),

                          // Container(
                          //   decoration: BoxDecoration(
                          //     color: Color(0xFFD6D6D6),
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   child: Padding(
                          //     padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                          //     child: Text(
                          //       'private only',
                          //       // style:
                          //     ),
                          //   ),
                          // ),\
                          SizedBox(
                            height: 10,
                          ),

                          Row(
                            children: [
                              if (widget.activity.genderSuitability["woman"] ==
                                      true &&
                                  (widget.activity.genderSuitability["man"] ==
                                          false ||
                                      widget.activity
                                              .genderSuitability["man"] ==
                                          null))
                                TextBoxActWidget(
                                  text: AppHelper.returnText(
                                      context, "Women only", "النساء فقط"),
                                ),
                              if (widget.activity.suitableAges["min"] != null &&
                                  widget.activity.suitableAges["min"]
                                          .toString()
                                          .trim() !=
                                      "")
                                TextBoxActWidget(
                                  text:
                                      "${AppHelper.returnText(context, 'Over', 'فوق')} ${widget.activity.suitableAges["min"].toString()}",
                                ),
                              if (widget.activity.op_GOA == true)
                                TextBoxActWidget(
                                  text: AppHelper.returnText(
                                      context, 'Private group', "متاح للعوائل"),
                                ),
                            ],
                          ),
                         
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    
        ],
      ),
    );
  }
}
