# Visual Studio 调试指南

您可以使用 Visual Studio 2022 调试本应用程序。

## 前置条件

1. 确保已运行过一次构建命令，生成必要的解决方案文件：
   ```powershell
   flutter build windows
   ```
2. 安装了 Visual Studio 2022 (包含 C++ 桌面开发工作负载)。

## 快速打开

双击项目根目录下的 **`OpenInVS.bat`** 脚本即可自动打开解决方案。

## 手动调试步骤

1. 打开生成的解决方案文件：
   `build\windows\x64\ckcp_lamp_flutter.sln`

2. 在右侧 "解决方案资源管理器" 中，找到 **`runner`** 项目。

3. 右键点击 **`runner`** 项目，选择 **"设为启动项目" (Set as Startup Project)**。

4. 点击顶部工具栏的 "本地 Windows 调试器" (Local Windows Debugger) 按钮开始调试。

## 注意事项

- **热重载**: 在 VS 中调试无法使用 Flutter 的热重载 (Hot Reload) 功能。如果需要修改 Dart 代码并快速查看效果，建议使用 VS Code 或命令行的 `flutter run`。
- **断点**: 您可以在 `windows\runner` 目录下的 C++ 代码中设置断点。如需调试 Dart 代码，请使用 DevTools 或 VS Code。
