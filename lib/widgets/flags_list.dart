import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/current_game.dart';
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
  void didChangeDependencies() {
    setState(() {
      
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<CurrentGame>(context);
    final flags = gameProvider.flags.where((e) => e.isConquerable == null ? true : e.isConquerable).toList();

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
