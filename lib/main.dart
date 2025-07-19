import 'package:flutter/material.dart';
import 'Adminlar.dart';
import 'Buyurtma_yaratish.dart';
import 'Page/AdminListPage.dart';
import 'Page/Login.dart';
import 'TTT.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yangi buyurtma',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:  AdminScreen(),
    );
  }
}
