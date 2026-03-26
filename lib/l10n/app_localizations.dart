import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SKY PATH'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'REACH THE SKY'**
  String get appSubtitle;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get stars;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @gameStatistics.
  ///
  /// In en, this message translates to:
  /// **'Game Statistics'**
  String get gameStatistics;

  /// No description provided for @totalStarsEarned.
  ///
  /// In en, this message translates to:
  /// **'Total Stars Earned'**
  String get totalStarsEarned;

  /// No description provided for @totalCoinsCollected.
  ///
  /// In en, this message translates to:
  /// **'Total Coins Collected'**
  String get totalCoinsCollected;

  /// No description provided for @levelsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Levels Completed'**
  String get levelsCompleted;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'GOT IT'**
  String get gotIt;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @levelComplete.
  ///
  /// In en, this message translates to:
  /// **'Level Complete'**
  String get levelComplete;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @best.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @unlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Whole Game'**
  String get unlockTitle;

  /// No description provided for @unlockDescription.
  ///
  /// In en, this message translates to:
  /// **'Get access to the whole game! Unlock all premium levels with unique challenges, special platforms, and exclusive content!'**
  String get unlockDescription;

  /// No description provided for @featureAllLevels.
  ///
  /// In en, this message translates to:
  /// **'All Premium Levels'**
  String get featureAllLevels;

  /// No description provided for @featurePlatforms.
  ///
  /// In en, this message translates to:
  /// **'Special Platforms'**
  String get featurePlatforms;

  /// No description provided for @featureRewards.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Rewards'**
  String get featureRewards;

  /// No description provided for @featureOneTime.
  ///
  /// In en, this message translates to:
  /// **'One-Time Purchase'**
  String get featureOneTime;

  /// No description provided for @unlockNow.
  ///
  /// In en, this message translates to:
  /// **'UNLOCK NOW'**
  String get unlockNow;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'LATER'**
  String get later;

  /// No description provided for @lockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete the previous level first!'**
  String get lockedMessage;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to services...'**
  String get connecting;

  /// No description provided for @checkingUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get checkingUpdates;

  /// No description provided for @loadingStore.
  ///
  /// In en, this message translates to:
  /// **'Loading store...'**
  String get loadingStore;

  /// No description provided for @preparingAudio.
  ///
  /// In en, this message translates to:
  /// **'Preparing audio...'**
  String get preparingAudio;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready!'**
  String get ready;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequired;

  /// No description provided for @updateDescription.
  ///
  /// In en, this message translates to:
  /// **'A new version of Sky Path is available.\nPlease update to continue playing.'**
  String get updateDescription;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'UPDATE NOW'**
  String get updateNow;

  /// No description provided for @level1Name.
  ///
  /// In en, this message translates to:
  /// **'Green Meadows'**
  String get level1Name;

  /// No description provided for @level1Desc.
  ///
  /// In en, this message translates to:
  /// **'A peaceful beginning in the sunny meadows'**
  String get level1Desc;

  /// No description provided for @level2Name.
  ///
  /// In en, this message translates to:
  /// **'Crystal Caves'**
  String get level2Name;

  /// No description provided for @level2Desc.
  ///
  /// In en, this message translates to:
  /// **'Explore the sparkling underground caverns'**
  String get level2Desc;

  /// No description provided for @level3Name.
  ///
  /// In en, this message translates to:
  /// **'Sunset Peaks'**
  String get level3Name;

  /// No description provided for @level3Desc.
  ///
  /// In en, this message translates to:
  /// **'Climb the mountains at golden hour'**
  String get level3Desc;

  /// No description provided for @level4Name.
  ///
  /// In en, this message translates to:
  /// **'Frozen Tundra'**
  String get level4Name;

  /// No description provided for @level4Desc.
  ///
  /// In en, this message translates to:
  /// **'Navigate the icy platforms of the north'**
  String get level4Desc;

  /// No description provided for @level5Name.
  ///
  /// In en, this message translates to:
  /// **'Volcano Core'**
  String get level5Name;

  /// No description provided for @level5Desc.
  ///
  /// In en, this message translates to:
  /// **'Jump through the fiery depths of the volcano'**
  String get level5Desc;

  /// No description provided for @level6Name.
  ///
  /// In en, this message translates to:
  /// **'Cloud Kingdom'**
  String get level6Name;

  /// No description provided for @level6Desc.
  ///
  /// In en, this message translates to:
  /// **'Bounce among the clouds in the sky kingdom'**
  String get level6Desc;

  /// No description provided for @level7Name.
  ///
  /// In en, this message translates to:
  /// **'Neon City'**
  String get level7Name;

  /// No description provided for @level7Desc.
  ///
  /// In en, this message translates to:
  /// **'Cyberpunk platforms in the neon-lit city'**
  String get level7Desc;

  /// No description provided for @level8Name.
  ///
  /// In en, this message translates to:
  /// **'Space Station'**
  String get level8Name;

  /// No description provided for @level8Desc.
  ///
  /// In en, this message translates to:
  /// **'Zero-gravity jumps in outer space'**
  String get level8Desc;

  /// No description provided for @level9Name.
  ///
  /// In en, this message translates to:
  /// **'Dragon\'s Lair'**
  String get level9Name;

  /// No description provided for @level9Desc.
  ///
  /// In en, this message translates to:
  /// **'The ultimate challenge in the dragon\'s domain'**
  String get level9Desc;

  /// No description provided for @level10Name.
  ///
  /// In en, this message translates to:
  /// **'The Void'**
  String get level10Name;

  /// No description provided for @level10Desc.
  ///
  /// In en, this message translates to:
  /// **'A mysterious dimension with endless darkness'**
  String get level10Desc;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Jump through exciting levels, collect stars, and reach the sky in premium worlds!'**
  String get aboutDescription;

  /// No description provided for @madeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ by TifaSoft'**
  String get madeWith;

  /// No description provided for @premiumTag.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get premiumTag;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
