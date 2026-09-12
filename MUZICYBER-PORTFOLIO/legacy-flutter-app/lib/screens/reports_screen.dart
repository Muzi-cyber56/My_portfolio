import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/case_model.dart';
import '../services/report_service.dart';
import '../utils/constants.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_button.dart';
import '../config/app_config.dart';

class ReportsScreen extends StatefulWidget {
  final CaseModel caseItem;
  const ReportsScreen({super.key, required this.caseItem});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _service = ReportService();
  late Future<List<dynamic>> _reports;
  bool _busy = false;
  String? _downloading;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _reports = _service.list(widget.caseItem.id);
  }

  Future<void> _generate() async {
    setState(() => _busy = true);
    try {
      await _service.generate(widget.caseItem.id);
      if (mounted) {
        setState(_refresh);
        showMessage(
          context,
          'Report generated. Evidence integrity was rechecked.',
        );
      }
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _download(String id) async {
    setState(() => _downloading = id);
    try {
      final data = await _service.download(id);
      await Printing.sharePdf(
        bytes: data,
        filename: '${widget.caseItem.caseNumber}.pdf',
      );
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => _downloading = null);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SectionTitle(
        'Investigation reports',
        'Bring the case together in a shareable PDF.',
      ),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.description_outlined,
              size: 32,
              color: AppConfig.blue,
            ),
            const SizedBox(height: 20),
            Text(
              widget.caseItem.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Includes case notes, findings, source links and evidence hashes. Each report rechecks evidence integrity before generation.',
              style: TextStyle(color: AppConfig.muted),
            ),
            const SizedBox(height: 22),
            CustomButton(
              label: 'Generate PDF report',
              onPressed: _generate,
              busy: _busy,
              icon: Icons.add,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      FutureBuilder<List<dynamic>>(
        future: _reports,
        builder: (context, s) {
          if (s.hasError) {
            return ErrorPanel(error: s.error!, retry: () => setState(_refresh));
          }
          if (!s.hasData) return const LoadingWidget();
          if (s.data!.isEmpty) {
            return const EmptyState(
              title: 'No reports yet',
              description:
                  'Generate a snapshot when your case is ready for review.',
              icon: Icons.description_outlined,
            );
          }
          return Column(
            children: s.data!
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Panel(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf_outlined,
                            color: AppConfig.blue,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Investigation report'),
                                Text(
                                  shortDate(DateTime.parse(r['createdAt'])),
                                  style: const TextStyle(
                                    color: AppConfig.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Download PDF',
                            onPressed: _downloading != null
                                ? null
                                : () => _download(r['id']),
                            icon: _downloading == r['id']
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.download_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    ],
  );
}
