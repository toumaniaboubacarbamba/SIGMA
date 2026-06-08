import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? email;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.email,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, String? email, String? error}) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, email, error];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(const AuthState());

  Future<void> check() async {
    final has = await _repo.hasToken();
    final email = await _repo.currentEmail();
    emit(AuthState(
      status: has ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      email: email,
    ));
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));
    try {
      await _repo.login(email, password);
      emit(AuthState(status: AuthStatus.authenticated, email: email));
    } on AuthException catch (e) {
      emit(AuthState(status: AuthStatus.unauthenticated, error: e.message));
    } catch (_) {
      emit(const AuthState(
        status: AuthStatus.unauthenticated,
        error: 'Une erreur est survenue. Réessayez.',
      ));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
