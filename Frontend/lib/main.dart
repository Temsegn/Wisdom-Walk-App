import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/chat_provider.dart';
import 'package:wisdomwalk/providers/confession_provider.dart';
import 'package:wisdomwalk/providers/location_provider.dart';
import 'package:wisdomwalk/providers/post_provider.dart';
import 'package:wisdomwalk/providers/prayer_provider.dart';
import 'package:wisdomwalk/providers/socket_provider.dart';
import 'package:wisdomwalk/providers/theme_provider.dart';
import 'package:wisdomwalk/screens/anonymous_share_screen.dart';
import 'package:wisdomwalk/screens/chat_list_screen.dart';
import 'package:wisdomwalk/screens/chat_screen.dart';
import 'package:wisdomwalk/screens/feed_screen.dart';
import 'package:wisdomwalk/screens/group_chat_screen.dart';
import 'package:wisdomwalk/screens/group_detail_screen.dart';
import 'package:wisdomwalk/screens/groups_screen.dart';
import 'package:wisdomwalk/screens/her_move_screen.dart';
import 'package:wisdomwalk/screens/home_screen.dart';
import 'package:wisdomwalk/screens/login_screen.dart';
import 'package:wisdomwalk/screens/post_detail_screen.dart';
import 'package:wisdomwalk/screens/prayer_wall_screen.dart';
import 'package:wisdomwalk/screens/profile_screen.dart';
import 'package:wisdomwalk/screens/settings_screen.dart';
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<AuthProvider, SocketProvider>(
          create: (_) => SocketProvider(),
          update: (_, auth, socketProvider) => socketProvider!..updateAuth(auth),
        ),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => ConfessionProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'WisdomWalk',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/feed': (context) => const FeedScreen(),
              '/prayer-wall': (context) => const PrayerWallScreen(),
              '/anonymous-share': (context) => const AnonymousShareScreen(),
              '/her-move': (context) => const HerMoveScreen(),
              '/chats': (context) => const ChatListScreen(),
              '/groups': (context) => const GroupsScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/chat') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => ChatScreen(userId: args['userId']),
                );
              } else if (settings.name == '/group-detail') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => GroupDetailScreen(groupId: args['groupId']),
                );
              } else if (settings.name == '/group-chat') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => GroupChatScreen(groupId: args['groupId']),
                );
              } else if (settings.name == '/post-detail') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => PostDetailScreen(postId: args['postId']),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
