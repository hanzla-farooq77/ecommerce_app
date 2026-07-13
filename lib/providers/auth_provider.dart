import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_signs.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({this.status = AuthStatus.idle, this.errorMessage});

  AuthState copyWith({AuthStatus? status, String? errorMessage}) {
    return AuthState(status: status ?? this.status, errorMessage: errorMessage);
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(email: email, password: password, name: name);
      state = state.copyWith(status: AuthStatus.success);
    } on FirebaseAuthException catch (e) {
      final msg = ref.read(authRepositoryProvider).getErrorMessage(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: "Error Occurred",
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Something went wrong.',
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      state = state.copyWith(status: AuthStatus.success);
    } on FirebaseAuthException catch (e) {
      final msg = ref.read(authRepositoryProvider).getErrorMessage(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: "Error Occurred",
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Something went wrong.',
      );
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
      state = state.copyWith(status: AuthStatus.success);
    } on FirebaseAuthException catch (e) {
      final msg = ref.read(authRepositoryProvider).getErrorMessage(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: "Error Occurred",
      );
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState();
  }

  void resetState() {
    state = const AuthState();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
