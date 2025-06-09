@echo off
echo 🔥 Firebase Storage Rules Check
echo ===============================
echo.

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Firebase CLI not found. Please install it first:
    echo    npm install -g firebase-tools
    exit /b 1
)

echo ✅ Firebase CLI found

REM Check if user is logged in
firebase projects:list >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Not logged in to Firebase. Please run:
    echo    firebase login
    exit /b 1
)

echo ✅ Firebase authenticated

REM Get current project
for /f "tokens=*" %%i in ('firebase use --json 2^>nul ^| findstr "id"') do set PROJECT_LINE=%%i
if "%PROJECT_LINE%"=="" (
    echo ❌ No Firebase project selected. Please run:
    echo    firebase use --add
    exit /b 1
)

echo ✅ Firebase project configured

echo.
echo 📋 Current Firebase Storage Rules Status:
echo ========================================
echo Check your Firebase Console for current rules

echo.
echo 🔧 Recommended Actions:
echo ======================
echo 1. Open Firebase Console -^> Storage -^> Rules
echo 2. Copy rules from COPY_THESE_FIREBASE_RULES.txt
echo 3. Or use simple rules from TEMPORARY_FIREBASE_RULES.txt
echo.
echo 🔗 Firebase Console: https://console.firebase.google.com/

echo.
echo 📄 Available rule files in this directory:
echo ==========================================
if exist "COPY_THESE_FIREBASE_RULES.txt" (
    echo ✅ COPY_THESE_FIREBASE_RULES.txt - Secure production rules
) else (
    echo ❌ COPY_THESE_FIREBASE_RULES.txt - Not found
)

if exist "TEMPORARY_FIREBASE_RULES.txt" (
    echo ✅ TEMPORARY_FIREBASE_RULES.txt - Simple testing rules
) else (
    echo ❌ TEMPORARY_FIREBASE_RULES.txt - Not found
)

echo.
echo 💡 Quick Test:
echo =============
echo To test if rules are working, run the app and use the diagnostic tool:
echo Settings -^> Firebase Storage Diagnostics
