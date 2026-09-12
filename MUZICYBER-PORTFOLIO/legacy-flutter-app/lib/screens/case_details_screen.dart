import 'package:flutter/material.dart';
import '../models/case_model.dart';
import '../models/finding.dart';
import '../services/case_service.dart';
import '../config/app_config.dart';
import '../widgets/loading_widget.dart';
import '../widgets/finding_card.dart';
import 'new_case_screen.dart';

class CaseDetailsScreen extends StatefulWidget {
  final CaseModel caseItem;
  final VoidCallback onChanged;
  final ValueChanged<String> onTool;
  const CaseDetailsScreen({
    super.key,
    required this.caseItem,
    required this.onChanged,
    required this.onTool,
  });
  @override
  State<CaseDetailsScreen> createState() => _CaseDetailsScreenState();
}

class _CaseDetailsScreenState extends State<CaseDetailsScreen> {
  late Future<List<Finding>> _findings;
  @override
  void initState() {
    super.initState();
    _findings = CaseService().findings(widget.caseItem.id);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionTitle(
        widget.caseItem.title,
        widget.caseItem.caseNumber,
        trailing: OutlinedButton.icon(
          onPressed: () async {
            final result = await showDialog<CaseModel>(
              context: context,
              builder: (_) => NewCaseScreen(existing: widget.caseItem),
            );
            if (result != null) widget.onChanged();
          },
          icon: const Icon(Icons.edit_outlined, size: 17),
          label: const Text('Edit case'),
        ),
      ),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              children: [
                Chip(label: Text(widget.caseItem.status)),
                Chip(label: Text('${widget.caseItem.priority} priority')),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              widget.caseItem.description.isEmpty
                  ? 'No scope notes added yet.'
                  : widget.caseItem.description,
              style: const TextStyle(color: AppConfig.muted),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => widget.onTool('tools'),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Investigate'),
                ),
                OutlinedButton.icon(
                  onPressed: () => widget.onTool('evidence'),
                  icon: const Icon(Icons.shield_outlined, size: 18),
                  label: const Text('View evidence'),
                ),
                OutlinedButton.icon(
                  onPressed: () => widget.onTool('reports'),
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('Reports'),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 28),
      Text('Recorded findings', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 16),
      FutureBuilder<List<Finding>>(
        future: _findings,
        builder: (context, s) {
          if (s.hasError) {
            return ErrorPanel(
              error: s.error!,
              retry: () => setState(
                () => _findings = CaseService().findings(widget.caseItem.id),
              ),
            );
          }
          if (!s.hasData) return const LoadingWidget();
          if (s.data!.isEmpty) {
            return const EmptyState(
              title: 'A new investigation starts here',
              description: 'Choose an OSINT tool to record your first finding.',
              icon: Icons.manage_search,
            );
          }
          return Column(
            children: s.data!.map((f) => FindingCard(finding: f)).toList(),
          );
        },
      ),
      const SizedBox(height: 24),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Delete empty case?'),
                content: const Text(
                  'Only a case with no findings, evidence or reports can be deleted.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(c, true),
                    child: const Text('Delete case'),
                  ),
                ],
              ),
            );
            if (confirmed != true) return;
            try {
              await CaseService().delete(widget.caseItem.id);
              widget.onChanged();
            } catch (e) {
              if (context.mounted) showMessage(context, e);
            }
          },
          icon: const Icon(Icons.delete_outline, size: 17),
          label: const Text('Delete empty case'),
        ),
      ),
    ],
  );
}
