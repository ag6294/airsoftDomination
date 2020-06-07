import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/game.dart';

import '../widgets/app_drawer.dart';

class SettingsRoute extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsRouteState createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  void _showAdminLogin(
      BuildContext context, Auth authProvider, Game gameProvider) async {
    if (authProvider.isAdmin) {
      setState(
        () {
          authProvider.toggleIsAdmin();
        },
      );
    } else {
      final _formKey = GlobalKey<FormState>();
      var confirm = false;
      confirm = await showDialog<bool>(
        context: context,
        builder: (cx) {
          return AlertDialog(
            title: Text('Password richiesta'),
            content: Column(
              children: <Widget>[
                Text(
                    'Inserisci la password per attivare le funzionalità di amministratore per questa giocata'),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    obscureText: true,
                    autofocus: true,
                    decoration: new InputDecoration(
                      labelText: 'Admin Password',
                    ),
                    validator: (value) {
                      return authProvider.isAdminPasswordValid(
                              gameProvider.gameId, value)
                          ? null
                          : 'Password Errata';
                    },
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Annulla'),
              ),
              FlatButton(
                onPressed: () {
                  if (_formKey.currentState.validate())
                    return Navigator.of(context).pop(true);
                },
                child: Text(
                  'Conferma',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          );
        },
      );

      if (confirm == true) {
        setState(
          () {
            authProvider.toggleIsAdmin();
          },
        );
      }
    }
  }

  void _showGMLogin(
      BuildContext context, Auth authProvider, Game gameProvider) async {
    if (authProvider.isGameMaster) {
      setState(
        () {
          authProvider.toggleisGameMaster();
        },
      );
    } else {
      final _formKey = GlobalKey<FormState>();
      var confirm = false;
      confirm = await showDialog<bool>(
        context: context,
        builder: (cx) {
          return AlertDialog(
            title: Text('Password richiesta'),
            content: Column(
              children: <Widget>[
                Text(
                    'Inserisci la password per attivare le funzionalità di Game Master per questa giocata'),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    obscureText: true,
                    autofocus: true,
                    decoration: new InputDecoration(
                      labelText: 'Game Master Password',
                    ),
                    validator: (value) {
                      return authProvider.isGMPasswordValid(
                              gameProvider.gameId, value)
                          ? null
                          : 'Password Errata';
                    },
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Annulla'),
              ),
              FlatButton(
                onPressed: () {
                  if (_formKey.currentState.validate())
                    return Navigator.of(context).pop(true);
                },
                child: Text(
                  'Conferma',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          );
        },
      );

      if (confirm == true) {
        setState(
          () {
            authProvider.toggleisGameMaster();
          },
        );
      }
    }
  }

  void _showGameLogin(BuildContext context, Auth authProvider,
      Game gameProvider, String gameId, String gameName) async {
    if (gameId == gameProvider.gameId) {
    } else {
      String factionId;

      final _formKey = GlobalKey<FormState>();
      var confirm = false;
      confirm = await showDialog<bool>(
        context: context,
        builder: (cx) {
          return AlertDialog(
            title: Text('Password richiesta'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      'Seleziona una fazione e inserisci la password per partecipare alla giocata'),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          hint: Text('Seleziona una fazione'),
                          items: authProvider
                              .getFactions(gameId)
                              .map((faction) => DropdownMenuItem(
                                  value: faction['id'],
                                  child: Text(faction['name'])))
                              .toList(),
                          onChanged: (value) => factionId = value,
                          validator: (value) =>
                              value == null ? 'Seleziona una fazione' : null,
                        ),
                      ),
                      TextFormField(
                        obscureText: true,
                        // autofocus: true,
                        decoration: new InputDecoration(
                          labelText: 'Password della giocata',
                        ),
                        validator: (value) {
                          return authProvider.isGamePasswordValid(
                                  gameId, factionId, value)
                              ? null
                              : 'Password Errata';
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Annulla'),
              ),
              FlatButton(
                onPressed: () {
                  if (_formKey.currentState.validate())
                    return Navigator.of(context).pop(true);
                },
                child: Text(
                  'Conferma',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          );
        },
      );

      if (confirm == true) {
        setState(
          () {
            if (authProvider.isAdmin) authProvider.toggleIsAdmin();
            if (authProvider.isGameMaster) authProvider.toggleisGameMaster();
            authProvider.setFaction(
                factionId,
                authProvider.getFactions(gameId).firstWhere(
                    (element) => element['id'] == factionId)['name']);
            gameProvider.setNewGame(gameId, gameName);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context, listen: false);
    final gameProvider = Provider.of<Game>(context);

    return FutureBuilder<Map<String, Map<String, dynamic>>>(
      future: authProvider.availableGames,
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(
          title: Text('Impostazioni'),
        ),
        body: snapshot.connectionState != ConnectionState.done
            ? Center(child: CircularProgressIndicator())
            : Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: <Widget>[
                    if (gameProvider.gameId != null)
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Text('Attiva modalità amministratore'),
                            ),
                            Switch.adaptive(
                              value: authProvider.isAdmin,
                              onChanged: (_) => _showAdminLogin(
                                  context, authProvider, gameProvider),
                            )
                          ],
                        ),
                      ),
                    if (gameProvider.gameId != null)
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Text('Attiva modalità Game Master'),
                            ),
                            Switch.adaptive(
                              value: authProvider.isGameMaster,
                              onChanged: (_) => _showGMLogin(
                                  context, authProvider, gameProvider),
                            )
                          ],
                        ),
                      ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: DropdownButton<String>(
                            hint: Text('Seleziona una giocata'),
                            value: gameProvider.gameId != null
                                ? gameProvider.gameId
                                : null,
                            items: snapshot.data
                                .map(
                                  (id, game) => MapEntry(
                                    id,
                                    DropdownMenuItem<String>(
                                      value: id,
                                      child: Text(game['name']),
                                    ),
                                  ),
                                )
                                .values
                                .toList(),
                            onChanged: (newValue) => _showGameLogin(
                                context,
                                authProvider,
                                gameProvider,
                                newValue,
                                snapshot.data[newValue]['name']),
                          ),
                        ),
                        // IconButton(icon: Icon(Icons.save), onPressed: null)
                      ],
                    ),
                    // SizedBox.expand(),
                    Spacer(),
                    if (gameProvider.gameId != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 10),
                        child: FlatButton(
                          onPressed: () async {
                            var confirm = false;
                            confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Attenzione'),
                                content: Text('Sei sicuro?'),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text('Annulla'),
                                  ),
                                  FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      'Conferma',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm) gameProvider.leaveGame();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.exit_to_app),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Lascia la giocata',
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor))
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
        drawer: AppDrawer(),
      ),
    );
  }
}
