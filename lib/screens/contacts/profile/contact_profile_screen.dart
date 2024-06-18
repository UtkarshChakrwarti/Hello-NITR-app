import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/screens/contacts/profile/widgets/additional_info.dart';
import 'package:hello_nitr/screens/contacts/profile/widgets/contact_tile.dart';
import 'package:hello_nitr/screens/contacts/profile/widgets/email_tile.dart';
import 'package:hello_nitr/screens/contacts/profile/widgets/profile_header.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hello_nitr/models/user.dart';

class ContactProfileScreen extends StatelessWidget {
  final User contact;
  const ContactProfileScreen(this.contact, {super.key});

  void _shareContact(BuildContext context) {
    final contactInfo = '''
${contact.firstName} ${contact.middleName ?? ''} ${contact.lastName} (${contact.departmentName})
Mobile: ${contact.mobile ?? 'N/A'}
Work: ${_prependPrefix(contact.workPhone) ?? 'N/A'}
Residence: ${_prependPrefix(contact.residencePhone) ?? 'N/A'}
Email: ${contact.email ?? 'N/A'}, NIT Rourkela
''';
    try {
      Share.share(contactInfo, subject: "Contact Information");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share contact: $e')),
      );
    }
  }

  bool _isValidBase64(String base64String) {
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Pattern.hasMatch(base64String);
  }

  static String? _prependPrefix(String? phoneNumber) {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      return '0661246$phoneNumber';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = [
      contact.firstName,
      contact.middleName,
      contact.lastName
    ].where((name) => name != null && name.isNotEmpty).join(' ');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          fullName,
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.primaryColor),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            color: AppColors.primaryColor,
            onPressed: () => _shareContact(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(contact: contact, isValidBase64: _isValidBase64),
              Divider(),
              ContactTile(
                  title: "Mobile", subtitle: contact.mobile, isMobile: true),
              if (contact.workPhone != null && contact.workPhone!.isNotEmpty)
                ContactTile(
                    title: "Work Number",
                    subtitle: _prependPrefix(contact.workPhone),
                    isMobile: false),
              if (contact.residencePhone != null &&
                  contact.residencePhone!.isNotEmpty)
                ContactTile(
                    title: "Residence",
                    subtitle: _prependPrefix(contact.residencePhone),
                    isMobile: false),
              Divider(),
              EmailTile(
                  title: "Personal Email", subtitle: contact.personalEmail),
              if (contact.email != null && contact.email!.isNotEmpty)
                EmailTile(title: "Work Email", subtitle: contact.email!),
              Divider(),
              if (contact.roomNo != null && contact.roomNo!.isNotEmpty)
                AdditionalInfoTile(
                    label: "Cabin Number:", info: contact.roomNo!),
              if (contact.quarterNo != null && contact.quarterNo!.isNotEmpty)
                AdditionalInfoTile(
                    label: "Quarter Number:", info: contact.quarterNo!),
            ],
          ),
        ),
      ),
    );
  }
}
