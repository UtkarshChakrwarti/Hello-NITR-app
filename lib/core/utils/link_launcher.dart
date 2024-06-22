import 'package:flutter/material.dart';
import 'package:hello_nitr/core/constants/app_colors.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logging/logging.dart';

class LinkLauncher {
  static final Logger _logger = Logger('LinkLauncher');

  static Future<void> launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
        _logger.info('Launched URL: $url');
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      Sentry.captureException(e);
      _logger.severe('Error launching URL: $url', e);
    }
  }

  static Future<void> makeCall(String phoneNumber) async {
    final url = "tel:$phoneNumber";
    try {
      if (await canLaunch(url)) {
        await launch(url);
        _logger.info('Initiated call to: $phoneNumber');
      } else {
        Sentry.captureException('Could not launch $url');
        throw 'Could not launch $url';
      }
    } catch (e) {
      Sentry.captureException(e);
      _logger.severe('Error making call to: $phoneNumber', e);
    }
  }

  static Future<void> sendWpMsg(String phoneNumber) async {
    final url = "https://wa.me/$phoneNumber";
    try {
      if (await canLaunch(url)) {
        await launch(url);
        Sentry.captureMessage('Sent WhatsApp message to: $phoneNumber');
        _logger.info('Sent WhatsApp message to: $phoneNumber');
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      Sentry.captureException(e);
      _logger.severe('Error sending WhatsApp message to: $phoneNumber', e);
    }
  }

  static Future<void> sendMsg(String phoneNumber) async {
    final url = "sms:$phoneNumber";
    try {
      if (await canLaunch(url)) {
        await launch(url);
        _logger.info('Sent SMS to: $phoneNumber');
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      Sentry.captureException(e);
      _logger.severe('Error sending SMS to: $phoneNumber', e);
    }
  }

  static Future<void> sendEmail(String email) async {
    final url = "mailto:$email";
    try {
      if (await canLaunch(url)) {
        await launch(url);
        _logger.info('Sent email to: $email');
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      Sentry.captureException(e);
      _logger.severe('Error sending email to: $email', e);
    }
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }
}
