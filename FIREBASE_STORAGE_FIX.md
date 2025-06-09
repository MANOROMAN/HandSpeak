# Firebase Storage Authorization Fix

## Problem
Your app is getting `[firebase_storage/unauthorized] User is not authorized to perform the desired action` errors when trying to upload files to Firebase Storage.

## Root Cause
The Firebase Storage security rules don't match the file path structure your app is using.

## Solutions

### Solution 1: Update Firebase Storage Rules (RECOMMENDED)

1. **Go to Firebase Console:**
   - Visit https://console.firebase.google.com/
   - Select your Hand Speak project
   - Navigate to **Storage** → **Rules**

2. **Replace current rules with:**
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       
       // Profile images - direct file under profile_images folder
       match /profile_images/{fileName} {
         allow read: if true; 
         allow write: if request.auth != null 
           && fileName.matches('.*\\.(jpg|jpeg|png|gif|webp)') 
           && request.resource.size < 5 * 1024 * 1024 
           && request.resource.contentType.matches('image/.*');
       }
       
       // Profile images - nested under user folders
       match /profile_images/{userId}/{fileName} {
         allow read: if true; 
         allow write: if request.auth != null 
           && request.auth.uid == userId
           && fileName.matches('.*\\.(jpg|jpeg|png|gif|webp)') 
           && request.resource.size < 5 * 1024 * 1024 
           && request.resource.contentType.matches('image/.*');
       }
       
       // Video files - user specific
       match /videos/{userId}/{fileName} {
         allow read: if request.auth != null && request.auth.uid == userId;
         allow write: if request.auth != null 
           && request.auth.uid == userId
           && fileName.matches('.*\\.(mp4|mov|avi|mkv|webm)') 
           && request.resource.size < 50 * 1024 * 1024 
           && request.resource.contentType.matches('video/.*');
       }
       
       // Default deny rule
       match /{allPaths=**} {
         allow read, write: if false;
       }
     }
   }
   ```

3. **Click "Publish"** to save the rules

### Solution 2: Test User Authentication

Add this temporary code to test authentication before upload:

```dart
// In your storage upload method, add this check:
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  throw Exception('User not authenticated');
}
print('User ID: ${user.uid}');
print('User Email: ${user.email}');

// Then proceed with upload
```

### Solution 3: Debug Storage Connection

1. **Add the debug helper to your app:**
   - Use the `firebase_storage_debug.dart` file created
   - Call `FirebaseStorageDebugHelper.debugStorageConnection()` in your app

2. **Check the debug output** for authentication and permission issues

### Solution 4: Temporary Open Rules (FOR TESTING ONLY)

If you need to test quickly, temporarily use these open rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ IMPORTANT:** Change back to secure rules before production!

## Testing Steps

1. **Update Firebase Storage rules** (Solution 1)
2. **Restart your app** completely
3. **Sign in as a user**
4. **Try uploading a profile image**
5. **Check Firebase Console Storage** to see if files appear

## Additional Checks

1. **Verify Firebase project configuration:**
   - Check `google-services.json` is latest version
   - Ensure project ID matches in Firebase Console

2. **Check network connectivity:**
   - Test on different networks
   - Verify firewall isn't blocking Firebase

3. **Review Firebase Authentication:**
   - Ensure user is properly signed in
   - Check token validity

## If Issues Persist

1. **Check Firebase Console Logs:**
   - Go to Firebase Console → Functions → Logs
   - Look for detailed error messages

2. **Enable Firebase Storage debug logging:**
   ```dart
   FirebaseStorage.instance.setMaxUploadRetryTime(Duration(seconds: 30));
   ```

3. **Contact support with:**
   - Full error logs
   - Firebase project ID
   - Exact upload path being used

## Files Modified

- ✅ `lib/services/storage_service.dart` - Updated upload paths
- ✅ `firebase_storage_rules_updated.txt` - New security rules
- ✅ `lib/debug/firebase_storage_debug.dart` - Debug helper

## Next Steps

1. Update Firebase Storage rules
2. Test profile image upload
3. Test video upload
4. Remove debug code after testing
5. Monitor Firebase Console for any new errors
