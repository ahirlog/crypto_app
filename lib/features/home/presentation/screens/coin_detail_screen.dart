import 'package:crypto_app/features/home/presentation/providers/coin_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/price_chart.dart';

class CoinDetailScreen extends ConsumerStatefulWidget {
  final String coinId;

  const CoinDetailScreen({super.key, required this.coinId});

  @override
  ConsumerState<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

// lib/features/home/presentation/screens/coin_detail_screen.dart (continued)
class _CoinDetailScreenState extends ConsumerState<CoinDetailScreen> {
  String selectedPeriod = '1W';
  List<String> periods = ['1D', '1W', '1M', '3M', '1Y'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(coinDetailsProvider.notifier).getCoinDetails(widget.coinId);
      ref.read(historicalDataProvider.notifier).getHistoricalData(widget.coinId, selectedPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    final coinDetailsState = ref.watch(coinDetailsProvider);
    final historicalDataState = ref.watch(historicalDataProvider);
    final isFavorite = ref.watch(favoritesProvider).contains(widget.coinId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coinId),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.amber : Colors.grey,
            ),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(widget.coinId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(coinDetailsProvider.notifier).getCoinDetails(widget.coinId);
              ref.read(historicalDataProvider.notifier).getHistoricalData(widget.coinId, selectedPeriod);
            },
          ),
        ],
      ),
      body: coinDetailsState.when(
        data: (coin) {
          if (coin == null) {
            return const Center(child: Text('Coin not found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(coinDetailsProvider.notifier).getCoinDetails(widget.coinId);
              await ref.read(historicalDataProvider.notifier).getHistoricalData(widget.coinId, selectedPeriod);
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Header with Price and Change
                _buildPriceHeader(coin),

                const SizedBox(height: 24),

                // Period Selection
                _buildPeriodSelector(),

                const SizedBox(height: 16),

                // Price Chart
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: historicalDataState.when(
                    data: (data) => PriceChart(
                      data: data,
                      period: selectedPeriod,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(
                      child: Text('Error loading chart data'),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Stats Cards
                _buildStatsCards(coin),

                const SizedBox(height: 16),

                // About
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About ${coin.name}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This is a placeholder description for ${coin.name}. Normally this would contain information about the cryptocurrency, its technology, use cases, and history.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(coinDetailsProvider.notifier).getCoinDetails(widget.coinId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceHeader(coin) {
    final priceChangeColor = coin.changePercent24h >= 0 ? Colors.green : Colors.red;

    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              coin.symbol.substring(0, 1),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coin.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                coin.symbol,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${coin.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(
                  coin.changePercent24h >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: priceChangeColor,
                  size: 16,
                ),
                Text(
                  '${coin.changePercent24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: priceChangeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((period) {
          final isSelected = period == selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              selectedColor: Colors.amber,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedPeriod = period;
                  });
                  ref.read(historicalDataProvider.notifier).getHistoricalData(widget.coinId, period);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsCards(coin) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildStatCard(
          'Market Cap',
          '\$${(coin.marketCap / 1000000).toStringAsFixed(2)}M',
          Icons.pie_chart,
        ),
        _buildStatCard(
          '24h Volume',
          '\$${(coin.volume24h / 1000000).toStringAsFixed(2)}M',
          Icons.show_chart,
        ),
        _buildStatCard(
          'Rank',
          '#${(coin.id.hashCode % 100).toString()}',
          Icons.format_list_numbered,
        ),
        _buildStatCard(
          'All-time High',
          '\$${(coin.price * 1.5).toStringAsFixed(2)}',
          Icons.arrow_upward,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
