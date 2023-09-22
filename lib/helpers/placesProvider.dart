import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

// For storing our result
class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider with ChangeNotifier {
  final client = Client();

//   PlaceApiProvider();

  String? sessionToken;

  static final String androidKey = AppHelper.placesApiKey;
  static final String iosKey = AppHelper.placesApiKey;
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  void init() {
    sessionToken = Uuid().v4().toString();
  }

  Future<List<Suggestion>> fetchSuggestions(
      BuildContext context, String input) async {
    // String lang = context.locale.languageCode;
    String lang = "ar";
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=%28cities%29&language=$lang&components=country:om&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print(result);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<LatLng?> getLocationFromPlaceId(String placeId) async {
    PlacesDetailsResponse detail = await getPlaceDetailFromId(placeId);
    if (detail.result.geometry == null) {
      return null;
    }
    return LatLng(detail.result.geometry!.location.lat, detail.result.geometry!.location.lng);
  }

  Future<PlacesDetailsResponse> getPlaceDetailFromId(String placeId) async {
    // if you want to get the details of the selected place by place_id

    GoogleMapsPlaces _places = GoogleMapsPlaces(
      apiKey: AppHelper.placesApiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(placeId);
    return detail;
  }
}
