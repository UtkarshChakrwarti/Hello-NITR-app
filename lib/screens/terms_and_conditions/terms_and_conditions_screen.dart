import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  static const double _padding = 16.0;

  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(_padding),
        child: SingleChildScrollView(
          //make it color white

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "This privacy policy explains how we collect, use, disclose, and safeguard your information when you visit our mobile application. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the application.",
                style: TextStyle(fontSize: 14, color: AppColors.textColor),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('1. Collection of your information'),
              _buildSectionContent(
                "We may collect information about you in a variety of ways. The information we may collect via the Application depends on the content and materials you use, and includes:\n\n"
                "- Personal Data\n"
                "Demographic and other personally identifiable information (such as your name and email address) that you voluntarily give to us when choosing to participate in various activities related to the Application, such as chat, posting messages in comment sections or in our forums, liking posts, sending feedback, and responding to surveys.\n\n"
                "- Derivative Data\n"
                "Information our servers automatically collect when you access the Application, such as your native actions that are integral to the Application, including liking, re-blogging, or replying to a post, as well as other interactions with the Application and other users via server log files.\n\n"
                "- Mobile Device Access\n"
                "We may request access or permission to certain features from your mobile device, including your mobile device’s calendar, camera, contacts, microphone, reminders, sensors, SMS messages, social media accounts, storage, and other features. If you wish to change our access or permissions, you may do so in your device’s settings.\n\n"
                "- Push Notifications\n"
                "We may request to send you push notifications regarding your account or the Application. If you wish to opt-out from receiving these types of communications, you may turn them off in your device’s settings.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('2. Use of your information'),
              _buildSectionContent(
                "Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the Application to:\n\n"
                "- Create and manage your account.\n"
                "- Compile anonymous statistical data and analysis for use internally or with third parties.\n"
                "- Deliver targeted advertising, coupons, newsletters, and other information regarding promotions and the Application to you.\n"
                "- Email you regarding your account or order.\n"
                "- Enable user-to-user communications.\n"
                "- Fulfill and manage purchases, orders, payments, and other transactions related to the Application.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(fontSize: 14, color: AppColors.textColor),
    );
  }
}
