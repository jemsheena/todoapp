import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/use_cases/sign_in_use_case.dart';
import '../../domain/value_objects/email.dart';

final authStateProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    // TODO: Inject dependencies via providers
    throw UnimplementedError('Need to set up providers');
  },
);

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final SignInUseCase _signInUseCase;

  AuthController(this._signInUseCase) : super(AuthState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final emailObj = Email(email);
    final result = await _signInUseCase(emailObj, password);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  void signOut() {
    state = AuthState();
  }
}
