import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SquareMapScreen extends StatefulWidget {
  @override
  _SquareMapScreenState createState() => _SquareMapScreenState();
}

class _SquareMapScreenState extends State<SquareMapScreen> {
  late Completer<GoogleMapController> _mapController = Completer();
  Set<Polygon> _polygons = {};
  List<LatLng> _squareCoordinates = [];
  List<Map<String, double>> _wgs84Coordinates = [];
  List<Map<String, double>> _utm32Coordinates = [];

  onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Square Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: onMapCreated,
            polygons: _polygons,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962),
              zoom: 10,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Square Coordinates',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _wgs84Coordinates.length,
                      itemBuilder: (context, index) {
                        final wgs84Coordinate = _wgs84Coordinates[index];
                        final utm32Coordinate = _utm32Coordinates[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Corner ${index + 1}',
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'WGS84: ${wgs84Coordinate['latitude']}, ${wgs84Coordinate['longitude']}',
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'UTM32: ${utm32Coordinate['easting']}, ${utm32Coordinate['northing']}',
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSquareCoordinates();
  }

  Future<void> _loadSquareCoordinates() async {
    final templateData =
        await DefaultAssetBundle.of(context).loadString('assets/template.json');
    final template = jsonDecode(templateData);
    _squareCoordinates = template.map<LatLng>((coordinate) {
      final latitude = coordinate['latitude'] as double;
      final longitude = coordinate['longitude'] as double;
      return LatLng(latitude, longitude);
    }).toList();
    // _generateSquare();
  }

  // void _generateSquare() async {
  //   final wgs84Coordinates = _squareCoordinates.map((coordinate) {
  //     final latLng = coordinate as LatLng;
  //     return {'latitude': latLng.latitude, 'longitude': latLng.longitude};
  //   }).toList();
  //   final utm32Coordinates = await _convertToUTM32(_squareCoordinates);
  //   setState(() {
  //     _wgs84Coordinates = wgs84Coordinates;
  //     _utm32Coordinates = utm32Coordinates;
  //     _polygons.add(Polygon(
  //       polygonId: PolygonId('square'),
  //       points: _squareCoordinates,
  //       strokeWidth: 3,
  //       strokeColor: Colors.red,
  //       fillColor: Colors.red.withOpacity(0.2),
  //     ));
  //   });
  // }
  //
  // Future<List<Map<String, double>>> _convertToUTM32(
  //     List<LatLng> coordinates) async {
  //   final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  //   _flutterFFmpeg.
  //
  //   final source = proj4dart.Projection.add(
  //       'WGS84', '+proj=longlat +datum=WGS84 +no_defs');
  //   final destination = proj4dart.Projection.add(
  //       'UTM32', '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs');
  //
  //   source.transform(destination, source);
  //   final transformer =
  //       proj4dart.Transformer.fromProjection(source, destination);
  //   final utm32Coordinates = coordinates.map((coordinate) {
  //     final point =
  //         proj4dart.Point(x: coordinate.longitude, y: coordinate.latitude);
  //     final transformedPoint = transformer.transform(point);
  //     return {'easting': transformedPoint.x, 'northing': transformedPoint.y};
  //   }).toList();
  //   return utm32Coordinates as List<Map<String, double>>;
  // }
}
