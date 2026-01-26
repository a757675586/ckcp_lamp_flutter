# Changelog / 更新日志 / 変更履歴

All notable changes to this project will be documented in this file.
本项目的所有重要更改都将记录在此文件中。
このプロジェクトへの重要な変更はすべてこのファイルに記録されます。

## [1.0.7] - 2026-01-26

### English
#### Fixed
- **Protocol Corrections**: Fixed incorrect command IDs for Factory Mode (VIN Registration `0x70` -> `0x0A`, Car Code `0x71` -> `0x0B`, Func Code `0x72` -> `0x0C`) and corrected VIN payload structure.

#### Added
- **Documentation**: Added comprehensive Mobile UI Specification (`MOBILE_UI_SPEC.md`) covering About Page and Factory Mode interaction logic.

### 中文
#### 修复
- **协议修正**：修复了工厂模式中的指令 ID 错误（VIN注册 `0x70` -> `0x0A`，车型编号 `0x71` -> `0x0B`，功能编号 `0x72` -> `0x0C`），并修正了 VIN 数据帧结构。

#### 新增
- **文档**：新增了完整的手机端 UI 规范文档 (`MOBILE_UI_SPEC.md`)，涵盖关于页面和工厂模式的交互逻辑。

### 日本語
#### 修正
- **プロトコル修正**：ファクトリーモードのコマンドIDの誤りを修正しました（VIN登録 `0x70` -> `0x0A`、車種コード `0x71` -> `0x0B`、機能コード `0x72` -> `0x0C`）、VINペイロード構造を修正しました。

#### 追加
- **ドキュメント**：Aboutページとファクトリーモードのインタラクションロジックをカバーする包括的なモバイルUI仕様書 (`MOBILE_UI_SPEC.md`) を追加しました。

---

## [1.0.6] - 2026-01-20

### English
#### Changed
- **Maintenance**: Routine maintenance update.

### 中文
#### 变更
- **维护**: 例行维护更新。

### 日本語
#### 変更
- **メンテナンス**: 定期的なメンテナンス更新。

---

## [1.0.5] - 2026-01-20

### English
#### Added
- **Publish Skill**: Automated build and release scripts for one-click publishing (`.agent/skills/publish_skill/`).
- **Complete Localization**: Added missing `lang_ja`, `appearance`, `theme_mode`, `theme_light`, `theme_dark` keys to ZH locale.

#### Fixed
- **Auto-Scroll in Remote Control**: Fixed log list not auto-scrolling to bottom by using `reverse: true` ListView.
- **Hardcoded Strings**: Replaced hardcoded Japanese text (`日本語`) with localized `context.tr('lang_ja')`.

### 中文
#### 新增
- **发布技能**：自动化构建和发布脚本，支持一键发布（`.agent/skills/publish_skill/`）。
- **完整本地化**：为中文语言包添加了缺失的 `lang_ja`、`appearance`、`theme_mode`、`theme_light`、`theme_dark` 键。

#### 修复
- **远程控制自动滚动**：修复日志列表不自动滚动到底部的问题，使用 `reverse: true` ListView。
- **硬编码字符串**：将硬编码的日语文本（`日本語`）替换为本地化的 `context.tr('lang_ja')`。

### 日本語
#### 追加
- **パブリッシュスキル**：ワンクリック公開のための自動ビルドとリリーススクリプト（`.agent/skills/publish_skill/`）。
- **完全なローカライゼーション**：ZHロケールに欠落していた `lang_ja`、`appearance`、`theme_mode`、`theme_light`、`theme_dark` キーを追加。

#### 修正
- **リモート制御の自動スクロール**：`reverse: true` ListViewを使用して、ログリストが自動的に下部にスクロールしない問題を修正。
- **ハードコードされた文字列**：ハードコードされた日本語テキスト（`日本語`）をローカライズされた `context.tr('lang_ja')` に置き換え。

---

## [1.0.4] - 2026-01-20

### English
#### Added
- **Glassmorphism 2.0 UI**: Complete UI overhaul with diffuse light background effects and glass container components (`DiffuseBackground`, `GlassContainer`).
- **Unified Visual Style**: Applied consistent glassmorphism aesthetic across all pages (Home, Settings, Factory, OTA, Ambient Light).
- **New Localization Keys**: Added `downloading` and `install_update` translations for EN, ZH, JA.

