import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:utm/utm.dart';

import '../models/player.dart';
import '../providers/location.dart';

import '../providers/current_game.dart';
import '../providers/auth.dart';
import './new_flag_form.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  UserLocation _locationProvider;
  CurrentGame _gameProvider;
  Auth _authProvider;

  final _mapBoxUrl =
      'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}';
  final _osmUrl = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";

  void _addNewFlag(LatLng location) async {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: NewFlagForm(
              LocationData.fromMap({
                'latitude': location.latitude,
                'longitude': location.longitude
              }),
            ),
          );
        });
  }

  @override
  void didChangeDependencies() {
    _locationProvider = Provider.of<UserLocation>(context);
    _gameProvider = Provider.of<CurrentGame>(context);
    _authProvider = Provider.of<Auth>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _locationProvider.timerDispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _startTimer();
    print('building map');

    final _userLocationData = _locationProvider.userLocation;
    final _userLocation = _userLocationData == null
        ? null
        : LatLng(_userLocationData.latitude, _userLocationData.longitude);

    List<Marker> _markers = [];
    _markers.addAll([
      ..._gameProvider.flags
          .where((f) => (f.lat != null && f.long != null))
          .map((e) => Marker(
                width: 30.0,
                height: 30.0,
                point: LatLng(e.lat, e.long),
                builder: (ctx) =>
                    CustomMarker(e.name, e.lat, e.long, MarkerType.commonObj),
              ))
    ]);

    _markers.addAll([
      Marker(
        width: 30.0,
        height: 30.0,
        point: _userLocation == null
            ? null
            : LatLng(_userLocation.latitude, _userLocation.longitude),
        builder: (ctx) => CustomMarker('user', _userLocation.latitude,
            _userLocation.longitude, MarkerType.player),
      )
    ]);
    return FlutterMap(
      options: _userLocationData != null
          ? MapOptions(
              center: _userLocation,
              zoom: 13.0,
              onLongPress: (value) {
                if (_authProvider.isAdmin || _authProvider.isGameMaster)
                  _addNewFlag(value);
              },
            )
          : MapOptions(
              zoom: 13.0,
              onLongPress: (value) {
                if (_authProvider.isAdmin || _authProvider.isGameMaster)
                  _addNewFlag(value);
              },
            ),
      layers: [
        TileLayerOptions(
          urlTemplate: _osmUrl,
          // additionalOptions: {
          //   'accessToken':
          //       'pk.eyJ1IjoiZzNudGkiLCJhIjoiY2pyMm03NTRiMDRqZjQzb2xiaDIweGlsZiJ9.gX2EbcqrObKQJI40r8l8OA',
          //   'id': 'mapbox.satellite',
          // }
          subdomains: ['a', 'b', 'c'], // activate for osmUrl
        ),
        MarkerLayerOptions(markers: _markers),
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return StreamBuilder<LocationData>(
  //     stream: Location().onLocationChanged,
  //     builder: (context, snapshot) => snapshot.connectionState ==
  //             ConnectionState.waiting
  //         ? Center(child: CircularProgressIndicator())
  //         : Consumer<CurrentGame>(builder: (context, _gameProvider, _) {
  //             final _userLocation =
  //                 LatLng(snapshot.data.latitude, snapshot.data.longitude);
  //             List<Marker> _markers = [];
  //             _markers.addAll([
  //               ..._gameProvider.flags
  //                   .where((f) => (f.lat != null && f.long != null))
  //                   .map((e) => Marker(
  //                         width: 30.0,
  //                         height: 30.0,
  //                         point: LatLng(e.lat, e.long),
  //                         builder: (ctx) => CustomMarker(
  //                             e.name, e.lat, e.long, MarkerType.commonObj),
  //                       ))
  //             ]);

  //             _markers.addAll([
  //               Marker(
  //                 width: 30.0,
  //                 height: 30.0,
  //                 point:
  //                     LatLng(_userLocation.latitude, _userLocation.longitude),
  //                 builder: (ctx) => CustomMarker('user', _userLocation.latitude,
  //                     _userLocation.longitude, MarkerType.player),
  //               )
  //             ]);
  //             return FlutterMap(
  //               options: MapOptions(
  //                 center: _userLocation,
  //                 zoom: 13.0,
  //                 onLongPress: (value) {
  //                   if (Provider.of<Auth>(context, listen: false).isAdmin ||
  //                       Provider.of<Auth>(context, listen: false).isGameMaster)
  //                     _addNewFlag(value);
  //                 },
  //               ),
  //               layers: [
  //                 TileLayerOptions(
  //                   urlTemplate: _osmUrl,
  //                   // additionalOptions: {
  //                   //   'accessToken':
  //                   //       'pk.eyJ1IjoiZzNudGkiLCJhIjoiY2pyMm03NTRiMDRqZjQzb2xiaDIweGlsZiJ9.gX2EbcqrObKQJI40r8l8OA',
  //                   //   'id': 'mapbox.satellite',
  //                   // }
  //                   subdomains: ['a', 'b', 'c'], // activate for osmUrl
  //                 ),
  //                 MarkerLayerOptions(markers: _markers),
  //               ],
  //             );
  //           }),
  //   );
  // }
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
