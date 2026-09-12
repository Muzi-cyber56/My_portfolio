import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/case_model.dart';
import '../services/osint_service.dart';
import '../config/app_config.dart';
import '../widgets/loading_widget.dart';

class RelationshipGraphScreen extends StatefulWidget {
  final CaseModel caseItem;
  const RelationshipGraphScreen({super.key, required this.caseItem});
  @override
  State<RelationshipGraphScreen> createState() =>
      _RelationshipGraphScreenState();
}

class _RelationshipGraphScreenState extends State<RelationshipGraphScreen> {
  late Future<Map<String, dynamic>> _graph;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _graph = OsintService().correlation(widget.caseItem.id);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SectionTitle(
        'Relationship graph',
        'Explore the investigations connected to this case.',
      ),
      FutureBuilder<Map<String, dynamic>>(
        future: _graph,
        builder: (context, s) {
          if (s.hasError) {
            return ErrorPanel(error: s.error!, retry: () => setState(_refresh));
          }
          if (!s.hasData) return const LoadingWidget();
          final nodes = s.data!['nodes'] as List;
          final matches = s.data!['matches'] as List;
          if (nodes.isEmpty) {
            return const EmptyState(
              title: 'Connect the first dots',
              description: 'Run an OSINT investigation to populate this graph.',
              icon: Icons.hub_outlined,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Panel(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: 410,
                  child: LayoutBuilder(
                    builder: (context, c) => InteractiveViewer(
                      minScale: .5,
                      maxScale: 3,
                      child: CustomPaint(
                        size: Size(c.maxWidth, 410),
                        painter: _GraphPainter(
                          nodes
                              .take(12)
                              .map((n) => n['label'] as String)
                              .toList(),
                          widget.caseItem.caseNumber,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                s.data!['notice'],
                style: const TextStyle(color: AppConfig.muted, fontSize: 12),
              ),
              if (nodes.length > 12)
                const Text(
                  'Graph shows the first 12 investigations. All investigations are listed below.',
                ),
              const SizedBox(height: 24),
              Text(
                '${nodes.length} investigations • ${matches.length} repeated input groups',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...nodes.map(
                (n) => ListTile(
                  leading: const Icon(Icons.search, color: AppConfig.blue),
                  title: Text(n['label']),
                  subtitle: Text(
                    n['id'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppConfig.muted,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ],
  );
}

class _GraphPainter extends CustomPainter {
  final List<String> labels;
  final String caseNumber;
  _GraphPainter(this.labels, this.caseNumber);
  void text(Canvas c, String text, Offset at, {Color color = Colors.white}) {
    final p = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 130);
    p.paint(c, at - Offset(p.width / 2, p.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2),
        radius = math.min(size.width * .33, 140.0);
    final grid = Paint()
      ..color = AppConfig.border
      ..strokeWidth = .5;
    for (double x = 20; x < size.width; x += 24) {
      for (double y = 20; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), .7, grid);
      }
    }
    for (int i = 0; i < labels.length; i++) {
      final angle = 2 * math.pi * i / labels.length - math.pi / 2;
      final pos =
          center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      canvas.drawLine(
        center,
        pos,
        Paint()
          ..color = AppConfig.blue.withValues(alpha: .4)
          ..strokeWidth = 1.5,
      );
      canvas.drawCircle(pos, 25, Paint()..color = AppConfig.surface);
      canvas.drawCircle(
        pos,
        25,
        Paint()
          ..color = AppConfig.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      text(canvas, '${i + 1}', pos);
      text(
        canvas,
        labels[i],
        pos + const Offset(0, 38),
        color: AppConfig.muted,
      );
    }
    canvas.drawCircle(center, 43, Paint()..color = AppConfig.blue);
    text(canvas, 'CASE', center - const Offset(0, 6));
    text(canvas, caseNumber.split('-').last, center + const Offset(0, 11));
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) =>
      old.labels != labels || old.caseNumber != caseNumber;
}
