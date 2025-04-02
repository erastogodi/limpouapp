import 'package:flutter/material.dart';
import 'package:limpou25k/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:limpou25k/providers/auth_provider.dart';
import 'package:limpou25k/providers/services_provider.dart';
import 'package:limpou25k/utils/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:limpou25k/providers/property_provider.dart';
import 'package:limpou25k/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Limpou',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white70,
        ),
      ),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
