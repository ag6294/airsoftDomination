import 'package:flutter/foundation.dart';

class Player {
  final String userId;
  final String nickname;
  final String factionId;
  final String factionName;

  Player(
      {@required this.userId,
      @required this.nickname,
      @required this.factionId,
      @required this.factionName});
}
