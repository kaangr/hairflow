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
}
