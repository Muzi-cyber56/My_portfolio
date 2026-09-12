import 'package:flutter/material.dart';
import '../models/case_model.dart';
import 'evidence_screen.dart';

class ImageAnalysisScreen extends StatelessWidget {
  final CaseModel caseItem;
  const ImageAnalysisScreen({super.key, required this.caseItem});
  @override
  Widget build(BuildContext context) =>
      EvidenceScreen(caseItem: caseItem, imageOnly: true);
}
