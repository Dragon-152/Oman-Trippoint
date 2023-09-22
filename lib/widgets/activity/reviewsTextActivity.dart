import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/widgets/textIocnActWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewsTextActivity extends StatelessWidget {
  ActivitySchema activitySchema;
  ReviewsTextActivity({super.key, required this.activitySchema});

  @override
  Widget build(BuildContext context) {
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);

    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: ColorsHelper.yellow,
                  size: 18,
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                  child: Text(
                    activityProvider
                            .previewMark(activitySchema.reviews)
                            .toString() +
                        "/5",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            activitySchema.reviews.length.toString() +
                " " +
                AppHelper.returnText(context, 'review', "مراجعة"),
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
