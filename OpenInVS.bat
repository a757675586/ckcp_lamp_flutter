@echo off
if not exist "build\windows\x64\ckcp_lamp_flutter.sln" (
    echo Error: Solution file not found. Please run "flutter build windows" first.
    pause
    exit /b 1
)
echo Opening Visual Studio Solution...
start "" "build\windows\x64\ckcp_lamp_flutter.sln"
