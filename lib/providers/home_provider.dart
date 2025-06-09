import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hand_speak/core/services/camera_service.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(
    cameraService: ref.watch(cameraServiceProvider),
  );
});

class HomeController extends StateNotifier<HomeState> {
  final CameraService _cameraService;
  
  HomeController({
    required CameraService cameraService,
  }) : _cameraService = cameraService,
       super(const HomeState());

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      await _cameraService.initialize();
      _cameraService.onGestureDetected = _onGestureDetected;
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void _onGestureDetected(String gesture) {
    state = state.copyWith(
      currentGesture: gesture,
      detectedGestures: [...state.detectedGestures, gesture],
    );
  }

  void clearGestures() {
    state = state.copyWith(
      detectedGestures: [],
      currentGesture: null,
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}

class HomeState {
  final bool isLoading;
  final bool isInitialized;
  final String? error;
  final String? currentGesture;
  final List<String> detectedGestures;

  const HomeState({
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
    this.currentGesture,
    this.detectedGestures = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? error,
    String? currentGesture,
    List<String>? detectedGestures,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
      currentGesture: currentGesture ?? this.currentGesture,
      detectedGestures: detectedGestures ?? this.detectedGestures,
    );
  }
}
