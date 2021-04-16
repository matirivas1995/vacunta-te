import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

import 'package:flutter/services.dart' show rootBundle;

part 'locations.g.dart';

@JsonSerializable()
class LatLng {
  LatLng({
    required this.lat,
    required this.lng,
  });

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
  Map<String, dynamic> toJson() => _$LatLngToJson(this);

  final double lat;
  final double lng;
}

@JsonSerializable()
class Region {
  Region({
    required this.coords,
    required this.id,
    required this.name,
    required this.zoom,
  });

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
  Map<String, dynamic> toJson() => _$RegionToJson(this);

  final LatLng coords;
  final String id;
  final String name;
  final double zoom;
}

@JsonSerializable()
class Office {
  Office({
    required this.address,
    required this.id,
    //required this.image,
    required this.lat,
    required this.lng,
    required this.name,
    required this.phone,
    required this.distance,
  });

  factory Office.fromJson(Map<String, dynamic> json) => _$OfficeFromJson(json);
  Map<String, dynamic> toJson() => _$OfficeToJson(this);

  final String address;
  final String id;
  // final String image;
  final double lat;
  final double lng;
  final String name;
  final String phone;
  final String distance;
}

@JsonSerializable()
class Locations {
  Locations({
    required this.centros,
    //required this.regions,
  });

  factory Locations.fromJson(Map<String, dynamic> json) =>
      _$LocationsFromJson(json);
  Map<String, dynamic> toJson() => _$LocationsToJson(this);

  final List<Office> centros;
  //final List<Region> regions;
}


/*Future<Locations> getCentrosVacunatorios() async {
  String data = await rootBundle.loadString("assets/data.json");
  return Locations.fromJson(json.decode(data));
}*/

Future<Locations> getCentrosVacunatorios() async {
  const googleLocationsURL = 'https://api.matirivas.me/hospitales';
  //const googleLocationsURL = 'http://localhost:3000/hospitales';
  //const googleLocationsURL = 'https://about.google/static/data/locations.json';

  // Retrieve the locations of Google offices
  final response = await http.get(Uri.parse(googleLocationsURL));
  if (response.statusCode == 200) {
    return Locations.fromJson(json.decode(response.body));
  } else {
    throw HttpException(
        'Unexpected status code ${response.statusCode}:'
        ' ${response.reasonPhrase}',
        uri: Uri.parse(googleLocationsURL));
  }
}

Future<Locations> getCentrosVacunatoriosByDistance(double lat, double lng) async {
  const googleLocationsURL = 'https://api.matirivas.me/hospitales';

  // Retrieve the locations of Google offices
  final response = await http.get(Uri.parse(googleLocationsURL));
  if (response.statusCode == 200) {
    return Locations.fromJson(json.decode(response.body));
  } else {
    throw HttpException(
        'Unexpected status code ${response.statusCode}:'
        ' ${response.reasonPhrase}',
        uri: Uri.parse(googleLocationsURL));
  }
}

/*
Future<Locations> getGoogleOffices() async {
  const googleLocationsURL = 'https://about.google/static/data/locations.json';

  // Retrieve the locations of Google offices
  final response = await http.get(Uri.parse(googleLocationsURL));
  if (response.statusCode == 200) {
    return Locations.fromJson(json.decode(response.body));
  } else {
    throw HttpException(
        'Unexpected status code ${response.statusCode}:'
        ' ${response.reasonPhrase}',
        uri: Uri.parse(googleLocationsURL));
  }
}
*/
