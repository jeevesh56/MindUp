@echo off
echo Starting Flutter app with Kotlin version bypass...
echo.
echo This bypasses the Kotlin version warning for compatibility.
echo.
flutter run --android-skip-build-dependency-validation
if %errorlevel% neq 0 (
    echo.
    echo Build failed. Trying with clean build...
    flutter clean
    flutter pub get
    flutter run --android-skip-build-dependency-validation
)
echo.
echo App execution completed.
pause
