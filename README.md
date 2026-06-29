# Pixela Buttons

A mobile app for recording your daily habits to [Pixela](https://pixe.la/) with a single tap.  
[Pixela](https://pixe.la/) への記録をワンタップで行えるスマホアプリです。

<!-- App Store バッジ（公開後に追加） -->
<!-- [![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/app/idXXXXXXXXXX) -->

## About / アプリについて

**English**

Pixela Buttons is a client app for Pixela users. Register your frequently used values as buttons and record your daily habits with a single tap.

**Features**
- Create a card for each graph and register preset value buttons
- Enter any value with the custom button (positive to add, negative to subtract)
- Reorder cards, customize emoji and colors
- Automatically retries Pixela's request rejections (non-supporters can record without interruption)
- Supports English and Japanese

**Requirements**
- iOS 13.0 or later

---

**日本語**

Pixela Buttons は、Pixela ユーザー向けのクライアントアプリです。よく使う記録値をボタンとして登録しておくことで、毎日の習慣をワンタップで記録できます。

**主な機能**
- グラフごとにカードを作成し、固定値ボタンを登録
- カスタムボタンで任意の値を入力（正の数で加算、負の数で減算）
- カードの並び替え・絵文字・カラーのカスタマイズ
- Pixela のリクエストリジェクトを自動リトライ（非サポーターでも記録が途切れない）
- 日本語・英語対応

**動作環境**
- iOS 13.0 以上

## Support / サポート・バグ報告

For bug reports and feature requests, please use [Issues](https://github.com/a-know/pixela_buttons/issues).  
不具合や要望は [Issues](https://github.com/a-know/pixela_buttons/issues) からご報告ください。

## Privacy Policy / プライバシーポリシー

https://pixe.la/app_privacy_policy.txt

---

## 開発環境のセットアップ

### 必要なもの

- [Flutter](https://docs.flutter.dev/get-started/install) (stable channel)
- [Android Studio](https://developer.android.com/studio)（Android開発・エミュレーター用）
- [Xcode](https://developer.apple.com/xcode/)（iOS開発用、Mac only）

### セットアップ手順

```bash
# 依存パッケージのインストール
flutter pub get
```

## iOS シミュレーターで実行する

```bash
# シミュレーターを起動（Simulator.app を開く）
open -a Simulator

# アプリを実行
flutter run
```

## Android エミュレーターで実行する

**1. エミュレーターを起動する**

Android Studio を開いて **Tools → Device Manager** → 作成済みのデバイスの ▶ ボタンをクリック

エミュレーターがまだない場合は **Virtual Device Manager → Create Virtual Device** から作成してください。

**2. 起動を確認する**

```bash
flutter devices
```

エミュレーターが一覧に表示されればOK。

**3. アプリを実行する**

```bash
flutter run
```

複数デバイスが接続されている場合はデバイスIDを指定：

```bash
flutter run -d <device_id>
```

## Android APK をビルドする

リリース用 APK をビルドするには、事前に `android/key.properties` にキーストア情報を設定する必要があります。

```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

## 静的解析・テスト

```bash
flutter analyze
flutter test
```

### Maestro E2E テスト

ネイティブ UI の E2E テストには [Maestro](https://maestro.mobile.dev/) を使います。flow は `.maestro/flows` にあります。

```bash
# Maestro のインストール
curl -fsSL "https://get.maestro.mobile.dev" | bash

# iOS シミュレーターで実行する場合。Android は com.aknow.pixela_buttons を指定してください。
export MAESTRO_APP_ID="com.a-know.pixelaButtons"

scripts/maestro_test.sh
```

実行前にシミュレーター/エミュレーターを起動し、言語を日本語にしてください。デフォルトでは disposable な Pixela ユーザーを作成し、後続テストで使い回し、最後に削除します。作成・削除を含むテストデータの詳細は `.maestro/README.md` を参照してください。

## セキュリティチェック

コミット前に、ステージ済みの変更を Semgrep と Gitleaks で検査します。

```bash
brew install semgrep gitleaks
git config core.hooksPath .githooks
```

設定後は、`git commit` の実行時にセキュリティチェックが自動で行われます。
