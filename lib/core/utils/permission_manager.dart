import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hand_speak/core/utils/translation_helper.dart';

class PermissionManager {
  static const String _permissionsGrantedKey = 'permissions_granted';
  
  // İzinler daha önce alındı mı kontrol et
  static Future<bool> hasPermissionsBeenGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionsGrantedKey) ?? false;
  }
  
  // İzinleri kaydet
  static Future<void> savePermissionsGranted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsGrantedKey, true);
  }
  
  // İzinleri al
  static Future<bool> requestPermissions(BuildContext context) async {
    // Önce cihazın mevcut izin durumunu kontrol et
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    
    debugPrint('İzin durumları - Kamera: $cameraStatus, Mikrofon: $micStatus');
    
    // Eğer izinler zaten verilmişse tekrar isteme
    if (await hasPermissionsBeenGranted() && 
        cameraStatus.isGranted && 
        micStatus.isGranted) {
      debugPrint('İzinler zaten verilmiş, tekrar istenmiyor');
      return true;
    }
    
    // İzinleri iste
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    
    // Sonuçları kontrol et
    bool allGranted = true;
    statuses.forEach((permission, status) {
      debugPrint('İzin: $permission, Durum: $status');
      if (!status.isGranted) {
        allGranted = false;
      }
    });
    
    if (allGranted) {
      // İzinlerin verildiğini kaydet
      await savePermissionsGranted();
      return true;
    } else if (context.mounted) {
      // İzin reddedildiyse kullanıcıya bilgi ver
      _showPermissionDeniedDialog(context);
      return false;
    }
    
    return false;
  }
      // İzinler reddedildiğinde gösterilecek dialog
  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(T(context, 'permissions.title')),
        content: Text(T(context, 'permissions.camera_microphone_required')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(T(context, 'permissions.cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: Text(T(context, 'permissions.go_to_settings')),
          ),
        ],
      ),
    );
  }
}
