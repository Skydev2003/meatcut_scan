import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/sign_in_screen.dart';
import '../screens/home_screen.dart';
import '../screens/capture_screen.dart';
import '../screens/predict_screen.dart';

/// App router provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/signin',
    redirect: (context, state) {
      final isAuthenticated = authState.maybeWhen(
        authenticated: (_, __) => true,
        orElse: () => false,
      );
      final isSignInRoute = state.matchedLocation == '/signin';

      if (!isAuthenticated && !isSignInRoute) {
        return '/signin';
      }
      if (isAuthenticated && isSignInRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/capture',
        builder: (context, state) => const CaptureScreen(),
      ),
      GoRoute(
        path: '/predict',
        builder: (context, state) {
          final imageBytes = state.extra as List<int>?;
          return PredictScreen(imageBytes: imageBytes);
        },
      ),
    ],
  );
});
