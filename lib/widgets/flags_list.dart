import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game.dart';
import '../providers/flag.dart';
import './flag_tile.dart';

class FlagsList extends StatefulWidget {
  @override
  _FlagsListState createState() => _FlagsListState();
}

class _FlagsListState extends State<FlagsList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<Game>(context);
    final flags = gameProvider.flags;

    return ListView.builder(
      itemBuilder: (context, index) {
        return ChangeNotifierProvider<Flag>.value(
          value: flags[index],
          child: FlagTile(),
        );
      },
      itemCount: flags.length,
    );
  }
}
