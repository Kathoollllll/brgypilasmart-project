class AppConstants {
  // App Info
  static const appName = 'BrgyPilaSmart';
  static const appTagline = 'Your barangay, smarter.';

  // Firebase Collections
  static const usersCol = 'users';
  static const requestsCol = 'requests';

  // Document Types
  static const docTypes = [
    'Barangay Clearance',
    'Certificate of Residency',
    'Barangay ID',
    'Certificate of Indigency',
    'Business Clearance',
  ];

  // Request Statuses
  static const statusRequested = 'Requested';
  static const statusVerified  = 'Verified';
  static const statusPrinted   = 'Printed';
  static const statusReady     = 'Ready';

  static const allStatuses = [
    statusRequested,
    statusVerified,
    statusPrinted,
    statusReady,
  ];

  // Processing time (days)
  static const processingDays = 2;
}

class AppRoutes {
  static const login        = '/login';
  static const register     = '/register';
  static const home         = '/home';
  static const requestCats  = '/request-categories';
  static const requestForm  = '/request-form';
  static const confirmation = '/confirmation';
  static const tracker      = '/tracker';
  static const profile      = '/profile';
}
