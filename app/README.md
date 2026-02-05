# Jako Vocab アプリ

語彙学習アプリ（Flutter）。設定画面とローカル通知で単語をお知らせします。のちに Java API（jako-vocab バックエンド）と連携できます。

## 機能

- **設定画面**: 通知頻度（1時間ごと / 3時間ごと / 1日1回）、学習レベル（初級・中級・上級）、通知許可（ON/OFF）
- **保存**: `shared_preferences` で端末内に設定を保存・読み出し
- **通知**: `flutter_local_notifications` で設定した頻度に応じて「りんご(사과)」のようなダミー単語を通知（のちに API から取得に差し替え可能）

## セットアップ

### 0. Flutter をインストールする（まだの場合）

**方法A: Homebrew（おすすめ）**

```bash
brew install --cask flutter
```

インストール後、**新しいターミナル**を開くか、以下で PATH を反映してから `flutter doctor` で確認します。

```bash
export PATH="$PATH:/opt/homebrew/bin"
# または Apple Silicon でない場合: export PATH="$PATH:/usr/local/bin"
flutter doctor
```

**方法B: 公式サイトから手動インストール**

1. [Flutter 公式 - macOS](https://docs.flutter.dev/get-started/install/macos) から SDK をダウンロード
2. 解凍して任意の場所に置く（例: `~/development/flutter`）
3. PATH に追加（`~/.zshrc` に追記）:
   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   ```
4. `source ~/.zshrc` のあと `flutter doctor` で確認

### 1. このフォルダでプロジェクトを生成（初回のみ）
   ```bash
   cd app
   flutter create . --project-name jako_vocab_app
   ```

### 2. Android で通知を動かす場合、`android/app/src/main/AndroidManifest.xml` の `<manifest>` 内に以下を追加:
   ```xml
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
   <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
   ```

### 3. 依存関係の取得と実行
   ```bash
   flutter pub get
   flutter run
   ```

## 構成

- `lib/main.dart` - エントリポイント、通知の初期化
- `lib/screens/settings_screen.dart` - 設定画面 UI
- `lib/services/settings_service.dart` - shared_preferences による設定の保存・読み出し
- `lib/services/notification_service.dart` - ローカル通知のスケジュール
- `lib/data/dummy_words.dart` - 通知用ダミー単語リスト（のちに API 取得に差し替え）

## ステップ3（後回し）

最初はアプリ内のダミー配列で動作します。動くアプリを確認したあと、`lib/data/dummy_words.dart` を「Java API から取得する処理」に書き換えて連携できます。
