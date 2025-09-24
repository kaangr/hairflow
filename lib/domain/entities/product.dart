import 'package:equatable/equatable.dart';

enum ProductType {
  minoxidil,
  finasteride,
  dutasteride,
  biotin,
  sawPalmetto,
  caffeineShampoo,
  ketoconazoleShampoo,
  dermaroller,
  generalCare, // Genel saç sağlığı için özel kategori
}

class Product extends Equatable {
  final ProductType type;
  final String name;
  final String? dosage;
  final bool requiresPrescription;

  const Product({
    required this.type,
    required this.name,
    this.dosage,
    this.requiresPrescription = false,
  });

  @override
  List<Object?> get props => [type, name, dosage, requiresPrescription];

  static ProductType? extractProductType(String taskTitle) {
    final title = taskTitle.toLowerCase();
    
    if (title.contains('minoxidil')) return ProductType.minoxidil;
    if (title.contains('finasteride')) return ProductType.finasteride;
    if (title.contains('dutasteride')) return ProductType.dutasteride;
    if (title.contains('biotin')) return ProductType.biotin;
    if (title.contains('saw palmetto')) return ProductType.sawPalmetto;
    if (title.contains('kafeinli') || title.contains('caffeine')) return ProductType.caffeineShampoo;
    if (title.contains('ketoconazole') || title.contains('dht-blokajlı')) return ProductType.ketoconazoleShampoo;
    if (title.contains('dermaroller') || title.contains('masaj')) return ProductType.dermaroller;
    
    return ProductType.generalCare; // Default for general care tasks
  }

  static const Map<ProductType, String> productNames = {
    ProductType.minoxidil: 'Minoxidil',
    ProductType.finasteride: 'Finasteride',
    ProductType.dutasteride: 'Dutasteride',
    ProductType.biotin: 'Biotin',
    ProductType.sawPalmetto: 'Saw Palmetto',
    ProductType.caffeineShampoo: 'Kafeinli Şampuan',
    ProductType.ketoconazoleShampoo: 'Ketoconazole Şampuan',
    ProductType.dermaroller: 'Dermaroller',
    ProductType.generalCare: 'Genel Saç Bakımı',
  };

  static const Map<ProductType, String> productImagePaths = {
    ProductType.minoxidil: 'assets/images/products/minoxidil.png',
    ProductType.finasteride: 'assets/images/products/finasteride.png',
    ProductType.biotin: 'assets/images/products/biotin.png',
    ProductType.sawPalmetto: 'assets/images/products/saw_palmetto.png',
    ProductType.caffeineShampoo: 'assets/images/products/caffeine_shampoo.png',
    ProductType.ketoconazoleShampoo: 'assets/images/products/ketoconazole.png',
    ProductType.dutasteride: 'assets/images/products/finasteride.png', // Fallback to similar
    ProductType.dermaroller: 'assets/images/products/minoxidil.png', // Fallback
    ProductType.generalCare: 'assets/images/products/biotin.png', // Fallback
  };

  /// Returns the image path for a product type
  static String? getProductImagePath(ProductType type) {
    return productImagePaths[type];
  }

  /// Returns the image path for a task title by extracting product type
  static String? getProductImageForTask(String taskTitle) {
    final productType = extractProductType(taskTitle);
    if (productType != null) {
      return getProductImagePath(productType);
    }
    return null;
  }
}
