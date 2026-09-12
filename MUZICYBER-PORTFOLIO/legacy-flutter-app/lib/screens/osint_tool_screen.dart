import 'package:flutter/material.dart';
import '../models/case_model.dart';
import '../models/finding.dart';
import '../services/osint_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/finding_card.dart';
import '../config/app_config.dart';

class OsintToolScreen extends StatefulWidget {
  final String type;
  final CaseModel caseItem;
  const OsintToolScreen({
    super.key,
    required this.type,
    required this.caseItem,
  });
  @override
  State<OsintToolScreen> createState() => _OsintToolScreenState();
}

class _OsintToolScreenState extends State<OsintToolScreen> {
  final _form = GlobalKey<FormState>(), _input = TextEditingController();
  bool _busy = false;
  String? _error, _notice;
  List<Finding>? _findings;
  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
      _findings = null;
      _notice = null;
    });
    try {
      final r = await OsintService().lookup(
        widget.type,
        widget.caseItem.id,
        _input.text.trim(),
      );
      if (mounted) {
        setState(() {
          _findings = (r['findings'] as List)
              .map((j) => Finding.fromJson(j))
              .toList();
          _notice = r['notice'];
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tool = toolDefinitions.firstWhere((t) => t.id == widget.type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(tool.name, tool.description),
        Panel(
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(tool.icon, color: AppConfig.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Investigating • ${widget.caseItem.caseNumber}',
                        style: const TextStyle(color: AppConfig.muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _input,
                  validator: Validators.required,
                  maxLength: 254,
                  decoration: InputDecoration(
                    labelText:
                        '${widget.type[0].toUpperCase()}${widget.type.substring(1)} to investigate',
                    hintText: tool.hint,
                  ),
                  onFieldSubmitted: (_) => _busy ? null : _run(),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomButton(
                    label: 'Run investigation',
                    onPressed: _run,
                    icon: Icons.search,
                    busy: _busy,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Results are saved to this case. Public profile and registration links need manual verification.',
                  style: TextStyle(color: AppConfig.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_error != null) ErrorPanel(error: _error!, retry: _run),
        if (_findings != null) ...[
          Text(
            '${_findings!.length} findings recorded',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ..._findings!.map((f) => FindingCard(finding: f)),
          Text(
            _notice ?? '',
            style: const TextStyle(color: AppConfig.muted, fontSize: 12),
          ),
        ],
        if (_findings == null && !_busy && _error == null)
          const EmptyState(
            title: 'Start with a lead',
            description: 'Enter a value above to run an investigation.',
            icon: Icons.travel_explore,
          ),
      ],
    );
  }
}
