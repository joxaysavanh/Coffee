class Coffee {
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double rating;
  final List<String> variations; // e.g., with Chocolate, with Oat Milk

  Coffee({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    this.variations = const [],
  });
}