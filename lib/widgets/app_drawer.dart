import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info/package_info.dart';

import '../routes/domination_route.dart';
import '../routes/settings_route.dart';

import '../providers/auth.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String version = '';

  @override
  Widget build(BuildContext context) {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        version = packageInfo.version;
      });
    });

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
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushReplacementNamed(DominationRoute.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Impostazioni'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushNamed(SettingsRoute.routeName)
                  .then((_) {
                Navigator.of(context)
                    .pushReplacementNamed(DominationRoute.routeName);
              });
            },
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('Versione $version',
                style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }
}
