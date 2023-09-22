import 'dart:async';

import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:oman_trippoint/helpers/adHelper.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/helpers/geolocateHelper.dart';
import 'package:oman_trippoint/helpers/placesProvider.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/screens/activityDetailsScreen.dart';
import 'package:oman_trippoint/widgets/AdContainerWidget.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/activityCardMap.dart';
import 'package:oman_trippoint/widgets/loadingWidget.dart';
import 'package:oman_trippoint/widgets/resultActivituBoxWidget.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart' as localized;

class SearchScreen extends StatefulWidget {
  static String router = "/search";

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  BannerAd? _bannerAd;

  late TabController _tabController = TabController(length: 2, vsync: this);
  int _currentTab = 0;
  bool _isLoading = true;
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  TextEditingController textEditingController = TextEditingController();
  var maptype = MapType.normal;

  List<ActivitySchema> activitiesList = [];
  // List<ActivitySchema> activitiesResultList = [];
  List<Marker>? markersList;

  String? noResult = null;

  final _initialCameraPosition = const CameraPosition(
    target: LatLng(23.244037241974922, 58.091192746314015),
    zoom: 10,
  );

  int page = 0;
  PageController pageController =
      PageController(initialPage: 0, viewportFraction: 0.8);
  FocusNode _focusNode = FocusNode();

  final Completer<GoogleMapController> _controller = Completer();
  Position? _currentPosition;

  fetchAllActivities() {
    Future.delayed(const Duration(milliseconds: 1000), () async {
      try {
        ActivityProvider activityProvider =
            Provider.of<ActivityProvider>(context, listen: false);

        activitiesList = await activityProvider.fetchAllActivites();
        print("DDUUUUUUUU");
        print(activitiesList.length);
        setState(() {
          activitiesList = activitiesList;

          _isLoading = false;
        });
        print(_isLoading);
      } catch (err) {
        print(err);
      }
    });
  }

  _getCurrentLocation() async {
    GeolocateHelper.determinePosition(context).then((position) {
      setState(() {
        // Store the position in the variable
        _currentPosition = position;

        print('CURRENT POS: $_currentPosition');

        // For moving the camera to current location
        _controller.future.then((value) => value.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 10,
                ),
              ),
            ));
      });
    }).catchError((error, stackTrace) => null);
  }

  Future _getActivityNearYourPoint() async {
    ActivityProvider activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);
    await _getCurrentLocation();
    activitiesList = await activityProvider.fetchActivitiesNearLocation(
        LatLng(_currentPosition!.latitude, _currentPosition!.latitude));
    setState(() {
      activitiesList = activitiesList;
    });
  }

