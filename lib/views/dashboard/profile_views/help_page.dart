import 'package:flutter/material.dart';
import 'package:BabyShop/utils/app_colors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Color(0xFF272727),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Color(0xFF272727),
            fontSize: 20,
            fontFamily: 'Circular Std',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Search for help',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 16,
                        fontFamily: 'Circular Std',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                color: Color(0xFF272727),
                fontSize: 20,
                fontFamily: 'Circular Std',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'Live Chat',
                    onTap: () {
                      // Handle live chat
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    onTap: () {
                      // Handle email
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // FAQs Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                color: Color(0xFF272727),
                fontSize: 20,
                fontFamily: 'Circular Std',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              question: 'How do I reset my password?',
              answer: 'Go to Profile > Sign Out > Reset Password.',
            ),
            _buildFAQItem(
              question: 'How do I update my account details?',
              answer: 'Navigate to Profile > Edit Profile to change your details.',
            ),
            _buildFAQItem(
              question: 'Why is my laptop listing not showing?',
              answer: 'Ensure your listing meets all guidelines. It may take up to 24 hours to appear.',
            ),
            _buildFAQItem(
              question: 'How can I contact a seller/buyer?',
              answer: 'Use the in-app chat feature or the provided contact details on the listing.',
            ),
            const SizedBox(height: 32),

            // Contact Support Section
            const Text(
              'Contact Support',
              style: TextStyle(
                color: Color(0xFF272727),
                fontSize: 20,
                fontFamily: 'Circular Std',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.phone_outlined,
              title: 'Call Support',
              subtitle: '+234 902 458 2724',
              onTap: () {
                // Handle phone call
              },
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@laptopharbor.com',
              onTap: () {
                // Handle email
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontFamily: 'Circular Std',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            color: Color(0xFF272727),
            fontSize: 16,
            fontFamily: 'Circular Std',
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
                fontFamily: 'Circular Std',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF272727),
                      fontSize: 16,
                      fontFamily: 'Circular Std',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                      fontFamily: 'Circular Std',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
