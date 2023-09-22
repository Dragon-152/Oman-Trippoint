import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class StartFromPriceTextActivity extends StatelessWidget {
  ActivitySchema activitySchema;
  StartFromPriceTextActivity({super.key, required this.activitySchema});

  @override
  Widget build(BuildContext context) {
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Text(
              AppHelper.returnText(context, 'From', "يبدأ من "),
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                activityProvider
                    .startFromPrice(activitySchema.prices)
                    .toString(),
                // ! widget.activity.priceStartFrom.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.red),
              ),
              const SizedBox(
                width: 5,
              ),
              //   const Text('OMR'),

              Text(
                'OMR',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
