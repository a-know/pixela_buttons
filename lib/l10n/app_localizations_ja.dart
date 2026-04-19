// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Pixela Buttons';

  @override
  String get appTagline => 'Pixela への記録をワンタップで';

  @override
  String get fieldRequired => '入力してください';

  @override
  String get errorInvalidCredentials => 'ユーザー名またはトークンが正しくありません。';

  @override
  String get errorTimeout => '接続がタイムアウトしました。ネットワークを確認してください。';

  @override
  String get errorNoNetwork => 'ネットワークに接続できません。';

  @override
  String errorGeneric(String statusCode) {
    return 'エラーが発生しました（$statusCode）。';
  }

  @override
  String errorUnknown(String detail) {
    return 'エラーが発生しました: $detail';
  }

  @override
  String get buttonStart => 'はじめる';

  @override
  String get linkCreateAccount => 'アカウントをお持ちでない方はこちら';

  @override
  String get tokenInvalidBanner => 'トークンが無効になったため、再度設定してください';

  @override
  String get screenRegister => '新規登録';

  @override
  String get fieldUsername => 'ユーザー名';

  @override
  String get fieldUsernameHelper => '小文字英字で始まる2〜17文字（英数字・ハイフン）';

  @override
  String get fieldUsernameError => '小文字英字で始まる2〜17文字（英数字・ハイフンのみ）';

  @override
  String get fieldToken => 'トークン';

  @override
  String get fieldTokenHelper => '8〜128文字（ASCII印字可能文字）';

  @override
  String get fieldTokenError => '8〜128文字のASCII印字可能文字';

  @override
  String get labelAgreeTerms => 'Pixelaの';

  @override
  String get linkTermsOfService => '利用規約';

  @override
  String get labelNotMinor => '18歳以上である、または保護者の同意を得ている';

  @override
  String get errorAgreeAll => 'すべての項目に同意してください';

  @override
  String get buttonRegister => '登録する';

  @override
  String errorRegisterFailed(String statusCode) {
    return '登録に失敗しました（$statusCode）。';
  }

  @override
  String errorRegisterUnknown(String detail) {
    return '登録に失敗しました: $detail';
  }

  @override
  String get screenHome => 'Pixela Buttons';

  @override
  String get tooltipAddButton => 'ボタンを追加';

  @override
  String labelUnit(String unit) {
    return '単位: $unit';
  }

  @override
  String labelToday(String value, String unit) {
    return '今日: $value$unit';
  }

  @override
  String labelUnitToday(String unit, String value) {
    return '単位: $unit　今日: $value$unit';
  }

  @override
  String get buttonCustom => 'カスタム';

  @override
  String get tooltipOpenGraph => 'グラフを開く';

  @override
  String get menuEdit => '編集';

  @override
  String get menuDelete => '削除';

  @override
  String get emptyHomeMessage => 'ボタンがまだありません';

  @override
  String get emptyHomeSubMessage => '右上の ＋ から追加してください';

  @override
  String get customDialogTitle => 'カスタム値を入力';

  @override
  String get customDialogHelper => '正の数: 加算　負の数: 減算';

  @override
  String get buttonRecord => '記録';

  @override
  String get buttonCancel => 'キャンセル';

  @override
  String get confirmDeleteTitle => '削除の確認';

  @override
  String get confirmDeleteMessage => 'このカードを削除しますか？';

  @override
  String get buttonDelete => '削除';

  @override
  String errorRecord(String detail) {
    return 'エラー: $detail';
  }

  @override
  String get dialogRecordedTitle => '記録しました';

  @override
  String dialogRecordedMessage(String value) {
    return '$value を記録しました';
  }

  @override
  String dialogTodayTotal(String value, String unit) {
    return '今日の合計: $value$unit';
  }

  @override
  String get dialogTodayFailed => '累計値の取得に失敗しました';

  @override
  String get buttonOk => 'OK';

  @override
  String get screenButtonEdit => 'ボタンを編集';

  @override
  String get screenButtonAdd => 'ボタンを追加';

  @override
  String get buttonSave => '保存';

  @override
  String get labelGraph => 'グラフ';

  @override
  String get labelGraphPlaceholder => 'タップして選択';

  @override
  String labelGraphSubtitle(String name, String id, String unit) {
    return '$name\n$id  ·  単位: $unit';
  }

  @override
  String get fieldDisplayName => '表示名';

  @override
  String get fieldEmoji => 'emoji（任意）';

  @override
  String get emojiNotSet => '未設定';

  @override
  String get labelButtonColor => 'ボタン色（加算）';

  @override
  String get labelFixedButtons => '固定値ボタン';

  @override
  String get tooltipAddFixedButton => 'ボタンを追加';

  @override
  String get noFixedButtons => 'ボタンがありません';

  @override
  String get addFixedButtonTitle => '固定値ボタンを追加';

  @override
  String get addFixedButtonHelper => '正: 加算 / 負: 減算';

  @override
  String get addFixedButtonError => '数値を入力してください';

  @override
  String get buttonAdd => '追加';

  @override
  String get snackSelectGraph => 'グラフを選択してください';

  @override
  String get emojiPickerTitle => 'emoji を選択';

  @override
  String get emojiPickerClear => 'クリア';

  @override
  String get screenGraphs => 'グラフ';

  @override
  String get tooltipCreateGraph => 'グラフを作成';

  @override
  String get noGraphs => 'グラフがありません';

  @override
  String get errorRetry => '再試行';

  @override
  String get screenCreateGraph => 'グラフを作成';

  @override
  String get buttonCreate => '作成';

  @override
  String get fieldGraphId => 'グラフID *';

  @override
  String get fieldGraphIdHelper => '小文字英字で始まる2〜17文字（英数字・ハイフン）';

  @override
  String get fieldGraphIdError => '小文字英字で始まる2〜17文字（英数字・ハイフンのみ）';

  @override
  String get fieldGraphName => 'グラフ名 *';

  @override
  String get fieldUnit => '単位 *';

  @override
  String get fieldUnitHelper => '例: km、commit、kg';

  @override
  String get fieldType => 'タイプ *';

  @override
  String get typeInt => 'int（整数）';

  @override
  String get typeFloat => 'float（小数）';

  @override
  String get fieldColor => 'カラー *';

  @override
  String get fieldTimezone => 'タイムゾーン';

  @override
  String get timezoneNotSet => '未設定';

  @override
  String get screenSettings => '設定';

  @override
  String get labelUsernameItem => 'ユーザー名';

  @override
  String get labelChangeToken => 'アプリに保存済みのトークンを変更';

  @override
  String get labelLogout => 'ログアウト';

  @override
  String get dialogChangeTokenTitle => '保存済みトークンを変更';

  @override
  String get fieldNewToken => '新しいトークン';

  @override
  String get errorTokenIncorrect => 'トークンが正しくありません';

  @override
  String get errorTokenGeneric => 'エラーが発生しました';

  @override
  String get dialogLogoutTitle => 'ログアウト';

  @override
  String get dialogLogoutMessage => 'ログアウトします。カード設定は保持され、再ログイン時に復元されます。';

  @override
  String get buttonLogout => 'ログアウト';

  @override
  String get tabHome => 'ホーム';

  @override
  String get tabGraphs => 'グラフ';

  @override
  String get tabSettings => '設定';

  @override
  String get screenTimezoneSearch => 'タイムゾーンを検索...';

  @override
  String get labelLanguage => '言語';

  @override
  String get languageSystem => 'システムに合わせる';

  @override
  String get languageJa => '日本語';

  @override
  String get languageEn => 'English';
}
