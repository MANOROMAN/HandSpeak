import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hand_speak/services/two_factor_auth_service.dart';

final twoFactorAuthProvider = Provider<TwoFactorAuthService>((ref) {
  return TwoFactorAuthService();
});

final twoFactorEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(twoFactorAuthProvider);
  return service.isTwoFactorEnabled();
});
