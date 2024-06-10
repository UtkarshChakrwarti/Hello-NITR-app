import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:hello_nitr/core/utils/link_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

    Share.share(contactInfo, subject: "Contact Information");
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
    String fullName =
        '${contact.firstName} ${contact.middleName ?? ''} ${contact.lastName}';
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
              _buildProfileHeader(),
              Divider(),
              _buildContactTile("Mobile", contact.mobile, true),
              if (contact.workPhone != null && contact.workPhone!.isNotEmpty)
                _buildContactTile(
                    "Work Number", _prependPrefix(contact.workPhone), false),
              if (contact.residencePhone != null &&
                  contact.residencePhone!.isNotEmpty)
                _buildContactTile(
                    "Residence", _prependPrefix(contact.residencePhone), false),
              Divider(),
              _buildEmailTile("Personal Email", contact.personalEmail),
              if (contact.email != null && contact.email!.isNotEmpty)
                _buildEmailTile("Work Email", contact.email!),
              Divider(),
              if (contact.roomNo != null && contact.roomNo!.isNotEmpty)
                _buildAdditionalInfo("Cabin Number:", contact.roomNo!),
              if (contact.quarterNo != null && contact.quarterNo!.isNotEmpty)
                _buildAdditionalInfo("Quarter Number:", "${contact.quarterNo}"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    String fullName =
        '${contact.firstName} ${contact.middleName ?? ''} ${contact.lastName}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryColor,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundImage:
                contact.photo != null && _isValidBase64(contact.photo!)
                    ? MemoryImage(base64Decode(contact.photo!))
                    : null,
            child: contact.photo == null || !_isValidBase64(contact.photo!)
                ? Text(
                    "${contact.firstName![0]}",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  )
                : null,
            backgroundColor: AppColors.secondaryColor,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 5),
              Text(
                contact.designation ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Roboto',
                ),
              ),
              Text(
                contact.departmentName ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile(String title, String? subtitle, bool isMobile) {
    if (subtitle == null || subtitle.isEmpty) {
      return SizedBox.shrink();
    }
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 1.0),
      title: Text(title, style: TextStyle(fontFamily: 'Roboto')),
      subtitle: Text(subtitle, style: TextStyle(fontFamily: 'Roboto')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon:
                Icon(CupertinoIcons.phone_solid, color: AppColors.primaryColor),
            onPressed: () => LinkLauncher.makeCall(subtitle),
          ),
          if (isMobile) ...[
            SizedBox(width: 10),
            IconButton(
              icon: Icon(FontAwesomeIcons.whatsapp,
                  color: AppColors.primaryColor),
              onPressed: () => LinkLauncher.sendWpMsg(subtitle),
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(CupertinoIcons.chat_bubble_text_fill,
                  color: AppColors.primaryColor),
              onPressed: () => LinkLauncher.sendMsg(subtitle),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmailTile(String title, String? subtitle) {
    if (subtitle == null || subtitle.isEmpty) {
      return SizedBox.shrink();
    }
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 1.0),
      title: Text(title, style: TextStyle(fontFamily: 'Roboto')),
      subtitle: Text(subtitle, style: TextStyle(fontFamily: 'Roboto')),
      trailing: IconButton(
        icon: Icon(CupertinoIcons.mail_solid, color: AppColors.primaryColor),
        onPressed: () => LinkLauncher.sendEmail(subtitle),
      ),
    );
  }

  Widget _buildAdditionalInfo(String label, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          Expanded(
            child: Text(
              info,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
