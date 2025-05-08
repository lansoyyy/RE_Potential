import 'dart:typed_data';

import 'package:excel/excel.dart' as ex;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:re_potential/utils/data.dart';
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

  String? selectedValue3;
  dynamic type;

  final List<String> items = [
    'Wind',
    'Energy',
    'Biomass',
    'Hydro',
  ];

  final List<String> items2 = ['None', 'Potential', 'Existing'];

  final cont = MapController();
  Future<void> loadLatLongFromExcel(String file) async {
    ByteData data = await rootBundle.load('assets/$file.xlsx');
    Uint8List bytes = data.buffer.asUint8List();

    var excel = ex.Excel.decodeBytes(bytes);

    List<LatLng> points = [];

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
                              selectedValue3 = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                selectedValue3 == 'Potential' || selectedValue3 == 'Existing'
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
                PolygonLayer(
                  polygons: [poly1],
                ),
                // Hydro
                MarkerLayer(
                  markers: selectedValue1 == 'Hydro'
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
                                      decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Image.asset(
                                            'assets/images/hydro-power.png'),
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
                  markers: selectedValue1 == 'Wind'
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
                                                    // Center(
                                                    //   child: Image.asset(
                                                    //     'assets/images/${biomassData[i]['Municipality'] == 'Gingoog City' ? 'Gingoog' : biomassData[i]['Municipality']}.PNG',
                                                    //     height: 250,
                                                    //     width: 500,
                                                    //   ),
                                                    // ),
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
                                      decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Image.asset(
                                            'assets/images/wind.png'),
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
                  markers: selectedValue1 == 'Biomass'
                      ? selectedValue3 != 'Potential' &&
                              selectedValue3 != 'Existing'
                          ? [
                              Marker(
                                  point: LatLng(
                                      locationCoordinates
                                          .where(
                                            (element) {
                                              return element['Municipality'] ==
                                                  selectedValue;
                                            },
                                          )
                                          .toList()
                                          .first['Latitude'],
                                      locationCoordinates
                                          .where(
                                            (element) {
                                              return element['Municipality'] ==
                                                  selectedValue;
                                            },
                                          )
                                          .toList()
                                          .first['Longitude']),
                                  builder: (context) {
                                    final data = biomassData
                                        .where(
                                          (element) {
                                            return element['Municipality'] ==
                                                selectedValue;
                                          },
                                        )
                                        .toList()
                                        .first;
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
                                                        CrossAxisAlignment
                                                            .start,
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
                                                          'assets/images/${data['Municipality'] == 'Gingoog City' ? 'Gingoog' : data['Municipality']}.PNG',
                                                          height: 250,
                                                          width: 500,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      TextWidget(
                                                        text: data[
                                                            'Municipality'],
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
                                                                text: data[
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
                                                                text: data[
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
                                                                text: data[
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
                                                                text: data[
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
                                                                text: data[
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
                                                                text: data[
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
                                                                text: data[
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
                                                                text: data[
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
                                                                text: data[
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
                                                                text: data[
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
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Image.asset(
                                              'assets/images/biomass.png'),
                                        ),
                                      ),
                                    );
                                  },
                                  height: 50,
                                  width: 50),
                            ]
                          : [
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
                                                        const EdgeInsets.all(
                                                            8.0),
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
                                                                              i]
                                                                          [
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
                                                                              i]
                                                                          [
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
                                                                              i]
                                                                          [
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
                                                                              i]
                                                                          [
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
                                                                              i]
                                                                          [
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
                                                                              i]
                                                                          [
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
                                                                              i]
                                                                          [
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
                                                                              i]
                                                                          [
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
                                                                              i]
                                                                          [
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
                                                                              i]
                                                                          [
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
                                          decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Image.asset(
                                                'assets/images/biomass.png'),
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
