import '../../domain/entities/tip.dart';
import '../datasources/local_datasource.dart';
import '../models/tip_model.dart';

abstract class TipRepository {
  Future<List<Tip>> getTips();
  Future<List<Tip>> getTipsByCategory(TipCategory category);
  Future<List<Tip>> getFavoriteTips();
  Future<int> createTip(Tip tip);
  Future<void> updateTip(Tip tip);
  Future<void> deleteTip(int id);
  Future<void> toggleTipFavorite(int id, bool isFavorite);
  Future<Tip?> getRandomTip();
}

class TipRepositoryImpl implements TipRepository {
  final LocalDataSource _localDataSource;

  TipRepositoryImpl(this._localDataSource);

  @override
  Future<List<Tip>> getTips() async {
    final tipModels = await _localDataSource.getTips();
    return tipModels.cast<Tip>();
  }

  @override
  Future<List<Tip>> getTipsByCategory(TipCategory category) async {
    final categoryString = category.toString().split('.').last;
    final tipModels = await _localDataSource.getTipsByCategory(categoryString);
    return tipModels.cast<Tip>();
  }

  @override
  Future<List<Tip>> getFavoriteTips() async {
    final allTips = await getTips();
    return allTips.where((tip) => tip.isFavorite).toList();
  }

  @override
  Future<int> createTip(Tip tip) async {
    final tipModel = TipModel.fromEntity(tip);
    return await _localDataSource.insertTip(tipModel);
  }

  @override
  Future<void> updateTip(Tip tip) async {
    final tipModel = TipModel.fromEntity(tip);
    await _localDataSource.updateTip(tipModel);
  }

  @override
  Future<void> deleteTip(int id) async {
    await _localDataSource.deleteTip(id);
  }

  @override
  Future<void> toggleTipFavorite(int id, bool isFavorite) async {
    await _localDataSource.toggleTipFavorite(id, isFavorite);
  }

  @override
  Future<Tip?> getRandomTip() async {
    final tips = await getTips();
    if (tips.isEmpty) return null;
    
    tips.shuffle();
    return tips.first;
  }
}
