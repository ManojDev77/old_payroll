import 'dart:convert';

LocationModal loginProfileFromJson(String str) {
  final jsonData = json.decode(str);
  return LocationModal.fromMap(jsonData);
}

String loginProfileToJson(LocationModal data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class LocationModal {
  // int locid;
  String? lat;
  String? long;
  String? time;
  String? date;

  LocationModal(
      {
      // this.locid,
      this.lat,
      this.long,
      this.time,
      this.date});

  factory LocationModal.fromMap(Map<String, dynamic> json) => LocationModal(
        // locid: json["locid"],
        lat: json["lat"],
        long: json["long"],
        time: json["time"],
        date: json["date"],
      );

  Map<String, dynamic> toMap() => {
        // "locid": locid,
        "lat": lat,
        "long": long,
        "time": time,
        "date": date,
      };
}
