import 'package:flutter/material.dart';
import 'pages/auth_page.dart';
import 'pages/dashboard_page.dart';
import 'services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Universités',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: FutureBuilder<bool>(
        future: _authService.loadAuthData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.data == true && _authService.isAuthenticated) {
            return DashboardPage(authService: _authService);
          }
          
          return AuthPage();
        },
      ),
    );
  }
}