import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  String sanitizePhone(String phone) {
    var value = phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (value.startsWith('00')) value = '+${value.substring(2)}';
    if (value.startsWith('+')) return value;
    if (value.startsWith('91') && value.length == 12) return '+$value';
    if (RegExp(r'^\d{10}$').hasMatch(value)) return '+91$value';
    return value;
  }

  Future<bool> sendWhatsAppMessage({
    required String phone,
    required String message,
  }) async {
    final normalized = sanitizePhone(phone);
    if (normalized.isEmpty) return false;

    final uri = Uri.parse(
      'whatsapp://send?phone=${Uri.encodeComponent(normalized)}&text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    final webFallback = Uri.parse(
      'https://wa.me/${Uri.encodeComponent(normalized.replaceFirst('+', ''))}?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(webFallback)) {
      return launchUrl(webFallback, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
