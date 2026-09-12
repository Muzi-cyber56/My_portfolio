import 'package:flutter/material.dart';
import '../models/case_model.dart';
import 'osint_tool_screen.dart';

class DomainOsintScreen extends StatelessWidget {
  final CaseModel caseItem;
  const DomainOsintScreen({super.key, required this.caseItem});
  @override
  Widget build(BuildContext context) =>
      OsintToolScreen(type: 'domain', caseItem: caseItem);
}
