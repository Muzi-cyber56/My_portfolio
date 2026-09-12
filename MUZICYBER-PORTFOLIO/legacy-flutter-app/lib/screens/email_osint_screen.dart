import 'package:flutter/material.dart';
import '../models/case_model.dart';
import 'osint_tool_screen.dart';

class EmailOsintScreen extends StatelessWidget {
  final CaseModel caseItem;
  const EmailOsintScreen({super.key, required this.caseItem});
  @override
  Widget build(BuildContext context) =>
      OsintToolScreen(type: 'email', caseItem: caseItem);
}
