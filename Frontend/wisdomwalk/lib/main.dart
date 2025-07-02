import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wisdomwalk/providers/chat_provider.dart';
import 'package:wisdomwalk/providers/event_provider.dart' show EventProvider;
import 'package:wisdomwalk/providers/notification_provider.dart';
import 'package:wisdomwalk/routing/app_routing.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/prayer_provider.dart';
import 'package:wisdomwalk/providers/wisdom_circle_provider.dart';
import 'package:wisdomwalk/providers/anonymous_share_provider.dart';
import 'package:wisdomwalk/providers/her_move_provider.dart';
import 'package:wisdomwalk/themes/app_theme.dart';
import 'package:wisdomwalk/providers/reflection_provider.dart';
import 'package:wisdomwalk/services/chat_service.dart';
import 'package:wisdomwalk/providers/user_provider.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider(context)),
        ChangeNotifierProvider(create: (_) => WisdomCircleProvider()),
        ChangeNotifierProvider(create: (_) => AnonymousShareProvider()),
        ChangeNotifierProvider(create: (_) => HerMoveProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ReflectionProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (_) => MessageProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'WisdomWalk',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: authProvider.themeMode,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
