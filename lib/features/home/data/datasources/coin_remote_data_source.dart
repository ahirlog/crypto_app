import 'dart:developer' as dev;
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
    try {
      final response = await apiService.get('/USD');
      
      dev.log('GetAllCoins Response type: ${response.runtimeType}');
      dev.log('GetAllCoins Response: ${response.toString().substring(0, min(200, response.toString().length))}...');

      // Check if response is a map and extract the list of coins
      if (response is Map<String, dynamic>) {
        // Check if the response contains a 'rates' field or another field that might contain the coin data
        if (response.containsKey('rates')) {
          final List<CoinModel> coins = [];
          final List<dynamic> ratesList = response['rates'] as List<dynamic>;
          final String baseAsset = response['asset_id_base'] ?? 'USD';
          
          // First add the base asset (USD)
          coins.add(CoinModel.fromJson({
            'asset_id_base': baseAsset,
            'name': baseAsset,
            'symbol': baseAsset,
            'rate': 1.0,
            'rate_change_percent_24h': 0.0,
            'volume_24h': 0.0,
            'market_cap': 0.0,
            'icon_url': '',
          }));
          
          // Convert each entry in the list to a CoinModel - these are other coins relative to USD
          for (final rateData in ratesList) {
            if (rateData is Map<String, dynamic>) {
              try {
                // Use quote asset as the coin ID instead of base asset
                final String coinId = rateData['asset_id_quote'] ?? '';
                if (coinId.isNotEmpty) {
                  final Map<String, dynamic> coinData = {
                    'asset_id_base': coinId,
                    'name': coinId,
                    'symbol': coinId,
                    'rate': 1.0 / (rateData['rate'] ?? 1.0),  // Invert rate since we're looking from the perspective of the quote asset
                    'rate_change_percent_24h': 0.0, // API doesn't seem to provide this directly
                    'volume_24h': 0.0,
                    'market_cap': 0.0,
                    'icon_url': '',
                    'time': rateData['time'],
                  };
                  
                  coins.add(CoinModel.fromJson(coinData));
                }
              } catch (e) {
                dev.log('Error parsing coin data: $e');
                dev.log('Coin data: $rateData');
              }
            }
          }
          
          return coins;
        } else if (response.containsKey('data')) {
          // Some APIs nest the data in a 'data' field
          final data = response['data'];
          if (data is List) {
            return data.map((coin) => CoinModel.fromJson(coin as Map<String, dynamic>)).toList();
          }
        } else {
          // If there's no obvious list structure, try to create a CoinModel from the map itself
          // This handles the case where the API returns a single object for all coins
          try {
            return [CoinModel.fromJson(response)];
          } catch (e) {
            dev.log('Error parsing single coin response: $e');
            throw Exception('Unexpected response format: ${response.toString().substring(0, min(100, response.toString().length))}...');
          }
        }
      } else if (response is List) {
        // If the response is already a list, use it directly
        dev.log('Response is a List with ${response.length} items');
        if (response.isNotEmpty) {
          dev.log('First item type: ${response.first.runtimeType}');
        }
        return response.map((coin) {
          if (coin is Map<String, dynamic>) {
            return CoinModel.fromJson(coin);
          } else {
            dev.log('Unexpected item type in list: ${coin.runtimeType}');
            throw Exception('Invalid coin data type: ${coin.runtimeType}');
          }
        }).toList();
      }
      
      // If we can't determine the structure, throw an exception
      throw Exception('Unexpected response format: ${response.toString().substring(0, min(100, response.toString().length))}...');
    } catch (e, stackTrace) {
      dev.log('Error in getAllCoins: $e');
      dev.log(stackTrace.toString());
      rethrow;
    }
  }

  @override
  Future<CoinModel> getCoinDetails(String coinId) async {
    try {
      final response = await apiService.get('/$coinId/USD');
      dev.log('GetCoinDetails Response type: ${response.runtimeType}');
      
      if (response is Map<String, dynamic>) {
        return CoinModel.fromJson(response);
      } else {
        dev.log('Unexpected response type in getCoinDetails: ${response.runtimeType}');
        dev.log('Response: ${response.toString().substring(0, min(200, response.toString().length))}...');
        throw Exception('Invalid response format for coin details');
      }
    } catch (e, stackTrace) {
      dev.log('Error in getCoinDetails: $e');
      dev.log(stackTrace.toString());
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCoinHistoricalData(String coinId, String period) async {
    try {
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
      
      dev.log('HistoricalData Response type: ${response.runtimeType}');
      
      // First, create safe sample data in case of errors
      List<Map<String, dynamic>> sampleData = [];
      final now = DateTime.now();
      for (int i = 30; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        sampleData.add({
          'time_period_start': date.toIso8601String(),
          'time_period_end': date.add(const Duration(days: 1)).toIso8601String(),
          'time_open': date.toIso8601String(),
          'time_close': date.add(const Duration(hours: 23, minutes: 59)).toIso8601String(),
          'rate_open': 20000.0 + (i * 100),
          'rate_high': 21000.0 + (i * 100),
          'rate_low': 19500.0 + (i * 100),
          'rate_close': 20500.0 + (i * 100 * (i % 2 == 0 ? 1 : -1)),
        });
      }
      
      // Try to convert the actual response to the required format
      List<Map<String, dynamic>> result = [];
      
      if (response is List) {
        dev.log('HistoricalData is a List with ${response.length} items');
        
        // Handle each item in the list
        for (final item in response) {
          if (item is Map<String, dynamic>) {
            // Item is already a Map<String, dynamic>, add it directly
            result.add(item);
          } else if (item is Map) {
            // Item is some other kind of Map, convert to Map<String, dynamic>
            final Map<String, dynamic> convertedItem = {};
            (item as Map).forEach((key, value) {
              if (key is String) {
                convertedItem[key] = value;
              } else {
                convertedItem[key.toString()] = value;
              }
            });
            result.add(convertedItem);
          } else {
            // Item is not a Map at all, create a simple wrapper
            dev.log('Warning: Historical data item is not a Map: ${item.runtimeType}');
            result.add({'value': item});
          }
        }
      } else if (response is Map<String, dynamic>) {
        dev.log('HistoricalData is a Map<String, dynamic>');
        
        // Check if response has a data field that contains the historical data
        if (response.containsKey('data') && response['data'] is List) {
          final List dataList = response['data'] as List;
          
          for (final item in dataList) {
            if (item is Map<String, dynamic>) {
              result.add(item);
            } else if (item is Map) {
              // Convert other Map types to Map<String, dynamic>
              final Map<String, dynamic> convertedItem = {};
              (item as Map).forEach((key, value) {
                if (key is String) {
                  convertedItem[key] = value;
                } else {
                  convertedItem[key.toString()] = value;
                }
              });
              result.add(convertedItem);
            } else {
              result.add({'value': item});
            }
          }
        } else {
          // No data field, use the response map itself
          result.add(response);
        }
      } else {
        dev.log('Warning: Historical data has unexpected format: ${response.runtimeType}');
        // Fall back to sample data
        dev.log('Using sample historical data instead');
        return sampleData;
      }
      
      // Return sample data if no data was successfully parsed
      if (result.isEmpty) {
        dev.log('No historical data was parsed from response, using sample data');
        return sampleData;
      }
      
      return result;
    } catch (e, stackTrace) {
      dev.log('Error in getCoinHistoricalData: $e');
      dev.log(stackTrace.toString());
      
      // Generate sample data for fallback
      final List<Map<String, dynamic>> sampleData = [];
      final now = DateTime.now();
      for (int i = 30; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        sampleData.add({
          'time_period_start': date.toIso8601String(),
          'time_period_end': date.add(const Duration(days: 1)).toIso8601String(),
          'time_open': date.toIso8601String(),
          'time_close': date.add(const Duration(hours: 23, minutes: 59)).toIso8601String(),
          'rate_open': 20000.0 + (i * 100),
          'rate_high': 21000.0 + (i * 100),
          'rate_low': 19500.0 + (i * 100),
          'rate_close': 20500.0 + (i * 100 * (i % 2 == 0 ? 1 : -1)),
        });
      }
      
      dev.log('Returning sample historical data due to error');
      return sampleData;
    }
  }
  
  int min(int a, int b) => a < b ? a : b;
}
