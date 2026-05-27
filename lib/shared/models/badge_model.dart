class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int colorValue; // Neobrutalist background color hex

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.colorValue,
  });
}
