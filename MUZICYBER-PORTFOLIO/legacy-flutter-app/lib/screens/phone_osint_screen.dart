import 'package:flutter/material.dart';
import '../models/case_model.dart';
import 'osint_tool_screen.dart';

class PhoneOsintScreen extends StatelessWidget {
  final CaseModel caseItem;
  const PhoneOsintScreen({super.key, required this.caseItem});
  @override
  Widget build(BuildContext context) =>
      OsintToolScreen(type: 'phone', caseItem: caseItem);
}
