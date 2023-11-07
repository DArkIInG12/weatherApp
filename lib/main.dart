import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/routes.dart';
import 'package:weather/screens/weather_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: getRoutes(),
      home: FutureBuilder(
          future: _determinePosition(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final lat = snapshot.data?.latitude.toString() ?? '0';
              final lon = snapshot.data?.longitude.toString() ?? '0';
              return WeatherScreen(
                lat: lat,
                lon: lon,
              );
            } else {
              // Muestra un indicador de carga mientras se obtiene la ubicación
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
