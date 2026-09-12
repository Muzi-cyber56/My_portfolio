import '../services/api_service.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/case_model.dart';
import '../models/evidence.dart';
import '../services/forensic_service.dart';
import '../config/app_config.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/evidence_card.dart';

class EvidenceScreen extends StatefulWidget {
  final CaseModel caseItem;
  final bool imageOnly;
  const EvidenceScreen({
    super.key,
    required this.caseItem,
    this.imageOnly = false,
  });
  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  final _service = ForensicService(), _source = TextEditingController();
  late Future<List<Evidence>> _items;
  bool _busy = false;
  String? _verifying;
  Evidence? _latest;
  String? _fileName;
  Uint8List? _bytes;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  void _refresh() {
    _items = _service.list(widget.caseItem.id);
  }

  Future<void> _pick() async {
    try {
      final r = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.imageOnly
            ? ['png', 'jpg', 'jpeg']
            : ['png', 'jpg', 'jpeg', 'pdf', 'txt'],
        withData: true,
      );
      if (r == null || !mounted) return;
      if (r.files.single.size > 10 * 1024 * 1024) {
        showMessage(context, 'Maximum file size is 10 MB.');
        return;
      }
      if (r.files.single.bytes == null) {
        showMessage(context, 'Could not read this file.');
        return;
      }
      setState(() {
        _fileName = r.files.single.name;
        _bytes = r.files.single.bytes;
      });
    } catch (e) {
      if (mounted) showMessage(context, e);
    }
  }

  Future<void> _upload() async {
    if (_bytes == null || _source.text.trim().isEmpty) {
      showMessage(context, 'Choose a file and enter its source.');
      return;
    }
    setState(() => _busy = true);
    try {
      final e = await _service.upload(
        widget.caseItem.id,
        _fileName!,
        _bytes!,
        _source.text.trim(),
        imageOnly: widget.imageOnly,
      );
      if (mounted) {
        setState(() {
          _latest = e;
          _fileName = null;
          _bytes = null;
          _source.clear();
          _refresh();
        });
      }
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify(Evidence e) async {
    setState(() => _verifying = e.id);
    try {
      final updated = await _service.verify(e);
      if (mounted) {
        showMessage(context, 'Integrity: ${updated.integrityStatus}');
        setState(_refresh);
      }
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => _verifying = null);
    }
  }

  Future<void> _download(Evidence e) async {
    setState(() => _verifying = e.id);
    try {
      final data = await ApiService.instance.download(
        '/api/evidence/${e.caseId}/${e.id}',
      );
      await FilePicker.platform.saveFile(
        dialogTitle: 'Save verified evidence',
        fileName: e.originalName,
        bytes: data,
      );
    } catch (error) {
      if (mounted) showMessage(context, error);
    } finally {
      if (mounted) setState(() => _verifying = null);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionTitle(
        widget.imageOnly ? 'Image forensics' : 'Evidence vault',
        widget.imageOnly
            ? 'Inspect image headers and preserve the original bytes.'
            : 'Collected files. Verifiable integrity. One case record.',
      ),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.caseItem.caseNumber,
              style: const TextStyle(
                color: AppConfig.muted,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: _busy ? null : _pick,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      size: 32,
                      color: AppConfig.blue,
                    ),
                    const SizedBox(height: 12),
                    Text(_fileName ?? 'Choose evidence file'),
                    const SizedBox(height: 8),
                    Text(
                      widget.imageOnly
                          ? 'PNG or JPEG • Up to 10 MB'
                          : 'PNG, JPEG, PDF or TXT • Up to 10 MB',
                      style: const TextStyle(
                        color: AppConfig.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _source,
              maxLength: 2048,
              decoration: const InputDecoration(
                labelText: 'Evidence source',
                hintText: 'Source URL or collection notes',
                counterText: '',
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: CustomButton(
                label: widget.imageOnly ? 'Analyze & preserve' : 'Add evidence',
                onPressed: _upload,
                busy: _busy,
                icon: Icons.add_moderator_outlined,
              ),
            ),
          ],
        ),
      ),
      if (widget.imageOnly) ...[
        const SizedBox(height: 16),
        const Text(
          'Available: SHA-256, file signature, dimensions and EXIF metadata. OCR requires a configured local engine. Metadata does not establish image authenticity.',
          style: TextStyle(color: AppConfig.muted, fontSize: 12),
        ),
        if (_latest != null) ...[
          const SizedBox(height: 20),
          Panel(
            child: SelectableText(
              const JsonEncoder.withIndent(
                '  ',
              ).convert(jsonDecode(_latest!.metadata)),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ],
      const SizedBox(height: 28),
      Text('Case evidence', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 16),
      FutureBuilder<List<Evidence>>(
        future: _items,
        builder: (context, s) {
          if (s.hasError) {
            return ErrorPanel(error: s.error!, retry: () => setState(_refresh));
          }
          if (!s.hasData) return const LoadingWidget();
          if (s.data!.isEmpty) {
            return const EmptyState(
              title: 'Your evidence belongs here',
              description:
                  'Add a source file to create its SHA-256 integrity record.',
              icon: Icons.shield_outlined,
            );
          }
          return Column(
            children: s.data!
                .map(
                  (e) => EvidenceCard(
                    evidence: e,
                    onVerify: () => _verify(e),
                    onDownload: () => _download(e),
                    busy: _verifying == e.id,
                  ),
                )
                .toList(),
          );
        },
      ),
    ],
  );
}
