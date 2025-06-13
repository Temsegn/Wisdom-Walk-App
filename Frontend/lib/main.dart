import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/socket_provider.dart';
import 'package:wisdomwalk/screens/splash_screen.dart';
import 'package:wisdomwalk/utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SocketProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'WisdomWalk',
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
