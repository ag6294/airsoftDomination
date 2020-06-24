import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:utm/utm.dart';

import '../providers/flag.dart';
import '../providers/current_game.dart';
import '../utils/location.dart';

class NewFlagForm extends StatefulWidget {
  LocationData _initialLocation;

  NewFlagForm([this._initialLocation]);

  @override
  NewFlagFormState createState() => NewFlagFormState();
}

class NewFlagFormState extends State<NewFlagForm> {
  var isLoading = false;

  final _minutesNode = FocusNode();
  final _latNode = FocusNode();
  final _longNode = FocusNode();
  final _utmZoneNode = FocusNode();
  final _utmNorthNode = FocusNode();
  final _utmEastNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  var _isUTM = true;
  var _isConquerable = true;

  UtmCoordinate _utmLocation;
  String _userLat;
  String _userLong;

  Flag _flag = Flag(
      gameId: null,
      id: null,
      name: '',
      isConquerable: true,
      conquerMinutes: 0,
      lat: 0.0,
      long: 0.0);

  @override
  void dispose() {
    _minutesNode.dispose();
    _longNode.dispose();
    _latNode.dispose();
    _utmZoneNode.dispose();
    _utmNorthNode.dispose();
    _utmEastNode.dispose();

    super.dispose();
  }

