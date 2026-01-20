# 构建并发布 GitHub 升级包完整教程

本教程详细说明如何构建 CKCP LAMP 应用程序、打包升级文件，并发布到 GitHub Releases 以供用户在线更新。

---

## 📋 目录

1. [前置准备](#1-前置准备)
2. [构建 Release 版本](#2-构建-release-版本)
3. [打包升级文件](#3-打包升级文件)
4. [发布到 GitHub](#4-发布到-github)
5. [验证发布](#5-验证发布)
6. [常见问题](#6-常见问题)

---

## 1. 前置准备

### 1.1 环境检查

确保已安装以下工具：

```powershell
# 检查 Flutter 版本
flutter --version

# 检查 Windows 构建工具
flutter doctor -v
```

**要求**：
- Flutter SDK >= 3.16.0
- Visual Studio 2022 (包含 C++ 桌面开发工作负载)

### 1.2 更新版本号

**重要**：每次发布前必须更新版本号，否则用户无法检测到新版本。

#### 步骤 A：修改 `pubspec.yaml`

```yaml
# 文件路径: pubspec.yaml
version: 1.0.5+1  # 格式：<主版本>.<次版本>.<修订号>+<构建号>
```

#### 步骤 B：修改 `version.json`（可选）

```json
{
    "version": "v1.0.5",
    "content": "# v1.0.5 更新\n\n- 新功能描述\n- Bug 修复",
    "date": "2026-01-21"
}
```

#### 步骤 C：更新 `CHANGELOG.md`

在文件顶部添加新版本的变更记录（支持 EN/ZH/JA 三语）。

---

## 2. 构建 Release 版本

### 2.1 使用发布脚本（推荐）

本项目集成了全自动化发布脚本，支持版本管理、构建、打包和发布。

```powershell
# 在项目根目录运行 (自动处理所有后续步骤)
..\.agent\skills\publish_skill\scripts\publish.bat <版本号>
```

详细说明请参考：[GITHUB_CLI_SETUP.md](GITHUB_CLI_SETUP.md)

### 2.2 手动构建 (仅调试)
如果只需要生成 EXE 而不发布：

```powershell
# 清理旧构建
flutter clean
flutter pub get

# 构建 Windows Release 版本 (需注入构建日期)
$Date = Get-Date -Format "yyyy-MM-dd"
flutter build windows --release --dart-define=BUILD_DATE=$Date
```

### 2.3 验证构建

构建完成后，检查输出目录：

```
build\windows\x64\runner\Release\
├── ckcp_lamp_flutter.exe    # 主程序
├── flutter_windows.dll      # Flutter 引擎
├── *.dll                    # 其他依赖库
└── data\                    # 资源文件夹
    ├── flutter_assets\
    └── ...
```

---

## 3. 打包升级文件

### 方式 A：ZIP 绿色升级（推荐）

这是最简单的方式，无需额外工具。

#### 步骤 1：进入构建目录

```powershell
cd build\windows\x64\runner\Release
```

#### 步骤 2：创建 ZIP 文件

**方法 1**：Windows 资源管理器
1. 打开 `build\windows\x64\runner\Release` 文件夹
2. 按 `Ctrl+A` 全选所有文件和文件夹
3. 右键 → **发送到** → **压缩(zipped)文件夹**
4. 命名为 `CKCP_LAMP_v1.0.5.zip`

**方法 2**：PowerShell 命令

```powershell
# 在项目根目录运行
$version = "v1.0.5"
$source = "build\windows\x64\runner\Release\*"
$dest = "releases\CKCP_LAMP_$version.zip"

# 创建 releases 目录
New-Item -ItemType Directory -Force -Path "releases"

# 压缩
Compress-Archive -Path $source -DestinationPath $dest -Force

Write-Host "✅ 已创建: $dest"
```

### 方式 B：EXE 安装包（高级）

需要安装 [Inno Setup](https://jrsoftware.org/isinfo.php)。

#### 步骤 1：安装 Inno Setup

下载并安装 Inno Setup 6.x。

#### 步骤 2：编译安装脚本

```powershell
# 使用 Inno Setup 编译
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installers\ckcp_lamp.iss
```

#### 步骤 3：获取输出

生成的安装包位于：`installers\setup_v1.0.5.exe`

---

## 4. 发布到 GitHub

### 4.1 登录 GitHub

访问项目仓库：https://github.com/a757675586/ckcp_lamp_flutter

### 4.2 创建新 Release

1. 点击右侧 **Releases** 区域
2. 点击 **Draft a new release** 按钮

### 4.3 填写 Release 信息

| 字段 | 说明 | 示例 |
|------|------|------|
| **Choose a tag** | 输入版本号，点击 "Create new tag" | `v1.0.5` |
| **Release title** | 发布标题 | `v1.0.5 - Glassmorphism UI` |
| **Description** | 更新说明（可从 CHANGELOG.md 复制） | 见下方 |

**Description 示例**：

```markdown
## What's New

### ✨ New Features
- Glassmorphism 2.0 UI overhaul
- Unified visual style across all pages

### 🐛 Bug Fixes
- Fixed HttpClient resource leak
- Fixed mounted check in upgrade dialog

### 🌐 Localization
- Added `downloading` and `install_update` translations
```

### 4.4 上传升级文件

1. 在 **Attach binaries** 区域
2. 将 `.zip` 或 `.exe` 文件拖拽上传
3. 等待上传完成

### 4.5 发布

1. 确认 **Set as the latest release** 已勾选
2. 点击 **Publish release** 按钮

---

## 5. 验证发布

### 5.1 检查 GitHub API

在浏览器中访问：

```
https://api.github.com/repos/a757675586/ckcp_lamp_flutter/releases/latest
```

确认返回的 JSON 中：
- `tag_name` 为新版本号
- `assets` 数组包含上传的文件

### 5.2 在应用中测试

1. 运行旧版本应用
2. 打开 **设置** → **检查更新**
3. 应显示新版本可用
4. 点击 **开始更新** 测试下载和安装流程

---

## 6. 常见问题

### Q1: 用户无法检测到新版本

**可能原因**：
- GitHub Tag 版本号 ≤ 当前 APP 版本号
- Tag 格式不正确（必须以 `v` 开头，如 `v1.0.5`）

**解决**：确保 Tag 版本号大于 pubspec.yaml 中的版本号。

### Q2: 下载失败

**可能原因**：
- 网络问题（GitHub 在部分地区访问不稳定）
- Asset 文件名不正确

**解决**：确保上传的文件名以 `.zip` 或 `.exe` 结尾。

### Q3: 升级后应用无法启动

**可能原因**：
- ZIP 文件结构不正确（包含了额外的父文件夹）

**解决**：确保 ZIP 根目录直接包含 `.exe` 和 `data` 文件夹，而不是嵌套在另一个文件夹中。

**正确结构**：
```
CKCP_LAMP_v1.0.5.zip
├── ckcp_lamp_flutter.exe  ✅
├── flutter_windows.dll
└── data/
```

**错误结构**：
```
CKCP_LAMP_v1.0.5.zip
└── Release/               ❌ 多余的父文件夹
    ├── ckcp_lamp_flutter.exe
    └── data/
```

---

## 📝 发布检查清单

发布前请确认：

- [ ] 已更新 `pubspec.yaml` 中的版本号
- [ ] 已更新 `CHANGELOG.md`
- [ ] 已运行 `flutter build windows --release`
- [ ] ZIP/EXE 文件结构正确
- [ ] GitHub Tag 版本号 > 当前 APP 版本
- [ ] Release 已设为 "latest"

---

*最后更新：2026-01-20*
