import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';

import '../providers/game.dart';
import '../providers/flag.dart';
import '../widgets/new_flag_form.dart';
import '../utils/location.dart';

class EditFlagsRoute extends StatefulWidget {
  static const routeName = '/editFlags';

  @override
  _EditFlagsRouteState createState() => _EditFlagsRouteState();
}

class _EditFlagsRouteState extends State<EditFlagsRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Modifica gli obiettivi'),
        ),
        body: _FlagsEditList(),
        floatingActionButton: _NewFlagFAB());
  }
}

class _FlagsEditList extends StatefulWidget {
  @override
  __FlagsEditListState createState() => __FlagsEditListState();
}

class __FlagsEditListState extends State<_FlagsEditList> {
  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<Game>(context);
    final flags = gameProvider.flags;

    return flags.length > 0
        ? Container(
            child: ListView.builder(
              itemCount: flags.length,
              itemBuilder: (context, index) => _FlagListTile(
                  flags[index].id, flags[index].name, gameProvider),
            ),
          )
        : Center(
            child: Text('Aggiungi una nuova bandiera per cominciare!'),
          );
  }
}

class _FlagListTile extends StatelessWidget {
  final String flagId;
  final String flagName;
  final Game gameProvider;

  _FlagListTile(this.flagId, this.flagName, this.gameProvider);

  void _deleteFlag(BuildContext ctx) async {
    try {
      await gameProvider.removeFlag(flagId);
    } catch (error) {
      // Scaffold.of(ctx).showSnackBar(
      //   SnackBar(
      //     content: Text('C\'è stato un errore, riprova!'),
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(flagId),
      title: Text(flagName),
      trailing: IconButton(
          icon: Icon(Icons.delete), onPressed: () => _deleteFlag(context)),
    );
  }
}

class _NewFlagFAB extends StatefulWidget {
  @override
  __NewFlagFABState createState() => __NewFlagFABState();
}

class __NewFlagFABState extends State<_NewFlagFAB> {
  void _showAddFlagModal(BuildContext context) async {
    LocationData _userLocation = await LocationUtils.getCurrentUserLocation();
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: NewFlagForm(_userLocation),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => _showAddFlagModal(context),
    );
  }
}
