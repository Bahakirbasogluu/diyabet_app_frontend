import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

// Auth state provider
// Auth state provider removed - merged into AuthNotifier

// Auth notifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiClientProvider));
});

class AuthState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;
  final bool requiresMfa;
  final String? mfaEmail;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.requiresMfa = false,
    this.mfaEmail,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
    bool? requiresMfa,
    String? mfaEmail,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      requiresMfa: requiresMfa ?? this.requiresMfa,
      mfaEmail: mfaEmail ?? this.mfaEmail,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api;

  AuthNotifier(this._api) : super(const AuthState()) {
    _checkInitialToken();
  }

  Future<void> _checkInitialToken() async {
    final hasToken = await _api.hasToken();
    if (hasToken) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data;

      // Check if MFA required
      if (data['otp_sent'] == true) {
        state = state.copyWith(
          isLoading: false,
          requiresMfa: true,
          mfaEmail: email,
        );
        return false; // MFA needed
      }

      // Save tokens
      await _api.saveTokens(
        data['access_token'],
        data['refresh_token'],
      );

      state = state.copyWith(isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      final data = response.data;
      await _api.saveTokens(
        data['access_token'],
        data['refresh_token'],
      );

      state = state.copyWith(isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> verifyMfa(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.post(
        ApiConstants.mfaVerify,
        data: {'email': email, 'otp': otp},
      );

      final data = response.data;
      await _api.saveTokens(
        data['access_token'],
        data['refresh_token'],
      );

      state = state.copyWith(
        isLoading: false,
        requiresMfa: false,
        isAuthenticated: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _api.clearTokens();
    state = const AuthState(isAuthenticated: false);
  }

  String _getErrorMessage(dynamic error) {
    try {
      if (error is Exception) {
        final message = error.toString();
        if (message.contains('detail')) {
          return message.split('detail:').last.trim().replaceAll('"', '').replaceAll('}', '');
        }
      }
    } catch (_) {}
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }
}
