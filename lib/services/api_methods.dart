import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_m/model/WeatherModel.dart';

class ApiMethods {
  String apiKey = "fa2f46d3b54840a195e80818241609";
  final http.Client client;
  ApiMethods(this.client);

  //method to fetch weather data

  Future<WeatherModel?> getWeather(String location) async {
    String url =
        "https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$location";

    try {
      final response = await client.get(Uri.parse(url));
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(body);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Failed to load weather data: $e');
    }
  }
}
