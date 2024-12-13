import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final searchController = TextEditingController();
  String nameSearched = '';

  String? selectedValue;

  // List of items in the dropdown
  final List<String> items = [
    'Municipality 1',
    'Municipality 2',
    'Municipality 3',
    'Municipality 4'
  ];

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
                      border: Border.all(
                        color: Colors.black,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: DropdownButton<String>(
                      underline: const SizedBox(),
                      value: selectedValue,
                      hint: const Text('Select Municipality'),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: items.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue = newValue;
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                      style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Bold',
                          fontSize: 14),
                      onChanged: (value) {
                        setState(() {
                          nameSearched = value;
                        });
                      },
                      decoration: const InputDecoration(
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          hintText: 'Search',
                          hintStyle:
                              TextStyle(fontFamily: 'Regular', fontSize: 18),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          )),
                      controller: searchController,
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
              options: const MapOptions(
                initialCenter:
                    LatLng(8.485383, 124.655940), // Center the map over London
                initialZoom: 16,
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
