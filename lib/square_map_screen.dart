import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeometryShape {
  final String name;
  final IconData icon;
  const GeometryShape({
    required this.name,
    required this.icon,
  });
}

class UTM32 {
  final double easting;
  final double northing;

  UTM32({required this.easting, required this.northing});

  factory UTM32.fromJson(Map<String, dynamic> json) {
    return UTM32(easting: json["easting"], northing: json["northing"]);
  }
}

const List<GeometryShape> geometryShapes = [
  GeometryShape(name: 'Circle', icon: Icons.circle),
  GeometryShape(name: 'Square', icon: Icons.crop_square),
  GeometryShape(name: 'Triangle', icon: Icons.change_history),
  GeometryShape(name: 'Star', icon: Icons.star),
];

class SquareMapScreen extends StatefulWidget {
  late InAppWebViewController _webViewController;
  @override
  _SquareMapScreenState createState() => _SquareMapScreenState();
}

class _SquareMapScreenState extends State<SquareMapScreen> {
  late Completer<GoogleMapController> _mapController = Completer();
  Set<Polygon> _polylines = {};
  List<LatLng> _locations = [];
  Set<Marker> _marker = {};
  int id = 1;
  List<UTM32> _utm32Coordinates = [];
  bool getUrlcall = false;
  bool showCoordinateSheet = false;

  onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    double _progress = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Square Map'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showShapesMenu();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialFile: 'flutter_assets/asset/tiny_rebort.html',
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress / 100;
              });
            },
            onLoadStop: (conttroller, url) {
              conttroller
                  .evaluateJavascript(source: 'getLatLongList()')
                  .then((result) {
                _locations = _parseLocations(result);
              });

              conttroller
                  .evaluateJavascript(source: 'initialize()')
                  .then((value) {
                setState(() {
                  _utm32Coordinates = _parseUTM(value);
                  // showCoordinates(context);
                });
              });
            },
            onWebViewCreated: (InAppWebViewController controller) {
              widget._webViewController = controller;
            },
            // onLoadError: (controller, url, code, message) =>
            //     SnackBar(content: Text(message))
          ),
          GoogleMap(
            onMapCreated: onMapCreated,
            polygons: _polylines,
            markers: _marker,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962),
              zoom: 10,
            ),
            onTap: (latlong) {
              print(
                  "========================${latlong.latitude} , ${latlong.longitude}");
            },
          ),
          _progress < 1
              ? SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.blue,
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  void _showShapesMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject()
        as RenderBox; //------- (context)!.context
    final RelativeRect position = RelativeRect.fromLTRB(
      MediaQuery.of(context).size.width - 50,
      kToolbarHeight + MediaQuery.of(context).padding.top + 10,
      MediaQuery.of(context).size.width - 10,
      0,
    );
    showModalBottomSheet<GeometryShape>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: ListView.builder(
            itemCount: geometryShapes.length,
            itemBuilder: (BuildContext context, int index) {
              final geometryShape = geometryShapes[index];
              return ListTile(
                leading: Icon(geometryShape.icon),
                title: Text(geometryShape.name),
                onTap: () {
                  if (geometryShape.name == "Square") {
                    setState(() {
                      getUrlcall = true;
                    });
                  }
                  Navigator.pop(context, geometryShape);
                },
              );
            },
          ),
          height: 200.0,
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      enableDrag: true,
    ).then<void>((GeometryShape? geometryShape) {
      if (geometryShape != null) {
        if (geometryShape.name == "Square") {
          print("=================================== square");
          addPolyLine(context);
        }
      }
    });
  }

  List<LatLng> _parseLocations(List<dynamic> result) {
    var locations = result.map((e) => LatLng(e['lat'], e['lng'])).toList();
    return locations;
  }

  void addPolyLine(BuildContext con) {
    _polylines.add(Polygon(
        polygonId: PolygonId("p"),
        points: [..._locations, _locations[0]],
        fillColor: Colors.deepOrangeAccent,
        strokeWidth: 2,
        onTap: () {},
        strokeColor: Colors.red));
    showCoordinates(con);
    setState(() {});
  }

  List<UTM32> _parseUTM(List<dynamic> result) {
    var location = result.map((e) => UTM32.fromJson(e)).toList();
    return location;
  }

  void showCoordinates(BuildContext con) {
    showModalBottomSheet(
      context: con,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            Text("LatLong"),
            Container(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _locations.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                        "${_locations[index].latitude}, ${_locations[index].longitude}"),
                  );
                },
              ),
            ),
            const Text('UTM 32 Coordinate'),
            Container(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _utm32Coordinates.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                        "${_utm32Coordinates[index].easting}, ${_utm32Coordinates[index].northing}"),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
