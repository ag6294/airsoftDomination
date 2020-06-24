import 'package:flutter/material.dart';

import './faction.dart';

class Game {
  final String id;
  final String name;
  final String description;
  final String gamePassword;
  final String gameMasterPassword;
  final String adminPassword;
  final List<Faction> factions;

  Game(
      {@required this.id,
      this.description,
      this.name,
      this.gamePassword,
      this.gameMasterPassword,
      this.adminPassword,
      this.factions});
}
