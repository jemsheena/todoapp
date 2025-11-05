import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/feed/presentation/screens/feed_screen.dart';
import '../features/todos/presentation/screens/todos_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import 'widgets/main_navigation.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // TODO: Add auth guard logic
      // final isAuthenticated = ref.read(authStateProvider);
      // final isGoingToLogin = state.matchedLocation == '/login';
      // if (!isAuthenticated && !isGoingToLogin) return '/login';
      // if (isAuthenticated && isGoingToLogin) return '/todos';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/todos',
        name: 'todos',
        builder: (context, state) => const MainNavigation(
          currentIndex: 0,
          child: TodosScreen(),
        ),
      ),
      GoRoute(
        path: '/feed',
        name: 'feed',
        builder: (context, state) => const MainNavigation(
          currentIndex: 1,
          child: FeedScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const MainNavigation(
          currentIndex: 2,
          child: SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const MainNavigation(
          currentIndex: 3,
          child: ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
});
