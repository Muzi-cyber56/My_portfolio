import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/finding.dart';
import '../config/app_config.dart';
import 'loading_widget.dart';

class FindingCard extends StatelessWidget {
  final Finding finding;
  const FindingCard({super.key, required this.finding});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.manage_search, color: AppConfig.blue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  finding.type,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                finding.confidence == 0 ? 'UNVERIFIED' : 'OBSERVED',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppConfig.muted,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(finding.value),
          if (finding.sourceUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                final u = Uri.tryParse(finding.sourceUrl);
                if (u != null && u.scheme == 'https') {
                  try {
                    if (!await launchUrl(
                          u,
                          mode: LaunchMode.externalApplication,
                        ) &&
                        context.mounted) {
                      showMessage(context, 'Cannot open the source.');
                    }
                  } catch (e) {
                    if (context.mounted) showMessage(context, e);
                  }
                }
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Review public source'),
            ),
          ],
        ],
      ),
    ),
  );
}
