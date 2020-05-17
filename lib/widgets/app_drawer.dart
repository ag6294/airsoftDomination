import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes/domination_route.dart';
import '../routes/settings_route.dart';

import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text(
                'Fazione ${Provider.of<Auth>(context, listen: false).loggedPlayer.factionName}'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.flag),
            title: Text('Dominio'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(DominationRoute.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Impostazioni'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(SettingsRoute.routeName);
              // Navigator.of(context).pushReplacement(
              //   CustomRoute(
              //     builder: (ctx) => OrdersScreen(),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }
}
