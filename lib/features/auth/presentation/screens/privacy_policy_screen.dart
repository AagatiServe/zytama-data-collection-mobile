import 'package:flutter/material.dart';
import 'package:zytama_data/core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: const [
          _SectionHeader('Last updated: May 2025'),
          SizedBox(height: 16),
          _Paragraph(
            'Zytama ("we", "us", or "our") operates the Zytama Data mobile application. '
            'This page informs you of our policies regarding the collection, use, and '
            'disclosure of personal data when you use our app and the choices you have '
            'associated with that data.',
          ),
          _Section(
            title: '1. Information We Collect',
            body:
                'We collect the following information to provide and improve our service:\n\n'
                '• Account credentials (email address, agent code)\n'
                '• Product barcode data scanned through the app\n'
                '• Product images captured during data collection (front, ingredients, nutrition)\n'
                '• Device information and usage logs for diagnostics',
          ),
          _Section(
            title: '2. How We Use Your Information',
            body:
                'The information we collect is used to:\n\n'
                '• Authenticate agents and manage access\n'
                '• Upload and store product data to our servers\n'
                '• Monitor and improve app performance\n'
                '• Comply with legal obligations',
          ),
          _Section(
            title: '3. Data Storage & Security',
            body:
                'All data is transmitted over encrypted HTTPS connections and stored on '
                'secured servers. We retain product images and barcode data as long as '
                'necessary to fulfil the purposes outlined in this policy. Agent account '
                'data is retained for the duration of employment and deleted upon request.',
          ),
          _Section(
            title: '4. Camera & Storage Permissions',
            body:
                'The app requests access to your device camera solely to capture product '
                'images for data collection purposes. No images are stored on your device '
                'after they are uploaded. We do not access your device photo library.',
          ),
          _Section(
            title: '5. Sharing of Information',
            body:
                'We do not sell or rent your personal data to third parties. Data may be '
                'shared with service providers who assist us in operating the app, subject '
                'to confidentiality agreements. We may disclose data when required by law.',
          ),
          _Section(
            title: '6. Your Rights',
            body:
                'You have the right to:\n\n'
                '• Access the personal data we hold about you\n'
                '• Request correction of inaccurate data\n'
                '• Request deletion of your data\n'
                '• Withdraw consent at any time\n\n'
                'To exercise these rights, contact your administrator or reach us at '
                'support@zytama.com.',
          ),
          _Section(
            title: '7. Changes to This Policy',
            body:
                'We may update this Privacy Policy from time to time. Changes will be '
                'communicated through the app or by other appropriate means. Continued '
                'use of the app after changes constitutes your acceptance of the revised policy.',
          ),
          _Section(
            title: '8. Contact Us',
            body:
                'If you have any questions about this Privacy Policy, please contact us:\n\n'
                'Email: support@zytama.com\n'
                'Website: www.zytama.com',
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textLight,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.65,
        color: AppColors.textMedium,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.65,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}
