import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const double _padding = 16.0;

  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(_padding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildSectionContent(
                "This privacy policy explains how we collect, use, disclose, and safeguard your information when you visit our mobile application. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the application.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('1. Collection of your information'),
              const SizedBox(height: 10),
              _buildSubsectionTitle('Personal Data'),
              _buildBulletContent(
                "Demographic and other personally identifiable information (such as your name and email address) that you voluntarily give to us when choosing to participate in various activities related to the Application, such as chat, posting messages in comment sections or in our forums, liking posts, sending feedback, and responding to surveys.",
              ),
              const SizedBox(height: 10),
              _buildSubsectionTitle('Device ID and Permissions'),
              _buildBulletContent(
                "Information related to your device, such as the device ID, to ensure the application runs correctly on your device. We may request permissions to access various features of your mobile device, including:",
              ),
              _buildSubBulletContent("Internet Access: To connect to online services and APIs."),
              _buildSubBulletContent("Biometric and Fingerprint Authentication: To enhance security and provide quick access to the app."),
              _buildSubBulletContent("Phone State and Phone Numbers: To manage app functionality related to phone calls and messaging."),
              _buildSubBulletContent("Receive Boot Completed: To enable the app to start on device boot."),
              _buildSubBulletContent("Post Notifications: To send you notifications related to your account and the application."),
              const SizedBox(height: 10),
              _buildSubsectionTitle('Derivative Data'),
              _buildBulletContent(
                "Information our servers automatically collect when you access the Application, such as your native actions that are integral to the Application, including liking, re-blogging, or replying to a post, as well as other interactions with the Application and other users via server log files.",
              ),
              const SizedBox(height: 10),
              _buildSubsectionTitle('Mobile Device Access'),
              _buildBulletContent(
                "We may request access or permission to certain features from your mobile device, including your mobile device’s calendar, camera, contacts, microphone, reminders, sensors, SMS messages, social media accounts, storage, and other features. If you wish to change our access or permissions, you may do so in your device’s settings.",
              ),
              const SizedBox(height: 10),
              _buildSubsectionTitle('Push Notifications'),
              _buildBulletContent(
                "We may request to send you push notifications regarding your account or the Application. If you wish to opt-out from receiving these types of communications, you may turn them off in your device’s settings.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('2. Use of your information'),
              const SizedBox(height: 10),
              _buildBulletContent(
                "Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the Application to:",
              ),
              _buildSubBulletContent("Create and manage your account."),
              _buildSubBulletContent("Compile anonymous statistical data and analysis for use internally or with third parties."),
              _buildSubBulletContent("Deliver targeted advertising, coupons, newsletters, and other information regarding promotions and the Application to you."),
              _buildSubBulletContent("Email you regarding your account or order."),
              _buildSubBulletContent("Enable user-to-user communications."),
              _buildSubBulletContent("Fulfill and manage purchases, orders, payments, and other transactions related to the Application."),
              _buildSubBulletContent("Improve the functionality and user experience of Hello NITR."),
              _buildSubBulletContent("Prevent fraudulent transactions, monitor against theft, and protect against criminal activity."),
              _buildSubBulletContent("Process payments and refunds."),
              _buildSubBulletContent("Request feedback and contact you about your use of the Application."),
              _buildSubBulletContent("Resolve disputes and troubleshoot problems."),
              _buildSubBulletContent("Respond to product and customer service requests."),
              const SizedBox(height: 20),
              _buildSectionTitle('3. Disclosure of your information'),
              const SizedBox(height: 10),
              _buildBulletContent(
                "We may share information we have collected about you in certain situations. Your information may be disclosed as follows:",
              ),
              _buildSubBulletContent("By Law or to Protect Rights: If we believe the release of information about you is necessary to respond to legal process, to investigate or remedy potential violations of our policies, or to protect the rights, property, and safety of others, we may share your information as permitted or required by any applicable law, rule, or regulation."),
              _buildSubBulletContent("Business Transfers: We may share or transfer your information in connection with, or during negotiations of, any merger, sale of company assets, financing, or acquisition of all or a portion of our business to another company."),
              _buildSubBulletContent("Third-Party Service Providers: We may share your information with third parties that perform services for us or on our behalf, including payment processing, data analysis, email delivery, hosting services, customer service, and marketing assistance."),
              _buildSubBulletContent("Marketing Communications: With your consent, or with an opportunity for you to withdraw consent, we may share your information with third parties for marketing purposes, as permitted by law."),
              _buildSubBulletContent("Interactions with Other Users: If you interact with other users of the Application, those users may see your name, profile photo, and descriptions of your activity, including sending invitations to other users, chatting with other users, liking posts, and following blogs."),
              _buildSubBulletContent("Online Postings: When you post comments, contributions or other content to the Application, your posts may be viewed by all users and may be publicly distributed outside the Application in perpetuity."),
              _buildSubBulletContent("Third-Party Advertisers: We may use third-party advertising companies to serve ads when you visit the Application. These companies may use information about your visits to the Application and other websites that are contained in web cookies to provide advertisements about goods and services of interest to you."),
              _buildSubBulletContent("Affiliates: We may share your information with our affiliates, in which case we will require those affiliates to honor this privacy policy. Affiliates include our parent company and any subsidiaries, joint venture partners, or other companies that we control or that are under common control with us."),
              _buildSubBulletContent("Business Partners: We may share your information with our business partners to offer you certain products, services or promotions."),
              const SizedBox(height: 20),
              _buildSectionTitle('4. Security of your information'),
              const SizedBox(height: 10),
              _buildBulletContent(
                "We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that despite our efforts, no security measures are perfect or impenetrable, and no method of data transmission can be guaranteed against any interception or other type of misuse.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('5. Policy for children'),
              const SizedBox(height: 10),
              _buildBulletContent(
                "We do not knowingly solicit information from or market to children under the age of 13. If we learn that we have collected information from a child under age 13 without verification of parental consent, we will delete that information as quickly as possible. If you become aware of any data we have collected from children under age 13, please contact us at [contact email].",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('6. Changes to this privacy policy'),
              const SizedBox(height: 10),
              _buildBulletContent(
                "We may update this privacy policy from time to time in order to reflect, for example, changes to our practices or for other operational, legal, or regulatory reasons. We will notify you of any changes by posting the new privacy policy on this page. You are advised to review this privacy policy periodically for any changes.",
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
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
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
          style: TextStyle(fontSize: 16, color: AppColors.textColor),
        ),
        Expanded(
          child: Text(
            content,
            style: const TextStyle(fontSize: 16, color: AppColors.textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSubBulletContent(String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "   • ",
          style: TextStyle(fontSize: 16, color: AppColors.textColor),
        ),
        Expanded(
          child: Text(
            content,
            style: const TextStyle(fontSize: 16, color: AppColors.textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(fontSize: 16, color: AppColors.textColor),
    );
  }
}
