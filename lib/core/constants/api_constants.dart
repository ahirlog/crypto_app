class ApiConstants {
  static const String baseUrl = 'https://rest.coinapi.io/v1/exchangerate';
  static const String apiKey = 'm';
  static const String assetsEndpoint = '/assets';
  static const Map<String, String> headers = {
    'X-CoinAPI-Key': apiKey,
    'Content-Type': 'application/json',
  };
}
