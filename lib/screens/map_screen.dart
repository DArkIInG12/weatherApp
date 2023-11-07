import 'dart:async';

import 'package:animated_floating_buttons/widgets/animated_floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather/database/weather_database.dart';
import 'package:weather/network/api_weather.dart';

// ignore: must_be_immutable
class MapScreen extends StatefulWidget {
  MapScreen(
      {super.key, this.lat, this.lon, this.locationTemp, this.locationIcon});
  String? lat;
  String? lon;
  String? locationTemp;
  String? locationIcon;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapType _currentMapType = MapType.hybrid;
  int markerKeys = 0;
  TextEditingController markerName = TextEditingController();
  Set<Marker> _markers = {};
  WeatherDataBase weatherdb = WeatherDataBase();

  Future<BitmapDescriptor> loadCustomMarker(String icon) async {
    var customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(60, 60)),
        'assets/images/$icon.png');
    return customIcon;
  }

  void _onMapTapped(LatLng location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nombre del marcador'),
          content: TextField(
            controller: markerName,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (markerName.text != "") {
                  weatherdb.INSERT({
                    'location_name': markerName.text,
                    'latitude': location.latitude,
                    'longitude': location.longitude
                  });
                  var apiWeather = ApiWeather(
                      lat: location.latitude.toString(),
                      lon: location.longitude.toString());
                  var res = await apiWeather.getCurrentWeather();
                  var temp = double.parse(res!["main"]["temp"].toString())
                      .toInt()
                      .toString();
                  _markers.add(
                    Marker(
                      markerId: MarkerId(markerKeys.toString()),
                      position: location,
                      icon: await loadCustomMarker(res["weather"][0]["icon"]),
                      infoWindow: InfoWindow(
                        title: markerName.text,
                        snippet: "$temp°C",
                      ),
                    ),
                  );
                  setState(() {
                    markerKeys++;
                    markerName.text = "";
                  });

                  Navigator.of(context).pop();
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Error"),
                          content: const Text(
                              "No puedes dejar el nombre del marcador en blanco"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cerrar"))
                          ],
                        );
                      });
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future getLocationsInMap() async {
    var res = await weatherdb.GETALLLOCATIONS();
    Set<Marker> aux = {};
    for (var location in res) {
      var apiWeather = ApiWeather(
          lat: location.latitude.toString(),
          lon: location.longitude.toString());
      var resApi = await apiWeather.getCurrentWeather();
      var temp =
          double.parse(resApi!["main"]["temp"].toString()).toInt().toString();
      aux.add(Marker(
        markerId: MarkerId(location.locationId.toString()),
        position: LatLng(location.latitude!, location.longitude!),
        icon: await loadCustomMarker(resApi["weather"][0]["icon"]),
        infoWindow: InfoWindow(
          title: location.locationName,
          snippet: "$temp°C",
        ),
      ));
    }
    setState(() {
      _markers = aux;
      markerKeys = res.length + 1;
    });
  }

  @override
  void initState() {
    super.initState();
    getLocationsInMap();
  }

  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> _controller =
        Completer<GoogleMapController>();

    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(double.parse(widget.lat!), double.parse(widget.lon!)),
      zoom: 14.4746,
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('Current Location'),
        position: LatLng(double.parse(widget.lat!), double.parse(widget.lon!)),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Ubicacion Actual',
          snippet: "${widget.locationTemp}°C",
        ),
      ),
    );
    return Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              zoomControlsEnabled: false,
              mapType: _currentMapType,
              initialCameraPosition: kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _markers,
              onTap: _onMapTapped,
            ),
          ],
        ),
        floatingActionButton: AnimatedFloatingActionButton(
            //Fab list
            fabButtons: [
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _currentMapType = MapType.normal;
                  });
                },
                tooltip: "Normal",
                child: Image.asset(
                  "assets/images/mapa.png",
                  width: 30,
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _currentMapType = MapType.satellite;
                  });
                },
                tooltip: "Satelital",
                child: Image.asset(
                  "assets/images/satelite.png",
                  width: 30,
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _currentMapType = MapType.terrain;
                  });
                },
                tooltip: "Terreno",
                child: Image.asset(
                  "assets/images/terreno.png",
                  width: 30,
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _currentMapType = MapType.hybrid;
                  });
                },
                tooltip: "Hibrido",
                child: Image.asset(
                  "assets/images/gps.png",
                  width: 30,
                ),
              )
            ],
            colorStartAnimation: Colors.blue,
            colorEndAnimation: Colors.red,
            animatedIconData: AnimatedIcons.menu_close));
  }
}
