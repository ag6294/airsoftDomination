import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import './utils/theme.dart';
import './routes/domination_route.dart';
import './routes/settings_route.dart';
import './routes/edit_flags.dart';

import './providers/auth.dart';
import './providers/current_game.dart';
import './providers/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (_) => Auth(),
        ),
        ChangeNotifierProvider<UserLocation>(
            create: (_) => UserLocation()),
        ChangeNotifierProxyProvider<Auth, CurrentGame>(create: (context) {
          print('Create game provider');
          return CurrentGame();
        }, update: (context, authProvider, prevGameProvider) {
          print(
              'Update proxy game provider with user ${authProvider.loggedPlayer.nickname}');
          return CurrentGame.update(
              authProvider.loggedPlayer, prevGameProvider);
        }),
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: ThemeUtils.rangerGreen,
            fontFamily: GoogleFonts.lato().fontFamily,
            textTheme: GoogleFonts.latoTextTheme(
              Theme.of(context).textTheme,
            ),
            primaryColorBrightness: Brightness.dark,
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
