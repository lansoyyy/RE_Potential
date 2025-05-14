import 'package:latlong2/latlong.dart';

class NewSolarModel {
  final String municipality;
  final String location;
  final LatLng area1;
  final LatLng area2;

  NewSolarModel(
      {required this.municipality,
      required this.location,
      required this.area1,
      required this.area2});
}
