part of 'main.dart';

/// A conservative adapter for the original chapter templates. A numerical
/// diagram is used only when the template and its answer agree. Unsupported
/// templates retain their original context symbols, rather than invented data.
class MathSceneModel {
  final String kind;
  final int first, second, result, remainder;
  const MathSceneModel(
    this.kind, {
    this.first = 0,
    this.second = 0,
    this.result = 0,
    this.remainder = 0,
  });

  static MathSceneModel fromQuestion(ChapterQuestion q) {
    final answer = q.options[q.correctIndex].en;
    final numeric = int.tryParse(answer);
    if (const {
      'addition',
      'subtraction',
      'equalGroups',
    }.contains(q.visualKind)) {
      final expected = {
        'addition': '+',
        'subtraction': '−',
        'equalGroups': '×',
      }[q.visualKind];
      final equations = RegExp(
        r'(\d+)\s*([+−×])\s*(\d+)\s*=\s*(\d+)',
      ).allMatches(q.explanation.en).toList();
      for (final match in equations.reversed) {
        final a = int.parse(match[1]!),
            b = int.parse(match[3]!),
            total = int.parse(match[4]!);
        final calculated = match[2] == '+'
            ? a + b
            : match[2] == '−'
            ? a - b
            : a * b;
        if (match[2] == expected && total == numeric && calculated == total) {
          return MathSceneModel(
            q.visualKind,
            first: a,
            second: b,
            result: total,
          );
        }
      }
    }
    if (q.visualKind == 'sharing') {
      final match = RegExp(
        r'^(\d+)\s*=\s*(\d+)\s*×\s*(\d+)(?:\s*\+\s*(\d+))?',
      ).firstMatch(q.explanation.en);
      if (match != null) {
        final total = int.parse(match[1]!),
            groups = int.parse(match[2]!),
            each = int.parse(match[3]!),
            rest = int.tryParse(match[4] ?? '') ?? 0;
        if (groups > 0 &&
            total == groups * each + rest &&
            rest < groups &&
            (numeric == each || numeric == rest)) {
          return MathSceneModel(
            'sharing',
            first: total,
            second: groups,
            result: each,
            remainder: rest,
          );
        }
      }
    }
    if (q.visualKind == 'fraction') {
      final parts = RegExp(r'^([0-9]+)/([0-9]+)$').firstMatch(answer);
      final template = RegExp(
        r'cut into (\d+) equal parts\. (\d+) parts are shaded',
      ).firstMatch(q.prompt.en);
      if (parts != null &&
          template != null &&
          parts[2] == template[1] &&
          parts[1] == template[2]) {
        return MathSceneModel(
          'fraction',
          first: int.parse(parts[1]!),
          second: int.parse(parts[2]!),
        );
      }
    }
    if (q.visualKind == 'clock') {
      final time = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(answer);
      if (time != null) {
        final hour = int.parse(time[1]!), minute = int.parse(time[2]!);
        if (hour >= 1 && hour <= 12 && minute >= 0 && minute < 60) {
          final start = RegExp(r'starts at (\d+):00').firstMatch(q.prompt.en);
          if (start == null) {
            final hands = RegExp(
              r'The short hand is (?:at|between) (\d+)(?: and \d+)? and the long hand is at (\d+)',
            ).firstMatch(q.prompt.en);
            if (hands == null ||
                int.parse(hands[1]!) != hour ||
                int.parse(hands[2]!) % 12 * 5 != minute)
              return const MathSceneModel('context');
          } else {
            final duration = RegExp(
              r'lasts (\d+) minutes',
            ).firstMatch(q.prompt.en);
            if (duration == null ||
                (int.parse(start[1]!) * 60 + int.parse(duration[1]!)) % 720 !=
                    (hour % 12) * 60 + minute)
              return const MathSceneModel('context');
          }
          return MathSceneModel(
            start == null ? 'clock' : 'elapsedClock',
            first: hour,
            second: minute,
            result: start == null ? hour : int.parse(start[1]!),
          );
        }
      }
    }
    if (q.visualKind == 'baseTen' &&
        numeric != null &&
        numeric >= 0 &&
        numeric <= 9999) {
      return MathSceneModel(
        q.prompt.en.startsWith('A basket has') ? 'count' : 'baseTen',
        first: numeric,
      );
    }
    if (q.visualKind == 'coins' && numeric != null) {
      final match = RegExp(
        r'You have (\d+) coins? worth ₹(\d+) each and one ₹(\d+) coin',
      ).firstMatch(q.prompt.en);
      if (match != null) {
        final count = int.parse(match[1]!),
            value = int.parse(match[2]!),
            extra = int.parse(match[3]!);
        if (count * value + extra == numeric)
          return MathSceneModel(
            'coins',
            first: count,
            second: value,
            remainder: extra,
            result: numeric,
          );
      }
    }
    if (q.visualKind == 'numberLine' && numeric != null) {
      final match = RegExp(r'^(\d+), (\d+), (\d+), __').firstMatch(q.prompt.en);
      if (match != null) {
        final a = int.parse(match[1]!),
            b = int.parse(match[2]!),
            c = int.parse(match[3]!);
        if (b - a == c - b && c + b - a == numeric)
          return MathSceneModel(
            'numberLine',
            first: a,
            second: b - a,
            result: numeric,
          );
      }
    }
    if (q.visualKind == 'barChart' && numeric != null) {
      final match = RegExp(
        r'shows (\d+) sun symbols.*Each sun stands for (\d+)',
      ).firstMatch(q.prompt.en);
      if (match != null &&
          int.parse(match[1]!) * int.parse(match[2]!) == numeric) {
        return MathSceneModel(
          'barChart',
          first: int.parse(match[1]!),
          second: int.parse(match[2]!),
          result: numeric,
        );
      }
    }
    return const MathSceneModel('context');
  }
}

