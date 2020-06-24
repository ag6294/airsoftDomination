import 'package:airsoft_domination/utils/http_exception.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/firebase.dart' as DB;

class Flag with ChangeNotifier {
  final String gameId;
  final String id;
  final String name;
  final bool isConquerable;
  final int conquerMinutes;

  double lat;
  double long;
  // final bool isConquerable;
  String factionConqueringID;
  String factionConqueringName;
  String lastConquerorFactionId;
  String lastConquerorFactionName;
  DateTime startConquering;

  DateTime creationTime = DateTime.now();

  Flag({
    @required this.gameId,
    @required this.id,
    @required this.name,
    @required this.isConquerable,
    @required this.conquerMinutes,
    // @required this.isConquerable,
    this.factionConqueringID,
    this.factionConqueringName,
    this.startConquering,
    this.lastConquerorFactionId,
    this.lastConquerorFactionName,
    this.lat,
    this.long,
  });

  DateTime get endConquering {
    return startConquering != null
        ? startConquering.add(Duration(minutes: conquerMinutes))
        : DateTime.fromMicrosecondsSinceEpoch(1);
  }

  bool get isFree {
    return factionConqueringID == null;
  }

  bool get isConquered {
    if (factionConqueringID == null && lastConquerorFactionId == null)
      return false;
    return endConquering.isBefore(DateTime.now());
  }

  bool get isBeingConquered {
    if (factionConqueringID == null || startConquering == null) return false;
    return !endConquering.isBefore(DateTime.now());
  }

  Future<void> stopCapture() async {
    try {
      await DB.Firebase.stopCapture(gameId, id);
      await DB.Firebase.sendGameNotification(gameId,
          title: 'Interruzione conquista',
          bodyMessage: 'La conquista del punto $name è stata interrotta');
    } catch (error) {
      throw error;
    }

    factionConqueringID = null;
    factionConqueringName = null;
    startConquering = null;
    notifyListeners();
  }

  Future<void> startCapture(String factionID, String factionName) async {
    if (isConquered) {
      lastConquerorFactionId = factionConqueringID;
      lastConquerorFactionName = factionConqueringName;
    }
    startConquering = DateTime.now();

    try {
      await DB.Firebase.startCapture(this, factionID, factionName);
      await DB.Firebase.sendGameNotification(gameId,
          title: 'Inizio conquista',
          bodyMessage:
              'La fazione $factionName ha iniziato a conquistare il punto $name');
    } catch (error) {
      startConquering = null;
      throw error;
    }

    factionConqueringID = factionID;
    factionConqueringName = factionName;
    notifyListeners();
  }
}
