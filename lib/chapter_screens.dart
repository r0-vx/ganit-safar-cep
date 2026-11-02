part of 'main.dart';

PageRoute<void> _chapterPageRoute(Widget page) {
  final duration = Duration(
    milliseconds: store.reducedMotion ? 0 : (store.slow ? 700 : 260),
  );
  return PageRouteBuilder<void>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        store.reducedMotion
        ? child
        : FadeTransition(opacity: animation, child: child),
  );
}

Words _chapterStrandWords(String strand) => switch (strand.toLowerCase()) {
  'spatial' => const Words('Position', 'स्थिती'),
  'sequence' => const Words('Sequence', 'क्रम'),
  'shape' => const Words('Shapes', 'आकार'),
  'number' => const Words('Numbers', 'संख्या'),
  'addition' => const Words('Addition', 'बेरीज'),
  'subtraction' => const Words('Subtraction', 'वजाबाकी'),
  'data' => const Words('Data', 'माहिती'),
  'pattern' => const Words('Patterns', 'आकृतिबंध'),
  'measurement' => const Words('Measurement', 'मापन'),
  'time' => const Words('Time', 'वेळ'),
  'money' => const Words('Money', 'पैसे'),
  'multiplication' => const Words('Multiplication', 'गुणाकार'),
  'division' => const Words('Division', 'भागाकार'),
  'fraction' => const Words('Fractions', 'अपूर्णांक'),
  'operations' => const Words('Operations', 'क्रिया'),
  'place' => const Words('Place value', 'स्थानिक किंमत'),
  'application' => const Words('Applications', 'उपयोजन'),
  'area' => const Words('Area', 'क्षेत्रफळ'),
  'capacity' => const Words('Capacity', 'धारकता'),
  'map' => const Words('Maps', 'नकाशे'),
  'puzzle' => const Words('Puzzles', 'कोडी'),
  'symmetry' => const Words('Symmetry', 'सममिती'),
  _ => const Words('Mathematics', 'गणित'),
};

Words _chapterPageRange(SchoolChapter chapter) =>
    chapter.pageStart == chapter.pageEnd
    ? Words('Page ${chapter.pageStart}', 'पान ${chapter.pageStart}')
    : Words(
        'Pages ${chapter.pageStart}–${chapter.pageEnd}',
        'पाने ${chapter.pageStart}–${chapter.pageEnd}',
      );

/// A teacher-facing index of the approved textbook chapters.
class ChapterDirectoryPage extends StatelessWidget {
  final String mode;
  const ChapterDirectoryPage({super.key, this.mode = 'learn'});

