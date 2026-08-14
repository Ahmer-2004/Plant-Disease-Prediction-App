import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// ─── Data Models ───

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int humidity;
  final double apparentTemperature;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.humidity,
    required this.apparentTemperature,
  });

  IconData getIcon() => _iconFromCode(weatherCode);
  String get condition => _conditionFromCode(weatherCode);
}

class DailyWeather {
  final DateTime date;
  final double temperatureMax;
  final double temperatureMin;
  final int weatherCode;
  final String sunrise;
  final String sunset;
  final double uvIndexMax;
  final int precipitationProbabilityMax;

  DailyWeather({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.weatherCode,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
    required this.precipitationProbabilityMax,
  });

  IconData getIcon() => _iconFromCode(weatherCode);
  String get condition => _conditionFromCode(weatherCode);

  String get dayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String get formattedDate => '${date.month}/${date.day}';
}

class WeatherData {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final String condition;
  final String cityName;
  // Extended current data (from hourly[0])
  final int humidity;
  final double feelsLike;
  // Forecast data
  final List<HourlyWeather> hourlyForecast;
  final List<DailyWeather> dailyForecast;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.condition,
    required this.cityName,
    required this.humidity,
    required this.feelsLike,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, {String cityName = 'Current Location'}) {
    final current = json['current_weather'];
    final code = current['weathercode'] as int;

    // Parse hourly
    final hourlyData = json['hourly'] as Map<String, dynamic>;
    final hourlyTimes = (hourlyData['time'] as List).cast<String>();
    final hourlyTemps = (hourlyData['temperature_2m'] as List);
    final hourlyCodes = (hourlyData['weathercode'] as List);
    final hourlyHumidity = (hourlyData['relative_humidity_2m'] as List);
    final hourlyApparent = (hourlyData['apparent_temperature'] as List);

    List<HourlyWeather> hourlyList = [];
    for (int i = 0; i < hourlyTimes.length; i++) {
      hourlyList.add(HourlyWeather(
        time: DateTime.parse(hourlyTimes[i]),
        temperature: (hourlyTemps[i] as num).toDouble(),
        weatherCode: (hourlyCodes[i] as num).toInt(),
        humidity: (hourlyHumidity[i] as num).toInt(),
        apparentTemperature: (hourlyApparent[i] as num).toDouble(),
      ));
    }

    // Parse daily
    final dailyData = json['daily'] as Map<String, dynamic>;
    final dailyTimes = (dailyData['time'] as List).cast<String>();
    final dailyMaxTemps = (dailyData['temperature_2m_max'] as List);
    final dailyMinTemps = (dailyData['temperature_2m_min'] as List);
    final dailyCodes = (dailyData['weathercode'] as List);
    final dailySunrise = (dailyData['sunrise'] as List).cast<String>();
    final dailySunset = (dailyData['sunset'] as List).cast<String>();
    final dailyUV = (dailyData['uv_index_max'] as List);
    final dailyPrecip = (dailyData['precipitation_probability_max'] as List);

    List<DailyWeather> dailyList = [];
    for (int i = 0; i < dailyTimes.length; i++) {
      dailyList.add(DailyWeather(
        date: DateTime.parse(dailyTimes[i]),
        temperatureMax: (dailyMaxTemps[i] as num).toDouble(),
        temperatureMin: (dailyMinTemps[i] as num).toDouble(),
        weatherCode: (dailyCodes[i] as num).toInt(),
        sunrise: dailySunrise[i],
        sunset: dailySunset[i],
        uvIndexMax: (dailyUV[i] as num).toDouble(),
        precipitationProbabilityMax: (dailyPrecip[i] as num).toInt(),
      ));
    }

    // Current humidity & feels like from first matching hourly entry
    int currentHumidity = hourlyList.isNotEmpty ? hourlyList[0].humidity : 0;
    double currentFeelsLike =
        hourlyList.isNotEmpty ? hourlyList[0].apparentTemperature : 0;

    // Find the hourly entry closest to now
    final now = DateTime.now();
    for (final h in hourlyList) {
      if (h.time.isAfter(now)) break;
      currentHumidity = h.humidity;
      currentFeelsLike = h.apparentTemperature;
    }

    return WeatherData(
      temperature: (current['temperature'] as num).toDouble(),
      windSpeed: (current['windspeed'] as num).toDouble(),
      weatherCode: code,
      condition: _conditionFromCode(code),
      cityName: cityName,
      humidity: currentHumidity,
      feelsLike: currentFeelsLike,
      hourlyForecast: hourlyList,
      dailyForecast: dailyList,
    );
  }

  IconData getIcon() => _iconFromCode(weatherCode);
}

// ─── Shared helpers ───

String _conditionFromCode(int code) {
  if (code == 0) return 'Clear sky';
  if (code == 1 || code == 2 || code == 3) return 'Partly cloudy';
  if (code == 45 || code == 48) return 'Fog';
  if (code >= 51 && code <= 57) return 'Drizzle';
  if (code >= 61 && code <= 67) return 'Rain';
  if (code >= 71 && code <= 77) return 'Snow';
  if (code >= 80 && code <= 82) return 'Rain showers';
  if (code >= 95 && code <= 99) return 'Thunderstorm';
  return 'Unknown';
}

IconData _iconFromCode(int code) {
  if (code == 0) return Icons.wb_sunny_rounded;
  if (code == 1 || code == 2 || code == 3) return Icons.cloud_queue_rounded;
  if (code == 45 || code == 48) return Icons.foggy;
  if (code >= 51 && code <= 67) return Icons.water_drop_rounded;
  if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
  if (code >= 80 && code <= 82) return Icons.water_drop_rounded;
  if (code >= 95 && code <= 99) return Icons.flash_on_rounded;
  return Icons.cloud_rounded;
}

// ─── Provider ───

class WeatherProvider with ChangeNotifier {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather() async {
    if (_weatherData != null && _error == null) return; // Already fetched successfully

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Get location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // 2. Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // 3. Fetch from Open-Meteo with full hourly + 16-day daily forecast
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast'
          '?latitude=${position.latitude}'
          '&longitude=${position.longitude}'
          '&current_weather=true'
          '&hourly=temperature_2m,relative_humidity_2m,weathercode,apparent_temperature'
          '&daily=temperature_2m_max,temperature_2m_min,weathercode,sunrise,sunset,uv_index_max,precipitation_probability_max'
          '&forecast_days=16'
          '&timezone=auto');

      final response = await http.get(url);

      // 4. Reverse-geocode to get city name
      String cityName = 'Current Location';
      try {
        final geoUrl = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?lat=${position.latitude}'
          '&lon=${position.longitude}'
          '&format=json'
          '&zoom=10');
        final geoResponse = await http.get(geoUrl, headers: {
          'User-Agent': 'PlantDiseaseDetector/1.0',
        });
        if (geoResponse.statusCode == 200) {
          final geoData = json.decode(geoResponse.body);
          final address = geoData['address'] as Map<String, dynamic>?;
          if (address != null) {
            cityName = address['city'] ??
                address['town'] ??
                address['village'] ??
                address['county'] ??
                'Current Location';
          }
        }
      } catch (_) {
        // Silently fail — use default 'Current Location'
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _weatherData = WeatherData.fromJson(data, cityName: cityName);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
