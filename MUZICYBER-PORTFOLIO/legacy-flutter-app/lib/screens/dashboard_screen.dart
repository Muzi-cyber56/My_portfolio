import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/case_model.dart';
import '../services/auth_service.dart';
import '../services/case_service.dart';
import '../utils/constants.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/search_field.dart';
import 'new_case_screen.dart';
import 'case_details_screen.dart';
import 'phone_osint_screen.dart';
import 'email_osint_screen.dart';
import 'username_osint_screen.dart';
import 'domain_osint_screen.dart';
import 'ip_osint_screen.dart';
import 'image_analysis_screen.dart';
import 'cnic_validation_screen.dart';
import 'evidence_screen.dart';
import 'relationship_graph_screen.dart';
import 'reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Future<void> Function() onLogout;
  const DashboardScreen({super.key, required this.onLogout});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scaffold = GlobalKey<ScaffoldState>();
  List<CaseModel> _cases = [];
  CaseModel? _selected;
  bool _loading = true;
  Object? _error;
  String _page = 'overview', _query = '', _filter = 'All';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cases = await CaseService().list();
      if (mounted) {
        setState(() {
          _cases = cases;
          final matches = cases.where((c) => c.id == _selected?.id);
          _selected = matches.isNotEmpty
              ? matches.first
              : cases.isNotEmpty
              ? cases.first
              : null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _newCase() async {
    final c = await showDialog<CaseModel>(
      context: context,
      builder: (_) => const NewCaseScreen(),
    );
    if (c == null || !mounted) return;
    setState(() {
      _selected = c;
      _page = 'details';
    });
    await _load();
  }

  void _navigate(String page) {
    setState(() => _page = page);
    if (_scaffold.currentState?.isDrawerOpen == true) {
      Navigator.pop(context);
    }
  }

  Widget _nav(String id, String label, IconData icon, {String? badge}) {
    final selected =
        _page == id ||
        (id == 'cases' && _page == 'details') ||
        (id == 'tools' && toolDefinitions.any((t) => t.id == _page));
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: selected
            ? AppConfig.blue.withValues(alpha: .13)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () => _navigate(id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? AppConfig.blue : AppConfig.muted,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? Colors.white : AppConfig.muted,
                    ),
                  ),
                ),
                if (badge != null)
                  Text(
                    badge,
                    style: const TextStyle(
                      color: AppConfig.muted,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sidebar() => Container(
    width: 238,
    decoration: const BoxDecoration(
      color: Color(0xFF0C1018),
      border: Border(right: BorderSide(color: AppConfig.border)),
    ),
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(25, 32, 20, 30),
            child: Row(
              children: [
                Icon(Icons.radar, size: 31, color: AppConfig.blue),
                SizedBox(width: 10),
                Text(
                  'SENTINEL',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 6, 0, 17),
                  child: Text(
                    'WORKSPACE',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppConfig.muted,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                _nav('overview', 'Overview', Icons.grid_view_rounded),
                _nav(
                  'cases',
                  'Case management',
                  Icons.folder_open_outlined,
                  badge: '${_cases.length}',
                ),
                _nav('tools', 'OSINT toolkit', Icons.travel_explore),
                _nav('image', 'Image forensics', Icons.fingerprint),
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 30, 0, 17),
                  child: Text(
                    'INVESTIGATION',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppConfig.muted,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                _nav('evidence', 'Evidence vault', Icons.shield_outlined),
                _nav('graph', 'Relationship graph', Icons.hub_outlined),
                _nav('reports', 'Reports', Icons.description_outlined),
                _nav('cnic', 'CNIC validation', Icons.badge_outlined),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: AppConfig.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: AppConfig.blue,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Evidence-first',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Preserve the source.\nVerify every finding.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppConfig.muted,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppConfig.blue.withValues(alpha: .2),
                  child: Text(
                    (AuthService.instance.user?.username ?? 'A')[0]
                        .toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AuthService.instance.user?.username ?? 'Analyst',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Investigation analyst',
                        style: TextStyle(fontSize: 10, color: AppConfig.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Sign out',
                  onPressed: widget.onLogout,
                  icon: const Icon(
                    Icons.logout,
                    size: 17,
                    color: AppConfig.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  Widget _stat(String label, String value, String detail, IconData icon) =>
      Panel(
        padding: const EdgeInsets.all(21),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppConfig.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
                Icon(icon, color: AppConfig.blue, size: 19),
              ],
            ),
            const SizedBox(height: 19),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              detail,
              style: const TextStyle(color: AppConfig.muted, fontSize: 11),
            ),
          ],
        ),
      );
  Widget _toolsGrid({bool compact = false}) {
    final tools = [
      ...toolDefinitions.map(
        (t) =>
            (id: t.id, name: t.name, description: t.description, icon: t.icon),
      ),
      (
        id: 'image',
        name: 'Image forensics',
        description: 'Hash, inspect & preserve image evidence',
        icon: Icons.fingerprint,
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final count = c.maxWidth > 850
            ? 3
            : c.maxWidth > 500
            ? 2
            : 1;
        final width = (c.maxWidth - (count - 1) * 14) / count;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: tools
              .map(
                (t) => SizedBox(
                  width: width,
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _navigate(t.id),
                      child: Padding(
                        padding: const EdgeInsets.all(21),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppConfig.blue.withValues(alpha: .1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    t.icon,
                                    color: AppConfig.blue,
                                    size: 21,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.north_east,
                                  size: 16,
                                  color: AppConfig.muted,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              t.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppConfig.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _caseList({bool recent = false}) {
    var items = _cases
        .where(
          (c) =>
              (c.title.toLowerCase().contains(_query.toLowerCase()) ||
                  c.caseNumber.toLowerCase().contains(_query.toLowerCase())) &&
              (_filter == 'All' || c.status == _filter),
        )
        .toList();
    if (recent) items = items.take(4).toList();
    if (items.isEmpty) {
      return EmptyState(
        title: _cases.isEmpty
            ? 'Your first case starts here'
            : 'No matching cases',
        description: _cases.isEmpty
            ? 'Open a case, follow a lead, and keep every detail connected.'
            : 'Try another search or status filter.',
        action: _cases.isEmpty
            ? CustomButton(
                label: 'Create first case',
                onPressed: _newCase,
                icon: Icons.add,
              )
            : null,
      );
    }
    return Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final c = entry.value;
          return Column(
            children: [
              if (entry.key != 0) const Divider(height: 1),
              InkWell(
                onTap: () => setState(() {
                  _selected = c;
                  _page = 'details';
                }),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: AppConfig.blue.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.folder_outlined,
                          color: AppConfig.blue,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${c.caseNumber}  •  ${shortDate(c.createdAt)}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppConfig.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppConfig.blue.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          c.status,
                          style: const TextStyle(
                            color: AppConfig.blue,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppConfig.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _overview() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionTitle(
        'Investigation overview',
        'A clear view of your cases, leads and next steps.',
        trailing: CustomButton(
          label: 'New case',
          onPressed: _newCase,
          icon: Icons.add,
        ),
      ),
      Container(
        padding: const EdgeInsets.all(27),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF254574)),
          gradient: const LinearGradient(
            colors: [Color(0xFF14294C), Color(0xFF101722)],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR INVESTIGATION WORKSPACE',
                    style: TextStyle(
                      color: AppConfig.blue,
                      fontSize: 9,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'Turn information into insight.',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.7,
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Research public sources. Preserve evidence. Connect the dots.',
                    style: TextStyle(color: AppConfig.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 21),
                  TextButton.icon(
                    onPressed: () => _navigate('tools'),
                    label: const Text('Explore the toolkit'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                  ),
                ],
              ),
            ),
            if (MediaQuery.sizeOf(context).width > 700)
              const Padding(
                padding: EdgeInsets.only(left: 20, right: 18),
                child: Icon(Icons.radar, size: 108, color: AppConfig.blue),
              ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      LayoutBuilder(
        builder: (context, c) {
          final columns = c.maxWidth > 680 ? 4 : 2;
          final w = (c.maxWidth - (columns - 1) * 14) / columns;
          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              SizedBox(
                width: w,
                child: _stat(
                  'Total cases',
                  '${_cases.length}',
                  'Your investigation records',
                  Icons.folder_open_outlined,
                ),
              ),
              SizedBox(
                width: w,
                child: _stat(
                  'Active cases',
                  '${_cases.where((c) => c.status != 'Closed').length}',
                  'Open or in progress',
                  Icons.radar,
                ),
              ),
              SizedBox(
                width: w,
                child: _stat(
                  'High priority',
                  '${_cases.where((c) => c.priority != 'Normal' && c.status != 'Closed').length}',
                  'Active cases to focus on',
                  Icons.flag_outlined,
                ),
              ),
              SizedBox(
                width: w,
                child: _stat(
                  'Closed cases',
                  '${_cases.where((c) => c.status == 'Closed').length}',
                  'Preserved for reference',
                  Icons.task_alt,
                ),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 30),
      Row(
        children: [
          Text('Recent cases', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          TextButton(
            onPressed: () => _navigate('cases'),
            child: const Text('View all cases  →'),
          ),
        ],
      ),
      const SizedBox(height: 14),
      _caseList(recent: true),
      const SizedBox(height: 30),
      Text(
        'Intelligence toolkit',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 6),
      const Text(
        'Choose a starting point for your next lead.',
        style: TextStyle(color: AppConfig.muted, fontSize: 12),
      ),
      const SizedBox(height: 18),
      _toolsGrid(compact: true),
    ],
  );
  Widget _content() {
    if (_loading) return const LoadingWidget();
    if (_error != null) return ErrorPanel(error: _error!, retry: _load);
    if (_page == 'overview') return _overview();
    if (_page == 'cases') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(
            'Case management',
            'Organize every investigation in one place.',
            trailing: CustomButton(
              label: 'New case',
              onPressed: _newCase,
              icon: Icons.add,
            ),
          ),
          SearchField(onChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['All', 'Open', 'In progress', 'Closed']
                .map(
                  (s) => ChoiceChip(
                    label: Text(s),
                    selected: _filter == s,
                    onSelected: (_) => setState(() => _filter = s),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 22),
          _caseList(),
        ],
      );
    }
    if (_page == 'tools') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(
            'OSINT toolkit',
            'Start with a lead. Build an evidence-backed case.',
          ),
          _toolsGrid(),
          const SizedBox(height: 22),
          const Text(
            'DNS resolution is live. Profile and registration URLs are unverified research leads. Subscriber, breach and private identity databases are not connected.',
            style: TextStyle(color: AppConfig.muted, fontSize: 12),
          ),
        ],
      );
    }
    if (_page == 'cnic') return const CnicValidationScreen();
    final c = _selected;
    if (c == null) {
      return EmptyState(
        title: 'Create a case to continue',
        description:
            'Investigations, evidence and reports are attached to a case.',
        action: CustomButton(
          label: 'New case',
          onPressed: _newCase,
          icon: Icons.add,
        ),
      );
    }
    final key = ValueKey('$_page-${c.id}');
    return switch (_page) {
      'details' => CaseDetailsScreen(
        key: key,
        caseItem: c,
        onChanged: _load,
        onTool: _navigate,
      ),
      'phone' => PhoneOsintScreen(key: key, caseItem: c),
      'email' => EmailOsintScreen(key: key, caseItem: c),
      'username' => UsernameOsintScreen(key: key, caseItem: c),
      'domain' => DomainOsintScreen(key: key, caseItem: c),
      'ip' => IpOsintScreen(key: key, caseItem: c),
      'image' => ImageAnalysisScreen(key: key, caseItem: c),
      'evidence' => EvidenceScreen(key: key, caseItem: c),
      'graph' => RelationshipGraphScreen(key: key, caseItem: c),
      'reports' => ReportsScreen(key: key, caseItem: c),
      _ => _overview(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return Scaffold(
      key: _scaffold,
      drawer: wide ? null : Drawer(width: 238, child: _sidebar()),
      body: Row(
        children: [
          if (wide) _sidebar(),
          Expanded(
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    height: 77,
                    padding: EdgeInsets.symmetric(horizontal: wide ? 34 : 14),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppConfig.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (!wide)
                          IconButton(
                            tooltip: 'Open navigation',
                            onPressed: () =>
                                _scaffold.currentState?.openDrawer(),
                            icon: const Icon(Icons.menu),
                          ),
                        if (wide) ...[
                          const Text(
                            'Workspace',
                            style: TextStyle(
                              color: AppConfig.muted,
                              fontSize: 12,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              '/',
                              style: TextStyle(color: AppConfig.border),
                            ),
                          ),
                          const Text(
                            'Investigation center',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                        const Spacer(),
                        if (_cases.isNotEmpty)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: wide ? 260 : 210,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selected?.id,
                                icon: const Icon(Icons.expand_more, size: 17),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                                items: _cases
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(
                                          c.caseNumber,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (id) => setState(
                                  () => _selected = _cases.firstWhere(
                                    (c) => c.id == id,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: 'Refresh cases',
                          onPressed: _load,
                          icon: const Icon(
                            Icons.refresh,
                            size: 19,
                            color: AppConfig.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      key: ValueKey(_page),
                      padding: EdgeInsets.all(wide ? 34 : 20),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1250),
                          child: _content(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
