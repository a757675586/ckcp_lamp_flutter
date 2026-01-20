# CKCP LAMP Flutter

<div align="center">

**车载氛围灯控制与固件升级** - Flutter 跨平台应用

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue?logo=flutter)](https://flutter.dev/)
[![Platforms](https://img.shields.io/badge/Platforms-Windows%20|%20macOS%20|%20Linux%20|%20Android%20|%20iOS-green)]()
[![License](https://img.shields.io/badge/License-MIT-yellow)]()

</div>

---

## 📚 文档资源

- [**构建与发布指南**](docs/BUILD_AND_RELEASE_GUIDE.md) - 如何构建应用与发布新版本。
- [**自动化发布配置**](docs/GITHUB_CLI_SETUP.md) - 配置 GitHub CLI 实现一键发布。
- [**架构设计**](docs/ARCHITECTURE.md) - 系统架构与设计模式。
- [**氛围灯逻辑**](docs/AMBIENT_LIGHT_LOGIC.md) - 核心控制逻辑说明。
- [**OTA 修复报告**](docs/OTA_BUG_FIX_REPORT.md) - 历史问题修复记录。

---

## ✨ 功能特性

### 🌈 氛围灯控制
- **单色模式** - HSL 颜色选择器，预设颜色一键应用
- **多色模式** - 10+ 预设主题，动态/静态切换
- **律动模式** - 音乐跟随，可调速度和灵敏度
- **亮度控制** - 统一亮度/区域独立控制
- **开关控制** - 开/关/跟随车灯三档

### 🚀 OTA 固件升级
- **文件选择** - 支持 .bin 固件文件
- **智能分帧** - 自动 MTU 适配
- **进度监控** - 实时进度和状态显示
- **重试机制** - 智能错误恢复

### 🔧 工厂模式
- **设备注册** - VIN 码、车型、功能编号
- **LED 配置** - 6 区域灯珠数量/方向配置
- **高级功能** - 迎宾灯、车门联动等开关

### 🎨 现代 UI
- **毛玻璃效果** - Glassmorphism 设计风格
- **暗黑模式** - 护眼深色主题
- **流畅动画** - 微交互动效
- **响应式布局** - 多尺寸屏幕适配

---

## 🖥️ 平台支持

| 平台 | 状态 | BLE 支持 |
|------|------|----------|
| Windows | ✅ 完成 | win_ble |
| Android | 🚧 开发中 | flutter_blue_plus |
| iOS | 🚧 开发中 | flutter_blue_plus |
| macOS | 📋 计划中 | flutter_blue_plus |
| Linux | 📋 计划中 | quick_blue |

---

## 🛠️ 开发环境

### 前置要求

- **Flutter SDK** >= 3.16.0
- **Dart SDK** >= 3.2.0
- **Windows**: Visual Studio 2022 (C++ 桌面开发)
- **Android**: Android Studio + Android SDK
- **iOS/macOS**: Xcode 15+

### 安装步骤

```bash
# 1. 克隆项目
cd e:\aiAngen\bletool4\ckcp_lamp_flutter

# 2. 获取依赖
flutter pub get

# 3. 运行 Windows 版本
flutter run -d windows

# 4. 构建 Windows 发布版
flutter build windows --release
```

---

## 📁 项目结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # App 根组件
│
├── core/                        # 核心模块
│   ├── constants/               # 常量定义
│   │   ├── ble_uuids.dart       # BLE UUID
│   │   ├── colors.dart          # 预设颜色
│   │   └── commands.dart        # 协议命令
│   │
│   ├── protocols/               # 协议层
│   │   ├── ckcp_protocol.dart   # CKCP 协议
│   │   └── ota_protocol.dart    # OTA 协议
│   │
│   └── services/                # 服务层
│       ├── ble_service.dart     # BLE 服务
│       └── ota_service.dart     # OTA 服务
│
└── presentation/                # 表现层
    ├── providers/               # Riverpod 状态管理
    ├── pages/                   # 页面
    ├── widgets/                 # 组件
    └── themes/                  # 主题
```

---

## 🔌 CKCP 协议

### BLE UUID

| 类型 | UUID |
|------|------|
| 服务 | `0000ffe0-0000-1000-8000-00805f9b34fb` |
| 写入 | `0000ff03-0000-1000-8000-00805f9b34fb` |
| 通知 | `0000ffe1-0000-1000-8000-00805f9b34fb` |

### 核心命令

| 功能 | 命令 | 格式 |
|------|------|------|
| 单色控制 | `0x01` | `<0103RRGGBB>` |
| 亮度调节 | `0x03` | `<0302ZONEVAL>` |
| 开关控制 | `0x04` | `<04010X>` |
| 动态模式 | `0x05` | `<050101>` |
| 多色主题 | `0x06` | `<0601XX>` |
| OTA升级 | `0xD8` | `D8 LEN SUBCMD DATA` |

---

## 🎯 开发路线图

- [x] **Phase 1**: Windows 平台核心功能
  - [x] 项目架构
  - [x] CKCP 协议实现
  - [x] Windows BLE 适配
  - [x] 氛围灯控制 UI
  - [x] OTA 升级功能

- [ ] **Phase 2**: 移动端适配
  - [ ] Android 平台
  - [ ] iOS 平台

- [x] **Phase 3**: 完善功能
  - [x] 工厂模式完整实现
  - [ ] 多设备管理
  - [x] 国际化支持 (EN/ZH/JA)
  - [x] Glassmorphism 2.0 UI

---

## 📄 License

MIT License

---

## 🙏 参考

- [WebOTA](../WebOTA) - Web BLE 氛围灯控制原型
- [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus) - Flutter BLE 插件
- [win_ble](https://pub.dev/packages/win_ble) - Windows BLE 插件
