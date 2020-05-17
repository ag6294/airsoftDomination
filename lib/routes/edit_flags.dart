import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game.dart';
import '../providers/flag.dart';

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
  void _showAddFlagModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BottomSheet(
        onClosing: () {},
        builder: (context) => Container(
          // height: 300,
          child: _NewFlagForm(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => _showAddFlagModal(context),
    );
  }
}

class _NewFlagForm extends StatefulWidget {
  @override
  __NewFlagFormState createState() => __NewFlagFormState();
}

class __NewFlagFormState extends State<_NewFlagForm> {
  var isLoading = false;

  final _minutesNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  Flag _flag = Flag(gameId: null, id: null, name: '', conquerMinutes: 0);

  @override
  void dispose() {
    _minutesNode.dispose();
    super.dispose();
  }

  void _saveForm(BuildContext ctx) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        setState(() {
          isLoading = true;
        });
        await Provider.of<Game>(context, listen: false).addFlag(_flag);
        Navigator.of(context).pop();
      } catch (error) {
        showDialog(
          context: ctx,
          builder: (cx) => AlertDialog(
            title: Text('Errore'),
            content: Text('C\'è stato un errore, riprova!'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(cx).pop(),
                child: Text('Chiudi'),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Titolo',
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_minutesNode),
                    onSaved: (value) {
                      _flag = Flag(
                          gameId: _flag.gameId,
                          id: _flag.id,
                          name: value,
                          conquerMinutes: _flag.conquerMinutes,
                          startConquering: _flag.startConquering);
                    },
                    validator: (value) {
                      if (value == null || value == '')
                        return 'Inserisci un nome';
                      return null;
                    },
                  ),
                  TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Minuti per la conquista',
                      ),
                      keyboardType: TextInputType.number,
                      focusNode: _minutesNode,
                      onFieldSubmitted: (_) => _saveForm(context),
                      onSaved: (value) {
                        _flag = Flag(
                            gameId: _flag.gameId,
                            id: _flag.id,
                            name: _flag.name,
                            conquerMinutes: int.parse(value),
                            startConquering: _flag.startConquering);
                      },
                      validator: (value) {
                        if (value == null || value == '')
                          return 'Inserisci una durata';
                        if (int.tryParse(value) == null ||
                            int.tryParse(value) < 0)
                          return 'Inserisci un numero valido';

                        return null;
                      }),
                  Container(
                    margin: EdgeInsets.all(12),
                    alignment: Alignment(1, 0),
                    child: FlatButton(
                        onPressed: () => _saveForm(context),
                        child: Text(
                          'Salva',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        )),
                  )
                ],
              ),
            ),
    );
  }
}
