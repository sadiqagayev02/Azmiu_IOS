class MaterialItem {
  final String number;
  final String subject;
  final String topic;
  final String link; // PDF fayl linki

  MaterialItem({
    required this.number,
    required this.subject,
    required this.topic,
    required this.link,
  });
}

class MaterialsModel {
  final String title;
  final List<MaterialItem> items;

  MaterialsModel({
    required this.title,
    required this.items,
  });
}