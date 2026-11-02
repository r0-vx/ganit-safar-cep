import 'dart:math';
import 'models.dart';
import 'localized_text.dart';
export 'localized_text.dart';

class Topic {
  final String id, icon;
  final Words _name;
  const Topic(this.id, this.icon, this._name);
  Words get name =>
      _name.identified('topic.$id.title', glossaryTerms: glossaryTermsFor(id));
}

const topics = [
  Topic('count', '🍎', Words('Numbers & counting', 'संख्या आणि मोजणी')),
  Topic('place', '🧩', Words('Place value', 'स्थानिक किंमत')),
  Topic('add', '🥭', Words('Addition', 'बेरीज')),
  Topic('subtract', '🍌', Words('Subtraction', 'वजाबाकी')),
  Topic('multiply', '🌻', Words('Multiplication', 'गुणाकार')),
  Topic('divide', '🧺', Words('Division', 'भागाकार')),
  Topic('fraction', '🍕', Words('Fractions', 'अपूर्णांक')),
  Topic('shape', '🔷', Words('Shapes & geometry', 'आकार आणि भूमिती')),
  Topic('measure', '📏', Words('Measurement', 'मोजमाप')),
  Topic('time', '🕒', Words('Time', 'वेळ')),
  Topic('money', '🪙', Words('Money', 'पैसे')),
  Topic('pattern', '🚂', Words('Patterns', 'नमुने')),
  Topic('data', '📊', Words('Data & graphs', 'माहिती आणि आलेख')),
  Topic('word', '📚', Words('Word problems', 'शाब्दिक उदाहरणे')),
];
const questionTypes = [
  'choice',
  'truefalse',
  'fill',
  'count',
  'order',
  'drag',
  'match',
  'story',
  'numberline',
  'model',
  'clock',
  'coins',
  'colour',
  'graph',
  'construct',
];
const typeNames = {
  'choice': Words('Multiple choice', 'योग्य पर्याय'),
  'truefalse': Words('True or false', 'बरोबर की चूक'),
  'fill': Words('Missing number', 'गाळलेली संख्या'),
  'count': Words('Count objects', 'वस्तू मोजा'),
  'order': Words('Arrange numbers', 'संख्या क्रमाने लावा'),
  'drag': Words('Drag the answer', 'उत्तर ओढा'),
  'match': Words('Match pairs', 'जोड्या जुळवा'),
  'story': Words('Visual story', 'चित्रकथा'),
  'numberline': Words('Number line', 'संख्यारेषा'),
  'model': Words('Choose a model', 'योग्य चित्र निवडा'),
  'clock': Words('Set the clock', 'घड्याळ लावा'),
  'coins': Words('Make a price', 'किंमत तयार करा'),
  'colour': Words('Colour a fraction', 'अपूर्णांक रंगवा'),
  'graph': Words('Choose a graph', 'आलेख निवडा'),
  'construct': Words('Build a shape', 'आकार तयार करा'),
};

class Question {
  final Words prompt, explanation;
  final int answer, a, b;
  final List<int> options;
  final String type, icon;
  final GenerationMetadata? metadata;
  String get id =>
      'gs-v2-${metadata?.grade}-${metadata?.topic}-${metadata?.templateId}-${metadata?.seed}';
  Question(
    this.prompt,
    this.explanation,
    this.answer,
    this.a,
    this.b,
    this.options,
    this.type,
    this.icon, {
    this.metadata,
  });

  Map<String, Words> get localizedTexts => {
    'prompt': prompt,
    'explanation': explanation,
    for (var i = 0; i < options.length; i++)
      'option.$i': Words(
        '${options[i]}',
        '${options[i]}',
        id: '${prompt.id}.option.$i',
        mathGlossaryTerms: glossaryTermsFor(metadata?.topic ?? ''),
      ),
  };
}

