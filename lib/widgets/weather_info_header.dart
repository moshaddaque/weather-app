import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/weather_provider.dart';
import '../theme/colors.dart';
import '../theme/text_style.dart';
import 'custom_shimmer.dart';

class WeatherInfoHeader extends StatelessWidget {
  const WeatherInfoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(builder: (context, weatherProv, child) {
      return SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            weatherProv.isLoading
                ? Expanded(
                    child: CustomShimmer(
                      height: 48,
                      borderRadius: BorderRadius.circular(8.00),
                    ),
                  )
                : Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: '${weatherProv.weather.city}, ',
                              style: semiboldText,
                              children: [
                                TextSpan(
                                  text: Country.tryParse(
                                          weatherProv.weather.countryCode)
                                      ?.name,
                                  style: regularText.copyWith(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 4.00,
                        ),
                        FittedBox(
                          child: Text(
                            DateFormat('EEEE MMM dd, y hh:mm a').format(
                              DateTime.now(),
                            ),
                            style: regularText.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(
              height: 8,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                padding: const EdgeInsets.all(4.0),
                color: Colors.grey.shade200,
                child: Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder: (child, animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: weatherProv.isCelcius
                                ? Offset(1.0, 0.0)
                                : Offset(-1.0, 0.0),
                            end: Offset(0.0, 0.0),
                          ).animate(animation),
                          child: child,
                        );
                      },
                      child: weatherProv.isCelcius
                          ? GestureDetector(
                              key: ValueKey<int>(0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 52,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: weatherProv.isLoading
                                          ? Colors.grey
                                          : primaryBlue,
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    width: 52,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => weatherProv.isLoading
                                  ? null
                                  : weatherProv.switchTempUnit(),
                            )
                          : GestureDetector(
                              key: ValueKey<int>(1),
                              child: Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 52,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    width: 52,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: weatherProv.isLoading
                                          ? Colors.grey
                                          : primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => weatherProv.switchTempUnit(),
                            ),
                    ),
                    IgnorePointer(
                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 52,
                            alignment: Alignment.center,
                            child: Text(
                              '°C',
                              style: semiboldText.copyWith(
                                fontSize: 16,
                                color: weatherProv.isCelcius
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 52,
                            alignment: Alignment.center,
                            child: Text(
                              '°F',
                              style: semiboldText.copyWith(
                                fontSize: 16,
                                color: weatherProv.isCelcius
                                    ? Colors.grey.shade600
                                    : Colors.white,
                              ),
                            ),
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
    });
  }
}
