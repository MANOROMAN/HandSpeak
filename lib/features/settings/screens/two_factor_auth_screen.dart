import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hand_speak/core/utils/translation_helper.dart' show T;

class TwoFactorAuthScreen extends ConsumerStatefulWidget {
  const TwoFactorAuthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends ConsumerState<TwoFactorAuthScreen> {
  bool _isLoading = false;
  String? _qrData;
  String? _secretKey;
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _enable2FA() async {
    setState(() => _isLoading = true);
    try {
      // 2FA servisinden QR kodu ve gizli anahtarı al
      // Bu kısmı daha sonra implement edeceğiz
      setState(() {
        _qrData = 'otpauth://totp/HandSpeak:user@example.com?secret=SECRETKEY&issuer=HandSpeak';
        _secretKey = 'SECRETKEY';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verify2FA() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen doğrulama kodunu girin')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Doğrulama kodunu kontrol et
      // Bu kısmı daha sonra implement edeceğiz
      await Future.delayed(const Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('2FA başarıyla etkinleştirildi')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İki Faktörlü Doğrulama'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İki faktörlü kimlik doğrulama (2FA)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    const Text(
                      'Hesabınızı daha güvenli hale getirmek için Google Authenticator veya benzer bir uygulama kullanarak iki faktörlü kimlik doğrulamayı etkinleştirin.',
                    ),
                    SizedBox(height: 16.h),
                    if (_qrData == null)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _enable2FA,
                          icon: const Icon(Icons.security),
                          label: Text(_isLoading ? 'Yükleniyor...' : '2FA\'yı Etkinleştir'),
                        ),
                      )
                    else ...[
                      const Text(
                        '1. Authenticator uygulamanızı açın ve QR kodu tarayın:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.h),
                      Center(
                        child: QrImageView(
                          data: _qrData!,
                          version: QrVersions.auto,
                          size: 200.w,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      const Text(
                        '2. Veya bu kodu manuel olarak girin:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _secretKey!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kod kopyalandı')),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _secretKey!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              const Icon(Icons.copy, size: 16),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      const Text(
                        '3. Authenticator uygulamasından aldığınız 6 haneli kodu girin:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          hintText: '000000',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                      SizedBox(height: 16.h),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verify2FA,
                          child: Text(_isLoading ? 'Doğrulanıyor...' : 'Doğrula ve Etkinleştir'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
