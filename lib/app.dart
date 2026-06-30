import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/user/booking_detail_screen.dart';
import 'screens/user/booking_form_screen.dart';
import 'screens/user/edit_profile_screen.dart';
import 'screens/user/my_plans_screen.dart';
import 'screens/user/buy_membership_screen.dart';
import 'screens/user/my_ratings_screen.dart';
import 'screens/user/settings_screen.dart';
import 'screens/user/help_support_screen.dart';
import 'screens/user/support_chat_screen.dart';
import 'screens/user/report_problem_screen.dart';
import 'screens/user/booking_chat_screen.dart';
import 'screens/user/track_expert_screen.dart';
import 'screens/user/select_location_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/user/notifications_screen.dart';
import 'screens/expert/expert_home_screen.dart';
import 'screens/expert/expert_order_detail_screen.dart';
import 'screens/expert/expert_edit_profile_screen.dart';
import 'screens/expert/expert_work_photos_screen.dart';
import 'screens/expert/expert_verify_screen.dart';
import 'screens/expert/expert_upgrade_screen.dart';
import 'screens/expert/expert_settings_screen.dart';
import 'screens/expert/expert_help_screen.dart';
import 'screens/expert/expert_chat_screen.dart';
import 'screens/expert/expert_privacy_screen.dart';
import 'screens/expert/expert_terms_screen.dart';
import 'screens/expert/expert_booking_chat_screen.dart';
import 'screens/expert/expert_profile_screen.dart';
import 'screens/expert/expert_notifications_screen.dart';
import 'screens/shared/search_results_screen.dart';
import 'screens/shared/expert_detail_screen.dart';
import 'screens/shared/privacy_policy_screen.dart';
import 'screens/shared/terms_screen.dart';
import 'models/expert.dart';

class SERVITApp extends StatelessWidget {
  const SERVITApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'SERVIT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AppEntry(),
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(
          builder: (_) => LoginScreen(role: args as String? ?? 'user'),
        );
      case '/register':
        return MaterialPageRoute(
          builder: (_) => RegisterScreen(role: args as String? ?? 'user'),
        );
      case '/forgot-password':
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );
      case '/user/home':
        return MaterialPageRoute(
          builder: (_) => const UserHomeScreen(),
        );
      case '/expert/home':
        return MaterialPageRoute(
          builder: (_) => const ExpertHomeScreen(),
        );
      case '/booking-detail':
        return MaterialPageRoute(
          builder: (_) => BookingDetailScreen(bookingId: args as String),
        );
      case '/booking':
        final expert = args as ExpertProfile;
        return MaterialPageRoute(
          builder: (_) => BookingFormScreen(
            expertId: expert.uid,
            expertName: expert.name,
            category: expert.category,
          ),
        );
      case '/expert-detail':
        final expert = args as ExpertProfile;
        return MaterialPageRoute(
          builder: (_) => ExpertDetailScreen(expert: expert),
        );
      case '/expert/order-detail':
        return MaterialPageRoute(
          builder: (_) => ExpertOrderDetailScreen(bookingId: args as String),
        );
      case '/expert/edit-profile':
        return MaterialPageRoute(
          builder: (_) => const ExpertEditProfileScreen(),
        );
      case '/expert/work-photos':
        return MaterialPageRoute(
          builder: (_) => const ExpertWorkPhotosScreen(),
        );
      case '/expert/verify':
        return MaterialPageRoute(
          builder: (_) => const ExpertVerifyScreen(),
        );
      case '/expert/upgrade':
        return MaterialPageRoute(
          builder: (_) => const ExpertUpgradeScreen(),
        );
      case '/expert/settings':
        return MaterialPageRoute(
          builder: (_) => const ExpertSettingsScreen(),
        );
      case '/expert/help':
        return MaterialPageRoute(
          builder: (_) => const ExpertHelpScreen(),
        );
      case '/expert/chat-support':
        return MaterialPageRoute(
          builder: (_) => const ExpertChatScreen(),
        );
      case '/expert/privacy':
        return MaterialPageRoute(
          builder: (_) => const ExpertPrivacyScreen(),
        );
      case '/expert/terms':
        return MaterialPageRoute(
          builder: (_) => const ExpertTermsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
        );
    }
  }
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlutterLogo(size: 80),
              SizedBox(height: 24),
              Text('SERVIT',
                  style: Theme.of(context).textTheme.headlineLarge),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
    if (auth.isLoggedIn) {
      if (auth.role == 'expert') return const ExpertHomeScreen();
      return const UserHomeScreen();
    }
    return const RoleSelectionScreen();
  }
}
