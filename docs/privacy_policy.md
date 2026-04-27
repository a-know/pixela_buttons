# Privacy Policy / プライバシーポリシー

> このファイルは文案です。公開時は Web ページ（GitHub Pages・Notion 等）にそのまま掲載できます。
> 公開後、App Store Connect の「プライバシーポリシー URL」欄に URL を入力してください。

---

## English

**Effective date:** TBD

### Overview

Pixela Buttons ("the App") is a client app for [Pixela](https://pixe.la/). This policy describes what information the App collects, how it is used, and how it is stored.

### Information We Collect

The App collects only the information you explicitly provide:

| Data | Purpose | Where it is stored |
|------|---------|-------------------|
| Pixela username | Identifying your Pixela account | On your device (SharedPreferences) |
| Pixela token | Authenticating API requests to Pixela | On your device (iOS Keychain via flutter_secure_storage) |
| Card and button settings | Displaying your configured cards | On your device (SharedPreferences) |

The App does not collect analytics, advertising identifiers, location data, or any other personal information.

### How Your Information Is Used

- Your username and token are used solely to make API requests to Pixela on your behalf.
- Card and button settings are used solely to display and operate your configured cards within the App.
- None of your information is used for advertising or sold to third parties.

### Third-Party Services

The App communicates exclusively with the [Pixela API](https://docs.pixe.la/) (pixe.la). Your username, token, and pixel values are transmitted to Pixela when you record an activity. Please refer to [Pixela's privacy policy](https://pixe.la/) for details on how Pixela handles your data.

No other third-party SDKs, analytics services, or advertising networks are used.

### Data Storage and Security

- Your Pixela token is stored in the iOS Keychain (via `flutter_secure_storage`), which is encrypted and protected by the operating system.
- All other settings are stored locally on your device and are never transmitted to any server other than Pixela.

### Children's Privacy

The App does not knowingly collect personal information from children under the age of 13.

### Changes to This Policy

If this policy is updated, the new version will be published at the same URL with an updated effective date.

### Contact

If you have any questions about this privacy policy, please contact:
**a.know.dev@gmail.com**

---

## 日本語

**施行日:** 未定

### 概要

Pixela Buttons（以下「本アプリ」）は、[Pixela](https://pixe.la/) のクライアントアプリです。本ポリシーでは、本アプリが収集する情報・その利用目的・保存方法について説明します。

### 収集する情報

本アプリが収集するのは、ユーザーが明示的に入力した情報のみです。

| データ | 目的 | 保存場所 |
|--------|------|----------|
| Pixela ユーザー名 | Pixela アカウントの識別 | 端末内（SharedPreferences） |
| Pixela トークン | Pixela API の認証 | 端末内（flutter_secure_storage 経由の iOS Keychain） |
| カード・ボタンの設定 | カード一覧の表示と操作 | 端末内（SharedPreferences） |

本アプリは、アナリティクス・広告識別子・位置情報・その他の個人情報を一切収集しません。

### 情報の利用目的

- ユーザー名とトークンは、ユーザーに代わって Pixela API へリクエストを送信する目的にのみ使用します。
- カード・ボタンの設定は、本アプリ内でカードを表示・操作する目的にのみ使用します。
- 収集した情報を広告目的に使用したり、第三者に販売したりすることはありません。

### 第三者サービス

本アプリは [Pixela API](https://docs.pixe.la/)（pixe.la）とのみ通信します。活動を記録する際、ユーザー名・トークン・記録値が Pixela へ送信されます。Pixela によるデータの取り扱いについては、Pixela のプライバシーポリシーをご参照ください。

その他のサードパーティ SDK・アナリティクスサービス・広告ネットワークは一切使用していません。

### データの保存とセキュリティ

- Pixela トークンは iOS Keychain（`flutter_secure_storage` 経由）に保存されます。Keychain はOSによって暗号化・保護されています。
- その他の設定はすべて端末内にのみ保存され、Pixela 以外のサーバーに送信されることはありません。

### 子どものプライバシー

本アプリは、13歳未満の子どもから意図的に個人情報を収集することはありません。

### ポリシーの変更

本ポリシーを更新する場合は、同一の URL に新しい内容を掲載し、施行日を更新します。

### お問い合わせ

本ポリシーに関するご質問は下記までご連絡ください。  
**a.know.dev@gmail.com**
