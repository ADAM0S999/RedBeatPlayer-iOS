@echo off
chcp 65001 >nul
title RedBeatPlayer iOS - Automated IPA Builder

echo ================================================================
echo   🎵 RedBeatPlayer v5.0 - Free Cloud IPA Builder (macOS)
echo ================================================================
echo.
echo Since Apple requires macOS + Xcode to compile native iOS binaries,
echo we use GitHub Actions' free macOS cloud runners to compile it for you!
echo.
echo STEP 1:
echo Open your browser and create a new repository:
echo   https://github.com/new
echo (You can name it "RedBeatPlayer-iOS" and set it to Private or Public)
echo.
echo STEP 2:
echo Copy your repository HTTPS URL from GitHub and paste it below:
echo (Example: https://github.com/username/RedBeatPlayer-iOS.git)
echo.
set /p REPO_URL="Enter GitHub Repository URL: "

if "%REPO_URL%"=="" (
    echo Error: No URL entered.
    pause
    exit /b
)

echo.
echo Pushing code to GitHub...
"D:\Program Files\Git\cmd\git.exe" remote remove origin 2>nul
"D:\Program Files\Git\cmd\git.exe" remote add origin %REPO_URL%
"D:\Program Files\Git\cmd\git.exe" branch -M main
"D:\Program Files\Git\cmd\git.exe" push -u origin main --force

echo.
echo ================================================================
echo   🚀 Code pushed successfully!
echo.
echo   GitHub is now automatically compiling your .IPA on a Mac runner!
echo   In ~2-3 minutes, your compiled IPA will be ready for download:
echo.
echo   Go to the "Actions" tab in your repository:
echo   %REPO_URL%/actions
echo.
echo   1. Click on the latest run "Build iOS IPA"
echo   2. Scroll down to "Artifacts"
echo   3. Click "RedBeatPlayer-v5.0-iOS-IPA" to download your .ipa!
echo   4. Drop the .ipa into Sideloadly to install on your iPhone!
echo ================================================================
echo.
pause
