import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

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
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pixela Buttons'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Record to Pixela with one tap'**
  String get appTagline;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Username or token is incorrect.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please check your network.'**
  String get errorTimeout;

  /// No description provided for @errorNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to the network.'**
  String get errorNoNetwork;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred ({statusCode}).'**
  String errorGeneric(String statusCode);

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {detail}'**
  String errorUnknown(String detail);

  /// No description provided for @buttonStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get buttonStart;

  /// No description provided for @linkCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up here'**
  String get linkCreateAccount;

  /// No description provided for @tokenInvalidBanner.
  ///
  /// In en, this message translates to:
  /// **'Your token has been invalidated. Please set it again.'**
  String get tokenInvalidBanner;

  /// No description provided for @screenRegister.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get screenRegister;

  /// No description provided for @fieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get fieldUsername;

  /// No description provided for @fieldUsernameHelper.
  ///
  /// In en, this message translates to:
  /// **'2–17 characters starting with a lowercase letter (letters, digits, hyphens)'**
  String get fieldUsernameHelper;

  /// No description provided for @fieldUsernameError.
  ///
  /// In en, this message translates to:
  /// **'2–17 characters, starting with lowercase letter (letters, digits, hyphens only)'**
  String get fieldUsernameError;

  /// No description provided for @fieldToken.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get fieldToken;

  /// No description provided for @fieldTokenHelper.
  ///
  /// In en, this message translates to:
  /// **'8–128 printable ASCII characters'**
  String get fieldTokenHelper;

  /// No description provided for @fieldTokenError.
  ///
  /// In en, this message translates to:
  /// **'8–128 printable ASCII characters'**
  String get fieldTokenError;

  /// No description provided for @labelAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to Pixela\'\'s '**
  String get labelAgreeTerms;

  /// No description provided for @linkTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get linkTermsOfService;

  /// No description provided for @labelNotMinor.
  ///
  /// In en, this message translates to:
  /// **'I am 18 or older, or have parental consent'**
  String get labelNotMinor;

  /// No description provided for @errorAgreeAll.
  ///
  /// In en, this message translates to:
  /// **'Please agree to all items'**
  String get errorAgreeAll;

  /// No description provided for @buttonRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get buttonRegister;

  /// No description provided for @errorRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed ({statusCode}).'**
  String errorRegisterFailed(String statusCode);

  /// No description provided for @errorRegisterUnknown.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {detail}'**
  String errorRegisterUnknown(String detail);

  /// No description provided for @screenHome.
  ///
  /// In en, this message translates to:
  /// **'Pixela Buttons'**
  String get screenHome;

  /// No description provided for @tooltipAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add button'**
  String get tooltipAddButton;

  /// No description provided for @labelUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit: {unit}'**
  String labelUnit(String unit);

  /// No description provided for @labelToday.
  ///
  /// In en, this message translates to:
  /// **'Today: {value}{unit}'**
  String labelToday(String value, String unit);

  /// No description provided for @labelUnitToday.
  ///
  /// In en, this message translates to:
  /// **'Unit: {unit}   Today: {value}{unit}'**
  String labelUnitToday(String unit, String value);

  /// No description provided for @buttonCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get buttonCustom;

  /// No description provided for @tooltipOpenGraph.
  ///
  /// In en, this message translates to:
  /// **'Open graph'**
  String get tooltipOpenGraph;

  /// No description provided for @menuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuEdit;

  /// No description provided for @menuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get menuDelete;

  /// No description provided for @emptyHomeMessage.
  ///
  /// In en, this message translates to:
  /// **'No buttons yet'**
  String get emptyHomeMessage;

  /// No description provided for @emptyHomeSubMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap + in the top right to add one'**
  String get emptyHomeSubMessage;

  /// No description provided for @customDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter custom value'**
  String get customDialogTitle;

  /// No description provided for @customDialogHelper.
  ///
  /// In en, this message translates to:
  /// **'Positive: add   Negative: subtract'**
  String get customDialogHelper;

  /// No description provided for @buttonRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get buttonRecord;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this card?'**
  String get confirmDeleteMessage;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @errorRecord.
  ///
  /// In en, this message translates to:
  /// **'Error: {detail}'**
  String errorRecord(String detail);

  /// No description provided for @dialogRecordedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get dialogRecordedTitle;

  /// No description provided for @dialogRecordedMessage.
  ///
  /// In en, this message translates to:
  /// **'{value} recorded'**
  String dialogRecordedMessage(String value);

  /// No description provided for @dialogTodayTotal.
  ///
  /// In en, this message translates to:
  /// **'Today\'\'s total: {value}{unit}'**
  String dialogTodayTotal(String value, String unit);

  /// No description provided for @dialogTodayFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve total'**
  String get dialogTodayFailed;

  /// No description provided for @buttonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// No description provided for @screenButtonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Button'**
  String get screenButtonEdit;

  /// No description provided for @screenButtonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Button'**
  String get screenButtonAdd;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @labelGraph.
  ///
  /// In en, this message translates to:
  /// **'Graph'**
  String get labelGraph;

  /// No description provided for @labelGraphPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get labelGraphPlaceholder;

  /// No description provided for @labelGraphSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\n{id}  ·  Unit: {unit}'**
  String labelGraphSubtitle(String name, String id, String unit);

  /// No description provided for @fieldDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get fieldDisplayName;

  /// No description provided for @fieldEmoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji (optional)'**
  String get fieldEmoji;

  /// No description provided for @emojiNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get emojiNotSet;

  /// No description provided for @labelButtonColor.
  ///
  /// In en, this message translates to:
  /// **'Button color (add)'**
  String get labelButtonColor;

  /// No description provided for @labelFixedButtons.
  ///
  /// In en, this message translates to:
  /// **'Fixed buttons'**
  String get labelFixedButtons;

  /// No description provided for @tooltipAddFixedButton.
  ///
  /// In en, this message translates to:
  /// **'Add button'**
  String get tooltipAddFixedButton;

  /// No description provided for @noFixedButtons.
  ///
  /// In en, this message translates to:
  /// **'No buttons'**
  String get noFixedButtons;

  /// No description provided for @addFixedButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Add fixed button'**
  String get addFixedButtonTitle;

  /// No description provided for @addFixedButtonHelper.
  ///
  /// In en, this message translates to:
  /// **'Positive: add   Negative: subtract'**
  String get addFixedButtonHelper;

  /// No description provided for @addFixedButtonError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number'**
  String get addFixedButtonError;

  /// No description provided for @buttonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// No description provided for @snackSelectGraph.
  ///
  /// In en, this message translates to:
  /// **'Please select a graph'**
  String get snackSelectGraph;

  /// No description provided for @emojiPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select emoji'**
  String get emojiPickerTitle;

  /// No description provided for @emojiPickerClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get emojiPickerClear;

  /// No description provided for @screenGraphs.
  ///
  /// In en, this message translates to:
  /// **'Graphs'**
  String get screenGraphs;

  /// No description provided for @tooltipCreateGraph.
  ///
  /// In en, this message translates to:
  /// **'Create graph'**
  String get tooltipCreateGraph;

  /// No description provided for @noGraphs.
  ///
  /// In en, this message translates to:
  /// **'No graphs'**
  String get noGraphs;

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errorRetry;

  /// No description provided for @screenCreateGraph.
  ///
  /// In en, this message translates to:
  /// **'Create Graph'**
  String get screenCreateGraph;

  /// No description provided for @buttonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get buttonCreate;

  /// No description provided for @fieldGraphId.
  ///
  /// In en, this message translates to:
  /// **'Graph ID *'**
  String get fieldGraphId;

  /// No description provided for @fieldGraphIdHelper.
  ///
  /// In en, this message translates to:
  /// **'2–17 chars starting with lowercase letter (letters, digits, hyphens)'**
  String get fieldGraphIdHelper;

  /// No description provided for @fieldGraphIdError.
  ///
  /// In en, this message translates to:
  /// **'2–17 chars, starting with lowercase letter (letters, digits, hyphens only)'**
  String get fieldGraphIdError;

  /// No description provided for @fieldGraphName.
  ///
  /// In en, this message translates to:
  /// **'Graph name *'**
  String get fieldGraphName;

  /// No description provided for @fieldUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit *'**
  String get fieldUnit;

  /// No description provided for @fieldUnitHelper.
  ///
  /// In en, this message translates to:
  /// **'e.g. km, commit, kg'**
  String get fieldUnitHelper;

  /// No description provided for @fieldType.
  ///
  /// In en, this message translates to:
  /// **'Type *'**
  String get fieldType;

  /// No description provided for @typeInt.
  ///
  /// In en, this message translates to:
  /// **'int (integer)'**
  String get typeInt;

  /// No description provided for @typeFloat.
  ///
  /// In en, this message translates to:
  /// **'float (decimal)'**
  String get typeFloat;

  /// No description provided for @fieldColor.
  ///
  /// In en, this message translates to:
  /// **'Color *'**
  String get fieldColor;

  /// No description provided for @fieldTimezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get fieldTimezone;

  /// No description provided for @timezoneNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get timezoneNotSet;

  /// No description provided for @screenSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get screenSettings;

  /// No description provided for @labelUsernameItem.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get labelUsernameItem;

  /// No description provided for @labelChangeToken.
  ///
  /// In en, this message translates to:
  /// **'Change saved token'**
  String get labelChangeToken;

  /// No description provided for @labelLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get labelLogout;

  /// No description provided for @dialogChangeTokenTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Saved Token'**
  String get dialogChangeTokenTitle;

  /// No description provided for @fieldNewToken.
  ///
  /// In en, this message translates to:
  /// **'New token'**
  String get fieldNewToken;

  /// No description provided for @errorTokenIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Token is incorrect'**
  String get errorTokenIncorrect;

  /// No description provided for @errorTokenGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorTokenGeneric;

  /// No description provided for @dialogLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get dialogLogoutTitle;

  /// No description provided for @dialogLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'You will be logged out. Card settings will be preserved and restored on next login.'**
  String get dialogLogoutMessage;

  /// No description provided for @buttonLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get buttonLogout;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabGraphs.
  ///
  /// In en, this message translates to:
  /// **'Graphs'**
  String get tabGraphs;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @screenTimezoneSearch.
  ///
  /// In en, this message translates to:
  /// **'Search Timezone'**
  String get screenTimezoneSearch;

  /// No description provided for @labelLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get labelLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get languageSystem;

  /// No description provided for @languageJa.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJa;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;
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
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
