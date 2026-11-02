part of 'main.dart';

const _dashBlue = green,
    _dashTeal = Color(0xFF166534),
    _dashPurple = Colors.purple,
    _dashAmber = orange,
    _dashMuted = Color(0xFF475569),
    _dashLine = Color(0xFFCBD5E1);

Duration _dashDuration(BuildContext context) =>
    store.reducedMotion || MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : const Duration(milliseconds: 420);

List<Map<String, dynamic>> _dashRows(Map<String, dynamic> data, String key) =>
    (data[key] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
int _dashInt(dynamic value) => (value as num?)?.toInt() ?? 0;
String dashboardDeviceReason(Map<String, dynamic> d) {
  if (d['revoked'] == 1) return tr('Access revoked', 'प्रवेश रद्द');
  if (d['active'] == 0) return tr('Device disabled', 'साधन बंद');
  if (d['reauth_required'] == 1)
    return tr('Sign-in needed', 'पुन्हा प्रवेश आवश्यक');
  if (d['health'] != 'ok')
    return tr('Health check needed', 'स्थिती तपासणे आवश्यक');
  if ((d['version_state'] as Map?)?['outdated'] == true)
    return tr('App update needed', 'अॅप अद्ययावत करा');
  return deviceStatusLabel(d['status'] ?? 'offline');
}

class DashboardPanel extends StatelessWidget {
  final String? title, subtitle;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  const DashboardPanel({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                ?trailing,
              ],
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  subtitle!,
                  style: const TextStyle(color: _dashMuted, fontSize: 14),
                ),
              ),
            const SizedBox(height: 22),
          ],
          child,
        ],
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Panel(
        padding: EdgeInsets.zero,
        child: onTap == null
            ? content
            : InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onTap,
                child: content,
              ),
      ),
    );
  }
}

class DashboardBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const DashboardBadge(
    this.label, {
    super.key,
    this.color = _dashTeal,
    this.icon,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: store.contrast ? .15 : .08),
      borderRadius: BorderRadius.circular(9),
      border: store.contrast ? Border.all(color: color) : null,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class DashboardColumns extends StatelessWidget {
  final Widget left, right;
  final double breakpoint;
  final int leftFlex, rightFlex;
  const DashboardColumns({
    super.key,
    required this.left,
    required this.right,
    this.breakpoint = 820,
    this.leftFlex = 3,
    this.rightFlex = 2,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      if (c.maxWidth / MediaQuery.textScalerOf(context).scale(1) < breakpoint)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [left, const SizedBox(height: 20), right],
        );
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: leftFlex, child: left),
          const SizedBox(width: 20),
          Expanded(flex: rightFlex, child: right),
        ],
      );
    },
  );
}

