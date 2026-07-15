import 'package:url_launcher/url_launcher.dart';

class PhoneService {
  static Future<void> makePhoneCall(String phoneNumber) async {
    // Clean the phone number by removing + and any special characters
    String cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanPhoneNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }
}
