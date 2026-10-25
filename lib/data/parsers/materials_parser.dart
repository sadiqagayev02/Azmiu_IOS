import 'package:flutter/foundation.dart' show debugPrint;
import 'package:html/parser.dart' as html_parser;
import 'package:azmiu_app/data/models/materials_model.dart';

class MaterialsParser {
  static MaterialsModel parse(String html) {
    debugPrint('=== MATERIALS PARSER BAŞLAYIR ===');
    final doc = html_parser.parse(html);

    // Başlıq
    String title = 'Elektron materiallar';
    final caption = doc.querySelector('.portlet .caption');
    if (caption != null) {
      title = caption.text.trim();
    }

    final List<MaterialItem> items = [];

    // Cədvəlləri gəzirik
    final table = doc.querySelector('table');
    if (table != null) {
      final rows = table.querySelectorAll('tr');
      for (int i = 1; i < rows.length; i++) {
        final cells = rows[i].querySelectorAll('td');
        if (cells.length >= 3) {
          final number = cells[0].text.trim();
          final subject = cells[1].text.trim();
          final topic = cells[2].text.trim();
          
          // Linki tap (əgər varsa)
          String link = '';
          final aTag = cells[1].querySelector('a');
          if (aTag != null) {
            link = aTag.attributes['href'] ?? '';
          }

          if (subject.isNotEmpty && topic.isNotEmpty) {
            items.add(MaterialItem(
              number: number,
              subject: subject,
              topic: topic,
              link: link,
            ));
          }
        }
      }
    }

    debugPrint('=== PARSER NƏTİCƏ: ${items.length} material tapıldı ===');

    return MaterialsModel(title: title, items: items);
  }
}