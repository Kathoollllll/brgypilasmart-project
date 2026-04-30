import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/registration_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/request/request_categories_screen.dart';
import 'presentation/screens/request/request_form_screen.dart';
import 'presentation/screens/request/confirmation_screen.dart';
import 'presentation/screens/tracker/status_tracker_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BrgyPilaSmartApp());
}

class BrgyPilaSmartApp extends StatelessWidget {
  const BrgyPilaSmartApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: AppConstants.appName,
    theme: AppTheme.theme,
    debugShowCheckedModeBanner: false,
    home: const _AuthGate(),
    routes: {
      AppRoutes.login:        (_) => const LoginScreen(),
      AppRoutes.register:     (_) => const RegistrationScreen(),
      AppRoutes.home:         (_) => const HomeScreen(),
      AppRoutes.requestCats:  (_) => const RequestCategoriesScreen(),
      AppRoutes.requestForm:  (_) => const RequestFormScreen(),
      AppRoutes.confirmation: (_) => const ConfirmationScreen(),
      AppRoutes.tracker:      (_) => const StatusTrackerScreen(),
      AppRoutes.profile:      (_) => const ProfileScreen(),
    },
  );
}

/// Redirects to Home if logged in, Login otherwise
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (_, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return snap.data != null ? const HomeScreen() : const LoginScreen();
    },
  );
}