class DashboardMetric extends StatelessWidget {
  final String label, value, note;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const DashboardMetric({
    super.key,
    required this.label,
    required this.value,
    required this.note,
    required this.icon,
    required this.color,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value. $note',
    button: onTap != null,
    excludeSemantics: true,
    child: DashboardPanel(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              if (onTap != null)
                const Icon(
                  Icons.arrow_outward_rounded,
                  color: _dashMuted,
                  size: 18,
                ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: _dashDuration(context),
            child: Text(
              value,
              key: ValueKey(value),
              style: const TextStyle(
                fontSize: 34,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(note, style: const TextStyle(fontSize: 13, color: _dashMuted)),
        ],
      ),
    ),
  );
}

class DashboardMetricGrid extends StatelessWidget {
  final List<Widget> children;
  const DashboardMetricGrid({super.key, required this.children});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final effective = c.maxWidth / MediaQuery.textScalerOf(context).scale(1);
      final columns = effective >= 840
          ? 4
          : effective >= 490
          ? 2
          : 1;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var start = 0; start < children.length; start += columns) ...[
            if (start > 0) const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var col = 0; col < columns; col++) ...[
                    if (col > 0) const SizedBox(width: 16),
                    Expanded(
                      child: start + col < children.length
                          ? children[start + col]
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    },
  );
}

class DashboardRing extends StatelessWidget {
  final int online, total;
  const DashboardRing({super.key, required this.online, required this.total});
  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : (online / total).clamp(0.0, 1.0);
    return Semantics(
      label: tr(
        '$online of $total classrooms online',
        '$total पैकी $online वर्ग ऑनलाइन',
      ),
      child: SizedBox(
        height: 194,
        child: Center(
          child: SizedBox.square(
            dimension: 186,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: _dashDuration(context),
                    builder: (_, value, _) => CustomPaint(
                      painter: _DashboardRingPainter(value, store.contrast),
                    ),
                  ),
                ),
                ExcludeSemantics(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$online',
                        key: const ValueKey('online-ring-count'),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                      Text(
                        tr('of $total online', '$total पैकी ऑनलाइन'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: _dashMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardRingPainter extends CustomPainter {
  final double value;
  final bool contrast;
  _DashboardRingPainter(this.value, this.contrast);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final ring = rect.deflate(15);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      ring,
      -pi / 2,
      pi * 2,
      false,
      paint
        ..color = contrast ? const Color(0xFFB4BFCE) : const Color(0xFFEBEFF7),
    );
    if (value > 0)
      canvas.drawArc(
        ring,
        -pi / 2,
        pi * 2 * value,
        false,
        paint..color = _dashBlue,
      );
  }

  @override
  bool shouldRepaint(_DashboardRingPainter old) =>
      old.value != value || old.contrast != contrast;
}

class DashboardWeekChart extends StatefulWidget {
  final List<dynamic> usage;
  final DateTime today;
  const DashboardWeekChart({
    super.key,
    required this.usage,
    required this.today,
  });
  @override
  State<DashboardWeekChart> createState() => _DashboardWeekChartState();
}

class _DashboardWeekChartState extends State<DashboardWeekChart> {
  String metric = 'started';
  int selected = 6;
  @override
  Widget build(BuildContext context) {
    final end = DateTime.utc(
      widget.today.year,
      widget.today.month,
      widget.today.day,
    );
    final days = List.generate(7, (i) => end.subtract(Duration(days: 6 - i)));
    final values = [
      for (final day in days)
        [
          for (final mode in ['learn', 'practice', 'quiz'])
            widget.usage
                .whereType<Map>()
                .where(
                  (r) =>
                      r['day'] == day.toIso8601String().split('T').first &&
                      r['mode'] == mode,
                )
                .fold<int>(0, (sum, r) => sum + _dashInt(r[metric])),
        ],
    ];
    final maximum = max(
      1,
      values.map((v) => v.reduce((a, b) => a + b)).reduce(max),
    );
    final total = values.expand((v) => v).fold<int>(0, (a, b) => a + b);
    const colors = [_dashBlue, _dashTeal, _dashPurple];
    final names = [
      tr('Learn', 'शिका'),
      tr('Practice', 'सराव'),
      tr('Quiz', 'प्रश्नमंजुषा'),
    ];
    final picked = days[selected];
    String date(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
    return DashboardPanel(
      title: tr('Learning through the week', 'आठवड्यातील अभ्यास'),
      subtitle: tr(
        'Last 7 days · UTC · touch a day for its breakdown',
        'मागील ७ दिवस · UTC · तपशीलासाठी दिवसाला स्पर्श करा',
      ),
      trailing: DashboardBadge(
        tr('$total sessions', '$total सत्रे'),
        color: _dashBlue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in [
                ('started', 'Started', 'सुरू'),
                ('completed', 'Completed', 'पूर्ण'),
              ])
                ChoiceChip(
                  label: Text(tr(option.$2, option.$3)),
                  selected: metric == option.$1,
                  onSelected: (_) => setState(() => metric = option.$1),
                ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: SizedBox(
                width: max(364, c.maxWidth),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: selected == i,
                          label:
                              '${date(days[i])}: ${names[0]} ${values[i][0]}, ${names[1]} ${values[i][1]}, ${names[2]} ${values[i][2]}',
                          child: InkWell(
                            key: ValueKey('usage-day-$i'),
                            onTap: () => setState(() => selected = i),
                            borderRadius: BorderRadius.circular(10),
                            child: ExcludeSemantics(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                                decoration: BoxDecoration(
                                  color: selected == i
                                      ? _dashBlue.withValues(alpha: .05)
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected == i
                                        ? _dashBlue.withValues(alpha: .3)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${values[i].reduce((a, b) => a + b)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _dashMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 142,
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              for (var m = 2; m >= 0; m--)
                                                AnimatedContainer(
                                                  duration: _dashDuration(
                                                    context,
                                                  ),
                                                  height:
                                                      values[i][m] /
                                                      maximum *
                                                      142,
                                                  color: colors[m],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(height: 1, color: _dashLine),
                                    const SizedBox(height: 10),
                                    Text(
                                      date(days[i]),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: _dashMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (var i = 0; i < 3; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 9, color: colors[i]),
                    const SizedBox(width: 6),
                    Text(
                      names[i],
                      style: const TextStyle(fontSize: 13, color: _dashMuted),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${date(picked)}  ·  ${List.generate(3, (i) => '${names[i]} ${values[selected][i]}').join('  ·  ')}',
              key: const ValueKey('usage-day-detail'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          if (total == 0)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                tr(
                  'No sessions recorded in this period yet.',
                  'या कालावधीत अद्याप सत्रांची नोंद नाही.',
                ),
                style: const TextStyle(fontSize: 13, color: _dashMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class DashboardClassroomMap extends StatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<String> onOpen;
  final bool live;
  const DashboardClassroomMap({
    super.key,
    required this.data,
    required this.onOpen,
    this.live = true,
  });
  @override
  State<DashboardClassroomMap> createState() => _DashboardClassroomMapState();
}

class _DashboardClassroomMapState extends State<DashboardClassroomMap> {
  String filter = 'all';
  @override
  Widget build(BuildContext context) {
    final rooms = _dashRows(widget.data, 'classrooms');
    final devices = _dashRows(widget.data, 'devices');
    final filtered = rooms
        .where(
          (r) =>
              filter == 'all' ||
              (filter == 'online' ? r['online'] == true : r['online'] != true),
        )
        .toList();
    return DashboardPanel(
      title: tr('Your classrooms, at a glance', 'एका नजरेत तुमचे वर्ग'),
      subtitle: tr(
        widget.live
            ? 'Live status · tap a classroom for its details'
            : 'Last received status · reconnect for current status',
        widget.live
            ? 'थेट स्थिती · तपशीलासाठी वर्गाला स्पर्श करा'
            : 'शेवटची मिळालेली स्थिती · आत्ताच्या स्थितीसाठी पुन्हा जोडा',
      ),
      trailing: DashboardBadge(
        '${rooms.length} ${tr('classrooms', 'वर्ग')}',
        color: _dashBlue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in [
                ('all', 'All', 'सर्व'),
                ('online', 'Online', 'ऑनलाइन'),
                ('offline', 'Offline', 'ऑफलाइन'),
              ])
                ChoiceChip(
                  label: Text(tr(f.$2, f.$3)),
                  selected: filter == f.$1,
                  onSelected: (_) => setState(() => filter = f.$1),
                ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, c) {
              final effective =
                  c.maxWidth / MediaQuery.textScalerOf(context).scale(1);
              final cols = effective >= 1020
                  ? 4
                  : effective >= 740
                  ? 3
                  : effective >= 460
                  ? 2
                  : 1;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final room in filtered)
                    SizedBox(
                      width: (c.maxWidth - (cols - 1) * 12) / cols,
                      child: Builder(
                        builder: (context) {
                          final board = devices
                              .where((d) => d['classroom_id'] == room['id'])
                              .toList();
                          final online = room['online'] == true;
                          final attention = board.any(
                            (d) =>
                                d['status'] == 'needs_attention' ||
                                d['status'] == 'disabled',
                          );
                          final color = attention
                              ? _dashAmber
                              : online
                              ? _dashTeal
                              : _dashMuted;
                          final current = board
                              .where((d) => d['online'] == true)
                              .firstOrNull;
                          final mode =
                              current?['current_mode']?.toString() ?? 'idle';
                          final label = room['status'] != 'active'
                              ? tr('Disabled / archived', 'बंद / संग्रहित')
                              : online
                              ? (widget.live
                                    ? tr('Online', 'ऑनलाइन')
                                    : tr(
                                        'Last known: online',
                                        'शेवटची स्थिती: ऑनलाइन',
                                      ))
                              : board.isEmpty
                              ? tr('No board registered', 'फळ्याची नोंदणी नाही')
                              : tr('Offline', 'ऑफलाइन');
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              key: ValueKey('room-${room['id']}'),
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => widget.onOpen(room['id'].toString()),
                              child: AnimatedContainer(
                                duration: _dashDuration(context),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: .035),
                                  border: Border.all(
                                    color: color.withValues(
                                      alpha: store.contrast ? 1 : .22,
                                    ),
                                    width: store.contrast ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: .09),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            online
                                                ? Icons.cast_connected_rounded
                                                : Icons.cast_rounded,
                                            size: 20,
                                            color: color,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          attention
                                              ? Icons.warning_amber_rounded
                                              : online
                                              ? Icons.check_circle_rounded
                                              : Icons.circle_outlined,
                                          size: 17,
                                          color: color,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 13),
                                    Text(
                                      room['name'].toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${tr('Class', 'इयत्ता')} ${room['grade']} · ${room['school_name'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: _dashMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 13),
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: color,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    AnimatedSwitcher(
                                      duration: _dashDuration(context),
                                      child: Text(
                                        online
                                            ? modeLabel(mode)
                                            : attention
                                            ? tr(
                                                'Needs attention',
                                                'लक्ष देणे आवश्यक',
                                              )
                                            : '—',
                                        key: ValueKey(
                                          '$online-$mode-$attention',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: _dashMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                tr(
                  'No classrooms match this status.',
                  'या स्थितीतील वर्ग नाहीत.',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DashboardOverview extends StatelessWidget {
  final Map<String, dynamic> data;
  final DateTime now;
  final ValueChanged<String> onNavigate, onClassroom;
  final bool live;
  const DashboardOverview({
    super.key,
    required this.data,
    required this.now,
    required this.onNavigate,
    required this.onClassroom,
    this.live = true,
  });
  @override
  Widget build(BuildContext context) {
    final o = Map<String, dynamic>.from(data['overview'] ?? {});
    final a = Map<String, dynamic>.from(data['analytics'] ?? {});
    final rooms = _dashRows(data, 'classrooms');
    final events = _dashRows(data, 'events');
    final devices = _dashRows(data, 'devices');
    final online = _dashInt(o['onlineClassrooms']),
        total = _dashInt(o['classrooms']);
    final active =
        _dashInt(o['activeLessons']) +
        _dashInt(o['activePractice']) +
        _dashInt(o['activeQuizzes']);
    final needing = devices
        .where((d) => ['needs_attention', 'disabled'].contains(d['status']))
        .toList();
    final alerts = _dashRows(
      data,
      'alerts',
    ).where((r) => r['status'] == 'open').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardMetricGrid(
          children: [
            DashboardMetric(
              label: tr('Classrooms online', 'ऑनलाइन वर्ग'),
              value: '$online / $total',
              note: tr(
                '${_dashInt(o['offlineClassrooms'])} offline or not connected yet',
                '${_dashInt(o['offlineClassrooms'])} वर्ग ऑफलाइन किंवा अद्याप जोडले नाहीत',
              ),
              icon: Icons.cast_connected_rounded,
              color: _dashBlue,
              onTap: () => onNavigate('classrooms'),
            ),
            DashboardMetric(
              label: live
                  ? tr('Learning right now', 'आत्ता सुरू असलेला अभ्यास')
                  : tr('Last known activity', 'शेवटची मिळालेली कृती'),
              value: '$active',
              note: tr(
                '${_dashInt(o['activeTeachers'])} active accounts',
                '${_dashInt(o['activeTeachers'])} सक्रिय खाती',
              ),
              icon: Icons.auto_stories_rounded,
              color: _dashTeal,
              onTap: () => onNavigate('devices'),
            ),
            DashboardMetric(
              label: tr('Sessions today', 'आजची सत्रे'),
              value: '${_dashInt(a['todayUsage'])}',
              note: tr(
                '${_dashInt(a['weeklyUsage'])} this week · UTC',
                'या आठवड्यात ${_dashInt(a['weeklyUsage'])} · UTC',
              ),
              icon: Icons.bar_chart_rounded,
              color: _dashPurple,
              onTap: () => onNavigate('analytics'),
            ),
            DashboardMetric(
              label: tr('Needs attention', 'लक्ष देणे आवश्यक'),
              value: '${_dashInt(o['attention'])}',
              note: tr(
                '${alerts.length} unresolved alerts',
                '${alerts.length} प्रलंबित सूचना',
              ),
              icon: Icons.health_and_safety_outlined,
              color: _dashAmber,
              onTap: () => onNavigate('alerts'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        DashboardColumns(
          left: DashboardWeekChart(
            usage: a['usageDaily'] as List? ?? [],
            today: now.toUtc(),
          ),
          right: DashboardPanel(
            title: tr('Classroom connection', 'वर्गांची जोडणी'),
            subtitle: tr(
              'Based on the latest received heartbeats',
              'शेवटच्या स्थिती नोंदींवर आधारित',
            ),
            child: Column(
              children: [
                DashboardRing(online: online, total: total),
                const SizedBox(height: 18),
                _legend(tr('Online', 'ऑनलाइन'), online, _dashBlue),
                const SizedBox(height: 12),
                _legend(
                  tr('Offline / not connected', 'ऑफलाइन / अद्याप जोडले नाहीत'),
                  max(0, total - online),
                  _dashMuted,
                ),
                const SizedBox(height: 20),
                const Divider(color: _dashLine),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    DashboardBadge(
                      '${_dashInt(o['activeLessons'])} ${tr('Learn', 'शिका')}',
                      color: _dashBlue,
                      icon: Icons.auto_stories_outlined,
                    ),
                    DashboardBadge(
                      '${_dashInt(o['activePractice'])} ${tr('Practice', 'सराव')}',
                      color: _dashTeal,
                      icon: Icons.edit_note_rounded,
                    ),
                    DashboardBadge(
                      '${_dashInt(o['activeQuizzes'])} ${tr('Quiz', 'प्रश्नमंजुषा')}',
                      color: _dashPurple,
                      icon: Icons.quiz_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 18,
                  runSpacing: 12,
                  children: [
                    Text(
                      '${_dashInt(o['schools'])} ${tr('schools', 'शाळा')}',
                      style: const TextStyle(color: _dashMuted, fontSize: 13),
                    ),
                    Text(
                      '${_dashInt(o['devices'])} ${tr('registered boards', 'नोंदणीकृत फळे')}',
                      style: const TextStyle(color: _dashMuted, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        DashboardClassroomMap(data: data, live: live, onOpen: onClassroom),
        const SizedBox(height: 22),
        DashboardColumns(
          left: DashboardPanel(
            title: tr('Live learning activity', 'थेट अभ्यास कृती'),
            subtitle: tr(
              'Classroom activity only · no individual scores',
              'फक्त वर्गातील कृती · वैयक्तिक गुण नाहीत',
            ),
            trailing: DashboardBadge(
              live ? tr('Live', 'थेट') : tr('Last received', 'शेवटची माहिती'),
              color: live ? _dashTeal : _dashAmber,
              icon: live ? Icons.sensors_rounded : Icons.cloud_off_outlined,
            ),
            child: Column(
              children: [
                if (events.isEmpty)
                  _empty(
                    Icons.auto_stories_outlined,
                    tr(
                      'Ready for the next learning moment',
                      'पुढील अभ्यासासाठी तयार',
                    ),
                    tr(
                      'Lesson, Practice and Quiz activity will appear here.',
                      'धडा, सराव आणि प्रश्नमंजुषेच्या कृती येथे दिसतील.',
                    ),
                  ),
                for (final event in events.take(5))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _modeColor(
                              event['mode'],
                            ).withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _modeIcon(event['mode']),
                            color: _modeColor(event['mode']),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${modeLabel(event['mode'])} · ${_eventLabel(event['event_type'].toString())}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${rooms.where((r) => r['id'] == event['classroom_id']).firstOrNull?['name'] ?? '—'} · ${chapterLabel(event['chapter_id'] ?? '')}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _dashMuted,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _relative(event['occurred_at'], now),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _dashMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          right: DashboardPanel(
            title: tr('A little attention needed', 'थोडे लक्ष देणे आवश्यक'),
            subtitle: tr(
              'The next useful actions, in one place',
              'पुढील आवश्यक कृती एकाच ठिकाणी',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (needing.isEmpty && alerts.isEmpty)
                  _empty(
                    Icons.verified_outlined,
                    tr('No issues reported', 'समस्या नोंदवलेल्या नाहीत'),
                    _dashRows(data, 'devices').isEmpty
                        ? tr(
                            'No boards registered yet. Connect a classroom to begin.',
                            'अद्याप फळ्यांची नोंदणी नाही. सुरू करण्यासाठी वर्ग जोडा.',
                          )
                        : tr(
                            'No board issues have been reported.',
                            'फळ्यांबाबत समस्या नोंदवलेल्या नाहीत.',
                          ),
                  ),
                for (final device in needing.take(3))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.warning_amber_rounded,
                      color: _dashAmber,
                    ),
                    title: Text(
                      device['name'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      '${device['classroom_name']} · ${dashboardDeviceReason(device)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => onNavigate('devices'),
                  ),
                if (alerts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      '${alerts.length} ${tr('unresolved alerts. Open Alerts to review them.', 'प्रलंबित सूचना. पाहण्यासाठी सूचना उघडा.')}',
                      style: const TextStyle(fontSize: 13, color: _dashMuted),
                    ),
                  ),
                if (needing.isNotEmpty || alerts.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => onNavigate('alerts'),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(tr('Review alerts', 'सूचना पाहा')),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _legend(String label, int value, Color color) => Row(
    children: [
      Icon(Icons.circle, size: 10, color: color),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: _dashMuted),
        ),
      ),
      Text(
        '$value',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    ],
  );
  static Widget _empty(IconData icon, String title, String subtitle) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        Icon(icon, size: 36, color: _dashTeal),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: _dashMuted),
        ),
      ],
    ),
  );
  static Color _modeColor(dynamic mode) => mode == 'practice'
      ? _dashTeal
      : mode == 'quiz'
      ? _dashPurple
      : _dashBlue;
  static IconData _modeIcon(dynamic mode) => mode == 'practice'
      ? Icons.edit_note_rounded
      : mode == 'quiz'
      ? Icons.quiz_outlined
      : Icons.auto_stories_outlined;
  static String _eventLabel(String type) => type.endsWith('_completed')
      ? tr('Completed', 'पूर्ण')
      : type.endsWith('_started')
      ? tr('Started', 'सुरू')
      : tr('Left', 'बाहेर पडले');
  static String _relative(dynamic seconds, DateTime now) {
    if (seconds is! num) return '—';
    final elapsed = max(
      0,
      now.millisecondsSinceEpoch ~/ 1000 - seconds.toInt(),
    );
    return elapsed < 60
        ? tr('Just now', 'आत्ताच')
        : elapsed < 3600
        ? tr('${elapsed ~/ 60} min ago', '${elapsed ~/ 60} मिनिटांपूर्वी')
        : monitorTime(seconds);
  }
}

class DashboardBars extends StatelessWidget {
  final List<(String, double, String)> items;
  final Color color;
  final double? scaleMax;
  const DashboardBars({
    super.key,
    required this.items,
    this.color = _dashBlue,
    this.scaleMax,
  });
  @override
  Widget build(BuildContext context) {
    final maximum = max(
      1.0,
      scaleMax ?? items.fold<double>(0, (n, i) => max(n, i.$2)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isEmpty)
          Text(
            tr('No activity recorded yet.', 'अद्याप कृतीची नोंद नाही.'),
            style: const TextStyle(color: _dashMuted, fontSize: 14),
          ),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Semantics(
              label: '${item.$1}: ${item.$3}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text(
                        item.$1,
                        style: const TextStyle(fontSize: 13, color: ink),
                      ),
                      Text(
                        item.$3,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: (item.$2 / maximum).clamp(0, 1),
                    ),
                    duration: _dashDuration(context),
                    builder: (_, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 9,
                      borderRadius: BorderRadius.circular(5),
                      color: color,
                      backgroundColor: const Color(0xFFEEF1F7),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class DashboardAnalytics extends StatelessWidget {
  final Map<String, dynamic> data;
  final DateTime now;
  const DashboardAnalytics({super.key, required this.data, required this.now});
  @override
  Widget build(BuildContext context) {
    final a = Map<String, dynamic>.from(data['analytics'] ?? {});
    final chapters =
        Map<String, dynamic>.from(
          a['chapterUsage'] ?? {},
        ).entries.where((e) => _dashInt(e.value['started']) > 0).toList()..sort(
          (x, y) => _dashInt(
            y.value['started'],
          ).compareTo(_dashInt(x.value['started'])),
        );
    final users = _dashRows(data, 'users');
    String user(String id) =>
        users.where((u) => u['id'] == id).firstOrNull?['name']?.toString() ??
        tr('Assigned teacher', 'नेमलेले शिक्षक');
    final teacher =
        Map<String, dynamic>.from(a['teacherActivity'] ?? {}).entries.toList()
          ..sort((x, y) => _dashInt(y.value).compareTo(_dashInt(x.value)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardMetricGrid(
          children: [
            DashboardMetric(
              label: tr(
                'Active classrooms this week',
                'आठवड्यातील सक्रिय वर्ग',
              ),
              value: '${_dashInt(a['weeklyActiveClassrooms'])}',
              note: tr(
                '${_dashInt(a['dailyActiveClassrooms'])} active today',
                'आज ${_dashInt(a['dailyActiveClassrooms'])} सक्रिय',
              ),
              icon: Icons.school_outlined,
              color: _dashBlue,
            ),
            DashboardMetric(
              label: tr('Lessons completed', 'पूर्ण केलेले धडे'),
              value: '${_dashInt(a['lessonsCompleted'])}',
              note: tr(
                '${_dashInt(a['lessonsStarted'])} lessons started',
                '${_dashInt(a['lessonsStarted'])} धडे सुरू',
              ),
              icon: Icons.task_alt_rounded,
              color: _dashTeal,
            ),
            DashboardMetric(
              label: tr(
                'Practice & Quiz sessions',
                'सराव व प्रश्नमंजुषा सत्रे',
              ),
              value:
                  '${_dashInt(a['practiceSessions']) + _dashInt(a['quizSessions'])}',
              note: tr('Last 7 days', 'मागील ७ दिवस'),
              icon: Icons.extension_outlined,
              color: _dashPurple,
            ),
            DashboardMetric(
              label: tr(
                'Average completed session',
                'पूर्ण सत्रांचा सरासरी वेळ',
              ),
              value:
                  '${((a['averageSessionDuration'] as num? ?? 0) / 60).toStringAsFixed(1)} ${tr('min', 'मिनिटे')}',
              note: tr(
                'Classroom sessions · not student scores',
                'वर्गातील सत्रे · विद्यार्थ्यांचे गुण नाहीत',
              ),
              icon: Icons.timer_outlined,
              color: _dashAmber,
            ),
          ],
        ),
        const SizedBox(height: 22),
        DashboardWeekChart(
          usage: a['usageDaily'] as List? ?? [],
          today: now.toUtc(),
        ),
        const SizedBox(height: 22),
        DashboardColumns(
          left: DashboardPanel(
            title: tr('Most-used chapters', 'सर्वाधिक वापरलेले धडे'),
            subtitle: tr(
              'Session starts · last 7 days',
              'सुरू झालेली सत्रे · मागील ७ दिवस',
            ),
            child: DashboardBars(
              items: [
                for (final e in chapters.take(5))
                  (
                    chapterLabel(e.key),
                    _dashInt(e.value['started']).toDouble(),
                    '${e.value['started']}',
                  ),
              ],
            ),
          ),
          right: DashboardPanel(
            title: tr('Completion by chapter', 'धड्यानुसार पूर्ण झालेली सत्रे'),
            subtitle: tr(
              'Completed sessions / started sessions',
              'पूर्ण सत्रे / सुरू झालेली सत्रे',
            ),
            child: DashboardBars(
              scaleMax: 100,
              color: _dashTeal,
              items: [
                for (final e in chapters.take(5))
                  (
                    chapterLabel(e.key),
                    min(
                      100.0,
                      _dashInt(e.value['completed']) /
                          max(1, _dashInt(e.value['started'])) *
                          100,
                    ),
                    '${_dashInt(e.value['completed'])} / ${_dashInt(e.value['started'])}',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        DashboardColumns(
          left: DashboardPanel(
            title: tr('Practice by class', 'इयत्तेनुसार सराव'),
            child: DashboardBars(
              color: _dashTeal,
              items: [
                for (var g = 1; g <= 4; g++)
                  (
                    '${tr('Class', 'इयत्ता')} $g',
                    _dashInt(
                      (a['practiceByClass'] as Map? ?? {})['$g'],
                    ).toDouble(),
                    '${_dashInt((a['practiceByClass'] as Map? ?? {})['$g'])}',
                  ),
              ],
            ),
          ),
          right: DashboardPanel(
            title: tr('Quiz by class', 'इयत्तेनुसार प्रश्नमंजुषा'),
            child: DashboardBars(
              color: _dashPurple,
              items: [
                for (var g = 1; g <= 4; g++)
                  (
                    '${tr('Class', 'इयत्ता')} $g',
                    _dashInt((a['quizByClass'] as Map? ?? {})['$g']).toDouble(),
                    '${_dashInt((a['quizByClass'] as Map? ?? {})['$g'])}',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        DashboardColumns(
          left: DashboardPanel(
            title: tr('Account activity', 'खात्यांच्या कृती'),
            subtitle: tr(
              'Classroom session starts',
              'वर्गात सुरू झालेली सत्रे',
            ),
            child: DashboardBars(
              items: [
                for (final e in teacher.take(8))
                  (user(e.key), _dashInt(e.value).toDouble(), '${e.value}'),
              ],
            ),
          ),
          right: DashboardPanel(
            title: tr('App versions & errors', 'अॅप आवृत्त्या व त्रुटी'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DashboardBars(
                  color: _dashPurple,
                  items: [
                    for (final e in Map<String, dynamic>.from(
                      a['versionDistribution'] ?? {},
                    ).entries)
                      (
                        '${tr('Version', 'आवृत्ती')} ${e.key}',
                        _dashInt(e.value).toDouble(),
                        '${e.value}',
                      ),
                  ],
                ),
                const Divider(color: _dashLine),
                DashboardBars(
                  color: _dashAmber,
                  items: [
                    for (final e in Map<String, dynamic>.from(
                      a['errorFrequency'] ?? {},
                    ).entries)
                      (
                        monitorCode(e.key),
                        _dashInt(e.value).toDouble(),
                        '${e.value}',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
