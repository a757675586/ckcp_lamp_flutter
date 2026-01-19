@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   CKCP LAMP Flutter - Windows 启动器
echo ========================================
echo.

:: 检查 Flutter
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未找到 Flutter SDK
    echo 请确保已安装 Flutter 并添加到 PATH
    echo.
    echo 安装指南: https://docs.flutter.dev/get-started/install/windows
    pause
    exit /b 1
)

echo [信息] Flutter SDK 已找到
flutter --version
echo.

:: 获取依赖
echo [步骤 1/3] 获取依赖...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 依赖获取失败
    pause
    exit /b 1
)
echo.

:: 检查 Windows 平台
echo [步骤 2/3] 检查 Windows 平台支持...
if not exist "windows" (
    echo [信息] 正在创建 Windows 平台配置...
    call flutter create --platforms=windows .
)
echo.

:: 运行应用
echo [步骤 3/3] 启动应用...
echo.
call flutter run -d windows

pause
