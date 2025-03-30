class ApiConstants {
  static const String baseUrl = 'https://rest.coinapi.io/v1/exchangerate';
  static const String apiKey = 'E8C0EB42-1893-417F-A2F3-9F08E506566F';
  static const String assetsEndpoint = '/assets';
  static const Map<String, String> headers = {
    'X-CoinAPI-Key': apiKey,
    'Content-Type': 'application/json',
  };
}
