#!/bin/bash

echo "🔥 Firebase Storage Rules Check"
echo "==============================="
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

echo "✅ Firebase CLI found"

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Not logged in to Firebase. Please run:"
    echo "   firebase login"
    exit 1
fi

echo "✅ Firebase authenticated"

# Get current project
PROJECT=$(firebase use --json 2>/dev/null | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

if [ -z "$PROJECT" ]; then
    echo "❌ No Firebase project selected. Please run:"
    echo "   firebase use --add"
    exit 1
fi

echo "✅ Firebase project: $PROJECT"

# Get current Storage rules
echo ""
echo "📋 Current Firebase Storage Rules:"
echo "=================================="

firebase firestore:rules get 2>/dev/null || echo "Note: Using default rules"

echo ""
echo "🔧 Recommended Actions:"
echo "======================"
echo "1. Check Firebase Console -> Storage -> Rules"
echo "2. Copy rules from COPY_THESE_FIREBASE_RULES.txt"
echo "3. Or use simple rules from TEMPORARY_FIREBASE_RULES.txt"
echo ""
echo "🔗 Firebase Console: https://console.firebase.google.com/project/$PROJECT/storage/rules"
