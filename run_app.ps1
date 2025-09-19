Write-Host "Starting Flutter app with Kotlin version bypass..." -ForegroundColor Green
Write-Host ""
Write-Host "This bypasses the Kotlin version warning for compatibility." -ForegroundColor Yellow
Write-Host ""

try {
    flutter run --android-skip-build-dependency-validation
} catch {
    Write-Host "Build failed. Trying with clean build..." -ForegroundColor Red
    flutter clean
    flutter pub get
    flutter run --android-skip-build-dependency-validation
}

Write-Host ""
Write-Host "App execution completed." -ForegroundColor Green
Read-Host "Press Enter to continue"

