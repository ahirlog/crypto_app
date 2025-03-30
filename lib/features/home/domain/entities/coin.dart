class Coin {
  final String id;
  final String name;
  final String symbol;
  final double price;
  final double changePercent24h;
  final double volume24h;
  final double marketCap;
  final String imageUrl;

  Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.changePercent24h,
    required this.volume24h,
    required this.marketCap,
    required this.imageUrl,
  });
}
