import 'package:oman_trippoint/helpers/adHelper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Adcontainer extends StatefulWidget {
  const Adcontainer({super.key});

  @override
  State<Adcontainer> createState() => _AdcontainerState();
}

class _AdcontainerState extends State<Adcontainer> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bannerAd?.dispose();
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bannerAd?.dispose();
    print("dispose Ad - 001001 ");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    return SizedBox();
  }
}
