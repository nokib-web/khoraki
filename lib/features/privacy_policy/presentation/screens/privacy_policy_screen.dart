import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Developer Note Alert Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.secondary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Developer Note: Please update and customize this Privacy Policy text before submitting to Google Play Store.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Privacy Policy for Khoraki',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Last updated: August 2026',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Divider(height: 32),
              const Text(
                '1. Information We Collect\n'
                'Khoraki collects information necessary to provide household meal and expense management services:\n'
                '• Phone Number: Used for secure authentication via SMS OTP.\n'
                '• Display Name & Role: Used to identify members and managers within your household mess.\n'
                '• Meal & Expense Data: Daily meal selections, bazar cost records, and optional receipt images.\n\n'
                '2. How We Use Information\n'
                'Your information is used solely to calculate mess meal rates, display daily headcount, and maintain mess expense history for household members.\n\n'
                '3. Data Storage & Security\n'
                'All data is stored securely using Google Firebase Authentication, Cloud Firestore, and Firebase Storage with strict encryption and role-based access rules.\n\n'
                '4. Third-Party Sharing\n'
                'Khoraki does not sell, rent, or share personal user data with any third-party advertisers.\n\n'
                '5. Contact Us\n'
                'For privacy inquiries, contact support at: support@khoraki.app',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
