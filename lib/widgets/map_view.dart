import 'package:airsoft_domination/models/player.dart';
import 'package:airsoft_domination/utils/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:utm/utm.dart';

import '../providers/game.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Future<LocationData> _userLocationFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userLocationFuture = LocationUtils.getCurrentUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationData>(
      future: _userLocationFuture,
      builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? Center(child: CircularProgressIndicator())
          : Consumer<Game>(builder: (context, _gameProvider, _) {
              final _userLocation =
                  LatLng(snapshot.data.latitude, snapshot.data.longitude);
              List<Marker> _markers = [];
              _markers.addAll([
                ..._gameProvider.flags
                    .where((f) => (f.lat != null && f.long != null))
                    .map((e) => Marker(
                          width: 30.0,
                          height: 30.0,
                          point: LatLng(e.lat, e.long),
                          builder: (ctx) => CustomMarker(
                              e.name, e.lat, e.long, MarkerType.commonObj),
                        ))
              ]);

              _markers.addAll([
                Marker(
                  width: 30.0,
                  height: 30.0,
                  point:
                      LatLng(_userLocation.latitude, _userLocation.longitude),
                  builder: (ctx) => CustomMarker('user', _userLocation.latitude,
                      _userLocation.longitude, MarkerType.player),
                )
              ]);
              return FlutterMap(
                options: MapOptions(
                  center: _userLocation,
                  zoom: 13.0,
                ),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']),
                  MarkerLayerOptions(
                      // markers: [
                      //   Marker(
                      //     width: 40.0,
                      //     height: 40.0,
                      //     point: dublin,
                      //     builder: (ctx) => CustomMarker(),
                      //   ),
                      // ],
                      markers: _markers),
                ],
              );
            }),
    );
  }
}

class CustomMarker extends StatelessWidget {
  final double lat;
  final double long;
  final String name;
  final MarkerType type;

  CustomMarker(this.name, this.lat, this.long, this.type);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () {
          var utmLocation = UTM.fromLatLon(lat: lat, lon: long);
          var text =
              '${name.toUpperCase()} ${utmLocation.zone} E: ${utmLocation.easting.toStringAsFixed(0)} N: ${utmLocation.northing.toStringAsFixed(0)}';

          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(text),
          ));
        },
        child: Stack(
          alignment: Alignment.center,
          overflow: Overflow.visible,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: type == MarkerType.player ? Colors.blue : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Positioned(
                bottom: -16,
                child: Text(
                  name.toUpperCase(),
                  overflow: TextOverflow.visible,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                )),
          ],
        ),
      ),
    );
  }
}

enum MarkerType { commonObj, player }
