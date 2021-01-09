import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
 
List<Marker> myMarker = [];

List<Marker> _markers = <Marker>[];

class _MyAppState extends State<MyApp> {
  Completer<GoogleMapController> _controller = Completer();
  
  String _currentAddress='' ;
  double latitude, longitude;    
 
  static const LatLng _center = const LatLng(6.4676929, 100.5067673);

  LatLng _lastMapPosition = _center;

  MapType _currentMapType = MapType.normal;

  void initState() {
    super.initState();
    getCurrentLocation(
      _MyAppState._center
    );
    myMarker = [];
    myMarker.add(Marker(
      markerId: MarkerId(_MyAppState._center.toString()),
      position: _MyAppState._center,
    ));
  }

  Widget build(BuildContext context) {
    
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: Stack(
          children: <Widget>[
            SizedBox(
              height: 400,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 17.0,
                ),
                mapType: _currentMapType,
                markers: Set.from(myMarker),
                onCameraMove: _onCameraMove,
                onTap: _handleTap,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: <Widget>[
                    FloatingActionButton(
                      onPressed: _onMapTypeButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.map, size: 36.0),
                    ),
                    SizedBox(height: 16.0),
                    FloatingActionButton(
                      onPressed: _onAddMarkerButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.add_location, size: 36.0),
                    ),
                    SizedBox(height: 300),
                    Column(
                      children: <Widget>[
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Latitude: ' + latitude.toString(),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )),
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Longitude: ' + longitude.toString(),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )),
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Address: ' + _currentAddress.toString(),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: '',
          snippet: '',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _handleTap(tappedPoint) {
    getCurrentLocation(tappedPoint);
    print(tappedPoint);
    setState(() {
      latitude = tappedPoint.latitude;
      longitude = tappedPoint.longitude;
      myMarker = [];

      myMarker.add(Marker(
        markerId: MarkerId(tappedPoint.toString()),
        position: tappedPoint,
      ));
    });
  }

  void getCurrentLocation(tappedPoint) async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          tappedPoint.latitude, tappedPoint.longitude);
      latitude = tappedPoint.latitude;
      longitude = tappedPoint.longitude;
      
        Placemark place = p[0];

     setState(() {
       _currentAddress =
           "${place.locality}, ${place.postalCode}, ${place.country}";
     });
      
     
    } catch (e) {
      print(e);
    }
    print(tappedPoint);
  }
  
}
