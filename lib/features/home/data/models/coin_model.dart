import 'package:hive/hive.dart';
import '../../domain/entities/coin.dart';

part 'coin_model.g.dart';

@HiveType(typeId: 0)
class CoinModel extends Coin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String symbol;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final double changePercent24h;

  @HiveField(5)
  final double volume24h;

  @HiveField(6)
  final double marketCap;

  @HiveField(7)
  final String imageUrl;

  @HiveField(8)
  final DateTime lastUpdated;

  CoinModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.changePercent24h,
    required this.volume24h,
    required this.marketCap,
    required this.imageUrl,
    required this.lastUpdated,
  }) : super(
    id: id,
    name: name,
    symbol: symbol,
    price: price,
    changePercent24h: changePercent24h,
    volume24h: volume24h,
    marketCap: marketCap,
    imageUrl: imageUrl,
  );

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      id: json['asset_id_base'] ?? '',
      name: json['asset_id_base'] ?? '',
      symbol: json['asset_id_base'] ?? '',
      price: json['rate']?.toDouble() ?? 0.0,
      changePercent24h: json['rate_change_percent_24h']?.toDouble() ?? 0.0,
      volume24h: json['volume_24h']?.toDouble() ?? 0.0,
      marketCap: json['market_cap']?.toDouble() ?? 0.0,
      imageUrl: json['icon_url'] ?? '',
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_id_base': id,
      'name': name,
      'symbol': symbol,
      'rate': price,
      'rate_change_percent_24h': changePercent24h,
      'volume_24h': volume24h,
      'market_cap': marketCap,
      'icon_url': imageUrl,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
