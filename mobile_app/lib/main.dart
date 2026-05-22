import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/registration_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/request/request_categories_screen.dart';
import 'presentation/screens/request/request_form_screen.dart';
import 'presentation/screens/request/confirmation_screen.dart';
import 'presentation/screens/tracker/status_tracker_screen.dart';
import 'presentation/screens/profile/profile_edit_screen.dart';
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
        onGenerateRoute: (settings) {
          late final Widget page;
          switch (settings.name) {
            case AppRoutes.login:
              page = const LoginScreen();
              break;
            case AppRoutes.register:
              page = const RegistrationScreen();
              break;
            case AppRoutes.home:
              page = const HomeScreen();
              break;
            case AppRoutes.requestCats:
              page = const RequestCategoriesScreen();
              break;
            case AppRoutes.requestForm:
              page = const RequestFormScreen();
              break;
            case AppRoutes.confirmation:
              page = const ConfirmationScreen();
              break;
            case AppRoutes.tracker:
              page = const StatusTrackerScreen();
              break;
            case AppRoutes.profile:
              page = const ProfileScreen();
              break;
            case AppRoutes.editProfile:
              page = const EditProfileScreen();
              break;
            default:
              return null;
          }
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (_, __, ___) => page,
            transitionDuration: const Duration(milliseconds: 280),
            reverseTransitionDuration: const Duration(milliseconds: 220),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity:
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            ),
          );
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
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          return snap.data != null ? const HomeScreen() : const LoginScreen();
        },
      );
}