Question makeQuestion(
  String topic,
  int grade,
  int index,
  String type, {
  int difficulty = 1,
}) {
  final r = Random(
    grade * 10000 + index * 31 + topics.indexWhere((t) => t.id == topic) * 101,
  );
  final limit = grade == 1
      ? 5
      : grade == 2
      ? 12
      : grade == 3
      ? 30
      : 60;
  var a = 1 + r.nextInt(limit * difficulty), b = 1 + r.nextInt(grade + 4);
  int answer;
  Words prompt, explanation;
  String icon = topics.firstWhere((t) => t.id == topic).icon;
  switch (topic) {
    case 'count':
      a = 1 + index % (grade * 3 + 7);
      b = 0;
      answer = a;
      prompt = const Words(
        'How many apples can you count?',
        'किती सफरचंदे आहेत? मोजा.',
      );
      explanation = Words(
        'Touch each apple once. ${a == 1 ? 'There is 1 apple' : 'There are $a apples'}.',
        'प्रत्येक सफरचंदाला एकदा स्पर्श करा. एकूण $a सफरचंदे आहेत.',
      );
    case 'place':
      a = grade == 1 ? 10 + index % 10 : 21 + index * grade;
      b = 10;
      answer = a ~/ 10;
      prompt = Words('How many tens are in $a?', '$a मध्ये किती दशक आहेत?');
      explanation = Words(
        '$a = ${a ~/ 10} tens and ${a % 10} ones.',
        '$a = ${a ~/ 10} दशक आणि ${a % 10} एकक.',
      );
    case 'subtract':
      if (b > a) {
        final temp = a;
        a = b;
        b = temp;
      }
      answer = a - b;
      prompt = Words(
        '$a ${a == 1 ? 'banana' : 'bananas'}. We eat $b. How many remain?',
        '$a केळी आहेत. आपण $b केळी खाल्ली. किती उरली?',
      );
      explanation = Words(
        'Start at $a and count back $b: $a − $b = $answer.',
        '$a पासून $b मागे मोजा: $a − $b = $answer.',
      );
    case 'multiply':
      a = 2 + index % (grade + 2);
      answer = a * b;
      prompt = Words(
        '$a groups of $b ${b == 1 ? 'flower' : 'flowers'}. How many flowers?',
        '$b फुलांचे $a गट आहेत. एकूण किती फुले?',
      );
      explanation = Words(
        'Add $b a total of $a times. $a × $b = $answer.',
        '$b ची $a वेळा बेरीज करा. $a × $b = $answer.',
      );
    case 'divide':
      answer = a % 8 + 1;
      a = answer * b;
      prompt = Words(
        'Share $a ${a == 1 ? 'book' : 'books'} equally among $b ${b == 1 ? 'child' : 'children'}. Each gets?',
        '$a पुस्तके $b मुलांना समान वाटा. प्रत्येकाला किती?',
      );
      explanation = Words(
        '$b equal ${b == 1 ? 'group' : 'groups'} of $answer make $a. $a ÷ $b = $answer.',
        '$answer चे $b समान गट म्हणजे $a. $a ÷ $b = $answer.',
      );
    case 'fraction':
      b = [2, 3, 4, 5, 6, 8][index % 6];
      a = 1 + (index ~/ 6) % (b - 1);
      answer = a;
      prompt = Words(
        'Colour $a of $b equal pizza slices. How many coloured?',
        'पिझ्झाच्या $b समान भागांपैकी $a भाग रंगवा. किती रंगवले?',
      );
      explanation = Words(
        '$a coloured ${a == 1 ? 'slice' : 'slices'} out of $b equal slices means $a/$b.',
        '$b समान भागांपैकी $a रंगवलेले भाग म्हणजे $a/$b.',
      );
    case 'shape':
      a = index % 3;
      b = 0;
      answer = [3, 4, 0][a];
      icon = ['🔺', '🟦', '🔵'][a];
      final names = [
        const Words('triangle', 'त्रिकोण'),
        const Words('square', 'चौरस'),
        const Words('circle', 'वर्तुळ'),
      ];
      prompt = Words(
        '${["Mira draws a shape.", "Ravi finds a toy.", "We look at a classroom picture.", "A farmer draws in the sand.", "A friend makes a paper shape."][index ~/ 3 % 5]} How many straight sides does this ${names[a].en} have?',
        '${["मीरा आकार काढते.", "रवीला खेळणे सापडते.", "आपण वर्गातील चित्र पाहतो.", "शेतकरी वाळूत आकार काढतो.", "मैत्रीण कागदाचा आकार बनवते."][index ~/ 3 % 5]} या ${names[a].mr} आकाराला किती सरळ बाजू आहेत?',
      );
      explanation = Words(
        'A ${names[a].en} has $answer straight sides.',
        '${names[a].mr} या आकाराला $answer सरळ बाजू आहेत.',
      );
    case 'measure':
      a = 1 + index % 10;
      b = 0;
      answer = a;
      prompt = Words(
        'A pencil ends at $a cm, starting at 0. Its length?',
        'पेन्सिल 0 पासून $a सेमीपर्यंत आहे. तिची लांबी किती?',
      );
      explanation = Words(
        'Read the ruler from zero. The pencil is $a cm long.',
        'पट्टीवर शून्यापासून मोजा. पेन्सिलची लांबी $a सेमी आहे.',
      );
    case 'time':
      a = index % 12 + 1;
      b = 0;
      answer = a;
      prompt = const Words(
        'The long hand is at 12. What hour is shown?',
        'मोठा काटा 12 वर आहे. किती वाजले आहेत?',
      );
      explanation = Words(
        'The short hand points to $a. It is $a o’clock.',
        'लहान काटा $a वर आहे. आता $a वाजले आहेत.',
      );
    case 'money':
      a = [1, 2, 5, 10][index % 4];
      b = [1, 2, 5][index % 3];
      answer = a + b;
      prompt = Words(
        'You have ₹$a and ₹$b. How much altogether?',
        'तुमच्याकडे ₹$a आणि ₹$b आहेत. एकूण किती रुपये?',
      );
      explanation = Words(
        'Add the coin values: ₹$a + ₹$b = ₹$answer.',
        'नाण्यांच्या किमतींची बेरीज करा: ₹$a + ₹$b = ₹$answer.',
      );
    case 'pattern':
      b = grade + 1;
      a = (index % 10 + 1) * b;
      answer = a + 3 * b;
      prompt = Words(
        '$a, ${a + b}, ${a + 2 * b}, … What comes next?',
        '$a, ${a + b}, ${a + 2 * b}, … पुढची संख्या कोणती?',
      );
      explanation = Words(
        'Add $b each time. The next number is $answer.',
        'प्रत्येक वेळी $b मिळवा. पुढची संख्या $answer आहे.',
      );
    case 'data':
      a = 2 + index % 7;
      b = 1 + index % 4;
      answer = a + b;
      prompt = Words(
        'Our farm has $a cows and $b ${b == 1 ? 'goat' : 'goats'}. Total animals?',
        'शेतावर $a गायी आणि $b शेळ्या आहेत. एकूण प्राणी किती?',
      );
      explanation = Words(
        'Combine both bars: $a + $b = $answer animals.',
        'दोन्ही स्तंभ मिळवा: $a + $b = $answer प्राणी.',
      );
    case 'word':
      answer = a + b;
      prompt = Words(
        'A train has $a ${a == 1 ? 'child' : 'children'}. $b more ${b == 1 ? 'gets' : 'get'} on at the village. How many now?',
        'आगगाडीत $a मुले आहेत. गावात आणखी $b मुले चढली. आता किती मुले आहेत?',
      );
      explanation = Words(
        'More children join, so add: $a + $b = $answer.',
        'आणखी मुले आली, म्हणून बेरीज करा: $a + $b = $answer.',
      );
    default:
      if (index == 0 && grade == 1) {
        a = 3;
        b = 2;
      }
      answer = a + b;
      prompt = Words(
        'Mira has $a ${a == 1 ? 'mango' : 'mangoes'}. A friend gives her $b more. How many now?',
        'मीराकडे $a आंबे आहेत. मैत्रीण आणखी $b आंबे देते. आता किती आंबे झाले?',
      );
      explanation = Words(
        'Put both groups together: $a + $b = $answer mangoes!',
        'दोन्ही गट एकत्र करा: $a + $b = $answer आंबे!',
      );
  }
  final opts = <int>{answer};
  while (opts.length < 4) {
    opts.add(max(0, answer + r.nextInt(9) - 4));
  }
  final options = opts.toList()..shuffle(r);
  if (type == 'order') {
    final sorted = List<int>.from(options)..sort();
    prompt = const Words(
      'Arrange these numbers from smallest to largest.',
      'या संख्या लहान ते मोठ्या क्रमाने लावा.',
    );
    explanation = Words(
      'Compare the numbers. The order is ${sorted.join(' → ')}.',
      'संख्यांची तुलना करा. योग्य क्रम ${sorted.join(' → ')} आहे.',
    );
  } else if (type == 'match') {
    prompt = const Words(
      'Match each number to the same number of dots.',
      'प्रत्येक संख्या तितक्याच ठिपक्यांशी जुळवा.',
    );
    explanation = const Words(
      'Count each dot once: 1 matches ●, 2 matches ●●, 3 matches ●●●.',
      'प्रत्येक ठिपका एकदा मोजा: 1 ची जोडी ●, 2 ची ●●, 3 ची ●●●.',
    );
  }
  if (type == 'model' && topic == 'count')
    prompt = Words('Find a group of $a objects.', '$a वस्तूंचा गट शोधा.');
  if (type == 'clock')
    prompt = const Words(
      'Move the short hand to the requested hour.',
      'सांगितलेल्या तासावर लहान काटा ठेवा.',
    );
  if (type == 'coins')
    prompt = const Words(
      'Use coins to make the price below.',
      'खालील किंमत नाण्यांनी तयार करा.',
    );
  if (type == 'colour')
    prompt = const Words(
      'Show the fraction using equal parts.',
      'समान भाग वापरून अपूर्णांक दाखवा.',
    );
  if (type == 'graph')
    prompt = const Words(
      'Match the farm counts to a graph.',
      'शेतातील प्राण्यांची संख्या आलेखाशी जुळवा.',
    );
  if (type == 'numberline' && topic == 'count')
    prompt = Words('Find $a on the number line.', 'संख्यारेषेवर $a शोधा.');
  return Question(
    prompt.identified(
      'sample-g$grade-$topic-$type-$difficulty-$index.prompt',
      glossaryTerms: glossaryTermsFor(topic),
    ),
    explanation.identified(
      'sample-g$grade-$topic-$type-$difficulty-$index.explanation',
      glossaryTerms: glossaryTermsFor(topic),
    ),
    answer,
    a,
    b,
    options,
    type,
    icon,
    metadata: GenerationMetadata(
      templateId: '$topic-$type-v2',
      outcomeId: 'mh-g$grade-$topic-v1',
      topic: topic,
      skill: type,
      source:
          'https://books.ebalbharati.in/Workbooks/pdfs/${['1st', '2nd', '3rd', '4th'][grade - 1]}-Maths-Mar.pdf',
      grade: grade,
      difficulty: difficulty,
      seed: index,
    ),
  );
}

Words lessonStory(String id) => switch (id) {
  'subtract' => const Words('A banana picnic', 'केळ्यांची सहल'),
  'multiply' => const Words(
    'Flowers in our school garden',
    'आपल्या शाळेच्या बागेतील फुले',
  ),
  'divide' => const Words(
    'Books for every friend',
    'प्रत्येक मित्रासाठी पुस्तके',
  ),
  'fraction' => const Words('A pizza to share', 'पिझ्झा वाटून खाऊया'),
  'time' => const Words('Time for school!', 'शाळेची वेळ झाली!'),
  'money' => const Words(
    'A visit to the village market',
    'गावच्या बाजाराची भेट',
  ),
  _ => const Words('Mira’s little maths adventure', 'मीराची छोटी गणित सफर'),
};
