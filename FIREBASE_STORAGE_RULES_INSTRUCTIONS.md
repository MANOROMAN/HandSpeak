# Firebase Storage Rules Update Guide

## CRITICAL: Apply These Storage Rules to Firebase Console

### Current Issue
The Hand Speak app is experiencing Firebase Storage authorization errors:
- `[firebase_storage/unauthorized] User is not authorized to perform the desired action`
- Profile image uploads failing
- Video uploads failing

### Solution: Update Firebase Storage Security Rules

## Step 1: Access Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your Hand Speak project
3. Click on **Storage** in the left sidebar
4. Click on the **Rules** tab

## Step 2: Replace Current Rules
**IMPORTANT**: Replace ALL existing rules with the following:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Profile images - nested under user folders (recommended structure)
    match /profile_images/{userId}/{fileName} {
      allow read: if true; // Profile photos can be viewed by everyone
      allow write: if request.auth != null 
        && request.auth.uid == userId
        && fileName.matches('.*\\.(jpg|jpeg|png|gif|webp)') // Only image files
        && request.resource.size < 5 * 1024 * 1024 // Max 5MB
        && request.resource.contentType.matches('image/.*'); // Only image content type
    }
    
    // Profile images - direct file under profile_images folder (fallback)
    match /profile_images/{fileName} {
      allow read: if true; // Profile photos can be viewed by everyone
      allow write: if request.auth != null 
        && fileName.matches('.*\\.(jpg|jpeg|png|gif|webp)') // Only image files
        && request.resource.size < 5 * 1024 * 1024 // Max 5MB
        && request.resource.contentType.matches('image/.*'); // Only image content type
    }
    
    // Video files - user can only access their own videos
    match /videos/{userId}/{fileName} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null 
        && request.auth.uid == userId
        && fileName.matches('.*\\.(mp4|mov|avi|mkv|webm)') // Only video files
        && request.resource.size < 100 * 1024 * 1024 // Max 100MB
        && request.resource.contentType.matches('video/.*'); // Only video content type
    }
    
    // Temporary files for processing (optional)
    match /temp/{userId}/{fileName} {
      allow read, write: if request.auth != null 
        && request.auth.uid == userId
        && request.resource.size < 200 * 1024 * 1024; // Max 200MB for temp files
    }
    
    // Public files (if any) - read only
    match /public/{fileName} {
      allow read: if true;
      allow write: if false; // No public writes allowed
    }
    
    // Default deny all other paths
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

## Step 3: Publish Rules
1. After pasting the rules, click **Publish**
2. Confirm the changes when prompted

## Step 4: Verify Rules Are Active
The rules will be live immediately. You can verify by:
1. Running the diagnostic tool in the app (Settings > Debug & Diagnostics > Firebase Storage Diagnostics)
2. Try uploading a profile image
3. Try recording and uploading a video

## Key Features of These Rules

### Security Features:
- **User Authentication Required**: All uploads require authenticated users
- **User Isolation**: Users can only access their own files
- **File Type Validation**: Only specific image/video formats allowed
- **Size Limits**: 
  - Images: 5MB max
  - Videos: 100MB max
  - Temp files: 200MB max
- **Content Type Validation**: Validates actual file content types

### File Structure:
```
storage/
├── profile_images/
│   ├── {userId}/
│   │   └── profile.jpg
│   └── profile.jpg (fallback)
├── videos/
│   └── {userId}/
│       └── {uniqueFileName}.mp4
├── temp/
│   └── {userId}/
│       └── {tempFiles}
└── public/
    └── {publicFiles}
```

### Supported File Types:
- **Images**: jpg, jpeg, png, gif, webp
- **Videos**: mp4, mov, avi, mkv, webm

## Troubleshooting

### If uploads still fail after applying rules:
1. **Check Authentication**: Ensure user is properly signed in
2. **Verify File Paths**: App uses `profile_images/{userId}/profile.jpg` format
3. **File Size**: Ensure files are within size limits
4. **File Type**: Ensure files have correct extensions and content types
5. **Run Diagnostics**: Use the built-in diagnostic tool in the app

### Common Error Codes:
- `unauthorized`: Rules not applied or user not authenticated
- `permission-denied`: File path doesn't match rules
- `invalid-argument`: File type or size doesn't meet requirements
- `quota-exceeded`: Storage quota exceeded

## Testing Checklist
After applying rules, test these features:
- [ ] User can sign in/out
- [ ] Profile image upload works
- [ ] Video recording and upload works
- [ ] Users cannot access other users' files
- [ ] File size limits are enforced
- [ ] Invalid file types are rejected

## Emergency Rollback
If something goes wrong, you can temporarily use these permissive rules:
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
**WARNING**: These rules allow any authenticated user to read/write any file. Use only for emergency testing.

---

**Next Steps After Applying Rules:**
1. Test the app thoroughly
2. Monitor Firebase Console for any error logs
3. Use the diagnostic tool to verify functionality
4. Report any issues for further debugging
