// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pixela Buttons';

  @override
  String get appTagline => 'Get started with your Pixela account';

  @override
  String get fieldRequired => 'Required';

  @override
  String get errorInvalidCredentials => 'Username or token is incorrect.';

  @override
  String get errorTimeout => 'Connection timed out. Please check your network.';

  @override
  String get errorNoNetwork => 'Cannot connect to the network.';

  @override
  String errorGeneric(String statusCode) {
    return 'An error occurred ($statusCode).';
  }

  @override
  String errorUnknown(String detail) {
    return 'An error occurred: $detail';
  }

  @override
  String get buttonStart => 'Get Started';

  @override
  String get linkCreateAccount => 'Don\'t have an account? Sign up here';

  @override
  String get tokenInvalidBanner =>
      'Your token has been invalidated. Please set it again.';

  @override
  String get screenRegister => 'Sign Up';

  @override
  String get fieldUsername => 'Username';

  @override
  String get fieldUsernameHelper =>
      '2–17 characters starting with a lowercase letter (letters, digits, hyphens)';

  @override
  String get fieldUsernameError =>
      '2–17 characters, starting with lowercase letter (letters, digits, hyphens only)';

  @override
  String get fieldToken => 'Token';

  @override
  String get fieldTokenHelper => '8–128 printable ASCII characters';

  @override
  String get fieldTokenError => '8–128 printable ASCII characters';

  @override
  String get labelAgreeTerms => 'I agree to Pixela\'\'s ';

  @override
  String get linkTermsOfService => 'Terms of Service';

  @override
  String get labelNotMinor => 'I am 18 or older, or have parental consent';

  @override
  String get errorAgreeAll => 'Please agree to all items';

  @override
  String get buttonRegister => 'Register';

  @override
  String errorRegisterFailed(String statusCode) {
    return 'Registration failed ($statusCode).';
  }

  @override
  String errorRegisterUnknown(String detail) {
    return 'Registration failed: $detail';
  }

  @override
  String get screenHome => 'Pixela Buttons';

  @override
  String get tooltipAddButton => 'Add button';

  @override
  String labelUnit(String unit) {
    return 'Unit: $unit';
  }

  @override
  String labelToday(String value, String unit) {
    return 'Today: $value$unit';
  }

  @override
  String labelUnitToday(String unit, String value) {
    return 'Unit: $unit   Today: $value$unit';
  }

  @override
  String get buttonCustom => 'Custom';

  @override
  String get tooltipOpenGraph => 'Open graph';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuDelete => 'Delete';

  @override
  String get emptyHomeMessage => 'No buttons yet';

  @override
  String get emptyHomeSubMessage => 'Tap + in the top right to add one';

  @override
  String get customDialogTitle => 'Enter custom value';

  @override
  String get customDialogHelper => 'Positive: add   Negative: subtract';

  @override
  String get buttonRecord => 'Record';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get confirmDeleteTitle => 'Confirm deletion';

  @override
  String get confirmDeleteMessage => 'Delete this card?';

  @override
  String get buttonDelete => 'Delete';

  @override
  String errorRecord(String detail) {
    return 'Error: $detail';
  }

  @override
  String get dialogRecordedTitle => 'Recorded';

  @override
  String dialogRecordedMessage(String value) {
    return '$value recorded';
  }

  @override
  String dialogTodayTotal(String value, String unit) {
    return 'Today\'\'s total: $value$unit';
  }

  @override
  String get dialogTodayFailed => 'Failed to retrieve total';

  @override
  String get buttonOk => 'OK';

  @override
  String get screenButtonEdit => 'Edit Button';

  @override
  String get screenButtonAdd => 'Add Button';

  @override
  String get buttonSave => 'Save';

  @override
  String get labelGraph => 'Graph';

  @override
  String get labelGraphPlaceholder => 'Tap to select';

  @override
  String labelGraphSubtitle(String name, String id, String unit) {
    return '$name\n$id  ·  Unit: $unit';
  }

  @override
  String get fieldDisplayName => 'Display name';

  @override
  String get fieldEmoji => 'Emoji (optional)';

  @override
  String get emojiNotSet => 'Not set';

  @override
  String get labelButtonColor => 'Button color (add)';

  @override
  String get labelFixedButtons => 'Fixed buttons';

  @override
  String get tooltipAddFixedButton => 'Add button';

  @override
  String get noFixedButtons => 'No buttons';

  @override
  String get addFixedButtonTitle => 'Add fixed button';

  @override
  String get addFixedButtonHelper => 'Positive: add   Negative: subtract';

  @override
  String get addFixedButtonError => 'Please enter a number';

  @override
  String get buttonAdd => 'Add';

  @override
  String get snackSelectGraph => 'Please select a graph';

  @override
  String get emojiPickerTitle => 'Select emoji';

  @override
  String get emojiPickerClear => 'Clear';

  @override
  String get screenGraphs => 'Graphs';

  @override
  String get tooltipCreateGraph => 'Create graph';

  @override
  String get noGraphs => 'No graphs';

  @override
  String get errorRetry => 'Retry';

  @override
  String get screenCreateGraph => 'Create Graph';

  @override
  String get buttonCreate => 'Create';

  @override
  String get fieldGraphId => 'Graph ID *';

  @override
  String get fieldGraphIdHelper =>
      '2–17 chars starting with lowercase letter (letters, digits, hyphens)';

  @override
  String get fieldGraphIdError =>
      '2–17 chars, starting with lowercase letter (letters, digits, hyphens only)';

  @override
  String get fieldGraphName => 'Graph name *';

  @override
  String get fieldUnit => 'Unit *';

  @override
  String get fieldUnitHelper => 'e.g. km, commit, kg';

  @override
  String get fieldType => 'Type *';

  @override
  String get typeInt => 'int (integer)';

  @override
  String get typeFloat => 'float (decimal)';

  @override
  String get fieldColor => 'Color *';

  @override
  String get fieldTimezone => 'Timezone';

  @override
  String get timezoneNotSet => 'Not set';

  @override
  String get screenSettings => 'Settings';

  @override
  String get labelUsernameItem => 'Username';

  @override
  String get labelChangeToken => 'Change saved token';

  @override
  String get labelLogout => 'Log Out';

  @override
  String get dialogChangeTokenTitle => 'Change Saved Token';

  @override
  String get fieldNewToken => 'New token';

  @override
  String get errorTokenIncorrect => 'Token is incorrect';

  @override
  String get errorTokenGeneric => 'An error occurred';

  @override
  String get dialogLogoutTitle => 'Log Out';

  @override
  String get dialogLogoutMessage =>
      'You will be logged out. Card settings will be preserved and restored on next login.';

  @override
  String get buttonLogout => 'Log Out';

  @override
  String get tabHome => 'Home';

  @override
  String get tabGraphs => 'Graphs';

  @override
  String get tabSettings => 'Settings';

  @override
  String get screenTimezoneSearch => 'Search Timezone';

  @override
  String get labelLanguage => 'Language';

  @override
  String get languageSystem => 'Follow system';

  @override
  String get languageJa => '日本語';

  @override
  String get languageEn => 'English';
}
