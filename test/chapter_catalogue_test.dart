import 'package:flutter_test/flutter_test.dart';

import 'package:ganit_safar/chapter_catalogue.dart';

void main() {
  group('school chapter directory', () {
    test('contains the exact 79 approved chapter placements', () {
      expect(schoolChapters, hasLength(79));
      expect(chaptersForGrade(1), hasLength(29));
      expect(chaptersForGrade(2), hasLength(22));
      expect(chaptersForGrade(3), hasLength(14));
      expect(chaptersForGrade(4), hasLength(14));
      expect(chaptersForGrade(5), isEmpty);

      for (var grade = 1; grade <= 4; grade++) {
        final chapters = chaptersForGrade(grade);
        for (var index = 0; index < chapters.length; index++) {
          final chapter = chapters[index];
          expect(chapter.grade, grade);
          expect(chapter.number, index + 1);
          expect(
            chapter.id,
            'G$grade-C${(index + 1).toString().padLeft(2, '0')}',
          );
          expect(chapter.pageStart, greaterThan(0));
          expect(chapter.pageEnd, greaterThanOrEqualTo(chapter.pageStart));
          expect(chapter.title.en.trim(), isNotEmpty);
          expect(chapter.title.mr.trim(), isNotEmpty);
          expect(chapter.strand.trim(), isNotEmpty);
          expect(
            chapter.sourceUrl,
            startsWith('https://books.ebalbharati.in/pdfs/'),
          );
        }
      }

      expect(schoolChapters.first.title.en, 'My village');
      expect(schoolChapters.first.title.mr, 'माझे गाव');
      expect(schoolChapters.first.pageStart, 1);
      expect(schoolChapters.first.pageEnd, 1);
      expect(schoolChapters.last.title.en, 'Patterns');
      expect(schoolChapters.last.grade, 4);
      expect(schoolChapters.last.number, 14);
      expect(schoolChapters.last.pageStart, 110);
      expect(schoolChapters.last.pageEnd, 126);
      expect(
        schoolChapters.last.sourceUrl,
        'https://books.ebalbharati.in/pdfs/401060004.pdf',
      );
    });

    test('every chapter has a stable, distinct five-question bilingual set', () {
      for (final chapter in schoolChapters) {
        final questions = chapter.questions();
        final repeatedCall = chapter.questions();

        expect(questions, hasLength(5), reason: chapter.id);
        expect(
          questions.map((question) => question.id).toSet(),
          hasLength(5),
          reason: chapter.id,
        );
        expect(
          questions.map((question) => question.prompt.en).toSet(),
          hasLength(5),
          reason: chapter.id,
        );
        expect(
          questions.map((question) => question.prompt.mr).toSet(),
          hasLength(5),
          reason: chapter.id,
        );

        for (var index = 0; index < questions.length; index++) {
          final question = questions[index];
          expect(question.id, repeatedCall[index].id);
          expect(question.prompt.en, repeatedCall[index].prompt.en);
          expect(question.prompt.mr, repeatedCall[index].prompt.mr);
          expect(
            question.options.map((option) => option.en).toList(),
            repeatedCall[index].options.map((option) => option.en).toList(),
          );
          expect(question.correctIndex, repeatedCall[index].correctIndex);

          expect(question.prompt.en.trim(), isNotEmpty, reason: question.id);
          expect(question.prompt.mr.trim(), isNotEmpty, reason: question.id);
          expect(
            question.explanation.en.trim(),
            isNotEmpty,
            reason: question.id,
          );
          expect(
            question.explanation.mr.trim(),
            isNotEmpty,
            reason: question.id,
          );
          expect(question.hint.en.trim(), isNotEmpty, reason: question.id);
          expect(question.hint.mr.trim(), isNotEmpty, reason: question.id);
          expect(question.options, hasLength(4), reason: question.id);
          expect(
            question.options.map((option) => option.en).toSet(),
            hasLength(4),
            reason: question.id,
          );
          expect(
            question.options.map((option) => option.mr).toSet(),
            hasLength(4),
            reason: question.id,
          );
          expect(
            question.correctIndex,
            inInclusiveRange(0, 3),
            reason: question.id,
          );
          expect(question.objects, isNotEmpty, reason: question.id);
          expect(question.visualKind, isNotEmpty, reason: question.id);
          expect(
            question.objects.any(
              (object) => RegExp(r'[A-Za-z]').hasMatch(object),
            ),
            isFalse,
            reason:
                'Visual object names must stay language-neutral in ${question.id}',
          );
        }

        final lesson = chapter.lesson;
        expect(lesson.story.en.trim(), isNotEmpty, reason: chapter.id);
        expect(lesson.story.mr.trim(), isNotEmpty, reason: chapter.id);
        expect(lesson.concept.en.trim(), isNotEmpty, reason: chapter.id);
        expect(lesson.concept.mr.trim(), isNotEmpty, reason: chapter.id);
        expect(lesson.workedExample.en.trim(), isNotEmpty, reason: chapter.id);
        expect(lesson.workedExample.mr.trim(), isNotEmpty, reason: chapter.id);
        expect(lesson.hint.en.trim(), isNotEmpty, reason: chapter.id);
        expect(lesson.hint.mr.trim(), isNotEmpty, reason: chapter.id);
        expect(lesson.recap.en.trim(), isNotEmpty, reason: chapter.id);
        expect(lesson.recap.mr.trim(), isNotEmpty, reason: chapter.id);
        expect(lesson.objects, isNotEmpty, reason: chapter.id);
        expect(lesson.visualKind, isNotEmpty, reason: chapter.id);
      }
    });

    test('question count is bounded to ten', () {
      expect(chaptersForGrade(1).first.questions(count: 0), isEmpty);
      expect(chaptersForGrade(1).first.questions(count: 10), hasLength(10));
      expect(chaptersForGrade(1).first.questions(count: 99), hasLength(10));
    });

    test('addition and subtraction examples respect their class limits', () {
      void expectNumericOptions(String id, int maximum) {
        final chapter = schoolChapters.singleWhere((item) => item.id == id);
        for (final question in chapter.questions(count: 10)) {
          final correct = question.options[question.correctIndex];
          expect(int.tryParse(correct.en), isNotNull, reason: question.id);
          for (final option in question.options) {
            final value = int.tryParse(option.en);
            if (value != null) {
              expect(value, inInclusiveRange(0, maximum), reason: question.id);
            }
          }
        }
      }

      expectNumericOptions('G1-C10', 9);
      expectNumericOptions('G1-C11', 9);
      expectNumericOptions('G1-C17', 18);
      expectNumericOptions('G1-C18', 9);
      expectNumericOptions('G1-C25', 18);
      expectNumericOptions('G2-C08', 99);
      expectNumericOptions('G2-C09', 99);
      expectNumericOptions('G2-C14', 99);
      expectNumericOptions('G2-C15', 99);
    });
  });
}
