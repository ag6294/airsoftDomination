import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

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

  static Future<void> sendGameNotification(String gameId,
      {String bodyMessage, String title}) async {
    final String serverToken =
        'AAAAUjxSYw8:APA91bFkCyC6pp_okaIVNo1q3dK-e3xO8uPd3vGD5-WQRxAazptzwRcF8i1Wh83P9LnDyqoVah632oSFc0xUqlI6ZSfMSabcR45n0kC5jZag_w9p-CbMOvALWhGNj5roWgErCEHZLV_Z';
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

    await firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );

    firebaseMessaging.subscribeToTopic(gameId);

    final response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          // 'to': await firebaseMessaging.getToken(),
          'condition': '\'$gameId\' in topics',
          'notification': <String, dynamic> {
            'body': bodyMessage != null
                ? bodyMessage
                : 'C\'è stato un aggiornamento',
            'title': title != null ? title : 'Aggiornamento'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
        },
      ),
    );

    // print(response.body);

    // final Completer<Map<String, dynamic>> completer =
    //     Completer<Map<String, dynamic>>();

    // firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     completer.complete(message);
    //   },
    // );

    // return completer.future;

    return null;
  }
}
