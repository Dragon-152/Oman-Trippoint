import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/widgets/activity/reviewsTextActivity.dart';
import 'package:oman_trippoint/widgets/textIocnActWidget.dart';
import 'package:oman_trippoint/widgets/wishlistIconButtonWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class ActivityCardWishlistWidget extends StatelessWidget {
  ActivitySchema activity;
  Function onPressed;
  ActivityCardWishlistWidget(
      {super.key, required this.activity, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 180,
      child: GestureDetector(
        onTap: () {
          onPressed();
        },
        child: Card(
          color: ColorsHelper.whiteCard,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          key: Key(activity.Id),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              overlayColor: ColorsHelper.cardOverlayColor,
              splashColor: ColorsHelper.cardSplashColor,
              onTap: () {
                onPressed();
              },
              child: Stack(
                children: [
                  Align(
                    alignment: context.locale.languageCode == "ar"
                        ? Alignment(1, 1)
                        : Alignment(1, -1),
                    child: WishlistIconButtonWidget(
                        activityStoreId: activity.storeId!,
                        activityId: activity.Id),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: activity.images[0],
                        child: Image.network(
                          // "",
                          activityProvider.mainDisplayImage(activity.images),

                          width: 80,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width:
                                    MediaQuery.of(context).size.width - 80 - 80,
                                child: Text(activity.title,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    style:
                                        Theme.of(context).textTheme.titleMedium
                                    //   ?.copyWith(fontWeight: FontWeight.bold),
                                    ),

                                // WishlistIconButtonWidget(activityId: activity.Id),
                              ),
                              TextIconInfoActWidget(
                                text: activity.address.toString().tr(),
                                icon: Icons.location_on_rounded,
                                //  style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ReviewsTextActivity(activitySchema: activity),
                                ],
                              ),
                            ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
