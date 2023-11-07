class LocationModel {
  int? locationId;
  String? locationName;
  double? latitude;
  double? longitude;

  LocationModel(
      {this.locationId, this.locationName, this.latitude, this.longitude});

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
        locationId: map["location_id"],
        locationName: map["location_name"],
        latitude: map["latitude"],
        longitude: map["longitude"]);
  }
}
