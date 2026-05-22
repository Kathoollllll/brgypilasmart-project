import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppConstants {
  // App Info
  static const appName = 'BrgyPilaSmart';
  static const appTagline = 'Your barangay, smarter.';

  // Firebase Collections
  static const usersCol = 'users';
  static const requestsCol = 'requests';

  // Request categories and document lists
  // EDITABLE: Update categories and document selections here.
  static const requestCategoryList = [
    RequestCategory('Personal ID', Icons.badge_outlined,
        'Barangay Clearance, ID & Residency', AppColors.primary),
    RequestCategory('Financial Aid', Icons.attach_money,
        'Assistance certificates for qualifying residents', Color(0xFFEA580C)),
    RequestCategory('Employment', Icons.work_outline,
        'Employment and residency verification', Color(0xFF7C3AED)),
    RequestCategory('Business', Icons.store_outlined,
        'Business clearances and permits', Color(0xFF059669)),
    RequestCategory('Legal & Travel', Icons.gavel_outlined,
        'Travel and legal certifications', Color(0xFFDC2626)),
  ];

  static const requestCategoryDocuments = {
    'Personal ID': [
      'Barangay Clearance',
      'Barangay ID',
      'Certificate of Residency',
      'Certificate of Household Membership',
      'Voter’s Residency Certification',
    ],
    'Financial Aid': [
      'Certificate of Indigency',
      'Certificate for Financial Assistance',
      'Certificate for Scholarship Assistance',
      'Certificate for Burial Assistance',
      'Certificate for Hospital Assistance',
      'Certificate for Senior Citizen Assistance',
      'Certificate for 4Ps / DSWD Support',
    ],
    'Employment': [
      'Barangay Clearance for Employment',
      'First Time Jobseeker Certificate',
      'Residency Certificate for Employment',
      'Local Employment Verification',
    ],
    'Business': [
      'Barangay Business Clearance',
      'Certificate of Business Residency',
      'Barangay Clearance for Mayor’s Permit',
      'Home Business Clearance',
      'Sari-Sari Store Clearance',
      'Business Closure Clearance',
    ],
    'Legal & Travel': [
      'Barangay Blotter Report',
      'Certificate of Appearance',
      'Incident Report Certification',
      'Barangay Protection Order (BPO) for VAWC cases',
      'Summon Notice',
      'Complaint Record Certification',
      'Travel Clearance',
      'Travel Residency Certificate',
      'Certificate for Travel Permit',
      'Minor Travel Consent Certification',
      'Local Travel Certification',
      'Residency Verification for Passport Application',
      'Barangay Clearance for Travel Abroad',
      'Student Travel Certification',
      'OFW Supporting Residency Certificate',
    ],
  };

  static List<String> get allDocTypes =>
      requestCategoryDocuments.values.expand((items) => items).toList();

  // Request Statuses
  static const statusRequested = 'Requested';
  static const statusVerified = 'Verified';
  static const statusPrinted = 'Printing';
  static const statusReady = 'Ready';
  static const statusCanceled = 'Canceled';

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
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const requestCats = '/request-categories';
  static const requestForm = '/request-form';
  static const confirmation = '/confirmation';
  static const tracker = '/tracker';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
}

class RequestCategory {
  final String label;
  final IconData icon;
  final String subtitle;
  final Color color;

  const RequestCategory(this.label, this.icon, this.subtitle, this.color);
}
