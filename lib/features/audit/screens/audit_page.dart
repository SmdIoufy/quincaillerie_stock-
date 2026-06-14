import 'package:flutter/material.dart';
import '../../../core/constants/app-colors.dart';

class AuditPage extends StatelessWidget {
  const AuditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Audit système')),
      body: const Center(child: Text("Journal d'audit")),
    );
  }
}
