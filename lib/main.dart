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

    return FutureBuilder(
    builder: (context, offices) {
      if (offices.connectionState == ConnectionState.none &&
          offices.hasData == null) {
        //print('project snapshot data is: ${offices.data}');
        return Container();
      }
      return ListView.builder(
        itemCount: offices.data.centros.length,
        itemBuilder: (context, index) {
          Office project = offices.data.centros[index];
          return Column(
            children: <Widget>[
              // Widget to display the list of project
            ],
          );
        },
      );
    },
    future: locations.getCentrosVacunatorios(),
  );
  }
}
