import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiWeather {
  String? lat;
  String? lon;
  Uri? zelda;
  Uri? link;
  ApiWeather({this.lat, this.lon}) {
    zelda = Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&lang=es&appid=");
    link = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&lang=es&units=metric&appid=");
  }
  Future<Map?> getWeather() async {
    var response = await http.get(zelda!);
    if (response.statusCode == 200) {
      var jsonRes = jsonDecode(response.body);
      return jsonRes;
    } else {
      return null;
    }
  }

  Future<Map?> getCurrentWeather() async {
    var response = await http.get(link!);
    if (response.statusCode == 200) {
      var jsonRes = jsonDecode(response.body);
      return jsonRes;
    } else {
      return null;
    }
  }
}
