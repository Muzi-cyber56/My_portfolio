import 'package:flutter/material.dart';
import '../services/forensic_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_button.dart';

class CnicValidationScreen extends StatefulWidget {
  const CnicValidationScreen({super.key});
  @override
  State<CnicValidationScreen> createState() => _CnicValidationScreenState();
}

class _CnicValidationScreenState extends State<CnicValidationScreen> {
  final _input = TextEditingController();
  bool _busy = false;
  String? _result;
  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    setState(() => _busy = true);
    try {
      final r = await ForensicService().cnic(_input.text);
      if (mounted) setState(() => _result = r['message']);
    } catch (e) {
      if (mounted) setState(() => _result = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SectionTitle(
        'CNIC validation',
        'Check the structure of a Pakistan CNIC number.',
      ),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _input,
              maxLength: 15,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'CNIC number',
                hintText: 'XXXXX-XXXXXXX-X',
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: CustomButton(
                label: 'Validate format',
                onPressed: _run,
                busy: _busy,
                icon: Icons.fact_check_outlined,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Format validation only. No NADRA connection, ownership check or identity lookup. The raw number is not stored.',
            ),
            if (_result != null) ...[
              const Divider(height: 40),
              Text(_result!, style: Theme.of(context).textTheme.titleMedium),
            ],
          ],
        ),
      ),
    ],
  );
}
