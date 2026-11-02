/// Versioned identities shared by curriculum, practice and central API boundaries.
const contentSchemaVersion = 2;

class ContentSourceReference {
  final String id, url, reviewStatus;
  const ContentSourceReference(this.id, this.url, this.reviewStatus);
}

class ClassPlan {
  final String id;
  final int grade;
  final List<String> topicIds;
  const ClassPlan(this.id, this.grade, this.topicIds);
}

class Subtopic {
  final String id, topicId, outcomeId;
  const Subtopic(this.id, this.topicId, this.outcomeId);
}

class Character {
  final String id, nameEn, nameMr;
  const Character(this.id, this.nameEn, this.nameMr);
}

class AnimationSpec {
  final String id, visualKind;
  final bool replayable, interruptible;
  const AnimationSpec(
    this.id,
    this.visualKind, {
    this.replayable = true,
    this.interruptible = true,
  });
}

class StoryScene {
  final String id, characterId, settingEn, settingMr, animationId;
  const StoryScene(
    this.id,
    this.characterId,
    this.settingEn,
    this.settingMr,
    this.animationId,
  );
}

class LessonSpec {
  final String id, outcomeId;
  final List<StoryScene> scenes;
  const LessonSpec(this.id, this.outcomeId, this.scenes);
}

class LearningHelpCard {
  final String id, outcomeId;
  const LearningHelpCard(this.id, this.outcomeId);
}

class QuestionTemplate {
  final String id, topic, skill;
  final int version;
  const QuestionTemplate(this.id, this.topic, this.skill, {this.version = 2});
}

class GenerationMetadata {
  final String templateId, outcomeId, topic, skill, source, reviewStatus;
  final int grade, difficulty, seed, schemaVersion;
  const GenerationMetadata({
    required this.templateId,
    required this.outcomeId,
    required this.topic,
    required this.skill,
    required this.source,
    required this.grade,
    required this.difficulty,
    required this.seed,
    this.reviewStatus = 'Needs curriculum review',
    this.schemaVersion = 2,
  });
}

class QuestionValidationResult {
  final List<String> errors;
  const QuestionValidationResult(this.errors);
  bool get valid => errors.isEmpty;
}

class PracticeSession {
  final String id;
  final List<String> topics, types;
  final int grade, difficulty, count;
  int current = 0, correct = 0;
  PracticeSession({
    required this.id,
    required this.topics,
    required this.types,
    required this.grade,
    required this.difficulty,
    required this.count,
  });
  Map<String, dynamic> toJson() => {
    'schemaVersion': 2,
    'id': id,
    'topics': topics,
    'types': types,
    'grade': grade,
    'difficulty': difficulty,
    'count': count,
    'current': current,
    'correct': correct,
  };
}

class QuizSpec {
  final String id;
  final int grade, count;
  final List<String> topics, types;
  const QuizSpec(this.id, this.grade, this.count, this.topics, this.types);
}

class ProgressRecord {
  final String id, topic;
  final int grade, correct, total;
  const ProgressRecord(
    this.id,
    this.topic,
    this.grade,
    this.correct,
    this.total,
  );
}

class MistakeRecord {
  final String id, questionId, explanationEn, explanationMr;
  const MistakeRecord(
    this.id,
    this.questionId,
    this.explanationEn,
    this.explanationMr,
  );
}

class TeacherIdentity {
  final String id, name, role, email;
  const TeacherIdentity(this.id, this.name, this.role, [this.email = '']);
}

class ClassroomIdentity {
  final String id, name, school;
  final int grade;
  const ClassroomIdentity(this.id, this.name, this.school, this.grade);
}

enum DeviceStatus { active, offline, neverConnected, needsAttention }

class WhiteboardDevice {
  final String id, name, classroomId;
  final DeviceStatus status;
  const WhiteboardDevice(this.id, this.name, this.classroomId, this.status);
}

class CentralSession {
  final TeacherIdentity teacher;
  final String token;
  const CentralSession(this.teacher, this.token);
}
