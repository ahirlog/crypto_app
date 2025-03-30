import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/api_service.dart';
import '../../../../services/storage_service.dart';
import '../../data/datasources/coin_remote_data_source.dart';
import '../../data/repositories/coin_repository_impl.dart';
import '../../domain/entities/coin.dart';
import '../../domain/repositories/coin_repository.dart';

// Service Providers
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

// Repository Providers
final coinRemoteDataSourceProvider = Provider<CoinRemoteDataSource>((ref) {
  return CoinRemoteDataSourceImpl(apiService: ref.watch(apiServiceProvider));
});

final coinRepositoryProvider = Provider<CoinRepository>((ref) {
  return CoinRepositoryImpl(
    remoteDataSource: ref.watch(coinRemoteDataSourceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

// State Providers
enum CoinListState { initial, loading, loaded, error }

class CoinListStateNotifier extends StateNotifier<AsyncValue<List<Coin>>> {
  final CoinRepository repository;

  CoinListStateNotifier(this.repository) : super(const AsyncValue.loading()) {
    getAllCoins();
  }

  Future<void> getAllCoins() async {
    state = const AsyncValue.loading();
    try {
      final coins = await repository.getAllCoins();
      state = AsyncValue.data(coins);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final coinListProvider = StateNotifierProvider<CoinListStateNotifier, AsyncValue<List<Coin>>>((ref) {
  return CoinListStateNotifier(ref.watch(coinRepositoryProvider));
});

// Coin Details Provider
class CoinDetailsStateNotifier extends StateNotifier<AsyncValue<Coin?>> {
  final CoinRepository repository;

  CoinDetailsStateNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> getCoinDetails(String coinId) async {
    state = const AsyncValue.loading();
    try {
      final coin = await repository.getCoinDetails(coinId);
      state = AsyncValue.data(coin);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final coinDetailsProvider = StateNotifierProvider<CoinDetailsStateNotifier, AsyncValue<Coin?>>((ref) {
  return CoinDetailsStateNotifier(ref.watch(coinRepositoryProvider));
});

// Historical Data Provider
class HistoricalDataStateNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final CoinRepository repository;

  HistoricalDataStateNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> getHistoricalData(String coinId, String period) async {
    state = const AsyncValue.loading();
    try {
      final data = await repository.getCoinHistoricalData(coinId, period);
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final historicalDataProvider = StateNotifierProvider<HistoricalDataStateNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return HistoricalDataStateNotifier(ref.watch(coinRepositoryProvider));
});

// Favorites Provider
class FavoritesNotifier extends StateNotifier<List<String>> {
  final StorageService storageService;

  FavoritesNotifier(this.storageService) : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = storageService.getFavorites();
  }

  Future<void> toggleFavorite(String coinId) async {
    if (state.contains(coinId)) {
      await storageService.removeFavorite(coinId);
      state = state.where((id) => id != coinId).toList();
    } else {
      await storageService.saveFavorite(coinId);
      state = [...state, coinId];
    }
  }

  bool isFavorite(String coinId) {
    return state.contains(coinId);
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  return FavoritesNotifier(ref.watch(storageServiceProvider));
});
