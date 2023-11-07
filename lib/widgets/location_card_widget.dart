import 'package:flutter/material.dart';
import 'package:weather/database/weather_database.dart';
import 'package:weather/global_values.dart';
import 'package:weather/models/location_model.dart';
import 'package:weather/screens/weather_screen.dart';

Widget locationCardWidget(LocationModel location, BuildContext context) {
  WeatherDataBase weatherdb = WeatherDataBase();
  TextEditingController textInput = TextEditingController();
  return InkWell(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WeatherScreen(
                    lat: location.latitude.toString(),
                    lon: location.longitude.toString(),
                  )));
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.locationName!,
                maxLines: 2,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "${location.latitude!} ${location.longitude!}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
          Expanded(child: Container()),
          Row(
            children: [
              SizedBox(
                width: 40,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Escribe algo'),
                          content: TextField(
                            controller: textInput,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                if (textInput.text.isNotEmpty) {
                                  weatherdb.UPDATE({
                                    'location_id': location.locationId,
                                    'location_name': textInput.text
                                  });
                                  GlobalValues.flagDatabase.value =
                                      !GlobalValues.flagDatabase.value;
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Mensaje del Sistema'),
                                          content: const Text(
                                              'No puede actualizar el nombre del marcador si el texto esta vacio'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Aceptar'))
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
                  },
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      backgroundColor: MaterialStateProperty.all(Colors.green)),
                  child: const Icon(
                    Icons.edit,
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              SizedBox(
                width: 40,
                child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Mensaje del Sistema'),
                              content: const Text(
                                  '¿Esta seguro de eliminar esta ubicación?'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      weatherdb
                                          .DELETE(location.locationId!)
                                          .then((value) {
                                        Navigator.pop(context);
                                        GlobalValues.flagDatabase.value =
                                            !GlobalValues.flagDatabase.value;
                                      });
                                    },
                                    child: const Text('Si')),
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('No'))
                              ],
                            );
                          });
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        padding: MaterialStateProperty.all(EdgeInsets.zero)),
                    child: const Icon(
                      Icons.delete,
                      size: 14,
                    )),
              )
            ],
          )
        ],
      ),
    ),
  );
}