//   Map _appCatogeriesSelected =
//       AppHelper.categories.asMap().map((k, v) => MapEntry(v["title"], false));
  String categorySelected = "discover_all";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bannerAd?.dispose();

    Future.delayed(const Duration(milliseconds: 1000), () async {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bannerAd?.dispose();

    super.dispose();
  }

  int onceCheck = 0;
  List suggestionSearchList = [];

  @override
  Widget build(BuildContext context) {
    print("build serach page");
    UserProvider userProvider = Provider.of<UserProvider>(context);
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);
    PlaceApiProvider placeApiProvider = Provider.of<PlaceApiProvider>(context);

    if (onceCheck == 0) {
      final args = ModalRoute.of(context)?.settings.arguments != null
          ? ModalRoute.of(context)?.settings.arguments as List<ActivitySchema>
          : ModalRoute.of(context)?.settings.arguments;

      if (args == null) {
        fetchAllActivities();
      } else {
        setState(() {
          activitiesList = args as List<ActivitySchema>;

          if (activitiesList.isNotEmpty) {
            categorySelected = AppHelper.categories
                .where((e) => e["title"] == activitiesList[0].category)
                .toList()[0]["key"];
          }
        });
      }

      onceCheck = 1;
    }

    // print(categorySelected);
    // if (args != null) activitiesList.add(args);

    // Marker _marker = Marker(
    //   markerId: MarkerId(Uuid().v4()),
    //   position: LatLng(activitiesList[0].lat, activitiesList[0].lng),
    //   infoWindow: InfoWindow(
    //     title: activitiesList[0].address,
    //   ),
    // );

    // void placeAutoComplete(String query) {
    //     Uri url = Uri.https("maps.googleapis.com", "maps/api/place/autocomplete/json", {
    //         "input": query,
    //         "key": AppHelper.placesApiKey
    //     });

//   ?input=amoeba
//   &location=37.76999%2C-122.44696
//   &radius=500
//   &types=establishment
//   &key=YOUR_API_KEY"

    // }

    List<Marker> markersList = activitiesList
        .asMap()
        .map((i, e) {
          return MapEntry(
              i,
              Marker(
                flat: true,
                markerId: MarkerId(e.Id),
                position: LatLng(e.lat, e.lng),
                infoWindow: InfoWindow(
                  title: e.address,
                  // !  snippet: (e.priceStartFrom.toString() + "\$"),
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRose),
                onTap: () {
                  pageController.animateToPage(i,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut);
                },
              ));
        })
        .values
        .toList();

    if (_isLoading) {
      return const LoadingWidget();
    }

    return SafeScreen(
      padding: 0,
      child: Stack(children: [
        GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          onMapCreated: (controller) {
            _controller.complete(controller);
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: maptype,
          markers: markersList != null ? {...markersList!} : {},
          onTap: (latLng) {
            FocusScope.of(context).unfocus();
          },
        ),

        Align(
          alignment: const AlignmentDirectional(0.9, .4),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black38,
                  spreadRadius: .6,
                  offset: Offset(0, 0),
                )
              ],
            ),
            child: ClipOval(
              child: Material(
                color: Colors.white, // button color
                child: InkWell(
                  splashColor: Colors.white12, // inkwell color
                  child:  SizedBox(
                    width: 60,
                    height: 60,
                    child: Icon(
                      maptype == MapType.normal ? FontAwesomeIcons.earthAsia : FontAwesomeIcons.map,
                      size: 35,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if (maptype == MapType.normal) {
                        maptype = MapType.satellite;
                      } else {
                        maptype = MapType.normal;
                      }
                    });
                  },
                ),
              ),
            ),
          ),
        ),

        Align(
          alignment: const AlignmentDirectional(-.9, .4),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black38,
                  spreadRadius: .6,
                  offset: Offset(0, 0),
                )
              ],
            ),
            child: ClipOval(
              child: Material(
                color: Colors.white, // button color
                child: InkWell(
                  splashColor: Colors.white12, // inkwell color
                  child: const SizedBox(
                    width: 60,
                    height: 60,
                    child: Icon(
                      Icons.my_location,
                      size: 35,
                    ),
                  ),
                  onTap: () {
                    // TODO: Add the operation to be performed
                    // on button tap
                    _getCurrentLocation();
                  },
                ),
              ),
            ),
          ),
        ),

        // if (activitiesList != null)
        Align(
          alignment: const AlignmentDirectional(0, .75),
          child: Container(
            height: 140,
            width: MediaQuery.of(context).size.width,
            child: PageView.builder(
              physics: const BouncingScrollPhysics(),
              //   dragStartBehavior: DragStartBehavior.down,
              itemCount: activitiesList.length,
              controller: pageController,
              onPageChanged: (p) async {
                if (markersList != null) {
                  GoogleMapController con = await _controller.future;

                  con.showMarkerInfoWindow(markersList[p].markerId);

                  con.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target: markersList[p].position, zoom: 15)));
                }
              },
              itemBuilder: (context, index) {
                return Align(
                  key: Key(const Uuid().v4()),
                  alignment: Alignment.topCenter,
                  child: ActivityCardMap(
                    onClicked: () async {
                      EasyLoading.show();

                      Navigator.pushNamed(context, ActivityDetailsScreen.router,
                          arguments: activitiesList[index]);
                      await Future.delayed(const Duration(milliseconds: 1000));
                      EasyLoading.dismiss();
                    },
                    activitySchema: activitiesList[index],
                  ),
                );
              },
            ),
          ),
        ),
        DraggableScrollableSheet(
            controller: draggableScrollableController,
            initialChildSize: 0.75,
            maxChildSize: 0.75,
            minChildSize: 0.12,
            snapSizes: const [0.12, 0.75],
            snap: true,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black12,
                      spreadRadius: .6,
                      offset: Offset(0, -8),
                    )
                  ],
                ),
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  controller: scrollController,
                  itemCount: activitiesList.length + 1,
                  itemBuilder: (context, index) {
                    ActivitySchema? a;
                    if (index != 0) {
                      a = index - 1 >= 0 ? activitiesList[index - 1] : null;
                    }
                    return Column(
                      children: [
                        if (index == 0)
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: ColorsHelper.grey),
                                width: 70,
                                height: 6,
                              ),
                            ),
                          ),
                        if (index == 0)
                          const SizedBox(
                            height: 20,
                          ),
                        // if (index == 0)
                        //   if (_bannerAd != null)
                        //     const SizedBox(
                        //       height: 20,
                        //     ),

                        //^---------------------- adverticment -----------------------
                        if (index == 0) const Adcontainer(),

                        //^----------------------------------------------------------

                        if (index == 0)
                          Container(
                            // height: 200,
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(vertical: 15),
                            color: Colors.white,
                            child: SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: suggestionSearchList.map((e) {
                                    return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            overlayColor:
                                                ColorsHelper.cardOverlayColor,
                                            splashColor:
                                                ColorsHelper.cardSplashColor,
                                            onTap: () async {
                                              // e.placeId
                                              EasyLoading.show();

                                              HttpsCallableResult r =
                                                  await FirebaseFunctions
                                                      .instance
                                                      .httpsCallable(
                                                          "SearchForActivity")
                                                      .call(e.description);

                                              textEditingController.text =
                                                  e.description;

                                              List<ActivitySchema> acl = [];
                                              for (var activityMap in r.data) {
                                                acl.add(ActivitySchema.toSchema(
                                                    activityMap));
                                              }
                                              setState(() {
                                                if (acl.isEmpty) {
                                                  noResult =
                                                      "No matching experience found.";
                                                }
                                                activitiesList = acl;
                                              });
                                              EasyLoading.dismiss();
                                            },
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(e.description),
                                                  ElevatedButton.icon(
                                                      onPressed: () async {
                                                        LatLng? latlng =
                                                            await placeApiProvider
                                                                .getLocationFromPlaceId(
                                                                    e.placeId);
                                                        if (latlng != null) {
                                                          draggableScrollableController.animateTo(
                                                              0.1,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500),
                                                              curve: Curves
                                                                  .easeInOut);

                                                          _controller.future
                                                              .then((value) =>
                                                                  value
                                                                      .animateCamera(
                                                                    CameraUpdate
                                                                        .newCameraPosition(
                                                                      CameraPosition(
                                                                        target: LatLng(
                                                                            latlng.latitude,
                                                                            latlng.longitude),
                                                                        zoom:
                                                                            15.0,
                                                                      ),
                                                                    ),
                                                                  ));
                                                        }
                                                      },
                                                      icon: Icon(Icons
                                                          .gps_fixed_rounded),
                                                      label: Text("On Map"))
                                                ],
                                              ),
                                            )));
                                  }).toList()),
                            ),
                          ),
