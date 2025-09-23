import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tip_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/tip.dart';
import '../../widgets/tip_card.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.knowledgeBase),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: AppStrings.searchTips,
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Tümü'),
                  Tab(text: 'Ürünler'),
                  Tab(text: 'Rutinler'),
                  Tab(text: 'Favoriler'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Consumer<TipProvider>(
        builder: (context, tipProvider, child) {
          if (tipProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTipsGrid(context, _filterTips(tipProvider.tips)),
              _buildTipsGrid(context, _filterTips(tipProvider.getTipsByCategory(TipCategory.product))),
              _buildTipsGrid(context, _filterTips(tipProvider.getTipsByCategory(TipCategory.routine))),
              _buildTipsGrid(context, _filterTips(tipProvider.favoriteTips)),
            ],
          );
        },
      ),
    );
  }

  List<dynamic> _filterTips(List<dynamic> tips) {
    if (_searchQuery.isEmpty) return tips;
    
    return tips.where((tip) {
      return tip.title.toLowerCase().contains(_searchQuery) ||
             tip.content.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Widget _buildTipsGrid(BuildContext context, List<dynamic> tips) {
    if (tips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'Arama sonucu bulunamadı'
                  : AppStrings.dataNotFound,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];
        return TipCard(
          tip: tip,
          onFavoriteToggle: (isFavorite) {
            context.read<TipProvider>().toggleTipFavorite(
              tip.id!,
              isFavorite,
            );
          },
          onTap: () => _showTipDetails(context, tip),
        );
      },
    );
  }

  void _showTipDetails(BuildContext context, dynamic tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tip.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        tip.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: tip.isFavorite 
                            ? Colors.red 
                            : Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        context.read<TipProvider>().toggleTipFavorite(
                          tip.id!,
                          !tip.isFavorite,
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryName(tip.category),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Text(
                      tip.content,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getCategoryName(TipCategory category) {
    switch (category) {
      case TipCategory.product:
        return 'Ürün';
      case TipCategory.routine:
        return 'Rutin';
      case TipCategory.general:
        return 'Genel';
      case TipCategory.nutrition:
        return 'Beslenme';
    }
  }
}
