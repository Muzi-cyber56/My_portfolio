import 'package:flutter/material.dart';
import '../models/case_model.dart';
import '../services/case_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';

class NewCaseScreen extends StatefulWidget {
  final CaseModel? existing;
  const NewCaseScreen({super.key, this.existing});
  @override
  State<NewCaseScreen> createState() => _NewCaseScreenState();
}

class _NewCaseScreenState extends State<NewCaseScreen> {
  final _form = GlobalKey<FormState>(),
      _title = TextEditingController(),
      _description = TextEditingController();
  String _priority = 'Normal', _status = 'Open';
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    if (c != null) {
      _title.text = c.title;
      _description.text = c.description;
      _priority = c.priority;
      _status = c.status;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final data = {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'priority': _priority,
        'status': _status,
      };
      final result = widget.existing == null
          ? await CaseService().create(data)
          : await CaseService().update(widget.existing!.id, data);
      if (mounted) Navigator.pop(context, result);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 540),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.existing == null ? 'Open a new case' : 'Edit case',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: _busy ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Keep your findings, evidence and reports together.'),
              const SizedBox(height: 24),
              TextFormField(
                controller: _title,
                validator: Validators.title,
                maxLength: 160,
                decoration: const InputDecoration(labelText: 'Case title'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _description,
                maxLines: 3,
                maxLength: 4000,
                decoration: const InputDecoration(
                  labelText: 'Scope & investigation notes',
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['Normal', 'High', 'Critical']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _priority = v!),
              ),
              if (widget.existing != null) ...[
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['Open', 'In progress', 'Closed']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(_error!),
                ),
              const SizedBox(height: 24),
              CustomButton(
                label: widget.existing == null ? 'Create case' : 'Save changes',
                icon: Icons.add,
                onPressed: _save,
                busy: _busy,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
