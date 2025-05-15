import 'dart:typed_data';

import 'package:excel/excel.dart' as ex;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:re_potential/utils/data.dart';
import 'package:re_potential/utils/solar_names.dart';
import 'package:re_potential/widgets/text_widget.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final searchController = TextEditingController();
  String nameSearched = '';
  String selectedValue = 'Alubijid';
  String? selectedValue1;

  String? selectedValue3 = 'Potential';
  dynamic type;

  final List<String> items = [
    'Wind',
    'Solar',
    'Biomass',
    'Hydro',
  ];

  final List<String> items2 = ['Potential', 'Existing'];

  final cont = MapController();

  List<LatLng> points = [];
  Future<void> loadLatLongFromExcel(String file) async {
    ByteData data = await rootBundle.load('assets/$file.xlsx');
    Uint8List bytes = data.buffer.asUint8List();

    var excel = ex.Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      var rows = excel.tables[table]!.rows;

      // Skip header row
      for (int i = 1; i < rows.length; i++) {
        var row = rows[i];
        var lon = row[2]?.value;
        var lat = row[3]?.value;

        if (lon != null && lat != null) {
          points.add(LatLng(
            double.parse(lat.toString()),
            double.parse(lon.toString()),
          ));
        }
      }
    }

    // Only update state once
    setState(() {
      poly1 = Polygon(
          points: points,
          color: Colors.red.withOpacity(0.4),
          borderColor: Colors.red,
          borderStrokeWidth: 2,
          isFilled: true);
    });
  }

  Polygon poly1 = Polygon(points: []);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      width: 300,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5),
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: DropdownButton<String>(
                          underline: const SizedBox(),
                          value: selectedValue1,
                          hint: const Text('Select Type'),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: items.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              poly1 = Polygon(points: []);
                              selectedValue1 = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Container(
                      height: 50,
                      width: 300,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5),
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: DropdownButton<String>(
                          underline: const SizedBox(),
                          value: selectedValue3,
                          hint: const Text('Select Type'),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: items2.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              if (newValue! == 'Existing') {
                                cont.move(
                                  LatLng(8.569381, 124.756252),
                                  10,
                                );
                              }
                              selectedValue3 = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                selectedValue3 == 'Existing'
                    ? const SizedBox()
                    : Container(
                        height: 50,
                        width: 300,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.5),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: DropdownButton<String>(
                            underline: const SizedBox(),
                            value: selectedValue,
                            hint: const Text('Select Municipality'),
                            icon: const Icon(Icons.arrow_drop_down),
                            items: locationCoordinates.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['Municipality'],
                                child: Text(item['Municipality']),
                              );
                            }).toList(),
                            onChanged: (String? newValue) async {
                              if (newValue != null) {
                                final item = locationCoordinates.firstWhere(
                                  (loc) => loc['Municipality'] == newValue,
                                );

                                // Show loading dialog
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => Dialog(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: TextWidget(
                                          text: 'Loading . . .', fontSize: 14),
                                    ),
                                  ),
                                );

                                if (selectedValue1 == 'Biomass') {
                                  await loadLatLongFromExcel(
                                      newValue.toLowerCase());
                                }

                                // Load Excel data

                                // Close loading dialog
                                Navigator.pop(context);

                                // Update UI
                                setState(() {
                                  cont.move(
                                    LatLng(item['Latitude'], item['Longitude']),
                                    13,
                                  );
                                  selectedValue = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 800,
            child: FlutterMap(
              mapController: cont,
              options: MapOptions(
                center:
                    LatLng(8.499816, 124.433209), // Center the map over London
                zoom: 13,
              ),
              children: [
                TileLayer(
                  // Display map tiles from any source
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                  userAgentPackageName: 'com.example.app',
                  // And many more recommended properties!
                ),
                for (int i = 0; i < points.length; i++)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                          points: [points[i]],
                          color: Colors.red,
                          borderColor: Colors.red,
                          borderStrokeWidth: 5,
                          isFilled: true)
                    ],
                  ),
                // PolygonLayer(
                //   polygons: selectedValue3 == 'Potential' ? [poly1] : [],
                // ),
                // Solar Existing
                MarkerLayer(
                  markers: selectedValue1 == 'Solar' &&
                          selectedValue3 == 'Existing'
                      ? [
                          for (int i = 0; i < solarProjects.length; i++)
                            Marker(
                                point: LatLng(
                                    double.parse(solarProjects[i]['coordinates']
                                        .split(',')[0]),
                                    double.parse(solarProjects[i]['coordinates']
                                        .split(',')[1])),
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            backgroundColor: Colors.white,
                                            child: SizedBox(
                                              width: 400,
                                              height: 375,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: IconButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        icon: const Icon(
                                                          Icons.close,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                    TextWidget(
                                                      text: solarProjects[i]
                                                          ['municipality'],
                                                      fontSize: 24,
                                                      fontFamily: 'Bold',
                                                    ),
                                                    const Divider(),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text:
                                                              'Project Name: ',
                                                          fontSize: 14,
                                                          fontFamily: 'Medium',
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: solarProjects[i]
                                                                  [
                                                                  'projectName']
                                                              .toString(),
                                                          fontSize: 18,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text: 'Developer: ',
                                                          fontSize: 14,
                                                          fontFamily: 'Medium',
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: solarProjects[i]
                                                                  ['developer']
                                                              .toString(),
                                                          fontSize: 18,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text: 'Status: ',
                                                          fontSize: 14,
                                                          fontFamily: 'Medium',
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: solarProjects[i]
                                                                  ['status']
                                                              .toString(),
                                                          fontSize: 18,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text:
                                                              'Capacity (MW): ',
                                                          fontSize: 14,
                                                          fontFamily: 'Medium',
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: solarProjects[i]
                                                                  ['capacityMW']
                                                              .toString(),
                                                          fontSize: 18,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 125,
                                      height: 125,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.orange.withOpacity(0.8),
                                            Colors.orange.withOpacity(0.4),
                                          ],
                                          center: Alignment.center,
                                          radius: 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                              'assets/images/Solar.png'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                height: 50,
                                width: 50),
                        ]
                      : [],
                ),
                // Wind Existing

                MarkerLayer(
                  markers: selectedValue1 == 'Wind' &&
                          selectedValue3 == 'Existing'
                      ? [
                          for (int i = 0; i < windProjects.length; i++)
                            Marker(
                                point: LatLng(
                                    double.parse(windProjects[i]['coordinates']
                                        .split(',')[0]),
                                    double.parse(windProjects[i]['coordinates']
                                        .split(',')[1])),
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            backgroundColor: Colors.white,
                                            child: SizedBox(
                                              width: 400,
                                              height: 375,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: IconButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        icon: const Icon(
                                                          Icons.close,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                    TextWidget(
                                                      text: windProjects[i]
                                                          ['municipality'],
                                                      fontSize: 24,
                                                      fontFamily: 'Bold',
                                                    ),
                                                    const Divider(),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text:
                                                              'Project Name: ',
                                                          fontSize: 14,
                                                          fontFamily: 'Medium',
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: windProjects[i][
                                                                  'projectName']
                                                              .toString(),
                                                          fontSize: 18,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text: 'Developer: ',
                                                          fontSize: 14,
                                                          fontFamily: 'Medium',
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: windProjects[i]
                                                                  ['developer']
                                                              .toString(),
                                                          fontSize: 18,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text: 'Status: ',
                                                          fontSize: 14,
                                                          fontFamily: 'Medium',
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: windProjects[i]
                                                                  ['status']
                                                              .toString(),
                                                          fontSize: 18,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text:
                                                              'Capacity (MW): ',
                                                          fontSize: 14,
                                                          fontFamily: 'Medium',
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: windProjects[i]
                                                                  ['capacityMW']
                                                              .toString(),
                                                          fontSize: 18,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 125,
                                      height: 125,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.green.withOpacity(0.8),
                                            Colors.green.withOpacity(0.4),
                                          ],
                                          center: Alignment.center,
                                          radius: 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                              'assets/images/wind.png'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                height: 50,
                                width: 50),
                        ]
                      : [],
                ),
                // Hydro Existing
                MarkerLayer(
                  markers: selectedValue1 == 'Hydro' &&
                          selectedValue3 == 'Existing'
                      ? [
                          for (int i = 0; i < hydroProjects.length; i++)
                            Marker(
                                point: LatLng(
                                    double.parse(hydroProjects[i]['coordinates']
                                        .split(',')[0]),
                                    double.parse(hydroProjects[i]['coordinates']
                                        .split(',')[1])),
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            backgroundColor: Colors.white,
                                            child: SizedBox(
                                              width: 400,
                                              height: 375,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: IconButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        icon: const Icon(
                                                          Icons.close,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                    TextWidget(
                                                      text: hydroProjects[i]
                                                          ['municipality'],
                                                      fontSize: 24,
                                                      fontFamily: 'Bold',
                                                    ),
                                                    const Divider(),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text:
                                                              'Project Name: ',
                                                          fontSize: 14,
                                                          fontFamily: 'Medium',
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: hydroProjects[i]
                                                                  [
                                                                  'projectName']
                                                              .toString(),
                                                          fontSize: 18,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text: 'Developer: ',
                                                          fontSize: 14,
                                                          fontFamily: 'Medium',
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: hydroProjects[i]
                                                                  ['developer']
                                                              .toString(),
                                                          fontSize: 18,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text: 'Status: ',
                                                          fontSize: 14,
                                                          fontFamily: 'Medium',
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: hydroProjects[i]
                                                                  ['status']
                                                              .toString(),
                                                          fontSize: 18,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text:
                                                              'Capacity (MW): ',
                                                          fontSize: 14,
                                                          fontFamily: 'Medium',
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        TextWidget(
                                                          text: hydroProjects[i]
                                                                  ['capacityMW']
                                                              .toString(),
                                                          fontSize: 18,
                                                          fontFamily: 'Bold',
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 125,
                                      height: 125,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.blue.withOpacity(0.8),
                                            Colors.blue.withOpacity(0.4),
                                          ],
                                          center: Alignment.center,
                                          radius: 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                              'assets/images/hydro-power.png'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                height: 50,
                                width: 50),
                        ]
                      : [],
                ),
                // Hydro
                MarkerLayer(
                  markers: selectedValue1 == 'Hydro' &&
                          selectedValue3 == 'Potential'
                      ? [
                          for (int i = 0; i < hydroSites.length; i++)
                            Marker(
                                point: LatLng(hydroSites[i].latitude,
                                    hydroSites[i].longitude),
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            backgroundColor: Colors.white,
                                            child: SizedBox(
                                              width: 500,
                                              height: 550,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: IconButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        icon: const Icon(
                                                          Icons.close,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Image.asset(
                                                        'assets/images/hydro/$i.PNG',
                                                        height: 250,
                                                        width: 500,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    TextWidget(
                                                      text: hydroSites[i].name,
                                                      fontSize: 24,
                                                      fontFamily: 'Bold',
                                                    ),
                                                    const Divider(),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Hydraulic Head: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: hydroSites[
                                                                      i]
                                                                  .hydraulicHead
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Penstock length: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: hydroSites[
                                                                      i]
                                                                  .penstockLength
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Diversion canal length: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: hydroSites[
                                                                      i]
                                                                  .diversionCanalLength
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Hydraulic flow rate: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: hydroSites[
                                                                      i]
                                                                  .hydraulicFlowRate
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Hydro Power Capacity: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: hydroSites[
                                                                      i]
                                                                  .hydroPowerCapacity
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 125,
                                      height: 125,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.blue.withOpacity(0.8),
                                            Colors.blue.withOpacity(0.4),
                                          ],
                                          center: Alignment.center,
                                          radius: 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                              'assets/images/hydro-power.png'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                height: 50,
                                width: 50),
                        ]
                      : [],
                ),
                //
                OverlayImageLayer(
                    overlayImages: selectedValue1 == 'Solar' &&
                            selectedValue3 == 'Potential'
                        ? [
                            for (int i = 0; i < newSolarDatas.length; i++)
                              OverlayImage(
                                opacity: 50,
                                bounds: LatLngBounds(newSolarDatas[i].area1,
                                    newSolarDatas[i].area2),
                                imageProvider: AssetImage(
                                  'assets/images/solar/${newSolarDatas[i].municipality}/${newSolarDatas[i].index}.png',
                                ),
                              ),
                          ]
                        : []),
                // Solar
                MarkerLayer(
                  markers: selectedValue1 == 'Solar' &&
                          selectedValue3 == 'Potential'
                      ? [
                          for (int i = 0; i < solarData.length; i++)
                            Marker(
                                point: LatLng(solarData[i]['latitude'],
                                    solarData[i]['longitude']),
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      int index = 1;
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            backgroundColor: Colors.white,
                                            child: StatefulBuilder(
                                                builder: (context, setState) {
                                              return SizedBox(
                                                width: 500,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: IconButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            icon: const Icon(
                                                              Icons.close,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                        Center(
                                                          child: Image.asset(
                                                            'assets/images/solar/$i.PNG',
                                                            height: 250,
                                                            width: 500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        TextWidget(
                                                          text: solarData[i]
                                                              ['municipality'],
                                                          fontSize: 24,
                                                          fontFamily: 'Bold',
                                                        ),
                                                        const Divider(),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                TextWidget(
                                                                  text:
                                                                      'Building: ',
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Medium',
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                TextWidget(
                                                                  text: solarData[
                                                                          i][
                                                                      'building'],
                                                                  fontSize: 18,
                                                                  fontFamily:
                                                                      'Bold',
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                TextWidget(
                                                                  text:
                                                                      'Roof Area: ',
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Medium',
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                TextWidget(
                                                                  text: solarData[
                                                                              i]
                                                                          [
                                                                          'roofArea']
                                                                      .toString(),
                                                                  fontSize: 18,
                                                                  fontFamily:
                                                                      'Bold',
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                TextWidget(
                                                                  text:
                                                                      'Utilized Area: ',
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Medium',
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                TextWidget(
                                                                  text: solarData[
                                                                              i]
                                                                          [
                                                                          'utilizedArea']
                                                                      .toString(),
                                                                  fontSize: 18,
                                                                  fontFamily:
                                                                      'Bold',
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                TextWidget(
                                                                  text:
                                                                      'Potential KW: ',
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Medium',
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                TextWidget(
                                                                  text: solarData[
                                                                              i]
                                                                          [
                                                                          'potentialKW']
                                                                      .toString(),
                                                                  fontSize: 18,
                                                                  fontFamily:
                                                                      'Bold',
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        newSolarDatas.where(
                                                          (element) {
                                                            return element
                                                                    .municipality ==
                                                                solarData[i][
                                                                    'municipality'];
                                                          },
                                                        ).isEmpty
                                                            ? const SizedBox()
                                                            : Column(
                                                                children: [
                                                                  const Divider(),
                                                                  Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/images/solar/${solarData[i]['municipality']}/$index$index.png',
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              20),
                                                                      Image
                                                                          .asset(
                                                                        'assets/images/solar/${solarData[i]['municipality']}/$index.png',
                                                                        height:
                                                                            250,
                                                                        width:
                                                                            250,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  TextWidget(
                                                                      text: newSolarDatas
                                                                          .where(
                                                                            (element) {
                                                                              return element.municipality == solarData[i]['municipality'];
                                                                            },
                                                                          )
                                                                          .elementAt(index - 1)
                                                                          .location,
                                                                      fontSize: 18),
                                                                  Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          if (index >
                                                                              1) {
                                                                            setState(() {
                                                                              index--;
                                                                            });
                                                                          }
                                                                        },
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .arrow_left,
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          if (index <
                                                                              (newSolarDatas.where(
                                                                                (element) {
                                                                                  return element.municipality == solarData[i]['municipality'];
                                                                                },
                                                                              ).length)) {
                                                                            setState(() {
                                                                              index++;
                                                                            });
                                                                          }
                                                                        },
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .arrow_right,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 125,
                                      height: 125,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.orange.withOpacity(0.8),
                                            Colors.orange.withOpacity(0.4),
                                          ],
                                          center: Alignment.center,
                                          radius: 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                              'assets/images/Solar.png'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                height: 50,
                                width: 50),
                        ]
                      : [],
                ),

                // Wind
                MarkerLayer(
                  markers: selectedValue1 == 'Wind' &&
                          selectedValue3 == 'Potential'
                      ? [
                          for (int i = 0; i < windSites.length; i++)
                            Marker(
                                point: LatLng(
                                    double.parse(
                                        windSites[i].coordinates.split(',')[1]),
                                    double.parse(windSites[i]
                                        .coordinates
                                        .split(',')[0])),
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            backgroundColor: Colors.white,
                                            child: SizedBox(
                                              width: 500,
                                              height: 550,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: IconButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        icon: const Icon(
                                                          Icons.close,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Image.asset(
                                                        'assets/images/wind/${i + 1}.png',
                                                        height: 250,
                                                        width: 500,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    TextWidget(
                                                      text: windSites[i]
                                                          .municipality,
                                                      fontSize: 24,
                                                      fontFamily: 'Bold',
                                                    ),
                                                    const Divider(),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Site Number: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: windSites[i]
                                                                  .siteNumber,
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Area (acres): ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: windSites[i]
                                                                  .areaAcres
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Average Wind Speed (m/s): ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: windSites[i]
                                                                  .avgWindSpeed
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Average Wind Density (w/m2): ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: windSites[i]
                                                                  .avgWindDensity
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Power Density (w/m2): ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: windSites[i]
                                                                  .powerDensity
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Blade Swept Area (m2): ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: windSites[i]
                                                                  .bladeSweptArea
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Maximum Efficiency: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: windSites[i]
                                                                  .maxEfficiency
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Number of Turbines: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: windSites[i]
                                                                  .numTurbines
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Effective Hours: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: windSites[i]
                                                                  .effectiveHours
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Annual Energy\nYield (Watt-Hour): ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: windSites[i]
                                                                  .annualEnergyYield
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 125,
                                      height: 125,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.green.withOpacity(0.8),
                                            Colors.green.withOpacity(0.4),
                                          ],
                                          center: Alignment.center,
                                          radius: 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                              'assets/images/wind.png'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                height: 50,
                                width: 50),
                        ]
                      : [],
                ),

                // Biomass
                MarkerLayer(
                  markers: selectedValue1 == 'Biomass' &&
                          selectedValue3 == 'Potential'
                      ? [
                          for (int i = 0; i < biomassData.length; i++)
                            Marker(
                                point: LatLng(
                                    locationCoordinates[i]['Latitude'],
                                    locationCoordinates[i]['Longitude']),
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            backgroundColor: Colors.white,
                                            child: SizedBox(
                                              width: 500,
                                              height: 550,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: IconButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        icon: const Icon(
                                                          Icons.close,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Image.asset(
                                                        'assets/images/${biomassData[i]['Municipality'] == 'Gingoog City' ? 'Gingoog' : biomassData[i]['Municipality']}.PNG',
                                                        height: 250,
                                                        width: 500,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    TextWidget(
                                                      text: biomassData[i]
                                                          ['Municipality'],
                                                      fontSize: 24,
                                                      fontFamily: 'Bold',
                                                    ),
                                                    const Divider(),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Total Shrubs Area: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: biomassData[
                                                                          i][
                                                                      'TotalShrubsArea']
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Hectares: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: biomassData[
                                                                          i][
                                                                      'Hectares']
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Tons Per Year: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: biomassData[
                                                                          i][
                                                                      'TonsPerYear']
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Tons Per 2x Year: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: biomassData[
                                                                          i][
                                                                      'TonsPer2xYear']
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Tons Per Day: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: biomassData[
                                                                          i][
                                                                      'TonsPerDay']
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Energy PerTon: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: biomassData[
                                                                          i][
                                                                      'EnergyPerTon']
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Biomass Kg Per Day: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: biomassData[
                                                                          i][
                                                                      'BiomassKgPerDay']
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Energy MJ Per Day: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: biomassData[
                                                                          i][
                                                                      'EnergyMJPerDay']
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Energy KWh Per Day: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: biomassData[
                                                                          i][
                                                                      'EnergyKWhPerDay']
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextWidget(
                                                              text:
                                                                  'Energy Output Percent: ',
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Medium',
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            TextWidget(
                                                              text: biomassData[
                                                                          i][
                                                                      'EnergyOutputPercent']
                                                                  .toString(),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Bold',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 125,
                                      height: 125,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.red.withOpacity(0.8),
                                            Colors.red.withOpacity(0.4),
                                          ],
                                          center: Alignment.center,
                                          radius: 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                              'assets/images/biomass.png'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                height: 50,
                                width: 50),
                        ]
                      : [],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
