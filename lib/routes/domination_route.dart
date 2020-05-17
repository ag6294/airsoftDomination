import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/flags_list.dart';
import '../widgets/app_drawer.dart';
import '../providers/auth.dart';
import '../providers/game.dart';
import '../routes/edit_flags.dart';

class DominationRoute extends StatelessWidget {
  static const routeName = '/domination';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context, listen: false);
    final gameProvider = Provider.of<Game>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dominio'),
        actions: <Widget>[
          authProvider.isAdmin && gameProvider.gameId != null
              ? IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(EditFlagsRoute.routeName))
              : Container(),
        ],
      ),
      body: gameProvider.gameId != null
          ? FutureBuilder(
              future: gameProvider.fetchFlags(),
              builder: (ctx, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: gameProvider.refreshFlags,
                          child: FlagsList()),
            )
          : Center(
              child: Text('Seleziona una giocata per cominciare'),
            ),
      drawer: AppDrawer(),
    );
  }
}
