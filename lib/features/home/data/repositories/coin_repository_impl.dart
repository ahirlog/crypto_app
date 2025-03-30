import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/coin.dart';
import '../../domain/repositories/coin_repository.dart';
import '../datasources/coin_remote_data_source.dart';
import '../../../../services/storage_service.dart';

class CoinRepositoryImpl implements CoinRepository {
  final CoinRemoteDataSource remoteDataSource;
  final StorageService storageService;

  CoinRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<List<Coin>> getAllCoins() async {
    try {
      final coins = await remoteDataSource.getAllCoins();
      await storageService.cacheCoinData(coins);
      return coins;
    } on ServerException {
      // Fallback to cached data if network fails
      return storageService.getCachedCoins();
    }
  }

  @override
  Future<Coin> getCoinDetails(String coinId) async {
    try {
      return await remoteDataSource.getCoinDetails(coinId);
    } on ServerException {
      // Try to get from cache
      final cachedCoins = storageService.getCachedCoins();
      final coin = cachedCoins.firstWhere(
            (coin) => coin.id == coinId,
        orElse: () => throw ServerException(
          message: 'Coin not found in cache',
          statusCode: 404,
        ),
      );
      return coin;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCoinHistoricalData(String coinId, String period) async {
    return await remoteDataSource.getCoinHistoricalData(coinId, period);
  }
}
