import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:weather_update/models/additional_weather_data.dart';
import 'package:weather_update/models/daily_weather.dart';
import 'package:weather_update/models/geocode.dart';
import 'package:weather_update/models/hourly_weather.dart';
import 'package:weather_update/models/weather.dart';

class WeatherProvider with ChangeNotifier {
  String apiKey = '78709be7f6b84b38e8509cc10e98d55e';
  late Weather weather;
  late AdditionalWeatherData additionalWeatherData;
  LatLng? currentLocation;
  List<HourlyWeather> hourlyWeather = [];
  List<DailyWeather> dailyWeather = [];
  bool isLoading = false;
  bool isErrorRequest = false;
  bool isSearchError = false;
  bool isLocationServiceEnable = false;
  bool isCelcius = true;
  LocationPermission? locationPermission;

  String get measurementUnit => isCelcius ? '°C' : '°F';

  // get the location
  Future<Position?> requestLocation(BuildContext context) async {
    isLocationServiceEnable = await Geolocator.isLocationServiceEnabled();
    notifyListeners();

    if (!isLocationServiceEnable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location service disabled"),
        ),
      );
      return Future.error('Location services are disabled.');
    }

    locationPermission = await Geolocator.checkPermission();

    if (locationPermission == LocationPermission.denied) {
      isLoading = false;
      notifyListeners();
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Permission denied"),
          ),
        );
        return Future.error('Location permissions are denied');
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, Please enable manually from app settings',
          ),
        ),
      );
      return Future.error('Location permissions are permanently denied');
    }
    return await Geolocator.getCurrentPosition();
  }

  // get weaather data
  Future<void> getWeatherData(BuildContext context,
      {bool notify = false}) async {
    isLoading = true;
    isErrorRequest = false;
    isSearchError = false;
    if (notify) notifyListeners();

    Position? locData = await requestLocation(context);

    if (locData == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      currentLocation = LatLng(locData.latitude, locData.longitude);
      await getCurrentWeather(currentLocation!);
      // await getDailyWeather(currentLocation!);
      notifyListeners();
    } catch (e) {
      print(e);
      isErrorRequest = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // get current weather
  Future<void> getCurrentWeather(LatLng currentLocation) async {
    Uri url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${currentLocation.latitude}&lon=${currentLocation.longitude}&units=metric&appid=$apiKey',
      // 'https://api.openweathermap.org/data/2.5/weather?lat=23.7104&lon=90.40744&appid=78709be7f6b84b38e8509cc10e98d55e',
    );

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      weather = Weather.fromJson(extractedData);
      print('Fetched Weather for: ${weather.city}/${weather.countryCode}');
    } catch (e) {
      print(e);
      isLoading = false;
      isErrorRequest = true;
    }
  }

  // get daily weather
  Future<void> getDailyWeather(LatLng currentLocation) async {
    isLoading = true;
    notifyListeners();

    Uri dailyUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/onecall?lat=${currentLocation.latitude}&lon=${currentLocation.longitude}&units=metric&exclude=minutely,current&appid=$apiKey',
    );

    try {
      final response = await http.get(dailyUrl);
      final dailyData = json.decode(response.body) as Map<String, dynamic>;
      additionalWeatherData = AdditionalWeatherData.fromJson(dailyData);
      List dailyList = dailyData['daily'];
      List hourlyList = dailyData['hourly'];

      hourlyWeather = hourlyList
          .map(
            (e) => HourlyWeather.fromJson(e),
          )
          .toList()
          .take(24)
          .toList();
      dailyWeather = dailyList
          .map(
            (e) => DailyWeather.fromDailyJson(e),
          )
          .toList();
    } catch (e) {
      print(e);
      isLoading = false;
      isErrorRequest = true;
    }
  }

  // Location to latLng
  Future<GeocodeData?> locationToLatLng(String location) async {
    try {
      Uri url = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$location&limit=5&appid=$apiKey',
      );
      final http.Response response = await http.get(url);
      if (response.statusCode != 200) return null;
      return GeocodeData.fromJson(
          json.decode(response.body)[0] as Map<String, dynamic>);
    } catch (e) {
      print(e);
      return null;
    }
  }

  // search weather
  Future<void> searchWeather(String location) async {
    isLoading = true;
    notifyListeners();
    isErrorRequest = false;
    print('search');

    try {
      GeocodeData? geoCodeData;
      geoCodeData = await locationToLatLng(location);
      if (geoCodeData == null) throw Exception('Unable to Find Location');
      await getCurrentWeather(geoCodeData.latLng);
      await getDailyWeather(geoCodeData.latLng);

      weather.city = geoCodeData.name;
    } catch (e) {
      print(e);
      isSearchError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void switchTempUnit() {
    isCelcius = !isCelcius;
    notifyListeners();
  }
}
