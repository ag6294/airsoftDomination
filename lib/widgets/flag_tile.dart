import 'package:airsoft_domination/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/flag.dart';

class FlagTile extends StatefulWidget {
  @override
  _FlagTileState createState() => _FlagTileState();
}

class _FlagTileState extends State<FlagTile> {
  Flag flagProvider;
  Auth authProvider;
  var isLoading = false;

  void _startTimer() async {
    // print('Start timer');
    while (flagProvider.isBeingConquered) {
      await new Future.delayed(const Duration(seconds: 1));
      // print('Tic Toc');
      if (this.mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<Auth>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    flagProvider = Provider.of<Flag>(context);
    _startTimer();
    super.didChangeDependencies();
  }

  void _stopCapture(BuildContext context, Flag flag) async {
    var confirm = false;
    confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Attenzione'),
        content: Text('Sei sicuro?'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annulla'),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Conferma',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm) {
      setState(() {
        isLoading = true;
      });
      try {
        await flag.stopCapture();
      } catch (error) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erore'),
            content: Text('C\'è stato un errore. Riprova!'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Chiudi'),
              )
            ],
          ),
        );
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void _startCapture(BuildContext context, Flag flag) async {
    var confirm = false;
    confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Attenzione'),
        content: Text('Sei sicuro?'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annulla'),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Conferma',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm) {
      setState(() {
        isLoading = true;
      });
      try {
        await flag.startCapture(authProvider.loggedPlayer.factionId,
            authProvider.loggedPlayer.factionName);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erore'),
            content: Text('C\'è stato un errore. Riprova!'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Chiudi'),
              )
            ],
          ),
        );
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildFreeFlagContent(Flag flag) {
    return Row(
      children: <Widget>[
        Flexible(
          child: Text(
              'Il punto ${flag.name} non è stato conquistato da nessuna fazione'),
        ),
        if (authProvider.isGameMaster)
          isLoading
              ? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CircularProgressIndicator(),
                )
              : IconButton(
                  icon: Icon(Icons.outlined_flag),
                  onPressed: () => _startCapture(context, flag))
      ],
    );
  }

  Widget _buildFlagConqueredContent(Flag flag) {
    var factionName = flag.lastConquerorFactionName != null
        ? flag.lastConquerorFactionName
        : flag.factionConqueringName;
    return Row(
      children: <Widget>[
        Flexible(
          child: Text(
              'Il punto ${flag.name} è stato conquistato dalla fazione $factionName'),
        ),
        if (authProvider.isGameMaster)
          isLoading
              ? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CircularProgressIndicator(),
                )
              : IconButton(
                  icon: Icon(Icons.outlined_flag),
                  onPressed: () => _startCapture(context, flag))
      ],
    );
  }

  Widget _buildFlagBeingConqueredContent(BuildContext context, Flag flag) {
    return Container(
        child: Row(
      children: <Widget>[
        Flexible(
          child: Text(
            'Il punto ${flag.name} è sotto conquista dalla fazione ${flag.factionConqueringName}',
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Counter(flag.endConquering.difference(DateTime.now())),
        if (authProvider.isGameMaster)
          isLoading
              ? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CircularProgressIndicator(),
                )
              : IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () => _stopCapture(context, flag))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 6.0,
      child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Consumer<Flag>(
            builder: (context, flag, _) => flag.isFree
                ? _buildFreeFlagContent(flag)
                : flag.isConquered
                    ? _buildFlagConqueredContent(flag)
                    : _buildFlagBeingConqueredContent(context, flag),
          )),
    );
  }
}

class Counter extends StatelessWidget {
  final Duration duration;
  final int _minutes;
  final int _seconds;

  Counter(this.duration)
      : this._minutes = duration.inMinutes,
        this._seconds = duration.inSeconds;

  String get _minutesString {
    var result = '';

    if (_minutes < 10)
      result = '0$_minutes';
    else
      result = _minutes.toString();

    return result;
  }

  String get _secondsString {
    var result = '';
    var actSeconds = _seconds - _minutes * 60;

    if (actSeconds < 10)
      result = '0$actSeconds';
    else
      result = actSeconds.toString();

    return result.toString();
  }

  String get timerString {
    return _minutes < 100 ? '$_minutesString:$_secondsString' : '99+';
  }

  @override
  Widget build(BuildContext context) {
    // print('$_minutesString:$_secondsString');
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '$_minutesString:$_secondsString',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
    );
  }
}
