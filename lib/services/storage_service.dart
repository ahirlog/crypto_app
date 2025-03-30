import 'package:hive_flutter/hive_flutter.dart';
import '../features/home/data/models/coin_model.dart';

const String favoritesBoxName = 'favorites';
const String coinsBoxName = 'coins';

Future<void> initializeStorage() async {
  // Register Adapters
  Hive.registerAdapter(CoinModelAdapter());

  // Open Boxes
  await Hive.openBox<String>(favoritesBoxName);
  await Hive.openBox<CoinModel>(coinsBoxName);
}

class StorageService {
  Future<void> saveFavorite(String coinId) async {
    final box = Hive.box<String>(favoritesBoxName);
    await box.put(coinId, coinId);
  }

  Future<void> removeFavorite(String coinId) async {
    final box = Hive.box<String>(favoritesBoxName);
    await box.delete(coinId);
  }

  List<String> getFavorites() {
    final box = Hive.box<String>(favoritesBoxName);
    return box.values.toList();
  }

  Future<void> cacheCoinData(List<CoinModel> coins) async {
    final box = Hive.box<CoinModel>(coinsBoxName);
    final Map<String, CoinModel> coinMap = {
      for (var coin in coins) coin.id: coin
    };
    await box.putAll(coinMap);
  }

  List<CoinModel> getCachedCoins() {
    final box = Hive.box<CoinModel>(coinsBoxName);
    return box.values.toList();
  }
}
