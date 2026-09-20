import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f0c29),
        title: const Text('Privacy Policy'),
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildHeader('Ludo Game App'),
            // _buildSubHeader('Privacy Policy'),
            // _buildDate('Effective Date: July 4, 2026 | Version: 1.0'),
            // const SizedBox(height: 24),
            _buildSection(
              '1. Introduction',
              'Welcome to Ludo Game App ("the App"). This App is an offline multiplayer '
                  'board game developed for entertainment purposes. It allows 2-4 players '
                  'to play Ludo on the same device without requiring an internet connection.\n\n'
                  'This Privacy Policy explains what data the App handles and how it is managed. '
                  'By using the App, you agree to the practices described in this policy.',
            ),
            _buildSection(
              '2. Data Collection',
              'We do not collect any personal data. The App is entirely offline and operates '
                  'without requiring any user accounts, login credentials, or personal information.\n\n'
                  'The App does not collect, store, transmit, or share any of the following:\n\n'
                  '• Names or email addresses\n'
                  '• Location data\n'
                  '• Device identifiers\n'
                  '• Gameplay statistics\n'
                  '• Any personally identifiable information\n\n'
                  'All game data (player names, scores, settings) is stored locally on your '
                  'device and never leaves it.',
            ),
            _buildSection(
              '3. Permissions',
              'The App does not request or require any special device permissions such as '
                  'camera, microphone, contacts, storage, or location access.\n\n'
                  'The App functions entirely without any device permissions.',
            ),
            _buildSection(
              '4. Children\'s Privacy',
              'The App is family-friendly and designed to be safe for users of all ages. '
                  'We do not knowingly collect any personal information from children under '
                  'the age of 13.\n\n'
                  'The App complies with the Children\'s Online Privacy Protection Act (COPPA). '
                  'Since no data is collected, the App is safe for children to use without '
                  'parental supervision.',
            ),
            _buildSection(
              '5. Third-Party Services',
              'The App does not integrate, use, or access any third-party services, '
                  'including but not limited to:\n\n'
                  '• Advertising networks (e.g., AdMob)\n'
                  '• Analytics tools (e.g., Firebase Analytics)\n'
                  '• Social media platforms\n'
                  '• Cloud services\n\n'
                  'No third party has access to any data through this App.',
            ),
            _buildSection(
              '6. Data Security',
              'Since the App does not collect, store, or transmit any data externally, '
                  'there is no risk of data breaches or unauthorized access to personal information.\n\n'
                  'All game data remains stored locally on your device in accordance with '
                  'standard Flutter/SharedPreferences practices.',
            ),
            _buildSection(
              '7. Changes to This Policy',
              'We may update this Privacy Policy from time to time to reflect changes in '
                  'the App\'s functionality or legal requirements. Any changes will be '
                  'reflected in the "Effective Date" at the top of this policy.\n\n'
                  'Users will be notified of significant changes through in-app updates '
                  'or App Store/Play Store update notes.',
            ),
            _buildSection(
              '8. Contact Information',
              'If you have any questions, concerns, or requests regarding this Privacy '
                  'Policy or the App\'s data practices, please contact us at:\n\n'
                  'Email: support@ludogame.app\n\n'
                  'We will respond to all inquiries within a reasonable time frame.',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 16,
      ),
    );
  }

  Widget _buildDate(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF9C7CF4),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
