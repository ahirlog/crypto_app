import '../entities/coin.dart';

abstract class CoinRepository {
  Future<List<Coin>> getAllCoins();
  Future<Coin> getCoinDetails(String coinId);
  Future<List<Map<String, dynamic>>> getCoinHistoricalData(String coinId, String period);
}
