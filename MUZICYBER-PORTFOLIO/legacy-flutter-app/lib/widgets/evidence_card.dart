import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/evidence.dart';
import '../config/app_config.dart';
import 'loading_widget.dart';

class EvidenceCard extends StatelessWidget {
  final Evidence evidence;
  final VoidCallback onVerify;
  final VoidCallback onDownload;
  final bool busy;
  const EvidenceCard({
    super.key,
    required this.evidence,
    required this.onVerify,
    required this.onDownload,
    this.busy = false,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insert_drive_file_outlined,
                color: AppConfig.blue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  evidence.originalName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${(evidence.size / 1024).toStringAsFixed(1)} KB',
                style: const TextStyle(color: AppConfig.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Source: ${evidence.source}',
            style: const TextStyle(color: AppConfig.muted),
          ),
          const SizedBox(height: 12),
          const Text(
            'SHA-256',
            style: TextStyle(
              color: AppConfig.muted,
              fontSize: 10,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 5),
          SelectableText(
            evidence.sha256,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Integrity: ${evidence.integrityStatus}',
                style: const TextStyle(color: Colors.white),
              ),
              TextButton.icon(
                onPressed: busy ? null : onVerify,
                icon: const Icon(Icons.verified_user_outlined, size: 17),
                label: Text(busy ? 'Verifying…' : 'Verify again'),
              ),
              TextButton.icon(
                onPressed: busy ? null : onDownload,
                icon: const Icon(Icons.download_outlined, size: 17),
                label: const Text('Download'),
              ),
              TextButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text(evidence.originalName),
                    content: SingleChildScrollView(
                      child: SelectableText(
                        const JsonEncoder.withIndent(
                          '  ',
                        ).convert(jsonDecode(evidence.metadata)),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(Icons.info_outline, size: 17),
                label: const Text('Metadata'),
              ),
              IconButton(
                tooltip: 'Copy SHA-256',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: evidence.sha256));
                  showMessage(context, 'Hash copied.');
                },
                icon: const Icon(Icons.copy, size: 17),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
