import 'package:airsoft_domination/models/player.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import './flag.dart';
import './mock.dart';
import '../utils/firebase.dart' as DB;

class CurrentGame with ChangeNotifier {
  Player _loggedPlayer;

  String _gameName;
  String _gameId;

  List<Flag> _flags = [];



  CurrentGame();

  CurrentGame.update(Player loggedPlayer, CurrentGame prevGame) {
    _loggedPlayer = loggedPlayer;
    _gameId = prevGame.gameId;
    _gameName = prevGame.gameName;
    _flags = List.from(prevGame.flags);
  }

  String get gameId {
    return _gameId;
  }

  String get gameName {
    return _gameName;
  }

  List<Flag> get flags {
    return _flags.length > 0 ? [..._flags] : [];
  }

  Future<void> addFlag(Flag flag) async {
    final flagId = await DB.Firebase.addFlag(flag, gameId);

    _flags.add(Flag(
      gameId: gameId,
      id: flagId,
      name: flag.name,
      isConquerable: flag.isConquerable,
      conquerMinutes: flag.conquerMinutes,
      lat: flag.lat,
      long: flag.long,
    ));

    notifyListeners();
  }

  Future<void> removeFlag(String flagId) async {
    var _safeFlag = _flags.firstWhere((flag) => flag.id == flagId);

    _flags.removeWhere((flag) => flag.id == flagId);
    notifyListeners();

    try {
      await DB.Firebase.removeFlag(gameId, flagId);
    } catch (error) {
      flags.add(_safeFlag);
      notifyListeners();
      throw error;
    }
  }

  void setNewGame(String newGameId, String newGameName) {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    if (_gameId != null) _firebaseMessaging.unsubscribeFromTopic(_gameId);
    _gameId = newGameId;
    _gameName = newGameName;
    _flags = [];

    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onLaunch: (notification) {
        print(notification);
        return;
      },
      onResume: (notification) {
        print(notification);
        return;
      },
      onMessage: (notification) {
        print(notification);
        refreshFlags();
        return;
      },
    );
    _firebaseMessaging.subscribeToTopic(_gameId);
    notifyListeners();
  }

  Future<void> fetchFlags() async {
    if (flags.isNotEmpty) return;

    print('[GameProvider] Loading $gameName');
    try {
      _flags = await DB.Firebase.fetchFlags(gameId);
    } catch (error) {
      _flags = [];
      throw error;
    } finally {
      notifyListeners();
    }
  }

//TO DO close Stream on Dispose
  Future<void> refreshFlags() async {
    print('[GameProvider] Refreshing flags for game $gameId $gameName');

    try {
      _flags = List.from(await DB.Firebase.fetchFlags(gameId));
    } catch (error) {
      _flags = [];
      // throw error;
    } finally {
      notifyListeners();
    }
  }

  void leaveGame() {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    _firebaseMessaging.deleteInstanceID();
    if (_gameId != null) _firebaseMessaging.unsubscribeFromTopic(_gameId);

    _gameName = null;
    _gameId = null;

    _flags = [];

    notifyListeners();
  }
}
