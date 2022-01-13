// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

const List<String> currenciesList = [
  'EUR',
  'GBP',
  'INR',
  'JPY',
  'NZD',
  'RUB',
  'SGD',
  'USD',
];

const List<String> cryptoList = [
  'BTC',
  'ETH',
  'ADA',
  'XRP',
  'DOGE',
  'LTC',
  'MATIC',
  'THETA',
  'SHIB',
  'XMR',
  'NEO'
];

const coinAPIURL = 'https://rest.coinapi.io/v1/exchangerate';
const apiKey = 'Your_API_Key';

class CoinData {
  Future getCoinData(String selectedCurrency) async {
    Map<String, String> cryptoPrices = {};
    for (String crypto in cryptoList) {
      String requestURL =
          '$coinAPIURL/$crypto/$selectedCurrency?apikey=$apiKey';
      http.Response response = await http.get(Uri.parse(requestURL));
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        double price = decodedData['rate'];
        cryptoPrices[crypto] = price.toStringAsFixed(0);
      } else {
        print(response.statusCode);
        throw 'Problem with the get request';
      }
    }
    return cryptoPrices;
  }
}
