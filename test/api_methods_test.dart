import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:weather_m/model/WeatherModel.dart';

import 'package:weather_m/services/api_methods.dart';

//  a mock class for the http.Client
class MockHTTPClient extends Mock implements http.Client {}

void main() {
  late ApiMethods apiMethods;
  late MockHTTPClient mockHTTPClient;

  setUp(() {
    mockHTTPClient = MockHTTPClient();
    apiMethods = ApiMethods(mockHTTPClient);
  });

  group('ApiMethods - ', () {
    group('getWeather function', () {
      test(
        'given ApiMethods class when getWeather function is called and status code is 200 then a WeatherModel should be returned',
        () async {
          // Arrange
          when(
            () => mockHTTPClient.get(
              Uri.parse(
                  'https://api.weatherapi.com/v1/current.json?key=fa2f46d3b54840a195e80818241609&q=London'),
            ),
          ).thenAnswer((invocation) async {
            return http.Response('''
            {
              "location": {
                "name": "London",
                "region": "City of London, Greater London",
                "country": "United Kingdom",
                "lat": 51.52,
                "lon": -0.13,
                "tz_id": "Europe/London",
                "localtime": "2024-09-17 09:00"
              },
              "current": {
                "temp_c": 14.0,
                "condition": {
                  "text": "Partly cloudy",
                  "icon": "//cdn.weatherapi.com/weather/64x64/day/116.png"
                }
              }
            }
            ''', 200);
          });

          // Act
          final weather = await apiMethods.getWeather('London');

          // Assert
          expect(weather, isA<WeatherModel>());
          expect(weather?.location?.name, 'London');
          expect(weather?.current?.tempC, 14.0);
        },
      );

      test(
        'given ApiMethods class when getWeather function is called and status code is not 200 then an exception should be thrown',
        () async {
          // Arrange
          when(
            () => mockHTTPClient.get(
              Uri.parse(
                  'https://api.weatherapi.com/v1/current.json?key=fa2f46d3b54840a195e80818241609&q=London'),
            ),
          ).thenAnswer((invocation) async => http.Response('{}', 500));

          // Act & Assert
          expect(
            () async => await apiMethods.getWeather('London'),
            throwsA(isA<Exception>()),
          );
        },
      );

      test(
        'given ApiMethods class when getWeather function is called and an exception is thrown then an exception should be thrown',
        () async {
          // Arrange
          when(
            () => mockHTTPClient.get(
              Uri.parse(
                  'https://api.weatherapi.com/v1/current.json?key=fa2f46d3b54840a195e80818241609&q=London'),
            ),
          ).thenThrow(Exception('Failed to connect'));

          // Act & Assert
          expect(
            () async => await apiMethods.getWeather('London'),
            throwsA(isA<Exception>()),
          );
        },
      );
    });
  });
}
