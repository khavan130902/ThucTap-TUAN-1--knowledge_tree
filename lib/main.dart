import 'package:flutter/material.dart';
import 'tree_page.dart';
import 'login_page.dart';
import 'register_page.dart';

void main() {
  runApp(const KnowledgeTreeApp());
}

class KnowledgeTreeApp extends StatelessWidget {
  const KnowledgeTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cây Tri Thức',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0077BB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0077BB)),
      ),
      // ✅ Chạy từ LoginPage đầu tiên
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/tree': (context) => const TreePage(),
      },
    );
  }
}