String _sceneNumber(int n) {
  if (store.language != 1) return '$n';
  const digits = '०१२३४५६७८९';
  return '$n'
      .split('')
      .map((c) => int.tryParse(c) == null ? c : digits[int.parse(c)])
      .join();
}

class MathScene extends StatefulWidget {
  final ChapterQuestion question;
  final bool interactive, revealAnswer;
  final Object? replayKey;
  final ValueChanged<int>? onCountChanged;
  const MathScene({
    super.key,
    required this.question,
    this.interactive = false,
    this.revealAnswer = false,
    this.replayKey,
    this.onCountChanged,
  });
  @override
  State<MathScene> createState() => _MathSceneState();
}

class _MathSceneState extends State<MathScene> {
  final Set<int> touched = {};
  bool combined = false;
  int removed = 0, shared = 0;
  MathSceneModel get model => MathSceneModel.fromQuestion(widget.question);
  @override
  void didUpdateWidget(MathScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id ||
        oldWidget.replayKey != widget.replayKey) {
      touched.clear();
      combined = false;
      removed = 0;
      shared = 0;
    }
  }

  void _touch(int id) {
    if (!widget.interactive || touched.contains(id)) return;
    setState(() => touched.add(id));
    widget.onCountChanged?.call(touched.length);
  }

  @override
  Widget build(BuildContext context) {
    final m = model;
    return Semantics(
      label: tr(
        'Mathematical model for this question',
        'या प्रश्नाचे गणिती चित्र',
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: store.contrast ? Colors.white : LearningPalette.paper,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: LearningPalette.teal.withValues(alpha: .18),
          ),
        ),
        child: store.reducedMotion
            ? _body(m)
            : AnimatedSize(
                duration: Duration(milliseconds: store.slow ? 500 : 220),
                alignment: Alignment.topCenter,
                child: _body(m),
              ),
      ),
    );
  }

  Widget _body(MathSceneModel m) => switch (m.kind) {
    'addition' => _addition(m),
    'subtraction' => _subtraction(m),
    'equalGroups' => _groups(m),
    'sharing' => _sharing(m),
    'fraction' => _fraction(m),
    'clock' || 'elapsedClock' => _clock(m),
    'baseTen' => _placeValue(m),
    'count' => _count(m),
    'coins' => _coins(m),
    'numberLine' => _numberLine(m),
    'barChart' => _chart(m),
    _ => _context(),
  };

  Widget _caption(String en, String mr) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Text(
      tr(en, mr),
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 15, color: LearningPalette.ink, height: 1.45),
    ),
  );

  Widget _quantity(int count, int offset, Color color, {int crossed = 0}) {
    if (count > 30) return _numberCard(count, color);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 5,
      runSpacing: 5,
      children: List.generate(
        count,
        (i) => _counter(offset + i, color, crossed: i >= count - crossed),
      ),
    );
  }

  Widget _counter(int id, Color color, {bool crossed = false}) {
    final selected = touched.contains(id);
    final prompt = widget.question.prompt.en.toLowerCase();
    final mango = prompt.contains('mango');
    final icon = prompt.contains('pencil')
        ? Icons.edit_rounded
        : prompt.contains('book')
        ? Icons.menu_book_rounded
        : prompt.contains('leaf') ||
              prompt.contains('leaves') ||
              prompt.contains('seed')
        ? Icons.eco_outlined
        : Icons.circle;
    final label = tr(
      'Count item ${id + 1}${selected ? ', already counted' : ''}',
      'वस्तू ${_sceneNumber(id + 1)} मोजा${selected ? ', मोजली आहे' : ''}',
    );
    return Semantics(
      button: widget.interactive,
      label: label,
      selected: selected,
      child: SizedBox(
        width: widget.interactive ? (store.smartboard ? 72 : 64) : 58,
        height: widget.interactive ? (store.smartboard ? 72 : 64) : 62,
        child: InkWell(
          key: ValueKey('scene-object-$id'),
          onTap: widget.interactive && !crossed ? () => _touch(id) : null,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (mango)
                Opacity(
                  opacity: crossed ? .25 : 1,
                  child: Image.asset(
                    'assets/art/mango.png',
                    cacheWidth: 128,
                    width: 48,
                    height: 48,
                    errorBuilder: (_, _, _) =>
                        Icon(Icons.spa_rounded, color: color, size: 36),
                  ),
                )
              else
                Opacity(
                  opacity: crossed ? .25 : 1,
                  child: Icon(
                    icon,
                    color: color,
                    size: icon == Icons.circle ? 24 : 38,
                  ),
                ),
              if (selected)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: LearningPalette.teal,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _sceneNumber(touched.toList().indexOf(id) + 1),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (crossed)
                Icon(Icons.close, color: LearningPalette.clay, size: 44),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberCard(int n, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      _sceneNumber(n),
      style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: color),
    ),
  );

  Widget _group(int n, int offset, Color color, {String? label}) => Container(
    constraints: const BoxConstraints(minWidth: 90),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      border: Border.all(color: color.withValues(alpha: .35), width: 2),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _quantity(n, offset, color),
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    ),
  );

  Widget _addition(MathSceneModel m) {
    final merged = combined || widget.revealAnswer;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (merged)
          _group(
            m.result,
            0,
            LearningPalette.teal,
            label: widget.revealAnswer ? _sceneNumber(m.result) : null,
          )
        else
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14,
            runSpacing: 12,
            children: [
              _group(
                m.first,
                0,
                LearningPalette.blue,
                label: _sceneNumber(m.first),
              ),
              Text(
                '+',
                style: TextStyle(fontSize: 34, color: LearningPalette.ink),
              ),
              _group(
                m.second,
                m.first,
                LearningPalette.clay,
                label: _sceneNumber(m.second),
              ),
            ],
          ),
        if (widget.interactive && !widget.revealAnswer) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const ValueKey('combine-groups'),
            onPressed: () => setState(() => combined = !combined),
            icon: Icon(
              merged ? Icons.call_split_rounded : Icons.call_merge_rounded,
            ),
            label: Text(
              merged
                  ? tr('Show two groups', 'दोन गट दाखवा')
                  : tr('Bring the groups together', 'गट एकत्र आणा'),
            ),
          ),
        ],
        if (widget.revealAnswer) _equation(m.first, '+', m.second, m.result),
        if (widget.interactive && m.result <= 30)
          _caption(
            'Counted ${touched.length} objects. Tap each object once.',
            '${_sceneNumber(touched.length)} वस्तू मोजल्या. प्रत्येक वस्तूला एकदा स्पर्श करा.',
          ),
      ],
    );
  }

  Widget _subtraction(MathSceneModel m) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (m.first <= 30)
        _quantity(
          m.first,
          0,
          LearningPalette.blue,
          crossed: widget.revealAnswer ? m.second : removed,
        )
      else
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _numberCard(m.first, LearningPalette.blue),
            const Text('−', style: TextStyle(fontSize: 32)),
            _numberCard(m.second, LearningPalette.clay),
          ],
        ),
      if (widget.interactive && !widget.revealAnswer && m.first <= 30) ...[
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: removed < m.second
              ? () => setState(() => removed++)
              : null,
          icon: const Icon(Icons.remove_circle_outline),
          label: Text(tr('Take away one', 'एक वस्तू बाजूला करा')),
        ),
        _caption(
          'Taken away $removed of ${m.second}. Count what remains.',
          '${_sceneNumber(m.second)} पैकी ${_sceneNumber(removed)} बाजूला केल्या. उरलेल्या मोजा.',
        ),
      ],
      if (widget.revealAnswer) _equation(m.first, '−', m.second, m.result),
    ],
  );

  Widget _groups(MathSceneModel m) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (m.first <= 8 && m.first * m.second <= 40)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            m.first,
            (i) => _group(
              m.second,
              i * m.second,
              i.isEven ? LearningPalette.blue : LearningPalette.teal,
            ),
          ),
        )
      else
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          children: [
            _numberCard(m.first, LearningPalette.blue),
            const Text('×', style: TextStyle(fontSize: 32)),
            _numberCard(m.second, LearningPalette.clay),
          ],
        ),
      _caption(
        '${m.first} equal groups, ${m.second} in each.',
        '${_sceneNumber(m.first)} समान गट, प्रत्येकात ${_sceneNumber(m.second)}.',
      ),
      if (widget.revealAnswer) _equation(m.first, '×', m.second, m.result),
    ],
  );

  Widget _sharing(MathSceneModel m) {
    final amount = widget.revealAnswer ? m.first - m.remainder : shared;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            m.second,
            (i) => _group(
              amount ~/ m.second + (i < amount % m.second ? 1 : 0),
              i * (m.result + 1),
              LearningPalette.blue,
              label: tr('Group ${i + 1}', 'गट ${_sceneNumber(i + 1)}'),
            ),
          ),
        ),
        if (widget.interactive && !widget.revealAnswer) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: shared < m.first - m.remainder
                ? () => setState(() => shared++)
                : null,
            icon: const Icon(Icons.move_down_rounded),
            label: Text(tr('Share one object', 'एक वस्तू वाटा')),
          ),
          _caption(
            '${m.first - shared} still to share or set aside.',
            '${_sceneNumber(m.first - shared)} वस्तू वाटण्यासाठी किंवा बाजूला ठेवण्यासाठी उरल्या.',
          ),
        ] else if (!widget.revealAnswer)
          _caption(
            '${m.first} objects to share among ${m.second} groups.',
            '${_sceneNumber(m.first)} वस्तू ${_sceneNumber(m.second)} गटांत वाटा.',
          ),
        if (widget.revealAnswer)
          _caption(
            '${m.result} in each group; ${m.remainder} left over.',
            'प्रत्येक गटात ${_sceneNumber(m.result)}; बाकी ${_sceneNumber(m.remainder)}.',
          ),
      ],
    );
  }

  Widget _fraction(MathSceneModel m) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 18,
        runSpacing: 16,
        children: List.generate(
          (m.first / m.second).ceil().clamp(1, 3),
          (whole) => SizedBox(
            width: 146,
            height: 146,
            child: CustomPaint(
              painter: _FractionScenePainter(
                m.second,
                (m.first - whole * m.second).clamp(0, m.second),
                LearningPalette.teal,
              ),
            ),
          ),
        ),
      ),
      _caption(
        'Each whole has ${m.second} equal parts. The coloured parts are shaded.',
        'प्रत्येक पूर्ण आकाराचे ${_sceneNumber(m.second)} समान भाग आहेत. रंगीत भाग मोजा.',
      ),
      if (widget.revealAnswer)
        Text(
          '${_sceneNumber(m.first)}/${_sceneNumber(m.second)}',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: LearningPalette.teal,
          ),
        ),
    ],
  );

  Widget _clock(MathSceneModel m) {
    final hour = m.kind == 'elapsedClock' && !widget.revealAnswer
        ? m.result
        : m.first;
    final minute = m.kind == 'elapsedClock' && !widget.revealAnswer
        ? 0
        : m.second;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 202,
          height: 202,
          child: CustomPaint(painter: _SceneClockPainter(hour, minute)),
        ),
        _caption(
          'Short hand: hours. Long hand: minutes.',
          'लहान काटा: तास. मोठा काटा: मिनिटे.',
        ),
        if (widget.revealAnswer)
          Text(
            '${_sceneNumber(hour)}:${_sceneNumber(minute).padLeft(2, store.language == 1 ? '०' : '0')}',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  Widget _placeValue(MathSceneModel m) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 10,
    runSpacing: 10,
    children: [
      for (final value in [1000, 100, 10, 1])
        if (value <= m.first || value == 1)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: LearningPalette.teal.withValues(alpha: .3),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr(
                    {
                      1000: 'Thousands',
                      100: 'Hundreds',
                      10: 'Tens',
                      1: 'Ones',
                    }[value]!,
                    {1000: 'हजार', 100: 'शतके', 10: 'दशके', 1: 'एकके'}[value]!,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 3,
                  children: List.generate(
                    m.first ~/ value % 10,
                    (_) => Icon(
                      value == 1 ? Icons.circle : Icons.square_rounded,
                      size: value == 1 ? 12 : 17,
                      color: value >= 100
                          ? LearningPalette.blue
                          : LearningPalette.teal,
                    ),
                  ),
                ),
                Text(
                  '${_sceneNumber(m.first ~/ value % 10)} × ${_sceneNumber(value)}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
    ],
  );

  Widget _count(MathSceneModel m) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _quantity(m.first, 0, LearningPalette.teal),
      if (widget.interactive)
        _caption(
          'Counted ${touched.length}. Touch each object once.',
          '${_sceneNumber(touched.length)} मोजल्या. प्रत्येक वस्तूला एकदा स्पर्श करा.',
        ),
      if (widget.revealAnswer) _numberCard(m.first, LearningPalette.teal),
    ],
  );

  Widget _coins(MathSceneModel m) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < m.first + 1; i++)
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LearningPalette.amber.withValues(alpha: .2),
                border: Border.all(color: LearningPalette.clay, width: 2),
              ),
              child: Text(
                '₹${_sceneNumber(i == m.first ? m.remainder : m.second)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
        ],
      ),
      _caption(
        'Add the values, not just the number of coins.',
        'फक्त नाण्यांची संख्या नव्हे, त्यांच्या किंमती मिळवा.',
      ),
      if (widget.revealAnswer)
        Text(
          '₹${_sceneNumber(m.result)}',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
    ],
  );

  Widget _numberLine(MathSceneModel m) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          for (var i = 0; i < 4; i++)
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == 3
                    ? LearningPalette.amber.withValues(alpha: .2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LearningPalette.blue),
              ),
              child: Text(
                i == 3 && !widget.revealAnswer
                    ? '?'
                    : _sceneNumber(m.first + m.second * i),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      _caption(
        'Make the same jump each time.',
        'प्रत्येक वेळी तेवढीच उडी घ्या.',
      ),
    ],
  );

  Widget _chart(MathSceneModel m) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          m.first,
          (_) => Icon(
            Icons.wb_sunny_rounded,
            color: LearningPalette.amber,
            size: 38,
          ),
        ),
      ),
      _caption(
        'Key: one sun stands for ${m.second} kite${m.second == 1 ? '' : 's'}.',
        'खूण: एक सूर्य म्हणजे ${_sceneNumber(m.second)} पतंग.',
      ),
      if (widget.revealAnswer) _numberCard(m.result, LearningPalette.teal),
    ],
  );

  Widget _context() {
    final q = widget.question;
    final icon = switch (q.visualKind) {
      'positions' || 'sketchMap' || 'gridMap' => Icons.explore_outlined,
      'shape' ||
      'solidShape' ||
      'geometry' ||
      'angles' => Icons.category_outlined,
      'measurement' => Icons.straighten_rounded,
      'calendar' => Icons.calendar_month_outlined,
      'symmetry' => Icons.flip_rounded,
      'capacity' => Icons.water_drop_outlined,
      'unitCubes' => Icons.view_in_ar_outlined,
      _ => Icons.auto_stories_outlined,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: LearningPalette.teal),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 10,
          children: [
            for (var i = 0; i < q.objects.length; i++)
              Semantics(
                label: tr(
                  'Story symbol ${i + 1}',
                  'गोष्टीतील चिन्ह ${_sceneNumber(i + 1)}',
                ),
                child: Text(q.objects[i], style: const TextStyle(fontSize: 34)),
              ),
          ],
        ),
        _caption(
          'Use the story and its clues. These symbols show the setting.',
          'गोष्ट आणि तिच्या खुणा वापरा. ही चिन्हे गोष्टीची जागा दाखवतात.',
        ),
        if (widget.revealAnswer)
          Text(
            q.explanation.inLanguage(store.language),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, height: 1.5),
          ),
      ],
    );
  }

  Widget _equation(int a, String sign, int b, int answer) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      children: [
        Text(
          _sceneNumber(a),
          style: TextStyle(
            color: LearningPalette.blue,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(sign, style: const TextStyle(fontSize: 28)),
        Text(
          _sceneNumber(b),
          style: TextStyle(
            color: LearningPalette.clay,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Text('=', style: TextStyle(fontSize: 28)),
        Text(
          _sceneNumber(answer),
          style: TextStyle(
            color: LearningPalette.teal,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _FractionScenePainter extends CustomPainter {
  final int total, shaded;
  final Color color;
  _FractionScenePainter(this.total, this.shaded, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero),
        radius = min(size.width, size.height) / 2 - 4;
    final rect = Rect.fromCircle(center: centre, radius: radius);
    for (var i = 0; i < total; i++) {
      canvas.drawArc(
        rect,
        -pi / 2 + 2 * pi * i / total,
        2 * pi / total,
        true,
        Paint()
          ..color = i < shaded ? color.withValues(alpha: .7) : Colors.white,
      );
      canvas.drawArc(
        rect,
        -pi / 2 + 2 * pi * i / total,
        2 * pi / total,
        true,
        Paint()
          ..color = LearningPalette.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FractionScenePainter old) =>
      old.total != total || old.shaded != shaded || old.color != color;
}

class _SceneClockPainter extends CustomPainter {
  final int hour, minute;
  _SceneClockPainter(this.hour, this.minute);
  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero),
        radius = min(size.width, size.height) / 2 - 8;
    canvas.drawCircle(centre, radius, Paint()..color = Colors.white);
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = LearningPalette.teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    for (var i = 1; i <= 12; i++) {
      final angle = i * pi / 6 - pi / 2;
      final tp = TextPainter(
        text: TextSpan(
          text: _sceneNumber(i),
          style: TextStyle(
            color: LearningPalette.ink,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        centre +
            Offset(cos(angle), sin(angle)) * (radius - 20) -
            Offset(tp.width / 2, tp.height / 2),
      );
    }
    void hand(double angle, double length, Color color, double stroke) =>
        canvas.drawLine(
          centre,
          centre + Offset(cos(angle), sin(angle)) * length,
          Paint()
            ..color = color
            ..strokeWidth = stroke
            ..strokeCap = StrokeCap.round,
        );
    hand(
      (hour % 12 + minute / 60) * pi / 6 - pi / 2,
      radius * .48,
      LearningPalette.clay,
      6,
    );
    hand(minute * pi / 30 - pi / 2, radius * .72, LearningPalette.blue, 4);
    canvas.drawCircle(centre, 5, Paint()..color = LearningPalette.ink);
  }

  @override
  bool shouldRepaint(covariant _SceneClockPainter old) =>
      old.hour != hour || old.minute != minute;
}
