# v1.0.7 Release

## 📦 Downloads

| File | Description |
|------|-------------|
| $ZipName | Windows portable version (recommended) |

## 🔄 Installation

1. Download the .zip file
2. Extract to any folder
3. Run ckcp_lamp_flutter.exe

For existing users: The app will auto-update when you click "Check Update" in Settings.

---

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

---

*Released: 2026-01-26*