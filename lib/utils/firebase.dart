import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../providers/flag.dart';
import './http_exception.dart';

class Firebase {
  static const endPoint = 'https://airsoft-domation-svil.firebaseio.com';

  static Future<String> addFlag(Flag flag, String gameId) async {
    final url = Firebase.endPoint + '/flags/$gameId.json';
    final response = await http.post(
      url,
      body: json.encode({
        'name': flag.name,
        'conquerMinutes': flag.conquerMinutes,
      }),
    );

    return json.decode(response.body)['name'];
  }

  static Future<void> removeFlag(String gameId, String flagId) async {
    final url = Firebase.endPoint + '/flags/$gameId/$flagId.json';
    await http.delete(url);

    final response = await http.delete(url);

    if (response.statusCode >= 400)
      throw HttpException('Errore comunicazione con il server');
  }

  static Future<List<Flag>> fetchFlags(String gameId) async {
    List<Flag> _flags = [];

    final url = Firebase.endPoint + '/flags/$gameId.json';

    String id;
    String name;
    int conquerMinutes;
    String factionConqueringID;
    String factionConqueringName;
    DateTime startConquering;
    String lastConquerorFactionId;
    String lastConquerorFactionName;

    try {
      final response = await http.get(url);

      var responseData = json.decode(response.body) as Map<String, dynamic>;

      if (responseData == null)
        _flags = [];
      else {
        responseData.forEach((flagId, flag) {
          id = flagId;
          name = flag['name'];
          conquerMinutes = flag['conquerMinutes'];
          factionConqueringID = flag['factionConqueringID'];
          factionConqueringName = flag['factionConqueringName'];
          startConquering = flag['startConquering'] == null
              ? null
              : DateTime.tryParse(flag['startConquering']);
          lastConquerorFactionId = flag['lastConquerorFactionId'];
          lastConquerorFactionName = flag['lastConquerorFactionName'];
          _flags.add(Flag(
              gameId: gameId,
              id: id,
              name: name,
              conquerMinutes: conquerMinutes,
              factionConqueringID: factionConqueringID,
              factionConqueringName: factionConqueringName,
              startConquering: startConquering,
              lastConquerorFactionId: lastConquerorFactionId,
              lastConquerorFactionName: lastConquerorFactionName));
        });
      }
    } catch (error) {
      throw error;
    }

    return _flags;
  }

  static Future<void> startCapture(
      Flag flag, String factionID, String factionName) async {
    final url = Firebase.endPoint + '/flags/${flag.gameId}/${flag.id}.json';

    var startConquering = DateTime.now();

    try {
      await http.patch(url,
          body: json.encode({
            'factionConqueringID': factionID,
            'factionConqueringName': factionName,
            'startConquering': startConquering.toIso8601String(),
            'lastConquerorFactionId': flag.lastConquerorFactionId,
            'lastConquerorFactionName': flag.lastConquerorFactionName,
          }));
    } catch (error) {
      throw error;
    }
  }

  static Future<void> stopCapture(String gameId, String flagId) async {
    final url = Firebase.endPoint + '/flags/$gameId/$flagId.json';
    try {
      await http.patch(url,
          body: json.encode({
            'factionConqueringID': null,
            'factionConqueringName': null,
            'startConquering': null,
          }));
    } catch (error) {
      throw error;
    }
  }

  static Future<Map<String, Map<String, dynamic>>> getAllGames() async {
    final url = Firebase.endPoint + '/games.json';

    Map<String, Map<String, dynamic>> _games = {};

    try {
      final response = await http.get(url);

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      responseData.forEach((gameId, gameData) {
        _games.addAll({
          gameId: {
            'name': gameData['name'],
            'gamePassword': gameData['gamePassword'],
            'gameMasterPassword': gameData['gameMasterPassword'],
            'adminPassword': gameData['adminPassword'],
            'factions': [
              ...(gameData['factions'] as List<dynamic>)
                  .map<Map<String, String>>((e) => {
                        'id': e['id'],
                        'name': e['name'],
                        'password': e['password'],
                      })
            ]
          }
        });
      });
    } catch (error) {
      throw error;
    }

    return _games;
  }
}
