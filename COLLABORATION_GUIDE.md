# 👥 HandSpeak Collaboration Guide

## 🚀 İlk Kurulum (Arkadaşınız için)

### 1. Repository'yi Clone Etme
```bash
git clone https://github.com/MANOROMAN/HandSpeak.git
cd HandSpeak
```

### 2. Flutter Dependencies Kurma
```bash
flutter pub get
flutter pub upgrade
```

### 3. Git Konfigürasyonu
```bash
git config user.name "ARKADAŞ_ADI"
git config user.email "arkadas@email.com"
```

## 📝 Günlük Çalışma Akışı

### 1. Son Değişiklikleri Çekme
```bash
git pull origin master
```

### 2. Değişiklik Yapma ve Commit Etme
```bash
# Değişiklikleri staging area'ya ekleme
git add .

# Commit mesajı ile kaydetme
git commit -m "Açıklayıcı commit mesajı"

# Master branch'e push etme
git push origin master
```

### 3. Conflict Çözme (Eğer çıkarsa)
```bash
# Conflictleri manuel olarak çözdükten sonra
git add .
git commit -m "Merge conflict çözüldü"
git push origin master
```

## 🔄 Önemli Git Komutları

### Mevcut Durumu Kontrol Etme
```bash
git status
git log --oneline -5
```

### Değişiklikleri Geri Alma
```bash
# Son commit'i geri alma (henüz push edilmemişse)
git reset --soft HEAD~1

# Dosyadaki değişiklikleri geri alma
git checkout -- dosya_adi.dart
```

### Branch İşlemleri (İsteğe Bağlı)
```bash
# Yeni branch oluşturma
git checkout -b yeni-feature

# Master'a geri dönme
git checkout master

# Branch'i merge etme
git merge yeni-feature
```

## ⚠️ Önemli Notlar

1. **Her zaman önce pull yapın**: `git pull origin master`
2. **Açıklayıcı commit mesajları yazın**
3. **Büyük değişiklikler öncesi backup alın**
4. **Test edin**: `flutter analyze` ve `flutter test`
5. **Conflict çıkarsa panik yapmayın, çözülebilir**

## 🛠️ Flutter Komutları

```bash
# Projeyi çalıştırma
flutter run

# Analiz yapma
flutter analyze

# Dependencies güncelleme
flutter pub upgrade

# Cache temizleme
flutter clean
flutter pub get
```

## 📞 Yardım

Herhangi bir sorun yaşarsanız:
1. `git status` komutunu çalıştırın
2. Hatayı tam olarak kopyalayın
3. WhatsApp/Telegram'dan mesaj atın

---
**Son Güncelleme**: Haziran 2025
