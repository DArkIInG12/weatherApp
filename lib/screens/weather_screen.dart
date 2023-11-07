import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/screens/map_screen.dart';
import 'package:weather/network/api_weather.dart';

// ignore: must_be_immutable
class WeatherScreen extends StatefulWidget {
  WeatherScreen({super.key, this.lat, this.lon});
  String? lat;
  String? lon;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  ApiWeather? weather;
  String temp = "";
  String weatherState = "";
  String minTemp = "";
  String maxTemp = "";
  String city = "Loading";
  String feels = "";
  String pressure = "";
  String humidity = "";
  String icon = "";
  String country = "";
  List todayTemps = [];
  List nextDays = [];
  bool isLoading = true;
  Map days = {
    "Monday": "Lunes",
    "Tuesday": "Martes",
    "Wednesday": "Miercoles",
    "Thursday": "Jueves",
    "Friday": "Viernes",
    "Saturday": "Sabado",
    "Sunday": "Domingo"
  };
  List nextTemps = [];
  @override
  void initState() {
    super.initState();
    weather = ApiWeather(lat: widget.lat, lon: widget.lon);
    getTemp();
  }

  Future<void> getTemp() async {
    var res = await weather!.getWeather();
    var resC = await weather!.getCurrentWeather();
    setState(() {
      temp = double.parse(resC!["main"]["temp"].toString()).toInt().toString();
      country = resC["sys"]["country"];
      minTemp =
          double.parse(resC["main"]["temp_min"].toString()).toInt().toString();
      maxTemp =
          double.parse(resC["main"]["temp_max"].toString()).toInt().toString();
      weatherState = resC["weather"][0]["description"].toString();
      feels = double.parse(resC["main"]["feels_like"].toString())
          .toInt()
          .toString();
      pressure = resC["main"]["pressure"].toString();
      humidity = resC["main"]["humidity"].toString();
      icon = resC["weather"][0]["icon"];
      city = resC["name"];
      var today = DateTime.now().toString().split(" ")[0];
      var list = res!["list"] as List;
      for (var element in list) {
        var date = element["dt_txt"].toString().split(" ")[0];
        if (today == date) {
          todayTemps.add([
            element["dt_txt"].toString().split(" ")[1].substring(0, 5),
            double.parse(element["main"]["temp"].toString()).toInt().toString()
          ]);
        }
        if (today != date) {
          var day = DateTime.parse(element["dt_txt"].toString().split(" ")[0]);
          var dayOfWeek = DateFormat('EEEE').format(day);
          if (!nextDays.contains(dayOfWeek)) {
            nextTemps.add([
              double.parse(element["main"]["temp_min"].toString())
                  .toInt()
                  .toString(),
              double.parse(element["main"]["temp_max"].toString())
                  .toInt()
                  .toString(),
              element["weather"][0]["description"].toString(),
              element["weather"][0]["icon"].toString(),
            ]);
            nextDays.add(dayOfWeek);
          }
        }
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ));
        }),
        centerTitle: true,
        //elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "$city - $country",
          style: const TextStyle(color: Colors.black),
        ),
      ),
      drawer: createDrawer(context, widget.lat!, widget.lon!, temp, icon),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        temp,
                        style: const TextStyle(fontSize: 90),
                      ),
                      const Text(
                        "°C",
                        style: TextStyle(fontSize: 26),
                      )
                    ],
                  ),
                  Text(
                    weatherState,
                    style: const TextStyle(fontSize: 28),
                  ),
                  Image.asset(
                    "assets/images/$icon.png",
                    width: 130,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Máx $maxTemp°C",
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(
                        width: 20,
                      ),
                      Text("Min $minTemp°C",
                          style: const TextStyle(fontSize: 18))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: const BoxDecoration(boxShadow: [
                      BoxShadow(color: Colors.grey, blurRadius: 2)
                    ], color: Colors.white),
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: SizedBox(
                          height: 80,
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/camiseta.png",
                                width: 40,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Sensación",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text("$feels°"),
                                ],
                              )
                            ],
                          ),
                        )),
                        Expanded(
                            child: SizedBox(
                          height: 80,
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/calibre.png",
                                width: 40,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Presión",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text("$pressure mm"),
                                ],
                              )
                            ],
                          ),
                        )),
                        Expanded(
                            child: SizedBox(
                          height: 80,
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/gota-de-agua.png",
                                width: 40,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Humedad",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text("$humidity%"),
                                ],
                              )
                            ],
                          ),
                        ))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Hoy",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Flexible(
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        children: todayTemps.map((temp) {
                          return Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(temp[0]),
                                    Text(
                                      "${temp[1]}°",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Próximos 5 dias",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 400,
                    height: 210,
                    child: ListView.builder(
                        itemCount: nextDays.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/images/${nextTemps[index][3]}.png",
                                      width: 60,
                                    ),
                                    index == 0
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Mañana",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(nextTemps[index][2])
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                days[nextDays[index]],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(nextTemps[index][2])
                                            ],
                                          ),
                                    Expanded(child: Container()),
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.arrow_downward),
                                          Text(
                                            "${nextTemps[index][0]}°",
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const Icon(Icons.arrow_upward),
                                          Text(
                                            "${nextTemps[index][1]}°",
                                            style:
                                                const TextStyle(fontSize: 16),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
    );
  }
}

Widget createDrawer(
    BuildContext context, String lat, String lon, String temp, String icon) {
  return Drawer(
    child: ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.map_outlined),
          title: const Text("Mapa"),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MapScreen(
                        lat: lat,
                        lon: lon,
                        locationTemp: temp,
                        locationIcon: icon,
                      ))),
        ),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text("Mis Lugares"),
          onTap: () => Navigator.pushNamed(context, '/locations'),
        )
      ],
    ),
  );
}
