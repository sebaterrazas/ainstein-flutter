import 'package:flutter/material.dart';
import 'views/home.dart';
import 'views/chat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 88, 88, 88),
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          iconTheme: IconThemeData(
            color: Colors.white, // Cambia 'green' por el color que prefieras.
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black, primary: const Color.fromARGB(255, 88, 88, 88), secondary: const Color.fromARGB(255, 231, 231, 231) ),
        useMaterial3: true,
      ),
      home: const ChatView(),
    );
  }
}
