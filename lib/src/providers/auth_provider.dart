import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_state.dart';
import 'supabase_provider.dart';

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AuthNotifier(supabase);
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AppAuthState> {
  final SupabaseClient _supabase;

  AuthNotifier(this._supabase) : super(const AppAuthState.initial()) {
    _init();
  }

  void _init() {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      state = AppAuthState.authenticated(
        userId: session.user.id,
        email: session.user.email ?? '',
      );
    } else {
      state = const AppAuthState.unauthenticated();
    }

    // Listen to auth changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        state = AppAuthState.authenticated(
          userId: session.user.id,
          email: session.user.email ?? '',
        );
      } else {
        state = const AppAuthState.unauthenticated();
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    state = const AppAuthState.loading();
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        state = AppAuthState.authenticated(
          userId: response.user!.id,
          email: response.user!.email ?? '',
        );
      }
    } on AuthException catch (e) {
      // Handle specific auth errors
      String errorMessage = 'เกิดข้อผิดพลาด';

      if (e.message.contains('Email not confirmed')) {
        errorMessage = 'กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ หรือสมัครสมาชิกใหม่';
      } else if (e.message.contains('Invalid login credentials')) {
        errorMessage = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
      } else if (e.message.contains('Email rate limit exceeded')) {
        errorMessage = 'ลองใหม่อีกครั้งในภายหลัง';
      } else {
        errorMessage = e.message;
      }

      state = AppAuthState.error(errorMessage);
      // Reset to unauthenticated after showing error
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          state = const AppAuthState.unauthenticated();
        }
      });
    } catch (e) {
      state = AppAuthState.error('เกิดข้อผิดพลาด: ${e.toString()}');
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          state = const AppAuthState.unauthenticated();
        }
      });
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AppAuthState.loading();
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      // If email confirmation is disabled, user will be logged in immediately
      if (response.session != null) {
        state = AppAuthState.authenticated(
          userId: response.user!.id,
          email: response.user!.email ?? '',
        );
      } else {
        // Email confirmation required - show success message
        state = AppAuthState.error(
          'สมัครสมาชิกสำเร็จ! กรุณาตรวจสอบอีเมลเพื่อยืนยันบัญชี',
        );
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            state = const AppAuthState.unauthenticated();
          }
        });
      }
    } on AuthException catch (e) {
      String errorMessage = 'เกิดข้อผิดพลาด';

      if (e.message.contains('User already registered')) {
        errorMessage = 'อีเมลนี้ถูกใช้งานแล้ว กรุณาเข้าสู่ระบบ';
      } else if (e.message.contains('Password should be at least')) {
        errorMessage = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
      } else {
        errorMessage = e.message;
      }

      state = AppAuthState.error(errorMessage);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          state = const AppAuthState.unauthenticated();
        }
      });
    } catch (e) {
      state = AppAuthState.error('เกิดข้อผิดพลาด: ${e.toString()}');
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          state = const AppAuthState.unauthenticated();
        }
      });
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = const AppAuthState.unauthenticated();
  }
}
