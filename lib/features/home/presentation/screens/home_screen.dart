import 'dart:developer';

import 'package:crypto_app/features/home/presentation/providers/coin_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/coin_list_item.dart';
import 'coin_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Add a test function to debug API responses
  void _testApiResponses() async {
    log('DEBUG: Testing API responses');
    try {
      // Test the getAllCoins method
      log('DEBUG: Testing getAllCoins');
      await ref.read(coinRemoteDataSourceProvider).getAllCoins();
      
      // Test the getCoinDetails method if we have a sample coin ID (using BTC as an example)
      log('DEBUG: Testing getCoinDetails');
      await ref.read(coinRemoteDataSourceProvider).getCoinDetails('BTC');
      
      // Test the getCoinHistoricalData method
      log('DEBUG: Testing getCoinHistoricalData');
      final histData = await ref.read(coinRemoteDataSourceProvider).getCoinHistoricalData('BTC', '1D');
      log('DEBUG: Historical data type: ${histData.runtimeType}');
      
      // If we got here, all methods ran without crashing
      log('DEBUG: All API methods completed successfully');
    } catch (e, stackTrace) {
      log('DEBUG ERROR: $e');
      log(stackTrace.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final coinsState = ref.watch(coinListProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Tracker'),
        actions: [
          // Add a debug button
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _testApiResponses,
            tooltip: 'Debug API',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(coinListProvider.notifier).getAllCoins();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search coins...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          DefaultTabController(
            length: 2,
            child: Expanded(
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'All Coins'),
                      Tab(text: 'Favorites'),
                    ],
                    indicatorColor: Colors.amber,
                    labelColor: Colors.amber,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // All Coins Tab
                        coinsState.when(
                          data: (coins) {
                            final filteredCoins = coins.where((coin) {
                              return coin.name.toLowerCase().contains(searchQuery) ||
                                  coin.symbol.toLowerCase().contains(searchQuery);
                            }).toList();

                            if (filteredCoins.isEmpty) {
                              return const Center(
                                child: Text('No coins found'),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                await ref.read(coinListProvider.notifier).getAllCoins();
                              },
                              child: ListView.builder(
                                itemCount: filteredCoins.length,
                                itemBuilder: (context, index) {
                                  final coin = filteredCoins[index];
                                  return CoinListItem(
                                    coin: coin,
                                    isFavorite: favorites.contains(coin.id),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CoinDetailScreen(coinId: coin.id),
                                        ),
                                      );
                                    },
                                    onFavoriteToggle: () {
                                      ref.read(favoritesProvider.notifier).toggleFavorite(coin.id);
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error, color: Colors.red, size: 48),
                                const SizedBox(height: 16),
                                Text('Error: ${error.toString()}'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    log('error::: ${error.toString()}');
                                    ref.read(coinListProvider.notifier).getAllCoins();
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Favorites Tab
                        coinsState.when(
                          data: (coins) {
                            final favoriteCoins = coins.where((coin) =>
                            favorites.contains(coin.id) &&
                                (coin.name.toLowerCase().contains(searchQuery) ||
                                    coin.symbol.toLowerCase().contains(searchQuery))
                            ).toList();

                            if (favoriteCoins.isEmpty) {
                              return const Center(
                                child: Text('No favorite coins yet'),
                              );
                            }

                            return ListView.builder(
                              itemCount: favoriteCoins.length,
                              itemBuilder: (context, index) {
                                final coin = favoriteCoins[index];
                                return CoinListItem(
                                  coin: coin,
                                  isFavorite: true,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CoinDetailScreen(coinId: coin.id),
                                      ),
                                    );
                                  },
                                  onFavoriteToggle: () {
                                    ref.read(favoritesProvider.notifier).toggleFavorite(coin.id);
                                  },
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const Center(child: Text('Error loading favorites')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
