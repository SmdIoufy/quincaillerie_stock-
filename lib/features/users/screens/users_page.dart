import 'package:flutter/material.dart';
import '../../../core/constants/app-colors.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Gestion des utilisateurs')),
      body: const Center(child: Text('Liste des utilisateurs')),
    );
  }
}
