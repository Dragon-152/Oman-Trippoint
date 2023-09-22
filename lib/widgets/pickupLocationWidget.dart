import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/screens/pickLocationScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickupLocationWidget extends StatefulWidget {
  Function(LatLng) onChanged;
  PickupLocationWidget({super.key, required this.onChanged});

  @override
  State<PickupLocationWidget> createState() => _PickupLocationWidgetState();
}

class _PickupLocationWidgetState extends State<PickupLocationWidget> {
  double? lat;
  double? lng;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.location_on_outlined),
          label: Text(lat == null && lng == null
              ? AppHelper.returnText(
                  context, "Add the activity location", "أضف موقع النشاط")
              : AppHelper.returnText(
                  context, "Change the activity location", "تغير موقع النشاط")),
          onPressed: () async {
            final latlanArg =
                await Navigator.pushNamed(context, PickLocationSceen.router)
                    as LatLng;
            print(latlanArg);
            if (latlanArg != null) {
              widget.onChanged(latlanArg);
              setState(() {
                lat = latlanArg.latitude;
                lng = latlanArg.longitude;
              });
            }
          },
        ),
        const SizedBox(
          height: 10,
        ),
        if (lat != null && lng != null)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(
                child: Text(
              lat.toString().substring(0, 6),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black45),
            )),
            Expanded(
                child: Text(
              lng.toString().substring(0, 6),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black45),
            )),
          ]),
      ],
    );
  }
}