#### Fixed
- **Resource Leak**: Fixed `HttpClient` not being closed after update check requests.
- **State Management**: Fixed `mounted` check missing before `ScaffoldMessenger` calls in upgrade dialog.
- **Performance**: Cached page widgets in `HomePage` to avoid recreation on every build.
- **Code Cleanup**: Removed unused imports and redundant code identified by code review.

### 中文
#### 新增
- **Glassmorphism 2.0 界面**：全面 UI 改版，引入弥散光背景效果和毛玻璃容器组件（`DiffuseBackground`、`GlassContainer`）。
- **统一视觉风格**：在所有页面（主页、设置、工厂模式、OTA、氛围灯）应用一致的毛玻璃美学。
- **新增本地化键**：为 EN、ZH、JA 添加了 `downloading` 和 `install_update` 翻译。

#### 修复
- **资源泄漏**：修复了更新检查请求后 `HttpClient` 未关闭的问题。
- **状态管理**：修复了升级对话框中 `ScaffoldMessenger` 调用前缺少 `mounted` 检查的问题。
- **性能优化**：在 `HomePage` 中缓存页面组件，避免每次构建时重新创建。
- **代码清理**：移除了代码审查中发现的未使用导入和冗余代码。

### 日本語
#### 追加
- **Glassmorphism 2.0 UI**：拡散光の背景効果とガラスコンテナコンポーネント（`DiffuseBackground`、`GlassContainer`）による完全なUI刷新。
- **統一されたビジュアルスタイル**：すべてのページ（ホーム、設定、ファクトリー、OTA、アンビエントライト）に一貫したグラスモーフィズムの美学を適用。
- **新しいローカライゼーションキー**：EN、ZH、JAに `downloading` と `install_update` の翻訳を追加。

#### 修正
- **リソースリーク**：更新チェックリクエスト後に `HttpClient` が閉じられない問題を修正。
- **状態管理**：アップグレードダイアログで `ScaffoldMessenger` 呼び出し前に `mounted` チェックが欠落していた問題を修正。
- **パフォーマンス**：`HomePage` でページウィジェットをキャッシュし、ビルドごとの再作成を回避。
- **コードクリーンアップ**：コードレビューで特定された未使用のインポートと冗長なコードを削除。

---

## [1.0.3] - 2026-01-20

### English
#### Added
- **Bluetooth State Detection**: The app now monitors the PC's Bluetooth adapter state. If Bluetooth is disabled, a red warning banner (SnackBar) appears at the bottom of the screen prompting the user to enable it.
- **Multilingual Support for Bluetooth Alerts**: Added English, Chinese, and Japanese translations for Bluetooth status messages.

#### Fixed
- **Japanese Localization**: Fixed missing translation keys (`unknown`, `no_update_info`) and corrected the "Supports .bin format" key in the OTA page.
- **Compilation Error**: Resolved a syntax error in `app.dart` related to `supportedLocales` configuration that prevented release builds.
- **OTA UI**: Corrected localized string references in the OTA upgrade screen.

### 中文
#### 新增
- **蓝牙状态检测**：应用现在会实时监控电脑的蓝牙适配器状态。如果蓝牙未开启，屏幕底部会出现红色的警告提示条 (SnackBar)，提醒用户开启蓝牙。
- **蓝牙提示多语言支持**：为蓝牙状态提示添加了英语、中文和日语翻译。

#### 修复
- **日语本地化**：修复了缺失的翻译键值（`unknown`, `no_update_info`）并更正了 OTA 页面中“支持 .bin 格式”的键值引用。
- **编译错误**：解决了 `app.dart` 中与 `supportedLocales` 配置相关的语法错误，该错误曾导致发布版本构建失败。
- **OTA 界面**：修正了 OTA 升级界面中的本地化字符串引用。

### 日本語
#### 追加
- **Bluetooth状態検出**：PCのBluetoothアダプターの状態を監視するようになりました。Bluetoothが無効になっている場合、画面下部に赤い警告バナー（スナックバー）が表示され、Bluetoothを有効にするよう促します。
- **Bluetoothアラートの多言語対応**：Bluetoothステータスメッセージに英語、中国語、日本語の翻訳を追加しました。

