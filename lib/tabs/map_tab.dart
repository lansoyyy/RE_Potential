import 'package:flutter/material.dart';
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
  String? selectedValue;
  String? selectedValue1;
  String? selectedValue2;
  dynamic type;

  final List<String> items = [
    'Wind',
    'Energy',
    'Biomass',
    'Hydro',
    'Potential',
    'Renewable'
  ];
  final List<String> items1 = [
    'Wind',
    'Energy',
    'Biomass',
    'Hydro',
  ];

  final cont = MapController();

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
                          selectedValue1 = newValue;
                        });
                      },
                    ),
                  ),
                ),
                selectedValue1 == 'Potential' || selectedValue1 == 'Renewable'
                    ? Container(
                        height: 50,
                        width: 300,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.5),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: DropdownButton<String>(
                            underline: const SizedBox(),
                            value: selectedValue2,
                            hint: const Text('Select Type'),
                            icon: const Icon(Icons.arrow_drop_down),
                            items: items1.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedValue2 = newValue;
                              });
                            },
                          ),
                        ),
                      )
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
                                onTap: () {
                                  setState(() {
                                    cont.move(
                                        LatLng(item['Latitude'],
                                            item['Longitude']),
                                        13);

                                    selectedValue = item['Municipality'];
                                  });
                                },
                                value: item['Municipality'],
                                child: Text(item['Municipality']),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              // setState(() {
                              //   selectedValue = newValue;
                              // });
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
                    LatLng(8.485383, 124.655940), // Center the map over London
                zoom: 10,
              ),
              children: [
                TileLayer(
                  // Display map tiles from any source
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                  userAgentPackageName: 'com.example.app',
                  // And many more recommended properties!
                ),
                MarkerLayer(
                  markers: selectedValue1 == 'Biomass' ||
                          selectedValue2 == 'Biomass'
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
                                      decoration: const BoxDecoration(
                                          color: Colors.green,
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
