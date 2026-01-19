@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   CKCP LAMP Flutter - Windows 构建器
echo ========================================
echo.

:: 检查 Flutter
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未找到 Flutter SDK
    pause
    exit /b 1
)

:: 获取依赖
echo [步骤 1/3] 获取依赖...
call flutter pub get
echo.

:: 检查 Windows 平台
echo [步骤 2/3] 检查 Windows 平台支持...
if not exist "windows" (
    call flutter create --platforms=windows .
)
echo.

:: 构建发布版
echo [步骤 3/3] 构建 Windows 发布版...
call flutter build windows --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   构建成功！
    echo ========================================
    echo.
    echo 输出目录: build\windows\x64\runner\Release\
    echo.
    explorer build\windows\x64\runner\Release
)

pause
