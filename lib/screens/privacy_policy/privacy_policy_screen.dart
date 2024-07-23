import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 20,
              fontFamily: 'Sans-serif',
              fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        elevation: 1,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSectionContent(
                "This privacy policy explains how we collect, use, disclose, and safeguard your information when you visit our mobile application. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the application.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('1. Collection of your information'),
              const SizedBox(height: 10),
              _buildSubsectionTitle('Personal Data'),
              _buildBulletContent(
                "We collect demographic and personally identifiable information (such as your name and email address) that you voluntarily provide when participating in activities related to the Application, such as chat, posting messages, liking posts, sending feedback, and responding to surveys.",
              ),
              const SizedBox(height: 10),
              _buildSubsectionTitle('Device ID and Permissions'),
              _buildBulletContent(
                "We collect device-related information, such as the device ID, to ensure the application runs correctly on your device. We may request permissions to access various features of your mobile device, including:",
              ),
              _buildSubBulletContent(
                  "Internet Access: To connect to online services and APIs."),
              _buildSubBulletContent(
                  "Biometric Authentication: To enhance security and provide quick access to the app."),
              _buildSubBulletContent(
                  "Phone State: To manage app functionality related to phone calls and messaging."),
              _buildSubBulletContent(
                  "Post Notifications: To send you notifications related to your account and the application."),
              const SizedBox(height: 10),
              _buildSubsectionTitle('Derivative Data'),
              _buildBulletContent(
                "Our servers automatically collect certain information when you access the Application, such as your actions that are integral to the Application, including liking, re-blogging, or replying to a post, and other interactions with the Application and other users via server log files.",
              ),
              const SizedBox(height: 10),
              _buildSubsectionTitle('Mobile Device Access'),
              _buildBulletContent(
                "We may request access to certain features of your mobile device, such as the calendar, camera, contacts, microphone, reminders, sensors, SMS messages, social media accounts, storage, and other features. You can change these permissions in your device’s settings.",
              ),
              const SizedBox(height: 10),
              _buildSubsectionTitle('Push Notifications'),
              _buildBulletContent(
                "We may request to send you push notifications regarding your account or the Application. You can opt-out from receiving these notifications in your device’s settings.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('2. Use of your information'),
              const SizedBox(height: 10),
              _buildBulletContent(
                "We use your information to provide you with a smooth, efficient, and customized experience. Specifically, we may use your information to:",
              ),
              _buildSubBulletContent("Create and manage your account."),
              _buildSubBulletContent(
                  "Compile anonymous statistical data and analysis."),
              _buildSubBulletContent(
                  "Deliver targeted advertising, coupons, and other information."),
              _buildSubBulletContent(
                  "Email you regarding your account or orders."),
              _buildSubBulletContent("Enable user-to-user communications."),
              _buildSubBulletContent(
                  "Fulfill and manage purchases and other transactions."),
              _buildSubBulletContent(
                  "Improve the functionality and user experience of Hello NITR."),
              _buildSubBulletContent(
                  "Prevent fraudulent transactions and protect against criminal activity."),
              _buildSubBulletContent("Process payments and refunds."),
              _buildSubBulletContent(
                  "Request feedback and contact you about your use of the Application."),
              _buildSubBulletContent(
                  "Resolve disputes and troubleshoot problems."),
              _buildSubBulletContent(
                  "Respond to product and customer service requests."),
              const SizedBox(height: 20),
              _buildSectionTitle('3. Disclosure of your information'),
              const SizedBox(height: 10),
              _buildBulletContent(
                "We may share your information in certain situations, including:",
              ),
              _buildSubBulletContent(
                  "By Law: If required to respond to legal process or protect rights."),
              _buildSubBulletContent(
                  "Business Transfers: During negotiations or in connection with any merger, sale of company assets, financing, or acquisition."),
              _buildSubBulletContent(
                  "Third-Party Service Providers: For services such as payment processing, data analysis, email delivery, hosting services, customer service, and marketing."),
              _buildSubBulletContent(
                  "Marketing Communications: With your consent for marketing purposes."),
              _buildSubBulletContent(
                  "Interactions with Other Users: Other users may see your name, profile photo, and activity descriptions."),
              _buildSubBulletContent(
                  "Online Postings: Your posts may be publicly distributed outside the Application."),
              _buildSubBulletContent(
                  "Third-Party Advertisers: These companies may use information about your visits to provide advertisements."),
              _buildSubBulletContent(
                  "Affiliates: With our affiliates, who will honor this privacy policy."),
              _buildSubBulletContent(
                  "Business Partners: To offer certain products, services, or promotions."),
              const SizedBox(height: 20),
              _buildSectionTitle('4. Security of your information'),
              const SizedBox(height: 10),
              _buildBulletContent(
                "We use administrative, technical, and physical security measures to protect your personal information. Despite our efforts, no security measures are perfect, and no method of data transmission can be guaranteed against interception or misuse.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('5. Policy for children'),
              const SizedBox(height: 10),
              _buildBulletContent(
                "We do not knowingly solicit information from or market to children under the age of 13. If we learn that we have collected information from a child under 13 without parental consent, we will delete that information as quickly as possible. If you become aware of any data we have collected from children under 13, please contact us.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('6. Changes to this privacy policy'),
              const SizedBox(height: 10),
              _buildBulletContent(
                "We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page. Please review this privacy policy periodically for any changes.",
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
        fontSize: 18,
         fontWeight: FontWeight.w500,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
         fontWeight: FontWeight.w500,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildBulletContent(String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "• ",
          style: TextStyle(fontSize: 14, color: AppColors.textColor),
        ),
        Expanded(
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, color: AppColors.textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSubBulletContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 14, color: AppColors.textColor),
          ),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(fontSize: 14, color: AppColors.textColor),
            ),
          ),
        ],
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
