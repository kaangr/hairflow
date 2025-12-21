import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tip_provider.dart';
import '../../../core/constants/app_colors.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'Tümü', 'icon': Icons.apps},
    {'id': 'minoxidil', 'name': 'Minoxidil', 'icon': Icons.water_drop},
    {'id': 'finasteride', 'name': 'Finasteride', 'icon': Icons.medication},
    {'id': 'shampoo', 'name': 'Şampuanlar', 'icon': Icons.shower},
    {'id': 'supplement', 'name': 'Takviyeler', 'icon': Icons.local_pharmacy},
    {'id': 'device', 'name': 'Cihazlar', 'icon': Icons.build},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Rehberi'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Ürün ara...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              // Category tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _categories.map((cat) => Tab(
                  icon: Icon(cat['icon'] as IconData, size: 20),
                  text: cat['name'] as String,
                )).toList(),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<TipProvider>(
        builder: (context, tipProvider, child) {
          final products = tipProvider.products;
          
          if (products.isEmpty) {
            return _buildEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: _categories.map((cat) {
              final categoryId = cat['id'] as String;
              final filteredProducts = categoryId == 'all'
                  ? products
                  : tipProvider.getProductsByCategory(categoryId);
              
              // Apply search filter
              final searchFiltered = filteredProducts.where((p) {
                if (_searchQuery.isEmpty) return true;
                final name = (p['name'] as String? ?? '').toLowerCase();
                final brand = (p['brand'] as String? ?? '').toLowerCase();
                final description = (p['description'] as String? ?? '').toLowerCase();
                return name.contains(_searchQuery) ||
                    brand.contains(_searchQuery) ||
                    description.contains(_searchQuery);
              }).toList();

              if (searchFiltered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bu kategoride ürün bulunamadı',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: searchFiltered.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(searchFiltered[index]);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Ürünler yükleniyor...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Firebase\'e bağlanılıyor. Ayarlar\'dan\n"Varsayılan Verileri Yükle" seçeneğini kullanın.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Geri Dön'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final name = product['name'] as String? ?? '';
    final brand = product['brand'] as String? ?? '';
    final description = product['description'] as String? ?? '';
    final dosage = product['dosage'] as String?;
    final warning = product['warning'] as String?;
    final effectiveness = (product['effectiveness'] as num?)?.toDouble() ?? 0.0;
    final price = product['price'] as String?;
    final tags = product['tags'] as List<dynamic>? ?? [];
    final category = product['category'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showProductDetails(product),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: _getCategoryColor(category),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          brand,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildEffectivenessStars(effectiveness),
                      if (price != null)
                        Text(
                          price,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              if (dosage != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      dosage,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              if (warning != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    warning,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: tags.take(3).map((tag) => Chip(
                  label: Text(
                    tag.toString(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.grey[200],
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEffectivenessStars(double effectiveness) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < effectiveness.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index < effectiveness) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        }
        return const Icon(Icons.star_border, color: Colors.amber, size: 16);
      }),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'minoxidil':
        return Colors.blue;
      case 'finasteride':
        return Colors.purple;
      case 'shampoo':
        return Colors.teal;
      case 'supplement':
        return Colors.green;
      case 'device':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'minoxidil':
        return Icons.water_drop;
      case 'finasteride':
        return Icons.medication;
      case 'shampoo':
        return Icons.shower;
      case 'supplement':
        return Icons.local_pharmacy;
      case 'device':
        return Icons.build;
      default:
        return Icons.inventory_2;
    }
  }

  void _showProductDetails(Map<String, dynamic> product) {
    final name = product['name'] as String? ?? '';
    final brand = product['brand'] as String? ?? '';
    final description = product['description'] as String? ?? '';
    final dosage = product['dosage'] as String?;
    final usage = product['usage'] as String?;
    final sideEffects = product['sideEffects'] as String?;
    final warning = product['warning'] as String?;
    final effectiveness = (product['effectiveness'] as num?)?.toDouble() ?? 0.0;
    final price = product['price'] as String?;
    final tags = product['tags'] as List<dynamic>? ?? [];
    final category = product['category'] as String? ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Header
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: _getCategoryColor(category),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          brand,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildEffectivenessStars(effectiveness),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (price != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Fiyat: $price',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Description
              const Text(
                '📝 Açıklama',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(description),

              if (dosage != null) ...[
                const SizedBox(height: 24),
                const Text(
                  '💊 Dozaj',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(dosage),
              ],

              if (usage != null) ...[
                const SizedBox(height: 24),
                const Text(
                  '📋 Kullanım',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(usage),
              ],

              if (sideEffects != null) ...[
                const SizedBox(height: 24),
                const Text(
                  '⚠️ Yan Etkiler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Text(sideEffects),
                ),
              ],

              if (warning != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text(warning)),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) => Chip(
                  label: Text(tag.toString()),
                  backgroundColor: _getCategoryColor(category).withValues(alpha: 0.15),
                )).toList(),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

