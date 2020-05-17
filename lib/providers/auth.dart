import 'package:flutter/material.dart';
import 'dart:async';

import '../models/player.dart';
import './mock.dart';

import '../utils/firebase.dart' as DB;

class Auth with ChangeNotifier {
  var _loggedPlayer = Player(
      userId: 'ID1', nickname: 'Hunter', factionId: null, factionName: null);

  bool _isAdmin = false;
  bool _isGameMaster = false;

  Map<String, Map<String, dynamic>> _availableGames;

  /*If i already got available games I update in background, otherwise I wait for them to load */
  Future<Map<String, Map<String, dynamic>>> get availableGames async {
    if (_availableGames != null) {
      print('[AuthProvider] Getting all games async');
      DB.Firebase.getAllGames().then((value) {
        _availableGames = value;
        // notifyListeners();
      });
    } else {
      print('[AuthProvider] Getting all games sync');
      _availableGames = await DB.Firebase.getAllGames();
    }
    return Map.from(_availableGames);
  }

  Player get loggedPlayer {
    return _loggedPlayer;
  }

  bool get isAdmin {
    return _isAdmin;
  }

  bool isAdminPasswordValid(String gameId, String password) {
    return _availableGames[gameId]['adminPassword'] == password;
  }

  bool isGMPasswordValid(String gameId, String password) {
    return _availableGames[gameId]['gameMasterPassword'] == password;
  }

  bool isGamePasswordValid(
    String gameId,
    String factionId,
    String password,
  ) {
    if (factionId == null) return false;
    final faction =
        (_availableGames[gameId]['factions'] as List<Map<String, String>>)
            .firstWhere((element) => element['id'] == factionId);

    return faction['password'] == password;
  }

  List<Map<String, String>> getFactions(String gameId) {
    return [
      ..._availableGames[gameId]['factions'] as List<Map<String, String>>
    ];
  }

  void setFaction(String factionId, String factionName){
    _loggedPlayer = Player(
      userId: _loggedPlayer.userId, nickname: _loggedPlayer .nickname, factionId: factionId, factionName:factionName);
  }

  void toggleIsAdmin() {
    _isAdmin = !isAdmin;
    notifyListeners();
  }

  bool get isGameMaster {
    return _isGameMaster;
  }

  void toggleisGameMaster() {
    _isGameMaster = !isGameMaster;
    notifyListeners();
  }
}
