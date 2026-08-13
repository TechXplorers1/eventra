import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppUtils {
  static Future<void> launchWhatsApp(BuildContext context, String phone, String message) async {
    final url = Uri.parse('whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open WhatsApp. Make sure it is installed on your device.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to launch WhatsApp.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
