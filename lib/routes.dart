import 'package:flutter/widgets.dart';
import 'package:weather/screens/locations_screen.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    '/locations': (BuildContext context) => const LocationsScreen(),
  };
}
