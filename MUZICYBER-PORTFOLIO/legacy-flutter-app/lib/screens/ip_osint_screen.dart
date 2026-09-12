import 'package:flutter/material.dart';
import '../models/case_model.dart';
import 'osint_tool_screen.dart';

class IpOsintScreen extends StatelessWidget {
  final CaseModel caseItem;
  const IpOsintScreen({super.key, required this.caseItem});
  @override
  Widget build(BuildContext context) =>
      OsintToolScreen(type: 'ip', caseItem: caseItem);
}
