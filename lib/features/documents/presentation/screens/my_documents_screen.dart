import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agenda_escolar_adventista/core/router/app_routes.dart';
import 'package:agenda_escolar_adventista/core/theme/app_colors.dart';

class MyDocumentsScreen extends StatelessWidget {
  const MyDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mis documentos')),
      body: const Center(child: Text('Lista de documentos')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => context.push(AppRoutes.uploadDocument),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
