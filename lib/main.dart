import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
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
  late BitmapDescriptor customIcon;
  final Map<String, Marker> _markers = {};
  LatLng _initialcameraposition = LatLng(-25.283097, -57.635235);
  final Location location = Location();

  Future<void> _onMapCreated(GoogleMapController controller) async {

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)),
        'assets/img/vaccine_icon.png')
          .then((d) {
        customIcon = d;
      });

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
          icon: customIcon,
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

    return Container(
      
      child: Column(
        children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            "Centros mas cercanos",
            style: TextStyle(color: Colors.blueGrey, fontSize: 18),
          ),
        ),
        Container(
          width: 300,
          height: 1,
          color: Colors.blueGrey[800],
        ),
        FutureBuilder<locations.Locations>(
          builder: (context, offices) {
            if (offices.connectionState == ConnectionState.none &&
                offices.hasData == null) {
              print('project snapshot data is: ${offices.data}');
              return Container();
            } 

            return ListView.builder(
              shrinkWrap: true,
              itemCount: offices.data!.centros.length,
              itemBuilder: (BuildContext context, int i) {
                return listItem(context, offices.data!.centros[i]);
              },
            );
          },
          future: _getHByUserLocation(),
        ),
      ]),
    );
  }

  Widget listItem(BuildContext context, locations.Office centro) {
    return GestureDetector(
      child: Card(
        child: Row(
          children: <Widget>[
            Container(margin: EdgeInsets.all(10), child: Text(centro.distance)),
            Container(
              height: 20,
              width: 1,
              color: Colors.blue,
            ),
            Container(margin: EdgeInsets.all(10), child: Text(centro.name))
          ],
        ),
      ),
      onTap: () {
        _handleTapCercano(centro);
      },
    );
  }

  Future<locations.Locations>_getHByUserLocation() async {
    geolocator.Position position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high);
      print("lat: "+position.latitude.toString()+ "lng"+ position.longitude.toString());
      return locations.getCentrosVacunatoriosByDistance(position.latitude, position.longitude);
  }

  _handleTapCercano(locations.Office centro) async {
    _pc.close();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(centro.lat, centro.lng), zoom: 16),
      ),
    );
  }
}
