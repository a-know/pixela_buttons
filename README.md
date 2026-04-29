# Pixela Buttons

[Pixela](https://pixe.la/) への記録をワンタップで行えるスマホアプリです。

<!-- App Store バッジ（公開後に追加） -->
<!-- [![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/app/idXXXXXXXXXX) -->

## アプリについて

Pixela Buttons は、Pixela ユーザー向けのクライアントアプリです。よく使う記録値をボタンとして登録しておくことで、毎日の習慣をワンタップで記録できます。

**主な機能**

- グラフごとにカードを作成し、固定値ボタンを登録
- カスタムボタンで任意の値を入力（正の数で加算、負の数で減算）
- カードの並び替え・絵文字・カラーのカスタマイズ
- Pixela のリクエストリジェクトを自動リトライ（非サポーターでも記録が途切れない）
- 日本語・英語対応

**動作環境**

- iOS 13.0 以上

## サポート・バグ報告

不具合や要望は [Issues](https://github.com/a-know/pixela_buttons/issues) からご報告ください。

## プライバシーポリシー

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
