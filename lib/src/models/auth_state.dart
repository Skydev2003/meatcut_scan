import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Authentication state for the app
@freezed
class AppAuthState with _$AppAuthState {
  const factory AppAuthState.initial() = _Initial;
  const factory AppAuthState.loading() = _Loading;
  const factory AppAuthState.authenticated({
    required String userId,
    required String email,
  }) = _Authenticated;
  const factory AppAuthState.unauthenticated() = _Unauthenticated;
  const factory AppAuthState.error(String message) = _Error;
}
