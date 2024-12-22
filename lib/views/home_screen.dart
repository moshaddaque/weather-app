import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_update/controllers/weather_provider.dart';
import 'package:weather_update/helpers/extensions.dart';
import 'package:weather_update/theme/text_style.dart';
import 'package:weather_update/widgets/custom_shimmer.dart';

import '../widgets/weather_info_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    requestWeather();
    super.initState();
  }

  Future<void> requestWeather() async {
    await Provider.of<WeatherProvider>(context, listen: false)
        .getWeatherData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProv, child) {
          if (!weatherProv.isLoading && !weatherProv.isLocationServiceEnable) {
            return Center(child: Text("Location is not enable"));
          }
          if (!weatherProv.isLoading &&
              weatherProv.locationPermission != LocationPermission.always &&
              weatherProv.locationPermission != LocationPermission.whileInUse) {
            return Center(child: Text("Enable Location"));
          }
          if (weatherProv.isErrorRequest) return Center(child: Text("error"));
          if (weatherProv.isSearchError)
            return Center(child: Text("search error"));

          //=====================================

          return Stack(
            children: [
              ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(12).copyWith(
                    top: kToolbarHeight +
                        MediaQuery.viewPaddingOf(context).top +
                        24.0),
                children: const [
                  WeatherInfoHeader(),
                  SizedBox(
                    height: 16,
                  ),
                  MainWeatherInfo(),
                  SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class MainWeatherInfo extends StatelessWidget {
  const MainWeatherInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProv, child) {
        if (weatherProv.isLoading) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: CustomShimmer(
                  height: 148.0,
                  width: 148.0,
                  borderRadius: BorderRadius.circular(8.00),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              CustomShimmer(
                height: 148.0,
                width: 148.0,
                borderRadius: BorderRadius.circular(8.00),
              ),
            ],
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 100,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            child: Text(
                              weatherProv.isCelcius
                                  ? weatherProv.weather.temp.toStringAsFixed(1)
                                  : weatherProv.weather.temp
                                      .toFahrenheit()
                                      .toStringAsFixed(1),
                              style: boldText.copyWith(fontSize: 86),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