//    if (index == 0)
//                           if (_bannerAd != null)
//                             const SizedBox(
//                               height: 10,
//                             ),
                        if (activitiesList.isEmpty && noResult != null)
                          Text(
                            noResult!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        if (index - 1 >= 0)
                          Container(
                            key: Key(const Uuid().v4()),
                            padding: const EdgeInsets.all(10),
                            child: ResultActivituBoxWidget(
                              onClicked: () async {
                                EasyLoading.show();

                                Navigator.pushNamed(
                                    context, ActivityDetailsScreen.router,
                                    arguments: a);
                                await Future.delayed(
                                    const Duration(milliseconds: 1000));

                                EasyLoading.dismiss();
                              },
                              activitySchema: a!,
                              showOnMap: () async {
                                draggableScrollableController.animateTo(0.1,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut);

                                GoogleMapController con =
                                    await _controller.future;
                                Marker __markerA = markersList
                                    .where((element) =>
                                        element.markerId == MarkerId(a!.Id))
                                    .toList()[0];
                                con.showMarkerInfoWindow(__markerA.markerId);

                                con.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                            target: __markerA.position,
                                            zoom: 15)));
                              },
                            ),
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    );
                  },
                ),
              );
            }),
        Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 28,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
// height: 200,
                        child: GestureDetector(
                          onTap: () async {
                            try {
                              // PlacesAutocomplete.show(context: context, apiKey: apiKey, )
                              //   activitiesList =
                              //       await Navigator.push(context, "")
                              //           as List<ActivitySchema>;
                            } catch (err) {}
                          },
                          child: Stack(
                            children: [
                              TextFormField(
                                controller: textEditingController,
                                textDirection:
                                    context.locale.languageCode == "ar"
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                onFieldSubmitted: (v) async {
                                  EasyLoading.show();

                                  HttpsCallableResult r =
                                      await FirebaseFunctions.instance
                                          .httpsCallable("SearchForActivity")
                                          .call(v);

                                  List<ActivitySchema> acl = [];
                                  for (var activityMap in r.data) {
                                    print(ActivitySchema.toSchema(activityMap));
                                    acl.add(
                                        ActivitySchema.toSchema(activityMap));
                                  }
                                  setState(() {
                                    if (acl.isEmpty) {
                                      noResult =
                                          "No matching experience found.";
                                    }
                                    activitiesList = acl;
                                  });
                                  EasyLoading.dismiss();
                                },
                                onChanged: (v) async {
                                  EasyLoading.show();
                                  draggableScrollableController.animateTo(0.75,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut);

                                  activitiesList = [];

                                  setState(() {
                                    noResult = null;
                                  });

                                  placeApiProvider
                                      .fetchSuggestions(context, v)
                                      .then(
                                    (value) {
                                      if (value != null) {
                                        setState(() {
                                          suggestionSearchList = value;
                                        });
                                      }
                                    },
                                  );

                                  EasyLoading.dismiss();
                                },
                                textInputAction: TextInputAction.search,
                                obscureText: false,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: "Where to go?".tr(),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black45,
                                      width: 1,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black45,
                                      width: 1,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                  ),
                                ),
                              ),
                              //   Align(
                              //                     alignment: const AlignmentDirectional(0, .9),

                              //     child: Container(
                              //       height: 200,
                              //       color: Colors.white,
                              //       child: SingleChildScrollView(
                              //         child: Column(
                              //           crossAxisAlignment: CrossAxisAlignment.start,
                              //             children: suggestionSearchList.map((e) {
                              //           return Material(
                              //               color: Colors.transparent,
                              //               child: InkWell(
                              //                   overlayColor:
                              //                       ColorsHelper.cardOverlayColor,
                              //                   splashColor:
                              //                       ColorsHelper.cardSplashColor,
                              //                   child: Container(
                              //                     margin: EdgeInsets.symmetric(
                              //                         vertical: 10),
                              //                     padding: EdgeInsets.all(10),
                              //                     child: Text(e.description),
                              //                   )));
                              //         }).toList()),
                              //       ),
                              //     ),
                              //   )
                            ],
                          ),

