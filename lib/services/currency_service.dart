import 'dart:convert';

import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _url = 'https://api.exchangerate-api.com/v4/latest/TRY';

  // Fetches exchange rates and converts them to "1 foreign currency = X TL".
  Future<Map<String, double>> getCurrencyRates() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode != 200) {
      throw Exception('Döviz verileri alınamadı.');
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic> || data['rates'] is! Map) {
      throw Exception('Beklenmeyen API yanıtı alındı.');
    }

    final rates = Map<String, dynamic>.from(data['rates'] as Map);

    final usdRate = _readRate(rates, 'USD');
    final eurRate = _readRate(rates, 'EUR');
    final gbpRate = _readRate(rates, 'GBP');

    return {
      'USD': 1 / usdRate,
      'EUR': 1 / eurRate,
      'GBP': 1 / gbpRate,
    };
  }

  // Reads one currency rate safely from the API response.
  double _readRate(Map<String, dynamic> rates, String code) {
    final value = rates[code];

    if (value is num && value > 0) {
      return value.toDouble();
    }

    throw Exception('$code kuru bulunamadı.');
  }
}
