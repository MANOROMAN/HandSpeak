# Firebase Console Kontrol Listesi

## 1. Firebase Authentication Ayarları ✅
- E-posta/Şifre girişi etkinleştirilmeli
- Google Sign-In etkinleştirilmeli (varsa)

## 2. Firestore Database Kuralları ✅
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcı dokümanları
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Diğer koleksiyonlar için varsayılan kural
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## 3. Firebase Storage Kuralları (YAPILACAKSİ BURASI ÖNEMLİ!)
Firebase Console > Storage > Rules bölümünde aşağıdaki kuralları yapıştırın:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profil fotoğrafları
    match /profile_images/{userId}.jpg {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Video dosyaları
    match /videos/{userId}/{allPaths=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId
        && request.resource.size < 50 * 1024 * 1024; // Max 50MB
    }
    
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

## 4. Firebase Proje Ayarları
- Authentication > Settings > Authorized domains listesinde uygulamanızın domain'i olmalı
- Storage bucket oluşturulmuş olmalı (handspeak-ace26.firebasestorage.app)
