import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import './routes/domination_route.dart';
import './routes/settings_route.dart';
import './routes/edit_flags.dart';

import './providers/auth.dart';
import './providers/game.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (_) => Auth(),

          
        ),
        ChangeNotifierProxyProvider<Auth, Game>(create: (context) {
          print('Create game provider');
          return Game();
        }, update: (context, authProvider, prevGameProvider) {
          print(
              'Update proxy game provider with user ${authProvider.loggedPlayer.nickname}');
          return Game.update(authProvider.loggedPlayer, prevGameProvider);
        }),
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.lime,
            fontFamily: GoogleFonts.lato().fontFamily,
            textTheme: GoogleFonts.latoTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          home: DominationRoute(),
          routes: {
            DominationRoute.routeName: (context) => DominationRoute(),
            SettingsRoute.routeName: (context) => SettingsRoute(),
            EditFlagsRoute.routeName: (context) => EditFlagsRoute(),
          }),
    );
  }
}