//                         TypeAheadField(
//   textFieldConfiguration: TextFieldConfiguration(
//     autofocus: true,
//     style: DefaultTextStyle.of(context).style.copyWith(
//       fontStyle: FontStyle.italic
//     ),
//     decoration: InputDecoration(
//       border: OutlineInputBorder()
//     )
//   ),
//   suggestionsCallback: (pattern) async {
//     return await BackendService.getSuggestions(pattern);
//   },
//   itemBuilder: (context, suggestion) {
//     return ListTile(
//       leading: Icon(Icons.shopping_cart),
//       title: Text(suggestion['name']),
//       subtitle: Text('\$${suggestion['price']}'),
//     );
//   },
//   onSuggestionSelected: (suggestion) {
//     Navigator.of(context).push(MaterialPageRoute(
//       builder: (context) => ProductPage(product: suggestion)
//     ));
//   },
// )
                        ),
                        //   ],
                        // ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.filter_list_rounded, size: 28),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                labelPadding: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(0),
                tabs: [
                  Tab(
                    child: Text("Activities".tr()),
                  ),
                  Tab(
                    child: Text("Chalets".tr()),
                  ),
                ],
                labelColor: Colors.black,
                indicatorColor: Colors.black87,
              ),
              const SizedBox(
                height: 10,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ...AppHelper.categories.map((e) {
                      print(categorySelected);
                      print(categorySelected == e["key"]);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: OutlinedButton(
                          onPressed: () async {
                            EasyLoading.show();

                            // HttpsCallableResult r = await FirebaseFunctions
                            //     .instance
                            //     .httpsCallable("SearchForActivityByCategory")
                            //     .call(e["title"]);

                            activitiesList = await activityProvider
                                .searchForActivityByCategory(
                                    e["title"].toString());

                            // activitiesList = [];
                            // for (var activityMap in r.data) {
                            //   print(activityMap);
                            //   activitiesList
                            //       .add(ActivitySchema.toSchema(activityMap));
                            // }

                            setState(() {
                              if (activitiesList.isEmpty) {
                                noResult = "No matching experience found.";
                              }
                              activitiesList = activitiesList;
                              categorySelected = e["key"];
                            });
                            EasyLoading.dismiss();
                          },
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black87,
                            backgroundColor: categorySelected == e["key"]
                                ? ColorsHelper.yellow.withOpacity(0.4)
                                : null,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            side: const BorderSide(width: 1),
                          ),
                          child: Text(
                            e["title"].toString().tr(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        Container(
            //   child: Expanded(
            // child: ListView.builder(
            //     itemCount: activitiesResultList.length,
            //     itemBuilder: (context, index) {
            //           ActivitySchema e = activitiesResultList[index];
            //           return GestureDetector(
            //             key: Key(e.Id),
            //             onTap: () async {
            //               activitiesList.add(e);
            //               setState(() {
            //                 activitiesList;
            //               });

            //               draggableScrollableController.animateTo(0.1,
            //                   duration: const Duration(milliseconds: 500),
            //                   curve: Curves.easeInOut);

            //               GoogleMapController con = await _controller.future;
            //               Marker __markerA = markersList
            //                   .where((element) =>
            //                       element.markerId == MarkerId(e.Id))
            //                   .toList()[0];
            //               con.showMarkerInfoWindow(__markerA.markerId);

            //               con.animateCamera(CameraUpdate.newCameraPosition(
            //                   CameraPosition(
            //                       target: __markerA.position, zoom: 30)));
            //             },
            //             child: Container(
            //               margin: EdgeInsets.symmetric(vertical: 10),
            //               child: Column(children: [
            //                 Text(
            //                   e.title,
            //                   overflow: TextOverflow.ellipsis,
            //                 ),
            //                 SizedBox(
            //                   height: 5,
            //                 ),
            //                 Text(
            //                   e.address,
            //                   style: Theme.of(context).textTheme.bodySmall,
            //                 )
            //               ]),
            //             ),
            //           );
            //         }),
            //   ),

            //   Column(children: [

            //     ...activitiesResultList.map(
            //       (e) {

            //       },
            //     ).toList()
            //   ]),
            ),
      ]),
    );
  }
}