  void _saveForm(BuildContext ctx) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        setState(() {
          isLoading = true;
        });
        await Provider.of<CurrentGame>(context, listen: false).addFlag(_flag);
        Navigator.of(context).pop();
      } catch (error) {
        showDialog(
          context: ctx,
          builder: (cx) => AlertDialog(
            title: Text('Errore'),
            content: Text('C\'è stato un errore, riprova!'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(cx).pop(),
                child: Text('Chiudi'),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _utmLocation = widget._initialLocation == null
        ? null
        : UTM.fromLatLon(
            lat: widget._initialLocation.latitude,
            lon: widget._initialLocation.longitude);
    _userLat = widget._initialLocation == null
        ? ''
        : widget._initialLocation.latitude.toStringAsFixed(2);
    _userLong = widget._initialLocation == null
        ? ''
        : widget._initialLocation.longitude.toStringAsFixed(2);

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Padding(
        padding: EdgeInsets.all(4),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // shrinkWrap: true,
                  children: <Widget>[
                    TextFormField(
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Titolo',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_minutesNode),
                      onSaved: (value) {
                        _flag = Flag(
                            gameId: _flag.gameId,
                            id: _flag.id,
                            name: value,
                            isConquerable: _isConquerable,
                            conquerMinutes: _flag.conquerMinutes,
                            startConquering: _flag.startConquering,
                            lat: _flag.lat,
                            long: _flag.long);
                      },
                      validator: (value) {
                        if (value == null || value == '')
                          return 'Inserisci un nome';
                        return null;
                      },
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Obiettivo',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              'conquistabile',
                              style: TextStyle(fontSize: 12),
                            ),
                            SizedBox(width: 4),
                            Switch.adaptive(
                                value: _isConquerable,
                                onChanged: (_) => setState(() {
                                      _isConquerable = !_isConquerable;
                                    })),
                          ],
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            enabled: _isConquerable,
                            decoration: InputDecoration(
                              labelText: 'Minuti per la conquista',
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            focusNode: _minutesNode,
                            onFieldSubmitted: (_) => _isUTM
                                ? FocusScope.of(context)
                                    .requestFocus(_utmZoneNode)
                                : FocusScope.of(context).requestFocus(_latNode),
                            onSaved: (value) {
                              _flag = Flag(
                                  gameId: _flag.gameId,
                                  id: _flag.id,
                                  name: _flag.name,
                                  isConquerable: _isConquerable,
                                  conquerMinutes:
                                      _isConquerable ? int.parse(value) : 0,
                                  startConquering: _flag.startConquering,
                                  lat: _flag.lat,
                                  long: _flag.long);
                            },
                            validator: (value) {
                              if ((value == null || value == '') &&
                                  _isConquerable) return 'Inserisci una durata';
                              if ((int.tryParse(value) == null ||
                                      int.tryParse(value) < 0) &&
                                  _isConquerable)
                                return 'Inserisci un numero valido';

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    FlatButton(
                      onPressed: () => setState(() {
                        _isUTM = !_isUTM;
                      }),
                      child: Text(_isUTM
                          ? 'Passa a latitudine e longitudine'
                          : 'Passa a coordinate UTM/WGS84'),
                    ),
                    if (_isUTM)
                      Row(children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            key: ValueKey('utmZone'),
                            decoration: InputDecoration(
                              labelText: 'Zona',
                            ),
                            initialValue: _utmLocation.zone,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            focusNode: _utmZoneNode,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_utmEastNode),
                            onSaved: (value) {
                              _utmLocation = UTM.fromUtm(
                                  easting: _utmLocation.easting,
                                  northing: _utmLocation.northing,
                                  zoneNumber: int.parse(
                                      RegExp(r'\d\d').stringMatch(value)),
                                  zoneLetter:
                                      RegExp(r'[a-zA-Z]').stringMatch(value));
                              _flag = Flag(
                                  gameId: _flag.gameId,
                                  id: _flag.id,
                                  name: _flag.name,
                                  isConquerable: _isConquerable,
                                  conquerMinutes: _flag.conquerMinutes,
                                  startConquering: _flag.startConquering,
                                  lat: _utmLocation.lat,
                                  long: _utmLocation.lon);
                            },
                            validator: (value) {
                              if (value == null || value == '')
                                return 'Inserisci la zona';
                              if (!RegExp(r'^\d\d[a-zA-Z]$').hasMatch(value))
                                return 'Errore';

                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('utmEast'),
                            expands: false,
                            decoration: InputDecoration(
                              labelText: 'EST',
                            ),
                            initialValue:
                                _utmLocation.easting.toStringAsFixed(0),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            focusNode: _utmEastNode,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_longNode),
                            onSaved: (value) {
                              _utmLocation = UTM.fromUtm(
                                  easting: double.parse(value),
                                  northing: _utmLocation.northing,
                                  zoneNumber: _utmLocation.zoneNumber,
                                  zoneLetter: _utmLocation.zoneLetter);
                              _flag = Flag(
                                  gameId: _flag.gameId,
                                  id: _flag.id,
                                  name: _flag.name,
                                  isConquerable: _isConquerable,
                                  conquerMinutes: _flag.conquerMinutes,
                                  startConquering: _flag.startConquering,
                                  lat: _utmLocation.lat,
                                  long: _utmLocation.lon);
                            },
                            validator: (value) {
                              if (value == null || value == '')
                                return 'Inserisci la latitudine';
                              if (double.tryParse(value) == null)
                                return 'Inserisci un numero valido';

                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('utmNorth'),
                            decoration: InputDecoration(
                              labelText: 'NORD',
                            ),
                            initialValue:
                                _utmLocation.northing.toStringAsFixed(0),
                            keyboardType: TextInputType.number,
                            focusNode: _utmNorthNode,
                            onFieldSubmitted: (_) => _saveForm(context),
                            onSaved: (value) {
                              _utmLocation = UTM.fromUtm(
                                  easting: _utmLocation.easting,
                                  northing: double.parse(value),
                                  zoneNumber: _utmLocation.zoneNumber,
                                  zoneLetter: _utmLocation.zoneLetter);
                              _flag = Flag(
                                  gameId: _flag.gameId,
                                  id: _flag.id,
                                  name: _flag.name,
                                  isConquerable: _isConquerable,
                                  conquerMinutes: _flag.conquerMinutes,
                                  startConquering: _flag.startConquering,
                                  lat: _utmLocation.lat,
                                  long: _utmLocation.lon);
                            },
                            validator: (value) {
                              if (value == null || value == '')
                                return 'Inserisci la longitudine';
                              if (double.tryParse(value) == null)
                                return 'Inserisci un numero valido';

                              return null;
                            },
                          ),
                        ),
                      ]),
                    if (!_isUTM)
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('lat'),
                            decoration: InputDecoration(
                              labelText: 'Latitudine',
                            ),
                            initialValue: _userLat,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            focusNode: _latNode,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_longNode),
                            onSaved: (value) {
                              _flag = Flag(
                                  gameId: _flag.gameId,
                                  id: _flag.id,
                                  name: _flag.name,
                                  isConquerable: _isConquerable,
                                  conquerMinutes: _flag.conquerMinutes,
                                  startConquering: _flag.startConquering,
                                  lat: double.parse(value),
                                  long: _flag.long);
                            },
                            validator: (value) {
                              if (value == null || value == '')
                                return 'Inserisci la latitudine';
                              if (double.tryParse(value) == null ||
                                  double.tryParse(value) < -90)
                                return 'Inserisci un numero valido';

                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('long'),
                            decoration: InputDecoration(
                              labelText: 'Longitudine',
                            ),
                            initialValue: _userLong,
                            keyboardType: TextInputType.number,
                            focusNode: _longNode,
                            onFieldSubmitted: (_) => _saveForm(context),
                            onSaved: (value) {
                              _flag = Flag(
                                  gameId: _flag.gameId,
                                  id: _flag.id,
                                  name: _flag.name,
                                  isConquerable: _isConquerable,
                                  conquerMinutes: _flag.conquerMinutes,
                                  startConquering: _flag.startConquering,
                                  lat: _flag.lat,
                                  long: double.parse(value));
                            },
                            validator: (value) {
                              if (value == null || value == '')
                                return 'Inserisci la longitudine';
                              if (double.tryParse(value) == null ||
                                  double.tryParse(value) < -180)
                                return 'Inserisci un numero valido';

                              return null;
                            },
                          ),
                        ),
                      ]),
                    // Spacer(),
                    Container(
                      margin: EdgeInsets.all(0),
                      alignment: Alignment(1, 0),
                      child: Row(
                        children: <Widget>[
                          FlatButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Annulla',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          FlatButton(
                            onPressed: () => _saveForm(context),
                            child: Text(
                              'Salva',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
