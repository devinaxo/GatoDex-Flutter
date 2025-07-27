@echo off
echo Installing GatoDex to personal profile only...
flutter build apk --debug
adb install --user 0 build\app\outputs\flutter-apk\app-debug.apk
echo Done! App installed to personal profile only.
pause
