class ProductModel {
  final String productId;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final int price;
  final bool isAvailable;

  ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.isAvailable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['product_id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      // Pastikan konversi ke int aman (API kadang kirim string)
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      isAvailable: json['is_available'] ?? false,
    );
  }
}