  void _selectGrade(int grade) {
    if (store.grade == grade) return;
    store.grade = grade;
    store.save();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final chapters = chaptersForGrade(store.grade);
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Heading(
              mode == 'practice'
                  ? tr('Choose a chapter to practise', 'सरावासाठी धडा निवडा')
                  : mode == 'quiz'
                  ? tr(
                      'Choose a chapter for a quiz',
                      'प्रश्नमंजुषेसाठी धडा निवडा',
                    )
                  : tr(
                      'Textbook chapter directory',
                      'पाठ्यपुस्तक धड्यांची सूची',
                    ),
              mode == 'practice'
                  ? tr(
                      'Browse the approved chapter list, then practise with questions from that chapter.',
                      'मंजूर धड्यांची सूची पाहा आणि निवडलेल्या धड्याच्या प्रश्नांचा सराव करा.',
                    )
                  : mode == 'quiz'
                  ? tr(
                      'Browse the approved chapter list, then start a quiz for that chapter.',
                      'मंजूर धड्यांची सूची पाहा आणि निवडलेल्या धड्याची प्रश्नमंजुषा सुरू करा.',
                    )
                  : tr(
                      'Choose a class to browse every approved chapter by number, title, strand, and page.',
                      'क्रमांक, शीर्षक, गणिती विभाग आणि पानानुसार मंजूर धडे पाहण्यासाठी इयत्ता निवडा.',
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              tr('Choose a class', 'इयत्ता निवडा'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final buttonWidth = min(174.0, constraints.maxWidth);
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(4, (i) {
                    final grade = i + 1;
                    final selected = store.grade == grade;
                    final count = chaptersForGrade(grade).length;
                    return SizedBox(
                      width: buttonWidth,
                      height: 120,
                      child: selected
                          ? FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: gradeColors[i],
                                minimumSize: const Size(64, 72),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              onPressed: () => _selectGrade(grade),
                              child: _gradeButtonLabel(grade, count),
                            )
                          : OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: gradeColors[i],
                                side: BorderSide(
                                  color: gradeColors[i],
                                  width: 2,
                                ),
                                minimumSize: const Size(64, 72),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              onPressed: () => _selectGrade(grade),
                              child: _gradeButtonLabel(grade, count),
                            ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Heading(
                    tr(
                      'Class ${store.grade} chapters',
                      'इयत्ता ${store.grade} चे धडे',
                    ),
                    tr(
                      '${chapters.length} chapters • Tap a chapter to open its lesson.',
                      '${chapters.length} धडे • धडा उघडण्यासाठी त्यावर स्पर्श करा.',
                    ),
                  ),
                ),
                Text(
                  tr('APPROVED LIST', 'मंजूर सूची'),
                  style: TextStyle(
                    color: gradeColors[store.grade - 1],
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1320
                    ? 3
                    : constraints.maxWidth >= 760
                    ? 2
                    : 1;
                final gap = 14.0;
                final cardWidth =
                    (constraints.maxWidth - (columns - 1) * gap) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final chapter in chapters)
                      SizedBox(
                        width: cardWidth,
                        child: _ChapterDirectoryCard(
                          chapter: chapter,
                          actionLabel: mode == 'practice'
                              ? tr('Practise', 'सराव')
                              : mode == 'quiz'
                              ? tr('Start quiz', 'प्रश्नमंजुषा')
                              : tr('Open lesson', 'धडा उघडा'),
                          onTap: () {
                            if (mode == 'practice') {
                              Navigator.push<void>(
                                context,
                                _chapterPageRoute(
                                  ChapterSessionPage(
                                    chapter: chapter,
                                    mode: ChapterSessionMode.practice,
                                  ),
                                ),
                              );
                            } else if (mode == 'quiz') {
                              Navigator.push<void>(
                                context,
                                _chapterPageRoute(
                                  ChapterSessionPage(
                                    chapter: chapter,
                                    mode: ChapterSessionMode.quiz,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push<void>(
                                context,
                                _chapterPageRoute(
                                  ChapterLessonPage(chapter: chapter),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    },
  );

  Widget _gradeButtonLabel(int grade, int count) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        tr('Class $grade', 'इयत्ता $grade'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 15,
          height: 1.05,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        tr('$count chapters', '$count धडे'),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, height: 1.05),
      ),
    ],
  );
}

class _ChapterDirectoryCard extends StatelessWidget {
  final SchoolChapter chapter;
  final String actionLabel;
  final VoidCallback onTap;
  const _ChapterDirectoryCard({
    required this.chapter,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final done = store.isChapterDone(chapter.id);
    final color = gradeColors[chapter.grade - 1];
    final numberBadge = Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        '${chapter.number}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 26,
        ),
      ),
    );
    final title = Text(
      chapter.title.inLanguage(store.language),
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        height: 1.4,
      ),
    );
    final metadata = Wrap(
      spacing: 8,
      runSpacing: 7,
      children: [
        _ChapterMetaChip(
          icon: Icons.menu_book_rounded,
          text: _chapterPageRange(chapter).inLanguage(store.language),
        ),
        _ChapterMetaChip(
          icon: Icons.category_rounded,
          text: _chapterStrandWords(chapter.strand).inLanguage(store.language),
        ),
        if (done)
          _ChapterMetaChip(
            icon: Icons.check_circle_rounded,
            text: tr('Lesson completed', 'धडा पूर्ण'),
            color: green,
          ),
      ],
    );
    final action = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.chevron_right_rounded, color: color, size: 30),
        Text(
          actionLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
    return LearningSurface(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 112),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 440) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          numberBadge,
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: color,
                            size: 28,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      title,
                      const SizedBox(height: 9),
                      metadata,
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          actionLabel,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    numberBadge,
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [title, const SizedBox(height: 9), metadata],
                      ),
                    ),
                    const SizedBox(width: 8),
                    action,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterMetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _ChapterMetaChip({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final foreground = color ?? const Color(0xFF334155);
      final iconColor = color ?? const Color(0xFF475569);
      return Container(
        constraints: BoxConstraints(
          minHeight: 34,
          maxWidth: constraints.maxWidth,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth < 100 ? 6 : 9,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(20),
        ),
        child: constraints.maxWidth < 100
            ? Tooltip(
                message: text,
                child: Semantics(
                  label: text,
                  child: Icon(icon, size: 18, color: iconColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 15, color: iconColor),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      text,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 12,
                        color: foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
      );
    },
  );
}

/// A locally navigated chapter lesson; changing language never resets its step.
class _ChapterRouteBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _ChapterRouteBar({required this.title, required this.onBack});
  @override
  Widget build(BuildContext context) => Material(
    color: store.contrast ? Colors.white : LearningPalette.surface,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: LayoutBuilder(
        builder: (context, c) {
          final selector = SizedBox(
            width: min(210, c.maxWidth),
            height: 64,
            child: DropdownButton<int>(
              isExpanded: true,
              value: store.language,
              itemHeight: 72,
              underline: const SizedBox(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              items: const [
                DropdownMenuItem(
                  value: 0,
                  child: Text('English', overflow: TextOverflow.ellipsis),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('मराठी', overflow: TextOverflow.ellipsis),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text(
                    'English + मराठी',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  store.language = value;
                  store.save();
                }
              },
            ),
          );
          final titleRow = Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: IconButton.filledTonal(
                  tooltip: tr('Back', 'मागे'),
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded, size: 27),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          );
          if (c.maxWidth / MediaQuery.textScalerOf(context).scale(1) < 620) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                titleRow,
                Align(alignment: Alignment.centerRight, child: selector),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: titleRow),
              const SizedBox(width: 12),
              selector,
            ],
          );
        },
      ),
    ),
  );
}

class _ChapterStepProgress extends StatelessWidget {
  final int current, total;
  const _ChapterStepProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        tr('Step ${current + 1} of $total', 'टप्पा ${current + 1} / $total'),
        textAlign: TextAlign.end,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
      const SizedBox(height: 7),
      LinearProgressIndicator(
        value: (current + 1) / total,
        minHeight: 7,
        borderRadius: BorderRadius.circular(8),
        color: green,
        backgroundColor: Colors.white,
      ),
    ],
  );
}

class _ChapterChoiceOption extends StatelessWidget {
  final int index;
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _ChapterChoiceOption({
    required this.index,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(
        color: selected ? green : const Color(0xFFCBD5E1),
        width: selected ? 3 : 1,
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? const Color(0xFFDBEAFE) : Colors.white,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 70),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: selected ? green : const Color(0xFFE2E8F0),
                    foregroundColor: selected ? Colors.white : ink,
                    child: Text(String.fromCharCode(65 + index)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle_rounded, color: green),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterHelpBox extends StatelessWidget {
  final String text;
  const _ChapterHelpBox({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7D6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEAB308)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lightbulb_rounded, color: Color(0xFFB45309)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(height: 1.55, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _ChapterCompletionMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFDCFCE7),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF166534),
          size: 30,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            tr('Chapter lesson complete', 'धड्याचा अभ्यास पूर्ण'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF166534),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

enum ChapterSessionMode { practice, quiz }
