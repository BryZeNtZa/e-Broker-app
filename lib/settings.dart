import 'package:ebroker/utils/helper_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// eBroker configuration file
/// Configure your app from here
/// Most of basic configuration will be from here
/// For theme colors go to [lib/ui/Theme/theme.dart]

class AppSettings {
  ///Basic Settings
  static const String applicationName = 'eBroker';
  static const String androidPackageName = 'com.ebroker.wrteam';

  ///API Setting
  static const String hostUrl = 'https://ebroker.wrteam.me/';
  // ebroker.wrteam.me

  static const int apiDataLoadLimit = 10;
  static const int maxCategoryShowLengthInHomeScreen = 5;

  static final String baseUrl =
      '${HelperUtils.checkHost(hostUrl)}api/'; //Don't change this

  static const int hiddenAPIProcessDelay = 1;

  /* this is for load data when open app if old data is already available so
it will call API in background without showing the process and when data available it will replace it with new data */

  ///Set type here
  static const DeepLinkType deepLinkingType = DeepLinkType.native;

  static String? priceFormat =
      'en'; //keep null if you want to use default one supported: [en,hi,ar_EN,ar]

  ///Deep link
  static const String shareNavigationWebUrl = 'ebrokerweb.wrteam.me';
  //ebrokerweb.wrteam.me

  static const MapType googleMapType =
      MapType.normal; //none , normal , satellite , terrain , hybrid

  ///Firebase authentication OTP timer.
  static const int otpResendSecond = 120;
  static const int otpTimeOutSecond = 120;
  static const int otpResendSecondForEmail = 600;

  ///This code will show on login screen [Note: don't add  + symbol]
  static const String defaultCountryCode = '91';
  static const bool disableCountrySelection = false;

  /* Default [False], this will hide
 Country number choose option in login screen. if your App is for only one country this might be helpful*/

  static List<HomeScreenSections> sections = [
    //[Note: We Recommend default setting you can make arrangement by your choice or you can hide any section if you do not want]
    HomeScreenSections.search,
    HomeScreenSections.slider,
    HomeScreenSections.category,
    HomeScreenSections.nearbyProperties,
    HomeScreenSections.featuredProperties,
    HomeScreenSections.personalizedFeed,
    HomeScreenSections.featuredProjects,
    HomeScreenSections.mostLikedProperties,
    HomeScreenSections.agents,
    HomeScreenSections.project,
    HomeScreenSections.mostViewed,
    HomeScreenSections.popularCities,
  ]; //[Note: We Recommend default setting you can make arrangement by your choice or you can hide any section if you do not want]

  ///Lottie animation
  ///Put your loading json file in [lib/assets/lottie/] folder
  static const String progressLottieFile = 'loading.json';
  static const String progressLottieFileWhite =
      'loading_white.json'; //When there is dark background and you want to show progress so it will be used

  static const String maintenanceModeLottieFile = 'maintenancemode.json';

  static const bool useLottieProgress =
      true; //if you don't want to use lottie progress then set it to false'

  ///Other settings
  static const String notificationChannel = 'basic_channel'; //
  static int uploadImageQuality = 50; //0 to 100th

  //// Don't change these
  //// Payment gatway API keys
  ///Here is for only reference you have to change it from panel
  static String enabledPaymentGatway = '';
  static String razorpayKey = '';
  static String paystackKey = ''; // public key
  static String paystackCurrency = '';
  static String paypalClientId = '';
  static String paypalServerKey = ''; //secrete
  static bool isSandBoxMode = true; //testing mode
  static String paypalCancelURL = '';
  static String paypalReturnURL = '';
  static String stripeCurrency = '';
  static String stripePublishableKey = '';
  static String stripeSecrateKey = '';
  static String otpServiceProvider = '';

  ///Do not set here
  static String iOSAppId = '';
  static String playstoreURLAndroid = '';
  static String appstoreURLios = '';

  static bool isVerificationRequired = false;

  // static String currencyName = '';
  static String currencyCode = '';
  static String currencySymbol = '';

  static String latitude = '';
  static String longitude = '';
  static String minRadius = '';
  static String maxRadius = '';

  static List<Map<String, dynamic>> bankTransferDetails = [];
}

enum HomeScreenSections {
  search,
  slider,
  personalizedFeed,
  nearbyProperties,
  featuredProperties,
  mostLikedProperties,
  popularCities,
  agents,
  mostViewed,
  category,
  project,
  featuredProjects,
}

enum DeepLinkType { native }