#### 修正
- **日本語ローカリゼーション**：欠落していた翻訳キー（`unknown`, `no_update_info`）を修正し、OTAページの「.bin形式に対応」キーを修正しました。
- **コンパイルエラー**：リリースビルドを妨げていた `app.dart` の `supportedLocales` 設定に関連する構文エラーを解決しました。
- **OTA UI**：OTAアップグレード画面のローカライズされた文字列参照を修正しました。

---

## [1.0.2] - 2026-01-19

### English
#### Added
- **Japanese Language Support**: Complete UI translation and `app.dart` configuration for Japanese (`ja`).
- **Online Upgrade System**: Integrated GitHub Releases API for checking and downloading updates.
- **Inno Setup Installer**: Added `installers/ckcp_lamp.iss` script to generate a Windows installer (`.exe`).
- **Build Information**: Added "Build Date" and "Framework" information to the Settings -> About section.

#### Fixed
- **Upgrade Dialog**: Fixed the "Check Update" button logic to correctly switch between auto-check and manual check modes.
- **UI Improvements**: Refined the Upgrade Dialog layout and cleared persistent version flags.

### 中文
#### 新增
- **日语语言支持**：完成了日语 (`ja`) 的完整 UI 翻译配置。
- **在线升级系统**：集成了 GitHub Releases API，用于检查和下载更新。
- **Inno Setup 安装包**：添加了 `installers/ckcp_lamp.iss` 脚本，用于生成 Windows 安装程序 (`.exe`)。
- **构建信息**：在“设置 -> 关于”部分添加了“编译日期”和“技术框架”显示。

#### 修复
- **升级对话框**：修复了“检查更新”按钮逻辑，正确切换自动检查和手动检查模式。
- **UI 改进**：优化了升级对话框布局，并清除了持久化的版本标记问题。

### 日本語
#### 追加
- **日本語サポート**：日本語 (`ja`) の完全なUI翻訳と `app.dart` 設定を追加しました。
- **オンラインアップグレード**：更新を確認およびダウンロードするために GitHub Releases API を統合しました。
- **Inno Setup インーラー**：Windowsインストーラー (`.exe`) を生成するための `installers/ckcp_lamp.iss` スクリプトを追加しました。
- **ビルド情報**：「設定 -> アプリについて」セクションに「ビルド日」と「フレームワーク」情報を追加しました。

#### 修正
- **更新ダイアログ**：「更新を確認」ボタンのロジックを修正し、自動チェックと手動チェックモードが正しく切り替わるようにしました。
- **UI 改善**：更新ダイアログのレイアウトを調整し、永続的なバージョンフラグをクリアしました。

---

## [1.0.1] - 2026-01-18

### English
#### Added
- **Factory Mode**: Implemented factory testing features including LED configuration and remote control (CAN/LIN).
- **Rhythm Mode**: Added rhythm effect controls and sensitivity settings.

### 中文
#### 新增
- **工厂模式**：实现了工厂测试功能，包括 LED 配置和远程控制 (CAN/LIN)。
- **律动模式**：添加了律动效果控制和灵敏度设置。

### 日本語
#### 追加
- **ファクトリーモード**：LED設定やリモート制御（CAN/LIN）を含む工場テスト機能を実装しました。
- **リズムモード**：リズム効果のコントロールと感度設定を追加しました。

---

## [1.0.0] - 2026-01-15

### English
#### Initial Release
- **Core Features**: Ambient light control (Solid, Multi-color, Rhythm).
- **BLE Connectivity**: Basic Windows BLE scanning and connection using `win_ble`.
- **UI Framework**: Flutter-based responsive UI with Sidebar navigation.

### 中文
#### 初始发布
- **核心功能**：氛围灯控制（单色、多色、律动）。
- **BLE 连接**：基于 `win_ble` 的基础 Windows 蓝牙扫描和连接。
- **UI 框架**：带有侧边栏导航的 Flutter 响应式 UI。

### 日本語
#### 初回リリース
- **コア機能**：アンビエントライト制御（単色、マルチカラー、リズム）。
- **BLE 接続**：`win_ble` を使用した基本的な Windows BLE スキャンと接続。
- **UI フレームワーク**：サイドバーナビゲーションを備えた Flutter ベースのレスポンシブ UI。
