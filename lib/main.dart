import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'src/locations.dart' as locations;
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Completer<GoogleMapController> _controller = Completer();
  final PanelController _pc = new PanelController();
  final Map<String, Marker> _markers = {};
  LatLng _initialcameraposition = LatLng(-25.283097, -57.635235);
  final Location location = Location();

  Future<void> _onMapCreated(GoogleMapController controller) async {
    location.onLocationChanged.listen((l) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 15),
        ),
      );
    });

    final googleOffices = await locations.getCentrosVacunatorios();
    setState(() {
      _markers.clear();
      for (final centro in googleOffices.centros) {
        final marker = Marker(
          markerId: MarkerId(centro.name),
          position: LatLng(centro.lat, centro.lng),
          infoWindow: InfoWindow(
            title: centro.name,
            snippet: centro.address,
          ),
        );
        _markers[centro.name] = marker;
      }
    });

    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Centros de Vacunacion',
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
            backgroundColor: Color(0xff009AAD),
          ),
          body: Stack(children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition:
                  CameraPosition(target: _initialcameraposition, zoom: 13),
              markers: _markers.values.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
            SlidingUpPanel(
              minHeight: 50,
              maxHeight: 400,
              controller: _pc,
              panelBuilder: (ScrollController sc) => _scrollingList(sc),
              collapsed: Container(
                color: Colors.blueGrey,
                child: Center(
                  child: Text(
                    "Ver Centros mas cercanos",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _scrollingList(ScrollController sc) {
//final centro in googleOffices.centros

    return FutureBuilder<locations.Locations>(
      builder: (context, offices) {
        print('project snapshot data is: ${offices}');
        print('project snapshot data is: ${offices.data}');
        print('project snapshot data is: ${offices.data!.centros}');
        if (offices.connectionState == ConnectionState.none &&
            offices.hasData == null) {
          print('project snapshot data is: ${offices.data}');
          return Container();
        }

        return ListView.builder(
          itemCount: offices.data!.centros.length,
          itemBuilder: (BuildContext context, int i) {
            return GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  height: 60,
                  color: Colors.blueGrey,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 0),
                      child: Column(
                        children: [
                          Text(
                            offices.data!.centros[i].name,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Text(
                            offices.data!.centros[i].address,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            "2.3 KM",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      )),
                ),
              ),
              onTap: () {
                _handleTapCercano(offices.data!.centros[i]);
              },
            );
          },
        );
      },
      future: locations.getCentrosVacunatorios(),
    );
  }

  _handleTapCercano(locations.Office centro) async {
    _pc.close();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(centro.lat, centro.lng),
          zoom: 16
        ),
      ),
    );
    
  }
}
