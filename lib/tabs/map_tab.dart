import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:re_potential/utils/data.dart';

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
                zoom: 16,
              ),
              children: [
                TileLayer(
                  // Display map tiles from any source
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                  userAgentPackageName: 'com.example.app',
                  // And many more recommended properties!
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
