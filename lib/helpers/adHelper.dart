import 'dart:io';

class AdHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9901773789494212/8746450607';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9901773789494212/8352269752';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9901773789494212/3674658145';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9901773789494212/3099943078';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
  

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9901773789494212/3985665246';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9901773789494212/7158623491';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9901773789494212/4604596434';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9901773789494212/9405512888';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}