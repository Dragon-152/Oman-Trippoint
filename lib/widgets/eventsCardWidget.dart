import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/schemas/eventsSchema.dart';
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
import 'package:url_launcher/url_launcher.dart';

class EventsCardWidget extends StatefulWidget {
  Function() onPressed;
  EventsSchema eventsSchema;
  EventsCardWidget(
      {Key? key, required this.eventsSchema, required this.onPressed})
      : super(key: key);

  @override
  State<EventsCardWidget> createState() => _EventsCardWidgetState();
}

class _EventsCardWidgetState extends State<EventsCardWidget> {
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
                                .mainDisplayImage([widget.eventsSchema.image]),
                            child: Image.network(
                              // "",
                              activityProvider.mainDisplayImage(
                                  [widget.eventsSchema.image]),
                              width: MediaQuery.of(context).size.width,
                              height: 170,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Align(
                          //   alignment: const Alignment(1, -1),
                          //   child: Container(
                          //     decoration: const BoxDecoration(
                          //       color: Colors.white,
                          //       borderRadius: BorderRadius.only(
                          //         topRight: Radius.circular(10),
                          //         bottomLeft: Radius.circular(10),
                          //       ),
                          //     ),
                          //     child: WishlistIconButtonWidget(
                          //         activityStoreId: widget.activity.storeId!,
                          //         activityId: widget.activity.Id),
                          //   ),
                          // ),
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
                            widget.eventsSchema.title,
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
                          Text(
                            widget.eventsSchema.text,
                            //   textAlign: context.locale == "ar" ? TextAlign.right : TextAlign.left,
                            // style: Theme.of(context)
                            //     .textTheme
                            //     .titleLarge
                            //     ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 15,
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextIconInfoActWidget(
                                text: widget.eventsSchema.date.toString(),
                                icon: Icons.timelapse_rounded,
                                //  style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (widget.eventsSchema.createdAt != null)
                                TextIconInfoActWidget(
                              text: activityProvider.formatTimeAgo(widget.eventsSchema.createdAt!),
                              icon: Icons.timelapse_outlined        ,
                              //  style: Theme.of(context).textTheme.bodySmall,
                            ),
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

                          OutlinedButton.icon(
                              onPressed: () async {
                                 final Uri url = Uri.parse(widget.eventsSchema.url);
                                 await launchUrl(url);
                              },
                              icon: Icon(Icons.open_in_new_rounded),
                              label: Text(AppHelper.returnText(
                                  context, "Learn more", "اعرف المزيد")))
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
