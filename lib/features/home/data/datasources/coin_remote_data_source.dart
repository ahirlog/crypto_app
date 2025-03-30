import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../services/api_service.dart';
import '../models/coin_model.dart';

abstract class CoinRemoteDataSource {
  Future<List<CoinModel>> getAllCoins();
  Future<CoinModel> getCoinDetails(String coinId);
  Future<List<Map<String, dynamic>>> getCoinHistoricalData(String coinId, String period);
}

class CoinRemoteDataSourceImpl implements CoinRemoteDataSource {
  final ApiService apiService;

  CoinRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<CoinModel>> getAllCoins() async {
    final response = await apiService.get('/USD');

    final List<dynamic> coinsList = response as List<dynamic>;
    return coinsList.map((coin) => CoinModel.fromJson(coin)).toList();
  }

  @override
  Future<CoinModel> getCoinDetails(String coinId) async {
    final response = await apiService.get('/$coinId/USD');
    return CoinModel.fromJson(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getCoinHistoricalData(String coinId, String period) async {
    String timespan;

    switch(period) {
      case '1D': timespan = '1DAY'; break;
      case '1W': timespan = '7DAY'; break;
      case '1M': timespan = '1MTH'; break;
      case '3M': timespan = '3MTH'; break;
      case '1Y': timespan = '1YRS'; break;
      default: timespan = '1DAY';
    }

    final response = await apiService.get(
        '/$coinId/USD/history',
        queryParams: {'period_id': timespan}
    );

    return List<Map<String, dynamic>>.from(response);
  }
}
