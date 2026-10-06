import 'package:url_launcher/url_launcher.dart';

class MapService {
  static Future<void> openLocation({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=$latitude,$longitude',
    );

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('تعذر فتح الخرائط');
    }
  }
}
