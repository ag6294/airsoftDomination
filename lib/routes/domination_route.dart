import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/flags_list.dart';
import '../widgets/app_drawer.dart';
import '../widgets/map_view.dart';
import '../providers/auth.dart';
import '../providers/current_game.dart';
import '../routes/edit_flags.dart';

class DominationRoute extends StatefulWidget {
  static const routeName = '/domination';

  @override
  _DominationRouteState createState() => _DominationRouteState();
}

class _DominationRouteState extends State<DominationRoute> {
  final List<Map<String, Object>> _tabs = [
    {
      'tab': FlagsList(),
      'title': 'Dominio',
    },
    {
      'tab': MapView(),
      'title': 'Mappa',
    },
  ];

  var _selectedTab = 0;

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context, listen: false);
    final gameProvider = Provider.of<CurrentGame>(context, listen: false);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_tabs[_selectedTab]['title']),
          actions: <Widget>[
            authProvider.isAdmin &&
                    gameProvider.gameId != null &&
                    _selectedTab == 0
                ? IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => Navigator.of(context)
                        .pushNamed(EditFlagsRoute.routeName))
                : Container(),
          ],
        ),
        body: gameProvider.gameId != null
            ? FutureBuilder(
                future: gameProvider.fetchFlags(),
                builder: (ctx, snapshot) =>
                    snapshot.connectionState != ConnectionState.done
                        ? Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: gameProvider.refreshFlags,
                            child: _tabs[_selectedTab]['tab']),
              )
            : Center(
                child: Text('Seleziona una giocata per cominciare'),
              ),
        drawer: AppDrawer(),
        bottomNavigationBar: BottomNavigationBar(
            onTap: _selectTab,
            currentIndex: _selectedTab,
            type: BottomNavigationBarType.shifting,
            backgroundColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            selectedItemColor: Theme.of(context).accentColor,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.flag),
                title: Text('Waypoints'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                title: Text('Mappa'),
              ),
            ]),
      ),
    );
  }
}
