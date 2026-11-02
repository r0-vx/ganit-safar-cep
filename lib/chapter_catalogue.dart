import 'content.dart';

/// One approved chapter in the Maharashtra Balbharati Classes 1–4 sequence.
class SchoolChapter {
  final String id;
  final int grade, number, pageStart, pageEnd;
  final Words title;
  final String strand, sourceUrl;

  const SchoolChapter({
    required this.id,
    required this.grade,
    required this.number,
    required this.pageStart,
    required this.pageEnd,
    required this.title,
    required this.strand,
    required this.sourceUrl,
  });

  ChapterLesson get lesson {
    final objective = _objectiveFor(this);
    final first = questions(count: 1).first;
    final terms = glossaryTermsFor(strand);
    return ChapterLesson(
      story: Words(
        'Mira and Ravi explore: ${first.prompt.en}',
        'मीरा आणि रवी शोध घेतात: ${first.prompt.mr}',
      ).identified('$id.lesson.story', glossaryTerms: terms),
      concept: objective.identified('$id.lesson.concept', glossaryTerms: terms),
      workedExample: first.explanation,
      hint: first.hint,
      recap: Words(
        'Remember: ${objective.en}',
        'लक्षात ठेवा: ${objective.mr}',
      ).identified('$id.lesson.recap', glossaryTerms: terms),
      objects: first.objects,
      visualKind: first.visualKind,
    );
  }

  /// Builds a stable set of up to ten original, bilingual questions.
  List<ChapterQuestion> questions({int count = 5}) {
    final safeCount = count.clamp(0, 10).toInt();
    return List<ChapterQuestion>.unmodifiable(
      List.generate(safeCount, (index) => _questionFor(this, index)),
    );
  }
}

class ChapterLesson {
  final Words story, concept, workedExample, hint, recap;
  final List<String> objects;
  final String visualKind;

  const ChapterLesson({
    required this.story,
    required this.concept,
    required this.workedExample,
    required this.hint,
    required this.recap,
    required this.objects,
    required this.visualKind,
  });

  Map<String, Words> get localizedTexts => {
    'story': story,
    'concept': concept,
    'workedExample': workedExample,
    'hint': hint,
    'recap': recap,
  };
}

class ChapterQuestion {
  final String id;
  final Words prompt, explanation, hint;
  final List<Words> options;
  final int correctIndex;
  final List<String> objects;
  final String visualKind;

  const ChapterQuestion({
    required this.id,
    required this.prompt,
    required this.explanation,
    required this.hint,
    required this.options,
    required this.correctIndex,
    required this.objects,
    required this.visualKind,
  });

  Map<String, Words> get localizedTexts => {
    'prompt': prompt,
    'explanation': explanation,
    'hint': hint,
    for (var i = 0; i < options.length; i++) 'option.$i': options[i],
  };
}

class _ChapterSeed {
  final int grade, number, pageStart, pageEnd;
  final String mr, en, strand, subtopics;
  const _ChapterSeed(
    this.grade,
    this.number,
    this.pageStart,
    this.pageEnd,
    this.mr,
    this.en,
    this.strand,
    this.subtopics,
  );
}

const _chapterSeeds = <_ChapterSeed>[
  _ChapterSeed(
    1,
    1,
    1,
    1,
    "माझे गाव",
    "My village",
    "spatial",
    "above/below; inside/outside; front/behind",
  ),
  _ChapterSeed(
    1,
    2,
    2,
    2,
    "कोंबडा कोठे?",
    "Where is the rooster?",
    "spatial",
    "position words; object location",
  ),
  _ChapterSeed(
    1,
    3,
    3,
    3,
    "आधी-नंतर",
    "Before and after",
    "sequence",
    "order of two events",
  ),
  _ChapterSeed(
    1,
    4,
    4,
    4,
    "जवळ-दूर",
    "Near and far",
    "spatial",
    "distance comparison",
  ),
  _ChapterSeed(
    1,
    5,
    5,
    5,
    "माझा आकार",
    "My shape",
    "shape",
    "match everyday objects to shapes",
  ),
  _ChapterSeed(
    1,
    6,
    6,
    8,
    "घरंगळणे-घसरणे",
    "Rolling and sliding",
    "shape",
    "roll/slide; properties of objects",
  ),
  _ChapterSeed(
    1,
    7,
    9,
    15,
    "१ ते ९ची ओळख",
    "Recognising 1 to 9",
    "number",
    "one-to-one counting; numeral formation; number names",
  ),
  _ChapterSeed(
    1,
    8,
    16,
    16,
    "०ची ओळख",
    "Recognising zero",
    "number",
    "empty set; zero numeral",
  ),
  _ChapterSeed(
    1,
    9,
    17,
    18,
    "१०ची ओळख",
    "Recognising ten",
    "number",
    "making ten; numeral 10",
  ),
  _ChapterSeed(
    1,
    10,
    19,
    24,
    "बेरीज (उत्तर ९पर्यंत)",
    "Addition (answers to 9)",
    "addition",
    "join sets; count all; sums to nine",
  ),
  _ChapterSeed(
    1,
    11,
    25,
    29,
    "वजाबाकी",
    "Subtraction",
    "subtraction",
    "take away; count remaining",
  ),
  _ChapterSeed(
    1,
    12,
    30,
    32,
    "११ ते २०ची ओळख",
    "Recognising 11 to 20",
    "number",
    "ten and ones; number names",
  ),
  _ChapterSeed(
    1,
    13,
    33,
    33,
    "लगतची पुढची, लगतची मागची व मधली संख्या",
    "Next, previous and between",
    "number",
    "predecessor; successor; missing middle number",
  ),
  _ChapterSeed(
    1,
    14,
    34,
    36,
    "संख्यांचा लहान-मोठेपणा",
    "Comparing numbers",
    "number",
    "greater; smaller; equal",
  ),
  _ChapterSeed(
    1,
    15,
    37,
    41,
    "चढता क्रम-उतरता क्रम",
    "Ascending and descending order",
    "number",
    "order small sets of numbers",
  ),
  _ChapterSeed(
    1,
    16,
    42,
    44,
    "माहिती समजून घेऊ",
    "Understanding information",
    "data",
    "picture evidence; simple comparisons",
  ),
  _ChapterSeed(
    1,
    17,
    45,
    47,
    "बेरीज (पुढे मोजून)",
    "Addition by counting on",
    "addition",
    "start from first number; count forward",
  ),
  _ChapterSeed(
    1,
    18,
    48,
    49,
    "वजाबाकी (मागे मोजून)",
    "Subtraction by counting back",
    "subtraction",
    "start from first number; count backward",
  ),
  _ChapterSeed(
    1,
    19,
    50,
    52,
    "२१ ते ३०ची ओळख",
    "Recognising 21 to 30",
    "number",
    "tens/ones; reading numerals",
  ),
  _ChapterSeed(
    1,
    20,
    53,
    61,
    "३१ ते ९९ची ओळख",
    "Recognising 31 to 99",
    "number",
    "tens/ones; number names; numeral sequence",
  ),
  _ChapterSeed(
    1,
    21,
    62,
    63,
    "संख्यांचे गाणे",
    "Number song",
    "sequence",
    "number sequence and rhythm",
  ),
  _ChapterSeed(
    1,
    22,
    64,
    67,
    "आकृतिबंध",
    "Patterns",
    "pattern",
    "repeat; extend; create patterns",
  ),
  _ChapterSeed(
    1,
    23,
    68,
    71,
    "मापन",
    "Measurement",
    "measurement",
    "measure length with fingers/spans/steps; compare weight informally",
  ),
  _ChapterSeed(
    1,
    24,
    72,
    78,
    "कालमापन",
    "Time measurement",
    "time",
    "sequence daily events; duration; weekdays",
  ),
  _ChapterSeed(
    1,
    25,
    79,
    86,
    "बेरीज (उत्तर १८पर्यंत)",
    "Addition (answers to 18)",
    "addition",
    "combinations with total at most eighteen",
  ),
  _ChapterSeed(
    1,
    26,
    87,
    92,
    "नाणी व नोटा",
    "Coins and notes",
    "money",
    "recognise rupees; compose amounts",
  ),
  _ChapterSeed(
    1,
    27,
    93,
    95,
    "गुणाकार पूर्वतयारी",
    "Preparation for multiplication",
    "multiplication",
    "equal groups; repeated addition",
  ),
  _ChapterSeed(
    1,
    28,
    96,
    98,
    "समान वाटणी, समान गट",
    "Equal sharing and equal groups",
    "division",
    "equal sharing; fair groups",
  ),
  _ChapterSeed(
    1,
    29,
    99,
    105,
    "गणितीय कोडी",
    "Mathematical puzzles",
    "puzzle",
    "visual reasoning; number puzzles",
  ),
  _ChapterSeed(
    2,
    1,
    1,
    4,
    "भौमितिक आकार समजून घेऊ - भाग १",
    "Understanding geometric shapes, part 1",
    "shape",
    "recognise solids; properties of shapes",
  ),
  _ChapterSeed(
    2,
    2,
    5,
    7,
    "संख्या व संख्यानामे",
    "Numbers and number names",
    "number",
    "read and write 0–99; Marathi number names",
  ),
  _ChapterSeed(
    2,
    3,
    8,
    10,
    "एकक व दशक",
    "Ones and tens",
    "place",
    "group tens and ones",
  ),
  _ChapterSeed(
    2,
    4,
    11,
    13,
    "दर्शनी किंमत व स्थानिक किंमत",
    "Face value and place value",
    "place",
    "face value; tens/ones position",
  ),
  _ChapterSeed(
    2,
    5,
    14,
    18,
    "संख्यांचा लहान-मोठेपणा",
    "Comparing numbers",
    "number",
    "compare two-digit numbers",
  ),
  _ChapterSeed(
    2,
    6,
    19,
    21,
    "तीन संख्यांचा चढता व उतरता क्रम",
    "Ordering three numbers",
    "number",
    "ascending; descending",
  ),
  _ChapterSeed(
    2,
    7,
    22,
    23,
    "टप्प्याने मोजणी",
    "Skip counting",
    "sequence",
    "step counting; number sequence",
  ),
  _ChapterSeed(
    2,
    8,
    24,
    28,
    "बेरीज",
    "Addition",
    "addition",
    "join; column addition",
  ),
  _ChapterSeed(
    2,
    9,
    29,
    33,
    "वजाबाकी",
    "Subtraction",
    "subtraction",
    "take away; difference",
  ),
  _ChapterSeed(
    2,
    10,
    34,
    35,
    "बेरीज-वजाबाकी : सहसंबंध",
    "Addition and subtraction relationship",
    "operations",
    "inverse relation; fact families",
  ),
  _ChapterSeed(
    2,
    11,
    36,
    44,
    "गुणाकार",
    "Multiplication",
    "multiplication",
    "equal groups; repeated addition; tables",
  ),
  _ChapterSeed(
    2,
    12,
    45,
    52,
    "मापन",
    "Measurement",
    "measurement",
    "length; weight; capacity",
  ),
  _ChapterSeed(
    2,
    13,
    53,
    59,
    "भौमितिक आकार समजून घेऊ - भाग २",
    "Understanding geometric shapes, part 2",
    "shape",
    "shape properties; lines and flat shapes",
  ),
  _ChapterSeed(
    2,
    14,
    60,
    67,
    "बेरीज (हातच्याची)",
    "Addition with regrouping",
    "addition",
    "make a ten; carry to tens",
  ),
  _ChapterSeed(
    2,
    15,
    68,
    75,
    "वजाबाकी (दशक मोकळा करून, मागे मोजून)",
    "Subtraction by opening a ten and counting back",
    "subtraction",
    "unbundle a ten; count back",
  ),
  _ChapterSeed(
    2,
    16,
    76,
    77,
    "माहिती समजून घेऊ",
    "Understanding information",
    "data",
    "read pictures; compare categories",
  ),
  _ChapterSeed(
    2,
    17,
    78,
    81,
    "आकृतिबंध",
    "Patterns",
    "pattern",
    "repeating and growing patterns",
  ),
  _ChapterSeed(
    2,
    18,
    82,
    91,
    "कालमापन",
    "Time measurement",
    "time",
    "months; calendar dates; hours and days",
  ),
  _ChapterSeed(
    2,
    19,
    92,
    96,
    "बालआनंद मेळावा",
    "Children's fair",
    "application",
    "contextual mathematics; purchase and count",
  ),
  _ChapterSeed(
    2,
    20,
    97,
    99,
    "उपयोग गुणाकाराचा",
    "Using multiplication",
    "multiplication",
    "apply equal groups to situations",
  ),
  _ChapterSeed(
    2,
    21,
    100,
    103,
    "भागाकार",
    "Division",
    "division",
    "equal sharing; groups",
  ),
  _ChapterSeed(
    2,
    22,
    104,
    112,
    "गणितीय कोडी",
    "Mathematical puzzles",
    "puzzle",
    "number and shape reasoning",
  ),
  _ChapterSeed(
    3,
    1,
    1,
    6,
    "सभोवताली शोधू आकार",
    "Find shapes around us",
    "shape",
    "shapes in surroundings; properties",
  ),
  _ChapterSeed(
    3,
    2,
    7,
    24,
    "संख्यांशी खेळू या",
    "Let's play with numbers",
    "number",
    "counting history; hundreds to 999; place and face value; ordering; ordinal positions",
  ),
  _ChapterSeed(
    3,
    3,
    25,
    36,
    "बेरीज व वजाबाकी",
    "Addition and subtraction",
    "operations",
    "three-digit operations; word situations",
  ),
  _ChapterSeed(
    3,
    4,
    37,
    46,
    "अपूर्णांक",
    "Fractions",
    "fraction",
    "equal halves/quarters/three-quarters; fractions of sets; numerator/denominator; proper/improper",
  ),
  _ChapterSeed(
    3,
    5,
    47,
    53,
    "लांबी व वजन",
    "Length and weight",
    "measurement",
    "informal/standard units; metres and centimetres; kilograms; estimate and check",
  ),
  _ChapterSeed(
    3,
    6,
    54,
    58,
    "माहितीचे व्यवस्थापन",
    "Organising information",
    "data",
    "collect; tabulate; interpret",
  ),
  _ChapterSeed(
    3,
    7,
    59,
    65,
    "नजरी नकाशा",
    "Sketch map",
    "map",
    "front/side/top views; symbols; positions; route reading",
  ),
  _ChapterSeed(
    3,
    8,
    66,
    79,
    "गुणाकार",
    "Multiplication",
    "multiplication",
    "equal rows; tables; two-digit products; three-digit by one-digit",
  ),
  _ChapterSeed(
    3,
    9,
    80,
    91,
    "भागाकार",
    "Division",
    "division",
    "sharing; grouping; remainders",
  ),
  _ChapterSeed(
    3,
    10,
    92,
    102,
    "आकारांची गंमत भारी (द्विमितीय आकार)",
    "Fun with two-dimensional shapes",
    "shape",
    "flat faces of solids; sides/corners; geoboard construction; compare angles to square corner",
  ),
  _ChapterSeed(
    3,
    11,
    103,
    106,
    "सममिती",
    "Symmetry",
    "symmetry",
    "mirror halves; line of symmetry",
  ),
  _ChapterSeed(
    3,
    12,
    107,
    110,
    "आकारमान व धारकता",
    "Volume and capacity",
    "capacity",
    "container capacity; litre; half/quarter/three-quarter litre",
  ),
  _ChapterSeed(
    3,
    13,
    111,
    118,
    "कालमापन",
    "Time measurement",
    "time",
    "hour/minute hands; quarter/half/three-quarter hour; calendar",
  ),
  _ChapterSeed(
    3,
    14,
    119,
    126,
    "आकृतिबंध",
    "Patterns",
    "pattern",
    "visual and numeric sequences",
  ),
  _ChapterSeed(
    4,
    1,
    1,
    17,
    "संख्यांशी खेळू या",
    "Let's play with numbers",
    "number",
    "place value to 9999; expanded form; comparison; even/odd; Indian number system",
  ),
  _ChapterSeed(
    4,
    2,
    18,
    26,
    "आकारांची गंमत भारी",
    "Fun with shapes",
    "shape",
    "angles; right-angle comparison; triangle/square/rectangle; circles and compass-like drawing",
  ),
  _ChapterSeed(
    4,
    3,
    27,
    36,
    "बेरीज व वजाबाकी",
    "Addition and subtraction",
    "operations",
    "larger-number operations; situations",
  ),
  _ChapterSeed(
    4,
    4,
    37,
    42,
    "अपूर्णांक",
    "Fractions",
    "fraction",
    "tangram partitions; mixed-number language; fractions of shapes and sets",
  ),
  _ChapterSeed(
    4,
    5,
    43,
    56,
    "लांबी व वजन",
    "Length and weight",
    "measurement",
    "millimetre/centimetre/metre/kilometre; length conservation; grams/kilograms; estimate and check",
  ),
  _ChapterSeed(
    4,
    6,
    57,
    61,
    "माहितीचे व्यवस्थापन",
    "Organising information",
    "data",
    "picture tables; pictograph scale; interpret categories",
  ),
  _ChapterSeed(
    4,
    7,
    62,
    67,
    "नजरी नकाशा",
    "Sketch map",
    "map",
    "front/side/top views; grid location; symbols; directions",
  ),
  _ChapterSeed(
    4,
    8,
    68,
    74,
    "गुणाकार",
    "Multiplication",
    "multiplication",
    "multi-digit multiplication; contexts",
  ),
  _ChapterSeed(
    4,
    9,
    75,
    86,
    "भागाकार",
    "Division",
    "division",
    "sharing; long division; remainders",
  ),
  _ChapterSeed(
    4,
    10,
    87,
    91,
    "सममिती",
    "Symmetry",
    "symmetry",
    "folding; mirror and water reflections; symmetry axes",
  ),
  _ChapterSeed(
    4,
    11,
    92,
    100,
    "परिमिती व क्षेत्रफळ",
    "Perimeter and area",
    "area",
    "boundary length; square units",
  ),
  _ChapterSeed(
    4,
    12,
    101,
    106,
    "आकारमान व धारकता",
    "Volume and capacity",
    "capacity",
    "unit cubes; cubic volume; litre/millilitre; conservation on pouring",
  ),
  _ChapterSeed(
    4,
    13,
    107,
    109,
    "कालमापन",
    "Time measurement",
    "time",
    "analogue/digital clock; 15/30/45-minute intervals; elapsed time",
  ),
  _ChapterSeed(
    4,
    14,
    110,
    126,
    "आकृतिबंध",
    "Patterns",
    "pattern",
    "growing visual and numeric sequences",
  ),
];

const _sourceByGrade = <int, String>{
  1: 'https://books.ebalbharati.in/pdfs/101050004.pdf',
  2: 'https://books.ebalbharati.in/pdfs/201060004.pdf',
  3: 'https://books.ebalbharati.in/pdfs/301060004.pdf',
  4: 'https://books.ebalbharati.in/pdfs/401060004.pdf',
};

final List<SchoolChapter> schoolChapters = List<SchoolChapter>.unmodifiable(
  _chapterSeeds.map(
    (seed) => SchoolChapter(
      id: 'G${seed.grade}-C${seed.number.toString().padLeft(2, '0')}',
      grade: seed.grade,
      number: seed.number,
      pageStart: seed.pageStart,
      pageEnd: seed.pageEnd,
      title: Words(
        seed.en,
        seed.mr,
        id: 'G${seed.grade}-C${seed.number.toString().padLeft(2, '0')}.title',
        mathGlossaryTerms: glossaryTermsFor(seed.strand),
      ),
      strand: seed.strand,
      sourceUrl: _sourceByGrade[seed.grade]!,
    ),
  ),
);

List<SchoolChapter> chaptersForGrade(int grade) =>
    List<SchoolChapter>.unmodifiable(
      schoolChapters.where((chapter) => chapter.grade == grade),
    );

String _modeFor(SchoolChapter c) {
  final key = c.grade * 100 + c.number;
  return const <int, String>{
    101: 'villageMap',
    102: 'roosterPosition',
    103: 'eventOrder',
    104: 'distance',
    105: 'flatShape',
    106: 'rollSlide',
    107: 'countOneToNine',
    108: 'zero',
    109: 'makeTen',
    110: 'addToNine',
    111: 'takeAway',
    112: 'teenNumbers',
    113: 'neighbors',
    114: 'compare',
    115: 'order',
    116: 'pictureData',
    117: 'countOn',
    118: 'countBack',
    119: 'rangeTwentyToThirty',
    120: 'rangeThirtyOneToNinetyNine',
    121: 'numberSong',
    122: 'repeatPattern',
    123: 'informalMeasure',
    124: 'dailyTime',
    125: 'addToEighteen',
    126: 'coinsNotes',
    127: 'equalGroupsIntro',
    128: 'fairSharing',
    129: 'puzzle',
    201: 'solidShape',
    202: 'readWriteZeroToNinetyNine',
    203: 'tensAndOnes',
    204: 'faceAndPlaceValue',
    205: 'compareTwoDigit',
    206: 'orderThree',
    207: 'skipCount',
    208: 'addition',
    209: 'subtraction',
    210: 'inverseFacts',
    211: 'multiplication',
    212: 'measureUnits',
    213: 'flatGeometry',
    214: 'regroupAddition',
    215: 'openTenSubtraction',
    216: 'pictureData',
    217: 'growingPattern',
    218: 'calendarTime',
    219: 'fairMath',
    220: 'multiplicationUse',
    221: 'division',
    222: 'puzzle',
    301: 'shapesAround',
    302: 'numbersToNineNinetyNine',
    303: 'threeDigitOperations',
    304: 'fractions',
    305: 'lengthAndWeight',
    306: 'organiseData',
    307: 'sketchMap',
    308: 'multiplication',
    309: 'divisionRemainder',
    310: 'geometryAngles',
    311: 'symmetry',
    312: 'capacity',
    313: 'quarterHourClock',
    314: 'numberPattern',
    401: 'numbersToNineThousand',
    402: 'anglesAndShapes',
    403: 'largeOperations',
    404: 'mixedFractions',
    405: 'metricUnits',
    406: 'scaledPictograph',
    407: 'gridMap',
    408: 'multiDigitMultiplication',
    409: 'longDivision',
    410: 'symmetryAxes',
    411: 'perimeterArea',
    412: 'volumeAndCapacity',
    413: 'elapsedTime',
    414: 'growingPattern',
  }[key]!;
}

Words _objectiveFor(SchoolChapter c) {
  final mode = _modeFor(c);
  const descriptions = <String, Words>{
    'villageMap': Words(
      'Use a landmark to describe where a village object is: above, below, beside, inside, or outside.',
      'खूणवस्तूच्या संदर्भाने गावातील वस्तूचे स्थान सांगा: वर, खाली, शेजारी, आत किंवा बाहेर.',
    ),
    'roosterPosition': Words(
      'Locate the rooster by comparing its position with a nearby object.',
      'जवळच्या वस्तूच्या संदर्भाने कोंबडा कुठे आहे ते ओळखा.',
    ),
    'eventOrder': Words(
      'Put two familiar events in the order they happen: first and next.',
      'दोन परिचित घटना आधी आणि नंतर अशा योग्य क्रमाने मांडा.',
    ),
    'distance': Words(
      'Compare two objects from the same place and decide which is nearer or farther.',
      'एकाच ठिकाणाहून दोन वस्तूंची तुलना करून कोणती जवळ किंवा दूर आहे ते ठरवा.',
    ),
    'flatShape': Words(
      'Notice corners and straight or curved edges to recognise a flat shape.',
      'कोपरे आणि सरळ किंवा वक्र कडा पाहून सपाट आकार ओळखा.',
    ),
    'rollSlide': Words(
      'Predict whether a solid object rolls, slides, or can do both from its surfaces.',
      'घन वस्तूच्या पृष्ठभागांवरून ती घरंगळेल, घसरेल की दोन्ही करेल ते ओळखा.',
    ),
    'countOneToNine': Words(
      'Match each object to one count and connect the total with a numeral from 1 to 9.',
      'प्रत्येक वस्तू एकदाच मोजून एकूण संख्या १ ते ९ या अंकाशी जोडा.',
    ),
    'zero': Words(
      'Use zero to show that a set has no objects, and recognise the numeral 0.',
      'गटात एकही वस्तू नसल्याचे शून्याने दाखवा आणि ० हा अंक ओळखा.',
    ),
    'makeTen': Words(
      'Combine two small groups to make exactly ten objects.',
      'दोन लहान गट एकत्र करून नेमक्या दहा वस्तू करा.',
    ),
    'addToNine': Words(
      'Join two groups and find a total no greater than nine.',
      'दोन गट एकत्र करून नऊपेक्षा मोठी नसलेली बेरीज शोधा.',
    ),
    'takeAway': Words(
      'Remove a stated number from a group and count what remains.',
      'गटातून दिलेल्या वस्तू काढून उरलेल्या वस्तू मोजा.',
    ),
    'teenNumbers': Words(
      'Build a teen number as one ten and some ones.',
      'किशोर संख्या एक दशक आणि काही एकक अशा प्रकारे तयार करा.',
    ),
    'neighbors': Words(
      'Find the number just before, just after, or between two neighbours.',
      'एखाद्या संख्येच्या आधीची, पुढची किंवा दोन संख्यांमधली संख्या शोधा.',
    ),
    'compare': Words(
      'Compare quantities and choose greater than, less than, or equal to.',
      'संख्यांची तुलना करून मोठे, लहान किंवा समान हे चिन्ह निवडा.',
    ),
    'order': Words(
      'Arrange a short set of numbers in ascending or descending order.',
      'दिलेल्या संख्यांचा चढता किंवा उतरता क्रम लावा.',
    ),
    'pictureData': Words(
      'Read the marks or pictures in a small display and compare categories.',
      'लहान चित्रमाहितीतील खुणा मोजून गटांची तुलना करा.',
    ),
    'countOn': Words(
      'Start at the first addend and count forward to add the next group.',
      'पहिल्या संख्येपासून पुढे मोजून दुसरी संख्या मिळवा.',
    ),
    'countBack': Words(
      'Start at the first number and count backwards to subtract.',
      'पहिल्या संख्येपासून मागे मोजून वजाबाकी करा.',
    ),
    'rangeTwentyToThirty': Words(
      'Read and build numbers from 21 to 30 using tens and ones.',
      'दशक आणि एकक वापरून २१ ते ३० मधील संख्या वाचा आणि तयार करा.',
    ),
    'rangeThirtyOneToNinetyNine': Words(
      'Read two-digit numbers from 31 to 99 and separate their tens and ones.',
      '३१ ते ९९ मधील दोन अंकी संख्या वाचून दशक आणि एकक वेगळे करा.',
    ),
    'numberSong': Words(
      'Continue a spoken number sequence by listening for its counting rhythm.',
      'मोजणीचा ठेका ओळखून बोललेली संख्या-मालिका पुढे चालू ठेवा.',
    ),
    'repeatPattern': Words(
      'Find the repeating unit in a pattern and use it to predict what comes next.',
      'आकृतिबंधातील पुन्हा येणारा भाग शोधून पुढे काय येईल ते सांगा.',
    ),
    'informalMeasure': Words(
      'Compare lengths with the same handspan or steps, then compare which object is heavier.',
      'एकाच वितीने किंवा पावलांनी लांबी मोजा आणि कोणती वस्तू जड आहे ते तुलना करा.',
    ),
    'dailyTime': Words(
      'Sequence daily events and name the day that comes before or after another day.',
      'दैनंदिन घटना क्रमाने मांडा आणि एखाद्या वाराच्या आधीचा किंवा पुढचा वार सांगा.',
    ),
    'addToEighteen': Words(
      'Join groups and find sums up to eighteen, using a make-ten step when useful.',
      'गट एकत्र करून अठरापर्यंतच्या बेरजा करा; उपयोगी असल्यास दहा पूर्ण करा.',
    ),
    'coinsNotes': Words(
      'Recognise rupee coins and notes and combine them to make an amount.',
      'रुपयांची नाणी व नोटा ओळखून दिलेली रक्कम तयार करा.',
    ),
    'equalGroupsIntro': Words(
      'Represent equal groups as repeated addition before using a multiplication sign.',
      'गुणाकाराचे चिन्ह वापरण्यापूर्वी समान गटांची पुनरावृत्ती बेरीज दाखवा.',
    ),
    'fairSharing': Words(
      'Share a collection equally and check that every group receives the same amount.',
      'प्रत्येक गटाला सारखीच संख्या मिळते याची खात्री करून वस्तू समान वाटा.',
    ),
    'puzzle': Words(
      'Use a clue, a number relation, or a shape property to solve a short puzzle.',
      'सूचना, संख्यांचा संबंध किंवा आकाराचा गुणधर्म वापरून छोटी कोडी सोडवा.',
    ),
    'solidShape': Words(
      'Match a solid to its faces and notice which shapes can stack, roll, or slide.',
      'घन आकाराचे पृष्ठभाग ओळखा आणि कोणते आकार रचता, घरंगळता किंवा घसरता येतात ते पाहा.',
    ),
    'readWriteZeroToNinetyNine': Words(
      'Read, write, and name numbers through 99, including zero.',
      'शून्यासह ९९ पर्यंतच्या संख्या वाचा, लिहा आणि त्यांची नावे सांगा.',
    ),
    'tensAndOnes': Words(
      'Bundle ten single objects into one ten and describe the leftover ones.',
      'दहा सुट्या वस्तूंचा एक दशकाचा गठ्ठा करा आणि उरलेली एकके सांगा.',
    ),
    'faceAndPlaceValue': Words(
      'Separate a digit’s face value from the value it gets from its position.',
      'अंकाची दर्शनी किंमत आणि स्थानामुळे मिळणारी स्थानिक किंमत वेगळी ओळखा.',
    ),
    'compareTwoDigit': Words(
      'Compare two-digit numbers by checking tens first, then ones if needed.',
      'दोन अंकी संख्यांची तुलना करताना आधी दशके आणि मग गरज असल्यास एकके पाहा.',
    ),
    'orderThree': Words(
      'Sort three two-digit numbers from least to greatest or greatest to least.',
      'तीन दोन अंकी संख्या लहान ते मोठ्या किंवा मोठ्या ते लहान क्रमाने लावा.',
    ),
    'skipCount': Words(
      'Continue equal jumps on a number path and name the step size.',
      'संख्यापथावर समान उड्या पुढे चालू ठेवून प्रत्येक उडीची संख्या ओळखा.',
    ),
    'addition': Words(
      'Join two collections and record the total with an addition sentence.',
      'दोन समूह एकत्र करून एकूण संख्या बेरीज-वाक्यात लिहा.',
    ),
    'subtraction': Words(
      'Find how many remain or how far apart two quantities are.',
      'किती उरले किंवा दोन संख्यांतील अंतर किती हे वजाबाकीने शोधा.',
    ),
    'inverseFacts': Words(
      'Use addition to check subtraction and subtraction to check addition.',
      'वजाबाकी तपासण्यासाठी बेरीज आणि बेरीज तपासण्यासाठी वजाबाकी वापरा.',
    ),
    'multiplication': Words(
      'Connect equal rows or groups with repeated addition and a multiplication fact.',
      'समान ओळी किंवा गटांना पुनरावृत्ती बेरीज आणि गुणाकाराशी जोडा.',
    ),
    'measureUnits': Words(
      'Choose a suitable standard unit and compare lengths, weights, or capacities.',
      'लांबी, वजन किंवा धारकता तुलना करण्यासाठी योग्य प्रमाणित एकक निवडा.',
    ),
    'flatGeometry': Words(
      'Describe a flat shape by its straight sides, corners, and line segments.',
      'सपाट आकाराचे सरळ बाजू, कोपरे आणि रेषाखंड ओळखून वर्णन करा.',
    ),
    'regroupAddition': Words(
      'Regroup ten ones as one ten when a column total reaches ten or more.',
      'एका स्तंभातील एकके दहापर्यंत पोहोचल्यावर दहा एककांचा एक दशक करा.',
    ),
    'openTenSubtraction': Words(
      'Open one ten as ten ones when there are not enough ones to subtract.',
      'वजाबाकीसाठी एकके कमी पडल्यास एक दशक उघडून दहा एकके करा.',
    ),
    'growingPattern': Words(
      'Compare neighbouring terms to discover the rule that grows the pattern.',
      'लगतच्या पदांची तुलना करून आकृतिबंध वाढवणारा नियम शोधा.',
    ),
    'calendarTime': Words(
      'Read dates on a calendar and relate days, weeks, and months.',
      'दिनदर्शिकेतील तारखा वाचून दिवस, आठवडे आणि महिने यांचा संबंध समजा.',
    ),
    'fairMath': Words(
      'Use counting and rupee amounts to solve a small fairground purchase.',
      'जत्रेतील छोटी खरेदी सोडवण्यासाठी मोजणी आणि रुपयांच्या रकमा वापरा.',
    ),
    'multiplicationUse': Words(
      'Choose multiplication when a story has equal groups of the same size.',
      'कथेत समान आकाराचे गट असतील तेव्हा गुणाकार निवडा.',
    ),
    'division': Words(
      'Find the number in each equal share or the number of equal groups.',
      'प्रत्येक समान वाट्यातील संख्या किंवा समान गटांची संख्या शोधा.',
    ),
    'shapesAround': Words(
      'Find a familiar two-dimensional shape in an everyday object and justify the match.',
      'दैनंदिन वस्तूमधील परिचित द्विमितीय आकार ओळखून जुळणीचे कारण सांगा.',
    ),
    'numbersToNineNinetyNine': Words(
      'Read and compare numbers to 999 using hundreds, tens, and ones, including position in a line.',
      'शेकडे, दशके आणि एकके वापरून ९९९ पर्यंतच्या संख्या वाचा, तुलना करा आणि क्रमातील स्थान सांगा.',
    ),
    'threeDigitOperations': Words(
      'Choose addition or subtraction for a story and calculate with three-digit numbers.',
      'कथेप्रमाणे बेरीज किंवा वजाबाकी निवडून तीन अंकी संख्या सोडवा.',
    ),
    'fractions': Words(
      'Name equal halves, quarters, and three-quarters in shapes or small sets.',
      'आकार किंवा छोट्या समूहातील समान अर्धे, चतुर्थांश आणि पाऊण भाग ओळखा.',
    ),
    'lengthAndWeight': Words(
      'Estimate and measure length in centimetres or metres and mass in grams or kilograms.',
      'लांबीचा अंदाज घेऊन सेंटीमीटर किंवा मीटरमध्ये आणि वजन ग्राम किंवा किलोग्रॅममध्ये मोजा.',
    ),
    'organiseData': Words(
      'Collect observations, sort them into a table, and answer a comparison question.',
      'निरीक्षणे गोळा करून तक्त्यात मांडा आणि तुलना-विषयक प्रश्नाचे उत्तर द्या.',
    ),
    'sketchMap': Words(
      'Use symbols and a top view to follow a route on a simple sketch map.',
      'चिन्हे आणि वरून दिसणारा आराखडा वापरून नकाशावरील मार्ग शोधा.',
    ),
    'divisionRemainder': Words(
      'Share into equal groups and state any objects left over as the remainder.',
      'वस्तू समान गटांत वाटून उरलेल्या वस्तू बाकी म्हणून सांगा.',
    ),
    'geometryAngles': Words(
      'Compare an angle with a square corner and describe sides and vertices of flat shapes.',
      'कोनाची काटकोनाशी तुलना करून सपाट आकाराच्या बाजू आणि शिरोबिंदू सांगा.',
    ),
    'symmetry': Words(
      'Fold or reflect a shape to decide whether both sides match across a line.',
      'रेषेच्या दोन्ही बाजू जुळतात का हे घडी किंवा प्रतिबिंबाने तपासा.',
    ),
    'capacity': Words(
      'Compare how much containers hold and describe capacity in litres or parts of a litre.',
      'भांड्यांची धारकता तुलना करून लिटर किंवा लिटरच्या भागांत सांगा.',
    ),
    'quarterHourClock': Words(
      'Read hour and minute hands at the hour, half hour, or quarter-hour marks.',
      'तास आणि मिनिटांचे काटे वाचून पूर्ण, अर्धा किंवा पाव तास ओळखा.',
    ),
    'numberPattern': Words(
      'Find the constant step in a number pattern and extend the sequence.',
      'संख्या-मालिकेतील ठरावीक फरक शोधून मालिका पुढे वाढवा.',
    ),
    'numbersToNineThousand': Words(
      'Read, expand, compare, and classify numbers through 9,999 using place value.',
      'स्थानिक किंमत वापरून ९,९९९ पर्यंतच्या संख्या वाचा, विस्तारित करा, तुलना करा आणि वर्गीकृत करा.',
    ),
    'anglesAndShapes': Words(
      'Compare angles with a right angle and classify triangles and four-sided shapes.',
      'कोनाची काटकोनाशी तुलना करून त्रिकोण आणि चौकोनी आकार ओळखा.',
    ),
    'largeOperations': Words(
      'Select an operation and calculate a larger-number situation, checking with its inverse.',
      'मोठ्या संख्येची परिस्थिती सोडवण्यासाठी क्रिया निवडा आणि उलट क्रियेने तपासा.',
    ),
    'mixedFractions': Words(
      'Partition shapes into equal parts and connect improper fractions with mixed-number language.',
      'आकारांचे समान भाग करून अपूर्णांक आणि मिश्र संख्येची भाषा जोडा.',
    ),
    'metricUnits': Words(
      'Convert and compare lengths from millimetres to kilometres and masses in grams or kilograms.',
      'मिलीमीटरपासून किलोमीटरपर्यंत लांबीची एकके बदला आणि ग्राम किंवा किलोग्रॅममधील वजन तुलना करा.',
    ),
    'scaledPictograph': Words(
      'Use the key on a pictograph to count a category and compare scaled totals.',
      'चित्रालेखातील खूण वापरून गटाची संख्या मोजा आणि प्रमाणित एकूणांची तुलना करा.',
    ),
    'gridMap': Words(
      'Read a grid location, symbol, direction, or view to trace a route on a map.',
      'नकाशावरील मार्ग शोधताना जाळीतील स्थान, चिन्ह, दिशा किंवा दृश्य वाचा.',
    ),
    'multiDigitMultiplication': Words(
      'Multiply multi-digit quantities by organising partial products by place value.',
      'स्थानिक किंमतीनुसार आंशिक गुणाकार मांडून मोठ्या संख्यांचा गुणाकार करा.',
    ),
    'longDivision': Words(
      'Divide with place-value steps and check the quotient and remainder by multiplication.',
      'स्थानिक किंमतीच्या पायऱ्यांनी भागाकार करून गुणाकाराने भागाकारफल आणि बाकी तपासा.',
    ),
    'symmetryAxes': Words(
      'Count lines that divide a shape into matching mirror halves.',
      'आकाराचे जुळणारे प्रतिबिंब-अर्धे करणाऱ्या सममिती रेषा मोजा.',
    ),
    'perimeterArea': Words(
      'Find boundary length by perimeter and count square units to compare area.',
      'परिमितीने सीमारेषेची लांबी शोधा आणि क्षेत्रफळ तुलना करण्यासाठी चौरस एकके मोजा.',
    ),
    'volumeAndCapacity': Words(
      'Count unit cubes for volume and compare liquid capacity in litres or millilitres.',
      'घनफळासाठी एकक घन मोजा आणि लिटर किंवा मिलीलीटरमधील धारकता तुलना करा.',
    ),
    'elapsedTime': Words(
      'Read an analogue or digital time and find the duration between two times.',
      'अनुरूप किंवा डिजिटल वेळ वाचून दोन वेळांतील कालावधी शोधा.',
    ),
  };
  return descriptions[mode]!;
}

ChapterQuestion _questionFor(SchoolChapter c, int i) {
  final seed = c.grade * 1000 + c.number * 31 + i * 17;
  final mode = _modeFor(c);
  switch (mode) {
    case 'villageMap':
      final places = [
        const Words('above the well', 'विहिरीच्या वर'),
        const Words('below the tree branch', 'झाडाच्या फांदीखाली'),
        const Words('inside the school gate', 'शाळेच्या प्रवेशद्वाराच्या आत'),
        const Words('outside the garden', 'बागेच्या बाहेर'),
        const Words('beside the bridge', 'पुलाच्या शेजारी'),
      ];
      final place = places[i % places.length];
      final wrong = places.where((p) => p.en != place.en).take(3).toList();
      return _choiceQuestion(
        c,
        i,
        seed,
        Words(
          'The blue kite is ${place.en}. Where is it?',
          'निळा पतंग ${place.mr} आहे. तो कुठे आहे?',
        ),
        place,
        wrong,
        Words(
          'Use the landmark named in the sentence: the kite is ${place.en}.',
          'वाक्यातील खूण लक्षात घ्या: पतंग ${place.mr} आहे.',
        ),
        const Words(
          'Look at the landmark first, then say where the object is.',
          'आधी खूण पाहा आणि मग वस्तू कुठे आहे ते सांगा.',
        ),
        ['🪁', '🌳', '🏫', '🌉'],
        'positions',
      );
    case 'roosterPosition':
      final pairs = [
        [const Words('on the roof', 'छपरावर'), '🏠'],
        [const Words('behind the pot', 'भांड्यामागे'), '🪴'],
        [const Words('in front of the cart', 'गाडीसमोर'), '🛒'],
        [const Words('inside the coop', 'खुराड्यात'), '🐓'],
        [const Words('beside the fence', 'कुंपणाजवळ'), '🪵'],
      ];
      final target = pairs[i % pairs.length][0] as Words;
      final wrong = pairs
          .map((p) => p[0] as Words)
          .where((p) => p.en != target.en)
          .take(3)
          .toList();
      return _choiceQuestion(
        c,
        i,
        seed,
        Words(
          'The rooster is ${target.en}. Choose its position.',
          'कोंबडा ${target.mr} आहे. त्याचे स्थान निवडा.',
        ),
        target,
        wrong,
        Words(
          'The position word is “${target.en}”.',
          'स्थान दाखवणारा शब्द “${target.mr}” आहे.',
        ),
        const Words(
          'Compare the rooster with the named nearby object.',
          'कोंबड्याची जवळच्या वस्तूशी तुलना करा.',
        ),
        ['🐓', '🏠', '🪴', '🛒'],
        'positions',
      );
    case 'eventOrder':
      final pairs = [
        [
          const Words('Wash the fruit', 'फळे धुणे'),
          const Words('Eat the fruit', 'फळे खाणे'),
        ],
        [
          const Words('Put on shoes', 'बूट घालणे'),
          const Words('Walk to school', 'शाळेत चालत जाणे'),
        ],
        [
          const Words('Plant a seed', 'बी पेरणे'),
          const Words('Water the plant', 'रोपाला पाणी देणे'),
        ],
        [
          const Words('Open the book', 'पुस्तक उघडणे'),
          const Words('Read a page', 'पान वाचणे'),
        ],
        [
          const Words('Mix the batter', 'पीठाचे मिश्रण करणे'),
          const Words('Bake the bread', 'भाकरी भाजणे'),
        ],
      ];
      final pair = pairs[i % pairs.length];
      return _choiceQuestion(
        c,
        i,
        seed,
        Words(
          '${pair[0].en} happens before ${pair[1].en}. What happens first?',
          '${pair[0].mr} हे ${pair[1].mr} आधी होते. आधी काय होते?',
        ),
        pair[0],
        [
          pair[1],
          const Words('Both at the same time', 'दोन्ही एकाच वेळी'),
          const Words('There is no order', 'क्रम नाही'),
        ],
        Words(
          'The first event is ${pair[0].en}.',
          'पहिली घटना म्हणजे ${pair[0].mr}.',
        ),
        const Words(
          'Follow the events from the beginning.',
          'घटनांचा सुरुवातीपासून क्रम लावा.',
        ),
        ['🧼', '🍎', '👟'],
        'sequence',
      );
    case 'distance':
      final nearer = i.isEven;
      final locations = [
        [
          const Words('mango tree', 'आंब्याचे झाड'),
          const Words('hill', 'डोंगर'),
        ],
        [const Words('well', 'विहीर'), const Words('market', 'बाजार')],
        [
          const Words('school gate', 'शाळेचे प्रवेशद्वार'),
          const Words('river', 'नदी'),
        ],
        [const Words('garden', 'बाग'), const Words('bus stop', 'बस थांबा')],
        [const Words('library', 'वाचनालय'), const Words('farm', 'शेत')],
      ];
      final pair = locations[i % locations.length];
      final close = pair[0];
      final far = pair[1];
      final closeSteps = 2 + i;
      final farSteps = closeSteps + 5 + i;
      final target = nearer ? close : far;
      final other = nearer ? far : close;
      final answer = Words(
        'The ${target.en}${nearer ? ' is nearer.' : ' is farther.'}',
        target.mr + (nearer ? ' जवळ आहे.' : ' दूर आहे.'),
      );
      final wrong = [
        Words(
          'The ${other.en}${nearer ? ' is nearer.' : ' is farther.'}',
          other.mr + (nearer ? ' जवळ आहे.' : ' दूर आहे.'),
        ),
        const Words('They are equally far.', 'दोन्ही सारखे दूर आहेत.'),
        const Words('Neither is a place.', 'दोन्ही ठिकाणे नाहीत.'),
      ];
      return _choiceQuestion(
        c,
        i,
        seed,
        Words(
          'From the village gate, the ${close.en} is $closeSteps steps away and the ${far.en} is $farSteps steps away. Which is ${nearer ? 'nearer?' : 'farther?'}',
          'गावच्या प्रवेशद्वारापासून ${close.mr} ${_mrDigits(closeSteps)} पावले आणि ${far.mr} ${_mrDigits(farSteps)} पावले दूर आहे. कोणते ${nearer ? 'जवळ आहे?' : 'दूर आहे?'}',
        ),
        answer,
        wrong,
        Words(
          nearer
              ? 'The shorter walk to the ${close.en} means it is nearer.'
              : 'The longer walk to the ${far.en} means it is farther.',
          nearer
              ? 'कमी पावले असलेले ${close.mr} जवळ आहे.'
              : 'जास्त पावले असलेले ${far.mr} दूर आहे.',
        ),
        const Words(
          'Compare the length of the walk from the same gate.',
          'एकाच प्रवेशद्वारापासून चालण्याच्या अंतरांची तुलना करा.',
        ),
        ['🚪', '🌳', '⛰️'],
        'distance',
      );
    case 'flatShape':
    case 'solidShape':
    case 'shapesAround':
    case 'geometryAngles':
    case 'anglesAndShapes':
      return _geometryQuestion(c, i, seed, mode);
    case 'rollSlide':
      final cases = [
        [
          const Words('A smooth ball', 'गुळगुळीत चेंडू'),
          const Words('rolls', 'घरंगळतो'),
        ],
        [
          const Words('A flat book', 'सपाट पुस्तक'),
          const Words('slides', 'घसरते'),
        ],
        [
          const Words('A tin can', 'डबा'),
          const Words('rolls and slides', 'घरंगळतो आणि घसरतो'),
        ],
        [
          const Words('A wooden block', 'लाकडी ठोकळा'),
          const Words('slides', 'घसरतो'),
        ],
        [
          const Words('A round orange', 'गोल संत्रे'),
          const Words('rolls', 'घरंगळते'),
        ],
        [
          const Words('A wooden ball', 'लाकडी चेंडू'),
          const Words('rolls', 'घरंगळतो'),
        ],
        [
          const Words('A flat eraser', 'सपाट खोडरबर'),
          const Words('slides', 'घसरते'),
        ],
        [
          const Words('A glass jar', 'काचेची बरणी'),
          const Words('rolls and slides', 'घरंगळते आणि घसरते'),
        ],
        [const Words('A matchbox', 'काडेपेटी'), const Words('slides', 'घसरते')],
        [
          const Words('A round coin', 'गोल नाणे'),
          const Words('rolls and slides', 'घरंगळते आणि घसरते'),
        ],
      ];
      final item = cases[i % cases.length];
      final choiceSet = [
        const Words('rolls', 'घरंगळते'),
        const Words('slides', 'घसरते'),
        const Words('rolls and slides', 'घरंगळते आणि घसरते'),
        const Words(
          'stays balanced on every side',
          'प्रत्येक बाजूवर स्थिर राहते',
        ),
      ];
      final right = item[1];
      return _choiceQuestion(
        c,
        i,
        seed,
        Words(
          'On a gentle ramp, what can ${(item[0]).en} do?',
          'हळू उतारावर ${(item[0]).mr} काय करू शकते?',
        ),
        right,
        choiceSet.where((x) => x.en != right.en).take(3).toList(),
        Words(
          'Its ${right.en.contains('roll') ? 'curved' : 'flat'} surface explains why it ${right.en}.',
          '${right.en.contains('roll') ? 'वक्र' : 'सपाट'} पृष्ठभागामुळे ती ${right.mr}.',
        ),
        const Words(
          'Think about whether the object has a curved surface, a flat face, or both.',
          'वस्तूला वक्र पृष्ठभाग, सपाट बाजू की दोन्ही आहेत ते पाहा.',
        ),
        ['🟠', '📘', '🥫', '🧊'],
        'rollSlide',
      );
    case 'countOneToNine':
    case 'readWriteZeroToNinetyNine':
    case 'rangeTwentyToThirty':
    case 'rangeThirtyOneToNinetyNine':
    case 'numbersToNineNinetyNine':
    case 'numbersToNineThousand':
      return _numberReadingQuestion(c, i, seed, mode);
    case 'zero':
      final names = [
        const Words('marbles', 'गोट्या'),
        const Words('mangoes', 'आंबे'),
        const Words('kites', 'पतंग'),
        const Words('books', 'पुस्तके'),
        const Words('cups', 'कप'),
        const Words('beads', 'मणी'),
        const Words('crayons', 'खडू'),
        const Words('balls', 'चेंडू'),
        const Words('spoons', 'चमचे'),
        const Words('seeds', 'बिया'),
      ];
      final item = names[i % names.length];
      return _numericQuestion(
        c,
        i,
        seed,
        Words(
          'An empty basket has no ${item.en}. How many ${item.en} are in it?',
          'रिकाम्या टोपलीत ${item.mr} नाहीत. त्यात किती ${item.mr} आहेत?',
        ),
        const Words(
          'The empty set contains 0 objects.',
          'रिकाम्या गटात ० वस्तू असतात.',
        ),
        const Words(
          'An empty set has no objects. Which numeral means none?',
          'रिकाम्या गटात वस्तू नसतात. काहीच नाही हे कोणता अंक दाखवतो?',
        ),
        0,
        ['🧺'],
        'counters',
      );
    case 'makeTen':
      final a = 4 + (i % 4);
      final b = 10 - a;
      final kinds = [
        const Words('shells', 'शिंपले'),
        const Words('pebbles', 'गोट्या'),
        const Words('flower buds', 'फुलांच्या कळ्या'),
        const Words('buttons', 'बटणे'),
        const Words('leaves', 'पाने'),
      ];
      final kind = kinds[i % kinds.length];
      return _numericQuestion(
        c,
        i,
        seed,
        Words(
          'There are $a ${kind.en}. How many more make 10?',
          '${_mrDigits(a)} ${kind.mr} आहेत. १० पूर्ण करण्यासाठी आणखी किती लागतील?',
        ),
        Words('$a + $b = 10.', '$a + $b = १०.'),
        const Words(
          'Count on from the group you already have until you reach ten.',
          'आधीच्या गटापासून दहापर्यंत पुढे मोजा.',
        ),
        b,
        ['🐚'],
        'tenFrame',
      );
    case 'addToNine':
    case 'addToEighteen':
    case 'countOn':
    case 'addition':
    case 'regroupAddition':
    case 'threeDigitOperations':
    case 'largeOperations':
      return _additionQuestion(c, i, seed, mode);
    case 'inverseFacts':
      return _inverseQuestion(c, i, seed);
    case 'takeAway':
    case 'countBack':
    case 'subtraction':
    case 'openTenSubtraction':
      return _subtractionQuestion(c, i, seed, mode);
    case 'teenNumbers':
    case 'tensAndOnes':
      final ones = 1 + (i * 2 % 9);
      final value = 10 + ones;
      return _numericQuestion(
        c,
        i,
        seed,
        Words(
          'Build a number with 1 ten and $ones ones. What is it?',
          '१ दशक आणि $ones एकक मिळून कोणती संख्या होते?',
        ),
        Words('10 + $ones = $value.', '१० + $ones = $value.'),
        const Words(
          'A teen number has one group of ten and some ones.',
          'किशोर संख्येत एक दशक आणि काही एकके असतात.',
        ),
        value,
        ['🔟', '🟡'],
        'baseTen',
      );
    case 'neighbors':
      final middle = 5 + i * 3;
      final ask = i % 3;
      final answer = ask == 0
          ? middle - 1
          : ask == 1
          ? middle + 1
          : middle;
      final prompt = ask == 0
          ? Words(
              'What number comes just before $middle?',
              '$middle च्या लगेच आधी कोणती संख्या येते?',
            )
          : ask == 1
          ? Words(
              'What number comes just after $middle?',
              '$middle च्या लगेच नंतर कोणती संख्या येते?',
            )
          : Words(
              'Fill the middle: ${middle - 1}, __, ${middle + 1}.',
              'मधली संख्या भरा: ${middle - 1}, __, ${middle + 1}.',
            );
      return _numericQuestion(
        c,
        i,
        seed,
        prompt,
        Words(
          'The neighbouring numbers are ${middle - 1}, $middle, ${middle + 1}.',
          'लगतच्या संख्या ${middle - 1}, $middle, ${middle + 1} आहेत.',
        ),
        const Words(
          'Step one number back or forward on the number path.',
          'संख्यापथावर एक पाऊल मागे किंवा पुढे जा.',
        ),
        answer,
        ['➡️'],
        'numberLine',
      );
    case 'compare':
    case 'compareTwoDigit':
      final a = (c.grade == 1 ? 3 : 24) + i * (c.grade == 1 ? 2 : 7);
      final b = a + (i.isEven ? 3 : -2);
      final symbol = a > b
          ? '>'
          : a < b
          ? '<'
          : '=';
      final target = Words(symbol, symbol);
      return _choiceQuestion(
        c,
        i,
        seed,
        Words(
          'Choose the correct sign: $a __ $b.',
          'योग्य चिन्ह निवडा: $a __ $b.',
        ),
        target,
        [
          const Words('<', '<'),
          const Words('>', '>'),
          const Words('=', '='),
        ].where((x) => x.en != symbol).toList(),
        Words(
          '$a is ${symbol == '>'
              ? 'greater than'
              : symbol == '<'
              ? 'less than'
              : 'equal to'} $b.',
          '$a ही ${symbol == '>'
              ? 'मोठी'
              : symbol == '<'
              ? 'लहान'
              : 'समान'} संख्या आहे $b पेक्षा.',
        ),
        const Words(
          'For two-digit numbers, compare tens first, then ones.',
          'दोन अंकी संख्यांत आधी दशके आणि मग एकके तुलना करा.',
        ),
        ['🔢', '⚖️'],
        'compare',
      );
    case 'order':
    case 'orderThree':
      final nums = [12 + i * 5, 4 + i * 3, 21 + i * 2];
      var ordered = List<int>.from(nums)..sort();
      if (i.isOdd) ordered = ordered.reversed.toList();
      final answer = Words(
        ordered.join('  <  '),
        ordered.map(_mrDigits).join('  <  '),
      );
      final descending = List<int>.from(nums)..sort((a, b) => b.compareTo(a));
      final wrong = [
        Words(
          nums.reversed.join('  <  '),
          nums.reversed.map(_mrDigits).join('  <  '),
        ),
        Words(nums.join('  <  '), nums.map(_mrDigits).join('  <  ')),
        Words(
          descending.join('  <  '),
          descending.map(_mrDigits).join('  <  '),
        ),
      ];
      return _choiceQuestion(
        c,
        i,
        seed,
        Words(
          'Arrange ${nums.join(', ')}${i.isOdd ? ' from greatest to least.' : ' from least to greatest.'}',
          'या संख्या ${nums.map(_mrDigits).join(', ')}${i.isOdd ? ' मोठ्या ते लहान मांडा.' : ' लहान ते मोठ्या मांडा.'}',
        ),
        answer,
        wrong,
        Words(
          'Compare each number, then read the ordered list: ${answer.en}.',
          'प्रत्येक संख्या तुलना करा. योग्य क्रम: ${answer.mr}.',
        ),
        const Words(
          'Find the smallest (or largest) first, then place the remaining numbers.',
          'सर्वांत लहान (किंवा मोठी) संख्या आधी शोधा आणि उरलेल्या मांडा.',
        ),
        ['🔢', '↕️'],
        'ordering',
      );
    case 'pictureData':
    case 'organiseData':
    case 'scaledPictograph':
      final n = 2 + i;
      final scale = mode == 'scaledPictograph' ? 2 : 1;
      final answer = n * scale;
      return _numericQuestion(
        c,
        i,
        seed,
        Words(
          'A class chart shows $n sun symbols for red kites. Each sun stands for $scale${scale == 1 ? ' kite.' : ' kites.'} How many red kites?',
          'वर्गाच्या तक्त्यात लाल पतंगांसाठी $n सूर्यचिन्हे आहेत. प्रत्येक सूर्य म्हणजे $scale पतंग. लाल पतंग किती?',
        ),
        Words(
          '$n × $scale = $answer red kites.',
          '$n × $scale = $answer लाल पतंग.',
        ),
        const Words(
          'Read the chart key first. One symbol may stand for more than one item.',
          'आधी तक्त्यातील खूण वाचा. एक चिन्ह एकापेक्षा जास्त वस्तू दाखवू शकते.',
        ),
        answer,
        ['📊', '☀️', '🪁'],
        'barChart',
      );
    case 'numberSong':
    case 'skipCount':
      final step = mode == 'numberSong' ? 1 : (i % 2 == 0 ? 2 : 5);
      final start = mode == 'numberSong'
          ? 4 + i
          : (i % 2 == 0 ? 2 + i * 2 : 5 + i * 5);
      final answer = start + 3 * step;
      return _numericQuestion(
        c,
        i,
        seed,
        Words(
          '$start, ${start + step}, ${start + 2 * step}, __. What comes next?',
          '${_mrDigits(start)}, ${_mrDigits(start + step)}, ${_mrDigits(start + 2 * step)}, __. पुढे कोणती संख्या?',
        ),
        Words(
          'The pattern adds $step each time, so the next number is $answer.',
          'या मालिकेत प्रत्येक वेळी $step मिळवतात. पुढची संख्या $answer.',
        ),
        Words(
          'Find the jump from one number to the next; repeat the same jump.',
          'एका संख्येपासून पुढच्या संख्येपर्यंतची उडी शोधा आणि तीच पुन्हा घ्या.',
        ),
        answer,
        ['🎵', '🔢'],
        'numberLine',
      );
    case 'repeatPattern':
    case 'growingPattern':
    case 'numberPattern':
      return _patternQuestion(c, i, seed);
    case 'informalMeasure':
    case 'measureUnits':
    case 'lengthAndWeight':
    case 'metricUnits':
      return _measureQuestion(c, i, seed, mode);
    case 'dailyTime':
    case 'calendarTime':
      return _calendarQuestion(c, i, seed, mode);
    case 'quarterHourClock':
    case 'elapsedTime':
      return _clockQuestion(c, i, seed, mode);
    case 'coinsNotes':
      final coinCount = 1 + i ~/ 3;
      final coinValue = [1, 2, 5, 10][i % 4];
      final noteValue = [1, 2, 5][i % 3];
      final total = coinCount * coinValue + noteValue;
      return _numericQuestion(
        c,
        i,
        seed,
        Words(
          'You have $coinCount coin${coinCount == 1 ? '' : 's'} worth ₹$coinValue each and one ₹$noteValue coin. How many rupees altogether?',
          'तुमच्याकडे प्रत्येकी ₹${_mrDigits(coinValue)} किमतीची ${_mrDigits(coinCount)} नाणी आणि ₹${_mrDigits(noteValue)} चे एक नाणे आहे. एकूण किती रुपये?',
        ),
        Words(
          '$coinCount × ₹$coinValue + ₹$noteValue = ₹$total.',
          '${_mrDigits(coinCount)} × ₹${_mrDigits(coinValue)} + ₹${_mrDigits(noteValue)} = ₹${_mrDigits(total)}.',
        ),
        const Words(
          'Put the coin and note values together, then add.',
          'नाणे आणि नोट यांच्या किंमती एकत्र करून बेरीज करा.',
        ),
        total,
        ['🪙', '📒', '✏️'],
        'coins',
      );
    case 'fairMath':
      final count = 1 + i % 4;
      final price = 2 + i;
      final total = count * price;
      return _numericQuestion(
        c,
        i,
        seed,
        Words(
          'At the fair, each paper pinwheel costs ₹$price. What do $count pinwheels cost?',
          'जत्रेत प्रत्येक कागदी भोवऱ्याची किंमत ₹${_mrDigits(price)} आहे. ${_mrDigits(count)} भोवऱ्यांची किंमत किती?',
        ),
        Words(
          '$count equal prices of ₹$price make ₹$total.',
          '${_mrDigits(count)} वेळा ₹${_mrDigits(price)} म्हणजे ₹${_mrDigits(total)}.',
        ),
        const Words(
          'Add the same price once for each item, or multiply the count by the price.',
          'प्रत्येक वस्तूची किंमत एकदा मिळवा किंवा वस्तूंची संख्या आणि किंमत गुणा.',
        ),
        total,
        ['🎪', '🎡', '🪙'],
        'fairPurchase',
      );
    case 'equalGroupsIntro':
    case 'multiplication':
    case 'multiplicationUse':
    case 'multiDigitMultiplication':
      return _multiplicationQuestion(c, i, seed, mode);
    case 'fairSharing':
    case 'division':
    case 'divisionRemainder':
    case 'longDivision':
      return _divisionQuestion(c, i, seed, mode);
    case 'puzzle':
      final a = 2 + i;
      final b = 3 + i * 2;
      return _numericQuestion(
        c,
        i,
        seed,
        Words(
          'A number machine adds $a. It shows $b. What number went in?',
          'संख्या यंत्र $a मिळवते आणि $b दाखवते. आत कोणती संख्या घातली?',
        ),
        Words(
          'Undo the addition: $b − $a = ${b - a}.',
          'बेरीज उलट करा: $b − $a = ${b - a}.',
        ),
        const Words(
          'Use the opposite operation to undo the machine.',
          'यंत्राची क्रिया उलट करण्यासाठी विरुद्ध क्रिया वापरा.',
        ),
        b - a,
        ['⚙️', '🔢'],
        'puzzle',
      );
    case 'fractions':
    case 'mixedFractions':
      return _fractionQuestion(c, i, seed, mode);
    case 'sketchMap':
    case 'gridMap':
      return _mapQuestion(c, i, seed, mode);
    case 'symmetry':
    case 'symmetryAxes':
      return _symmetryQuestion(c, i, seed, mode);
    case 'capacity':
      final amount = 1 + i;
      final answer = amount * 2;
      return _numericQuestion(
        c,
        i,
        seed,
        Words(
          'A jug holds $amount${amount == 1 ? ' litre' : ' litres'}. How many half-litre cups fill it?',
          'एका जगात ${_mrDigits(amount)} लिटर पाणी मावते. अर्धा-लिटरचे किती कप भरतील?',
        ),
        Words(
          'Each litre is two half-litres, so $amount litres need $answer cups.',
          'एका लिटरमध्ये अर्धा-लिटरचे दोन कप होतात, म्हणून ${_mrDigits(amount)} लिटरसाठी ${_mrDigits(answer)} कप लागतील.',
        ),
        const Words(
          'A litre is made from two half-litres.',
          'एका लिटरमध्ये दोन अर्धे-लिटर असतात.',
        ),
        answer,
        ['🫗', '🥛'],
        'capacity',
      );
    case 'volumeAndCapacity':
      final cubes = 2 + i;
      return _numericQuestion(
        c,
        i,
        seed,
        Words(
          'A box is packed with $cubes unit cubes. What is its volume in cubic units?',
          'एका पेटीत $cubes एकक घन आहेत. घन एककांत घनफळ किती?',
        ),
        Words(
          'Count each unit cube once: the volume is $cubes cubic units.',
          'प्रत्येक एकक घन एकदा मोजा: घनफळ $cubes घन एकक.',
        ),
        const Words(
          'Volume counts the unit cubes that fill the solid.',
          'घनफळ म्हणजे घन वस्तू भरणारे एकक घन मोजणे.',
        ),
        cubes,
        ['🧊', '📦'],
        'unitCubes',
      );
    case 'perimeterArea':
      return _areaQuestion(c, i, seed);
    default:
      return _patternQuestion(c, i, seed);
  }
}

ChapterQuestion _numericQuestion(
  SchoolChapter c,
  int index,
  int seed,
  Words prompt,
  Words explanation,
  Words hint,
  int answer,
  List<String> objects,
  String visualKind, {
  int? maxAnswer,
}) {
  final classLimit = c.grade < 3
      ? 99
      : c.grade == 3
      ? 999
      : 9999;
  final ceiling = maxAnswer ?? classLimit;
  final distractors = <int>{};
  for (final delta in const [1, -1, 2, -2, 3, -3, 4, -4, 5, 10, -10, 100]) {
    final candidate = answer + delta;
    if (candidate >= 0 && candidate != answer && candidate <= ceiling) {
      distractors.add(candidate);
    }
    if (distractors.length == 3) break;
  }
  final all = distractors.toList();
  final slot = seed % 4;
  final options = <Words>[];
  var distractorIndex = 0;
  for (var position = 0; position < 4; position++) {
    if (position == slot) {
      options.add(Words(answer.toString(), _mrDigits(answer)));
    } else {
      final value = all[distractorIndex++];
      options.add(Words(value.toString(), _mrDigits(value)));
    }
  }
  return ChapterQuestion(
    id: '${c.id}-q${index + 1}',
    prompt: prompt.identified(
      '${c.id}-q${index + 1}.prompt',
      glossaryTerms: glossaryTermsFor(c.strand),
    ),
    explanation: explanation.identified(
      '${c.id}-q${index + 1}.explanation',
      glossaryTerms: glossaryTermsFor(c.strand),
    ),
    hint: hint.identified(
      '${c.id}-q${index + 1}.hint',
      glossaryTerms: glossaryTermsFor(c.strand),
    ),
    options: List<Words>.unmodifiable([
      for (var p = 0; p < options.length; p++)
        options[p].identified(
          '${c.id}-q${index + 1}.option.$p',
          glossaryTerms: glossaryTermsFor(c.strand),
        ),
    ]),
    correctIndex: slot,
    objects: List<String>.unmodifiable(objects),
    visualKind: visualKind,
  );
}

ChapterQuestion _choiceQuestion(
  SchoolChapter c,
  int index,
  int seed,
  Words prompt,
  Words answer,
  List<Words> wrong,
  Words explanation,
  Words hint,
  List<String> objects,
  String visualKind,
) {
  final unique = <String, Words>{answer.en: answer};
  for (final option in wrong) {
    if (option.en != answer.en) unique.putIfAbsent(option.en, () => option);
    if (unique.length == 4) break;
  }
  var filler = 1;
  while (unique.length < 4) {
    final option = Words('Option $filler', 'पर्याय $filler');
    unique.putIfAbsent(option.en, () => option);
    filler++;
  }
  final rest = unique.values.where((item) => item.en != answer.en).toList();
  final slot = seed % 4;
  final options = <Words>[];
  var cursor = 0;
  for (var position = 0; position < 4; position++) {
    options.add(position == slot ? answer : rest[cursor++]);
  }
  return ChapterQuestion(
    id: '${c.id}-q${index + 1}',
    prompt: prompt.identified(
      '${c.id}-q${index + 1}.prompt',
      glossaryTerms: glossaryTermsFor(c.strand),
    ),
    explanation: explanation.identified(
      '${c.id}-q${index + 1}.explanation',
      glossaryTerms: glossaryTermsFor(c.strand),
    ),
    hint: hint.identified(
      '${c.id}-q${index + 1}.hint',
      glossaryTerms: glossaryTermsFor(c.strand),
    ),
    options: List<Words>.unmodifiable([
      for (var p = 0; p < options.length; p++)
        options[p].identified(
          '${c.id}-q${index + 1}.option.$p',
          glossaryTerms: glossaryTermsFor(c.strand),
        ),
    ]),
    correctIndex: slot,
    objects: List<String>.unmodifiable(objects),
    visualKind: visualKind,
  );
}

String _mrDigits(int value) {
  const western = '0123456789';
  const marathi = '०१२३४५६७८९';
  return value.toString().split('').map((digit) {
    final index = western.indexOf(digit);
    return index < 0 ? digit : marathi[index];
  }).join();
}

String _mrText(String value) {
  const western = '0123456789';
  const marathi = '०१२३४५६७८९';
  return value.split('').map((digit) {
    final index = western.indexOf(digit);
    return index < 0 ? digit : marathi[index];
  }).join();
}

ChapterQuestion _numberReadingQuestion(
  SchoolChapter c,
  int i,
  int seed,
  String mode,
) {
  int value;
  Words prompt, explanation, hint;
  if (mode == 'countOneToNine') {
    value = 1 + i % 9;
    final objects = [
      const Words('mangoes', 'आंबे'),
      const Words('marbles', 'गोट्या'),
      const Words('flowers', 'फुले'),
      const Words('shells', 'शिंपले'),
      const Words('buttons', 'बटणे'),
      const Words('guavas', 'पेरू'),
      const Words('kites', 'पतंग'),
      const Words('books', 'पुस्तके'),
      const Words('cups', 'कप'),
      const Words('leaves', 'पाने'),
    ];
    final item = objects[i % objects.length];
    prompt = Words(
      'A basket has $value ${item.en}. Choose the numeral for the total.',
      'एका टोपलीत ${_mrDigits(value)} ${item.mr} आहेत. एकूण संख्या दाखवणारा अंक निवडा.',
    );
    explanation = Words(
      'Count each object once: the total is $value.',
      'प्रत्येक वस्तू एकदा मोजा: एकूण ${_mrDigits(value)}.',
    );
    hint = const Words(
      'Touch or point to each object once, then say the last count.',
      'प्रत्येक वस्तूला एकदा स्पर्श करा किंवा दाखवा आणि शेवटची मोजणी सांगा.',
    );
  } else if (mode == 'rangeTwentyToThirty') {
    value = 21 + i % 10;
    final tens = value ~/ 10, ones = value % 10;
    prompt = Words(
      'Build $tens ten and $ones ones. Which number is it?',
      '${_mrDigits(tens)} दशक आणि ${_mrDigits(ones)} एकके मिळून कोणती संख्या होते?',
    );
    explanation = Words(
      '$tens tens and $ones ones make $value.',
      '${_mrDigits(tens)} दशके आणि ${_mrDigits(ones)} एकके मिळून ${_mrDigits(value)} होतात.',
    );
    hint = const Words(
      'Count the tens first, then attach the ones.',
      'आधी दशके मोजा आणि मग एकके जोडा.',
    );
  } else if (mode == 'rangeThirtyOneToNinetyNine') {
    value = 31 + (i * 13) % 69;
    final tens = value ~/ 10, ones = value % 10;
    prompt = Words(
      'Which numeral has $tens tens and $ones ones?',
      '${_mrDigits(tens)} दशके आणि ${_mrDigits(ones)} एकके असलेला अंक कोणता?',
    );
    explanation = Words(
      '$value is $tens tens and $ones ones.',
      '${_mrDigits(value)} म्हणजे ${_mrDigits(tens)} दशके आणि ${_mrDigits(ones)} एकके.',
    );
    hint = const Words(
      'The tens digit gives groups of ten; the ones digit gives leftovers.',
      'दशकाचा अंक दहाचे गट दाखवतो; एककाचा अंक उरलेली एकके दाखवतो.',
    );
  } else if (mode == 'readWriteZeroToNinetyNine') {
    final tens = 2 + i % 8, ones = (i * 3) % 10;
    value = tens * 10 + ones;
    prompt = Words(
      'Read $tens tens and $ones ones as one number.',
      '${_mrDigits(tens)} दशके आणि ${_mrDigits(ones)} एकके एकत्र करून संख्या सांगा.',
    );
    explanation = Words(
      '$tens tens and $ones ones make $value.',
      '${_mrDigits(tens)} दशके आणि ${_mrDigits(ones)} एकके मिळून ${_mrDigits(value)} होतात.',
    );
    hint = const Words(
      'Write the tens digit first and the ones digit next.',
      'आधी दशकाचा अंक आणि मग एककाचा अंक लिहा.',
    );
  } else if (mode == 'numbersToNineNinetyNine') {
    final hundreds = 2 + i % 8, tens = (i * 3) % 10, ones = (i * 7) % 10;
    value = hundreds * 100 + tens * 10 + ones;
    prompt = Words(
      'Build $hundreds hundreds, $tens tens, and $ones ones.',
      '${_mrDigits(hundreds)} शतके, ${_mrDigits(tens)} दशके आणि ${_mrDigits(ones)} एकके मिळून संख्या बनवा.',
    );
    explanation = Words(
      '$hundreds hundreds + $tens tens + $ones ones = $value.',
      '${_mrDigits(hundreds)} शतके + ${_mrDigits(tens)} दशके + ${_mrDigits(ones)} एकके = ${_mrDigits(value)}.',
    );
    hint = const Words(
      'Read the hundreds, tens, then ones from left to right.',
      'डावीकडून उजवीकडे शतके, दशके आणि एकके वाचा.',
    );
  } else {
    final thousands = 1 + i % 8,
        hundreds = (i * 3) % 10,
        tens = (i * 5) % 10,
        ones = (i * 7) % 10;
    value = thousands * 1000 + hundreds * 100 + tens * 10 + ones;
    final even = value.isEven;
    final expanded =
        '${thousands * 1000} + ${hundreds * 100} + ${tens * 10} + $ones';
    if (i % 3 == 0) {
      prompt = Words(
        'Choose the number with $thousands thousands, $hundreds hundreds, $tens tens, and $ones ones.',
        '${_mrDigits(thousands)} हजार, ${_mrDigits(hundreds)} शतके, ${_mrDigits(tens)} दशके आणि ${_mrDigits(ones)} एकके असलेली संख्या निवडा.',
      );
      explanation = Words(
        '$expanded builds $value from its place values.',
        '${_mrText(expanded)} या स्थानिक किंमती मिळून ${_mrDigits(value)} होतात.',
      );
      hint = const Words(
        'Keep each digit in its place-value column.',
        'प्रत्येक अंक त्याच्या स्थानिक किंमतीच्या घरात ठेवा.',
      );
    } else {
      prompt = Words(
        'Is $value even or odd?',
        '${_mrDigits(value)} ही सम की विषम संख्या आहे?',
      );
      final parity = even
          ? const Words('even', 'सम')
          : const Words('odd', 'विषम');
      return _choiceQuestion(
        c,
        i,
        seed,
        prompt,
        parity,
        [
          even ? const Words('odd', 'विषम') : const Words('even', 'सम'),
          const Words('neither', 'दोन्ही नाही'),
          const Words('both', 'दोन्ही'),
        ],
        Words(
          'The ones digit is ${ones == 0 ? '0' : ones.toString()}. This number is ${even ? 'even.' : 'odd.'}',
          'एककाचा अंक ${_mrDigits(ones)} आहे. ही संख्या ${even ? 'सम आहे.' : 'विषम आहे.'}',
        ),
        const Words('Check the ones digit.', 'एककाचा अंक पाहा.'),
        ['🔢'],
        'placeValue',
      );
    }
  }
  return _numericQuestion(c, i, seed, prompt, explanation, hint, value, [
    '🔢',
    '🟡',
  ], 'baseTen');
}

ChapterQuestion _additionQuestion(
  SchoolChapter c,
  int i,
  int seed,
  String mode,
) {
  late int a, b, cap;
  if (mode == 'addToNine') {
    cap = 9;
    a = 1 + i % 4;
    b = 1 + (i * 3) % (cap - a);
  } else if (mode == 'addToEighteen') {
    cap = 18;
    a = 6 + i % 8;
    b = 1 + (i * 5) % (cap - a);
  } else if (mode == 'regroupAddition') {
    a = 27 + i * 2;
    b = 16 + i * 2;
  } else if (mode == 'threeDigitOperations') {
    a = 236 + i * 31;
    b = 112 + i * 17;
  } else if (mode == 'largeOperations') {
    a = 1240 + i * 113;
    b = 357 + i * 41;
  } else if (mode == 'countOn') {
    a = 4 + i % 5;
    b = 1 + i % 4;
  } else if (c.grade == 2) {
    a = 22 + i * 3;
    b = 11 + i * 2;
  } else {
    a = 12 + i * 2;
    b = 7 + i;
  }
  final total = a + b;
  final collections = [
    const Words('leaves', 'पाने'),
    const Words('mangoes', 'आंबे'),
    const Words('marbles', 'गोट्या'),
    const Words('flowers', 'फुले'),
    const Words('shells', 'शिंपले'),
    const Words('seeds', 'बिया'),
    const Words('buttons', 'बटणे'),
    const Words('kites', 'पतंग'),
    const Words('books', 'पुस्तके'),
    const Words('guavas', 'पेरू'),
  ];
  final collection = collections[i % collections.length];
  final sentence = mode == 'countOn'
      ? Words(
          'Begin at $a and count forward $b steps. What is the total?',
          '$a पासून सुरुवात करून $b पावले पुढे मोजा. एकूण किती?',
        )
      : Words(
          'A class collects $a ${collection.en}, then $b more. How many altogether?',
          'वर्गाने ${_mrDigits(a)} ${collection.mr} गोळा केली; नंतर आणखी $b मिळाली. एकूण किती?',
        );
  final worked = mode == 'regroupAddition'
      ? Words(
          'Ones: ${a % 10} + ${b % 10} = ${(a % 10) + (b % 10)}. Regroup ten ones: $a + $b = $total.',
          'एकके: ${_mrDigits(a % 10)} + ${_mrDigits(b % 10)} = ${_mrDigits((a % 10) + (b % 10))}. दहा एककांचा एक दशक करा: ${_mrDigits(a)} + ${_mrDigits(b)} = ${_mrDigits(total)}.',
        )
      : Words(
          '$a + $b = $total.',
          '${_mrDigits(a)} + ${_mrDigits(b)} = ${_mrDigits(total)}.',
        );
  final hint = mode == 'countOn'
      ? const Words(
          'Keep the first number in mind and make the next count one step at a time.',
          'पहिली संख्या लक्षात ठेवा आणि एकेक पाऊल पुढे मोजा.',
        )
      : mode == 'regroupAddition'
      ? const Words(
          'Add the ones column first. Trade ten ones for one ten when needed.',
          'आधी एककांच्या घराची बेरीज करा. गरज पडल्यास दहा एककांचा एक दशक करा.',
        )
      : const Words(
          'Put both groups together, then count or add their totals.',
          'दोन्ही गट एकत्र करा आणि त्यांची बेरीज मोजा.',
        );
  final maxAnswer = mode == 'addToNine'
      ? 9
      : mode == 'addToEighteen'
      ? 18
      : c.grade == 2
      ? 99
      : c.grade == 3
      ? 999
      : 9999;
  return _numericQuestion(
    c,
    i,
    seed,
    sentence,
    worked,
    hint,
    total,
    ['🍃', '➕', '🧺'],
    'addition',
    maxAnswer: maxAnswer,
  );
}

ChapterQuestion _subtractionQuestion(
  SchoolChapter c,
  int i,
  int seed,
  String mode,
) {
  late int a, b;
  if (mode == 'openTenSubtraction') {
    final tens = 5 + i % 5;
    a = tens * 10 + 2;
    b = (tens - 1) * 10 + 3 + i % 6;
  } else if (c.grade >= 3) {
    a = 648 + i * 37;
    b = 219 + i * 13;
  } else if (c.grade == 2) {
    a = 78 + i;
    b = 23 + i * 2;
  } else {
    a = mode == 'countBack' ? 9 - i % 3 : 9;
    b = 1 + i % (a - 1);
  }
  final answer = a - b;
  final subtractionObjects = [
    const Words('seed pods', 'शेंगा'),
    const Words('mangoes', 'आंबे'),
    const Words('shells', 'शिंपले'),
    const Words('picture cards', 'चित्रांची कार्डे'),
    const Words('buttons', 'बटणे'),
  ];
  final item = subtractionObjects[i % subtractionObjects.length];
  final prompt = mode == 'countBack'
      ? Words(
          'Start at $a and count back $b. Where do you land?',
          '$a पासून $b मागे मोजा. कोणत्या संख्येवर याल?',
        )
      : Words(
          'There are $a ${item.en}. $b are used. How many remain?',
          '${_mrDigits(a)} ${item.mr} आहेत. त्यांपैकी $b वापरल्या. किती उरल्या?',
        );
  final explanation = mode == 'openTenSubtraction'
      ? Words(
          '$a = ${a ~/ 10 - 1} tens and 12 ones. Subtract ${b % 10} ones from 12, then subtract the equal tens: $a − $b = $answer.',
          '${_mrDigits(a)} = ${_mrDigits(a ~/ 10 - 1)} दशके आणि १२ एकके. १२ मधून ${_mrDigits(b % 10)} एकके वजा करा; उरलेली दशके वजा केल्यावर उत्तर ${_mrDigits(answer)}.',
        )
      : Words(
          '$a − $b = $answer.',
          '${_mrDigits(a)} − ${_mrDigits(b)} = ${_mrDigits(answer)}.',
        );
  final hint = mode == 'openTenSubtraction'
      ? const Words(
          'If the ones are too few, exchange one ten for ten ones.',
          'एकके कमी पडल्यास एक दशक बदलून दहा एकके घ्या.',
        )
      : const Words(
          'Count backwards by the number taken away.',
          'वजा केलेल्या संख्येइतके मागे मोजा.',
        );
  return _numericQuestion(
    c,
    i,
    seed,
    prompt,
    explanation,
    hint,
    answer,
    ['🌱', '➖', '🫘'],
    'subtraction',
    maxAnswer: c.grade == 1 ? 9 : null,
  );
}

ChapterQuestion _inverseQuestion(SchoolChapter c, int i, int seed) {
  final a = 8 + i * 3;
  final b = 4 + i * 2;
  final total = a + b;
  return _numericQuestion(
    c,
    i,
    seed,
    Words(
      'A number sentence is $a + __ = $total. What number is missing?',
      'संख्या-वाक्य ${_mrDigits(a)} + __ = ${_mrDigits(total)} आहे. कोणती संख्या गाळली आहे?',
    ),
    Words(
      '$a + $b = $total. Check with subtraction: $total − $a = $b.',
      '${_mrDigits(a)} + ${_mrDigits(b)} = ${_mrDigits(total)}. उलट तपासणी: ${_mrDigits(total)} − ${_mrDigits(a)} = ${_mrDigits(b)}.',
    ),
    const Words(
      'Use the total and take away the known addend to find the missing one.',
      'एकूणातून दिलेली संख्या वजा करून गाळलेली संख्या शोधा.',
    ),
    b,
    ['🧮', '➕', '➖'],
    'factFamily',
  );
}

ChapterQuestion _patternQuestion(SchoolChapter c, int i, int seed) {
  final step = 1 + i % 4;
  final start = 2 + i * 2;
  final answer = start + 3 * step;
  final objects = const [
    ['🔴', '🔵'],
    ['⭐', '🌙'],
    ['🟩', '🟨'],
    ['🍎', '🍐'],
    ['🔺', '🟣'],
  ][i % 5];
  return _numericQuestion(
    c,
    i,
    seed,
    Words(
      '$start, ${start + step}, ${start + 2 * step}, __. What comes next?',
      '${_mrDigits(start)}, ${_mrDigits(start + step)}, ${_mrDigits(start + 2 * step)}, __. पुढे काय येईल?',
    ),
    Words(
      'Each step adds $step, so ${start + 2 * step} + $step = $answer.',
      'प्रत्येक वेळी ${_mrDigits(step)} मिळवतात. म्हणून ${_mrDigits(start + 2 * step)} + ${_mrDigits(step)} = ${_mrDigits(answer)}.',
    ),
    const Words(
      'Compare neighbours to find what changes each time.',
      'लगतच्या पदांची तुलना करून प्रत्येक वेळी काय बदलते ते शोधा.',
    ),
    answer,
    objects,
    'pattern',
  );
}

ChapterQuestion _geometryQuestion(
  SchoolChapter c,
  int i,
  int seed,
  String mode,
) {
  if (mode == 'solidShape') {
    final set = [
      [
        const Words('a cube', 'घन'),
        const Words('six square flat faces', 'सहा चौकोनी सपाट पृष्ठभाग'),
      ],
      [
        const Words('a sphere', 'गोल'),
        const Words(
          'one curved surface and no flat face',
          'एक वक्र पृष्ठभाग आणि सपाट बाजू नाही',
        ),
      ],
      [
        const Words('a cylinder', 'दंडगोल'),
        const Words(
          'two flat circles and one curved surface',
          'दोन सपाट वर्तुळे आणि एक वक्र पृष्ठभाग',
        ),
      ],
      [
        const Words('a cuboid', 'इष्टिकाचिती'),
        const Words('six rectangular flat faces', 'सहा आयताकृती सपाट पृष्ठभाग'),
      ],
      [
        const Words('a cone', 'शंकू'),
        const Words(
          'one flat circle and one curved surface',
          'एक सपाट वर्तुळ आणि एक वक्र पृष्ठभाग',
        ),
      ],
      [
        const Words('a triangular prism', 'त्रिकोणी प्रिझम'),
        const Words(
          'two triangular faces and three rectangular faces',
          'दोन त्रिकोणी आणि तीन आयताकृती पृष्ठभाग',
        ),
      ],
      [
        const Words('a square pyramid', 'चौरस पिरॅमिड'),
        const Words(
          'one square face and four triangular faces',
          'एक चौकोनी आणि चार त्रिकोणी पृष्ठभाग',
        ),
      ],
      [
        const Words('a hexagonal prism', 'षट्कोनी प्रिझम'),
        const Words(
          'two hexagonal faces and six rectangular faces',
          'दोन षट्कोनी आणि सहा आयताकृती पृष्ठभाग',
        ),
      ],
      [
        const Words('a hemisphere', 'अर्धगोल'),
        const Words(
          'one flat circular face and one curved surface',
          'एक सपाट वर्तुळाकार बाजू आणि एक वक्र पृष्ठभाग',
        ),
      ],
      [
        const Words('a triangular pyramid', 'त्रिकोणी पिरॅमिड'),
        const Words('four triangular faces', 'चार त्रिकोणी पृष्ठभाग'),
      ],
    ];
    final target = set[i % set.length];
    final wrong = set
        .where((row) => (row[1]).en != (target[1]).en)
        .map((row) => row[1])
        .take(3)
        .toList();
    return _choiceQuestion(
      c,
      i,
      seed,
      Words(
        'Which description matches ${(target[0]).en}?',
        '${(target[0]).mr} या आकाराचे योग्य वर्णन कोणते?',
      ),
      target[1],
      wrong,
      Words(
        'A solid ${(target[0]).en} has ${(target[1]).en}.',
        '${(target[0]).mr} ला ${(target[1]).mr} असतात.',
      ),
      const Words(
        'Think about its flat faces and curved surface.',
        'त्याचे सपाट पृष्ठभाग आणि वक्र पृष्ठभाग विचारात घ्या.',
      ),
      ['🧊', '⚽', '🥫', '📦'],
      'solidShape',
    );
  }
  if (mode == 'geometryAngles' || mode == 'anglesAndShapes') {
    final scenes = [
      [
        const Words('The corner of a notebook', 'वहीचा कोपरा'),
        const Words('the same as a square corner', 'काटकोनाएवढा'),
      ],
      [
        const Words('The narrow opening of scissors', 'कात्रीचे अरुंद उघडणे'),
        const Words('smaller than a square corner', 'काटकोनापेक्षा लहान'),
      ],
      [
        const Words('A barn door opened wide', 'गोठ्याचा दरवाजा पूर्ण उघडलेला'),
        const Words('larger than a square corner', 'काटकोनापेक्षा मोठा'),
      ],
      [
        const Words('The corner of a square tile', 'चौरस फरशीचा कोपरा'),
        const Words('the same as a square corner', 'काटकोनाएवढा'),
      ],
      [
        const Words(
          'The sharp tip of a paper triangle',
          'कागदी त्रिकोणाचे टोक',
        ),
        const Words('smaller than a square corner', 'काटकोनापेक्षा लहान'),
      ],
      [
        const Words(
          'The corner of a square window frame',
          'चौरस खिडकीच्या चौकटीचा कोपरा',
        ),
        const Words('the same as a square corner', 'काटकोनाएवढा'),
      ],
      [
        const Words(
          'Two narrow paths meeting',
          'एकत्र येणाऱ्या दोन अरुंद वाटा',
        ),
        const Words('smaller than a square corner', 'काटकोनापेक्षा लहान'),
      ],
      [
        const Words(
          'A gate swung open beyond a quarter turn',
          'चतुर्थांश वळणापेक्षा जास्त उघडलेले फाटक',
        ),
        const Words('larger than a square corner', 'काटकोनापेक्षा मोठा'),
      ],
      [
        const Words(
          'The corner of a square picture frame',
          'चौरस चित्रचौकटीचा कोपरा',
        ),
        const Words('the same as a square corner', 'काटकोनाएवढा'),
      ],
      [
        const Words(
          'The narrow point of a folded paper fan',
          'घडीच्या कागदी पंख्याचे अरुंद टोक',
        ),
        const Words('smaller than a square corner', 'काटकोनापेक्षा लहान'),
      ],
    ];
    final scene = scenes[i % scenes.length];
    final object = scene[0];
    final angle = scene[1];
    final choices = [
      const Words('smaller than a square corner', 'काटकोनापेक्षा लहान'),
      const Words('the same as a square corner', 'काटकोनाएवढा'),
      const Words('larger than a square corner', 'काटकोनापेक्षा मोठा'),
      const Words('a curved line, not an angle', 'वक्र रेषा, कोन नाही'),
    ];
    return _choiceQuestion(
      c,
      i,
      seed,
      Words(
        '${object.en}. Is its angle smaller than, the same as, or larger than a square corner?',
        '${object.mr}. त्याचा कोन काटकोनापेक्षा लहान, समान की मोठा आहे?',
      ),
      angle,
      choices.where((x) => x.en != angle.en).take(3).toList(),
      Words(
        'Compare ${object.en.toLowerCase()} with a paper square corner: it is ${angle.en}.',
        'कागदाच्या काटकोनाशी तुलना केल्यास ${object.mr} ${angle.mr}.',
      ),
      const Words(
        'Use the corner of a paper square as your reference.',
        'कागदाच्या चौकोनाचा कोपरा संदर्भ म्हणून वापरा.',
      ),
      ['📐', '📄'],
      'angles',
    );
  }
  final shapes = [
    [
      const Words('triangle', 'त्रिकोण'),
      const Words('three straight sides', 'तीन सरळ बाजू'),
      const Words('a three-sided sign', 'तीन बाजूंची पाटी'),
    ],
    [
      const Words('square', 'चौरस'),
      const Words(
        'four equal sides and four square corners',
        'चार समान बाजू आणि चार काटकोन',
      ),
      const Words('a four-equal-side tile', 'चार समान बाजूंची फरशी'),
    ],
    [
      const Words('rectangle', 'आयत'),
      const Words(
        'four sides with opposite sides equal',
        'विरुद्ध बाजू समान असलेल्या चार बाजू',
      ),
      const Words('a book cover', 'पुस्तकाचे मुखपृष्ठ'),
    ],
    [
      const Words('circle', 'वर्तुळ'),
      const Words(
        'a perfectly round curved edge and no straight sides',
        'गोल वक्र कडा आणि सरळ बाजू नाहीत',
      ),
      const Words('a round plate', 'गोल ताट'),
    ],
    [
      const Words('oval', 'लंबवर्तुळ'),
      const Words(
        'a stretched round curved edge and no straight sides',
        'लांबट गोल वक्र कडा आणि सरळ बाजू नाहीत',
      ),
      const Words('an oval mirror', 'लंबवर्तुळाकार आरसा'),
    ],
    [
      const Words('triangle', 'त्रिकोण'),
      const Words('three straight sides', 'तीन सरळ बाजू'),
      const Words('a triangular roof sign', 'त्रिकोणी छताची पाटी'),
    ],
    [
      const Words('square', 'चौरस'),
      const Words(
        'four equal sides and four square corners',
        'चार समान बाजू आणि चार काटकोन',
      ),
      const Words(
        'a window with four equal sides',
        'चार समान बाजू असलेली खिडकी',
      ),
    ],
    [
      const Words('rectangle', 'आयत'),
      const Words(
        'four sides with opposite sides equal',
        'विरुद्ध बाजू समान असलेल्या चार बाजू',
      ),
      const Words('a rectangular classroom door', 'आयताकृती वर्गखोलीचा दरवाजा'),
    ],
    [
      const Words('circle', 'वर्तुळ'),
      const Words(
        'a perfectly round curved edge and no straight sides',
        'गोल वक्र कडा आणि सरळ बाजू नाहीत',
      ),
      const Words('a bicycle wheel outline', 'सायकलच्या चाकाची बाह्यरेषा'),
    ],
    [
      const Words('oval', 'लंबवर्तुळ'),
      const Words(
        'a stretched round curved edge and no straight sides',
        'लांबट गोल वक्र कडा आणि सरळ बाजू नाहीत',
      ),
      const Words('an egg-shaped drawing', 'अंड्यासारखे चित्र'),
    ],
  ];
  final item = shapes[i % shapes.length];
  final name = item[0];
  final property = item[1];
  final context = item[2];
  final prompt = mode == 'shapesAround'
      ? Words(
          'At home, ${context.en} has the outline of which flat shape?',
          'घरी ${context.mr} चा बाह्य आकार कोणता सपाट आकार आहे?',
        )
      : mode == 'flatShape' && c.grade == 1
      ? Words(
          'Which flat shape fits ${context.en}: ${property.en}?',
          '${context.mr}: ${property.mr}. कोणता सपाट आकार?',
        )
      : Words(
          'A ${context.en} has an outline like which flat shape?',
          '${context.mr} चा बाह्य आकार कोणत्या सपाट आकारासारखा आहे?',
        );
  final namesByEnglish = <String, Words>{};
  for (final shape in shapes) {
    final candidate = shape[0];
    namesByEnglish[candidate.en] = candidate;
  }
  final wrong = namesByEnglish.values
      .where((x) => x.en != name.en)
      .take(3)
      .toList();
  return _choiceQuestion(
    c,
    i,
    seed,
    prompt,
    name,
    wrong,
    Words(
      'A ${name.en} has ${property.en}.',
      '${name.mr} या आकाराला ${property.mr}.',
    ),
    const Words(
      'Trace the outline and count its straight sides and corners.',
      'बाह्यरेषेवरून बोट फिरवा आणि सरळ बाजू व कोपरे मोजा.',
    ),
    ['🔺', '🟦', '📘', '🍽️'],
    'flatShape',
  );
}

ChapterQuestion _measureQuestion(
  SchoolChapter c,
  int i,
  int seed,
  String mode,
) {
  if (mode == 'metricUnits') {
    final conversion = i % 3;
    late int answer;
    late Words prompt, explanation;
    if (conversion == 0) {
      final m = 2 + i;
      answer = m * 100;
      prompt = Words(
        'How many centimetres are in $m metres?',
        '${_mrDigits(m)} मीटरमध्ये किती सेंटीमीटर असतात?',
      );
      explanation = Words(
        '1 metre = 100 centimetres, so $m m = $answer cm.',
        '१ मीटर = १०० सेंटीमीटर, म्हणून ${_mrDigits(m)} मीटर = ${_mrDigits(answer)} सेंटीमीटर.',
      );
    } else if (conversion == 1) {
      final cm = 3 + i;
      answer = cm * 10;
      prompt = Words(
        'How many millimetres are in $cm centimetres?',
        '${_mrDigits(cm)} सेंटीमीटरमध्ये किती मिलीमीटर असतात?',
      );
      explanation = Words(
        '1 centimetre = 10 millimetres, so $cm cm = $answer mm.',
        '१ सेंटीमीटर = १० मिलीमीटर, म्हणून ${_mrDigits(cm)} सेंटीमीटर = ${_mrDigits(answer)} मिलीमीटर.',
      );
    } else {
      final kg = 2 + i;
      answer = kg * 1000;
      prompt = Words(
        'How many grams are in $kg kilograms?',
        '${_mrDigits(kg)} किलोग्रॅममध्ये किती ग्राम असतात?',
      );
      explanation = Words(
        '1 kilogram = 1,000 grams, so $kg kg = $answer g.',
        '१ किलोग्रॅम = १,००० ग्राम, म्हणून ${_mrDigits(kg)} किलोग्रॅम = ${_mrDigits(answer)} ग्राम.',
      );
    }
    return _numericQuestion(
      c,
      i,
      seed,
      prompt,
      explanation,
      const Words(
        'Use the unit relationship before changing the number.',
        'संख्या बदलण्यापूर्वी दोन एककांतील संबंध वापरा.',
      ),
      answer,
      ['📏', '⚖️'],
      'measurement',
    );
  }
  if (mode == 'lengthAndWeight') {
    final measures = [
      [
        const Words('a finger length', 'बोटाची लांबी'),
        const Words('centimetres', 'सेंटीमीटर'),
      ],
      [
        const Words('a grain of rice mass', 'तांदळाच्या दाण्याचे वजन'),
        const Words('grams', 'ग्राम'),
      ],
      [
        const Words('a classroom length', 'वर्गखोलीची लांबी'),
        const Words('metres', 'मीटर'),
      ],
      [
        const Words('a school bag mass', 'शाळेच्या दप्तराचे वजन'),
        const Words('kilograms', 'किलोग्रॅम'),
      ],
      [
        const Words('the distance between two towns', 'दोन गावांतील अंतर'),
        const Words('kilometres', 'किलोमीटर'),
      ],
      [
        const Words('the width of a notebook', 'वहीची रुंदी'),
        const Words('centimetres', 'सेंटीमीटर'),
      ],
      [
        const Words('a sack of rice mass', 'तांदळाच्या पोत्याचे वजन'),
        const Words('kilograms', 'किलोग्रॅम'),
      ],
      [
        const Words('a classroom wall length', 'वर्गखोलीच्या भिंतीची लांबी'),
        const Words('metres', 'मीटर'),
      ],
      [
        const Words('a single bean mass', 'एका बियाचे वजन'),
        const Words('grams', 'ग्राम'),
      ],
      [
        const Words(
          'the road from the village to the city',
          'गावापासून शहरापर्यंतचा रस्ता',
        ),
        const Words('kilometres', 'किलोमीटर'),
      ],
    ];
    final measure = measures[i % measures.length];
    final item = measure[0];
    final unit = measure[1];
    return _choiceQuestion(
      c,
      i,
      seed,
      Words(
        'Which unit is most suitable for ${item.en}?',
        '${item.mr} मोजण्यासाठी कोणते एकक योग्य आहे?',
      ),
      unit,
      [
        const Words('centimetres', 'सेंटीमीटर'),
        const Words('grams', 'ग्राम'),
        const Words('metres', 'मीटर'),
        const Words('kilograms', 'किलोग्रॅम'),
        const Words('kilometres', 'किलोमीटर'),
      ],
      Words(
        'Use ${unit.en} for ${item.en}.',
        '${item.mr} मोजण्यासाठी ${unit.mr} वापरा.',
      ),
      const Words(
        'Choose the unit that measures mass at this scale.',
        'या आकाराचे वजन मोजणारे एकक निवडा.',
      ),
      ['🎒', '⚖️'],
      'measurement',
    );
  }
  if (mode == 'measureUnits') {
    final labels = [
      [
        const Words('length of a crayon', 'खडूची लांबी'),
        const Words('centimetres', 'सेंटीमीटर'),
      ],
      [
        const Words('mass of a watermelon', 'कलिंगडाचे वजन'),
        const Words('kilograms', 'किलोग्रॅम'),
      ],
      [
        const Words('water in a bottle', 'बाटलीतील पाणी'),
        const Words('litres', 'लिटर'),
      ],
      [
        const Words('distance between towns', 'दोन गावांतील अंतर'),
        const Words('kilometres', 'किलोमीटर'),
      ],
      [
        const Words('mass of a paper clip', 'पेपर क्लिपचे वजन'),
        const Words('grams', 'ग्राम'),
      ],
      [
        const Words('width of a notebook', 'वहीची रुंदी'),
        const Words('centimetres', 'सेंटीमीटर'),
      ],
      [
        const Words('mass of a sack of rice', 'तांदळाच्या पोत्याचे वजन'),
        const Words('kilograms', 'किलोग्रॅम'),
      ],
      [
        const Words('length of a classroom wall', 'वर्गखोलीच्या भिंतीची लांबी'),
        const Words('metres', 'मीटर'),
      ],
      [
        const Words('mass of a single bean', 'एका बियाचे वजन'),
        const Words('grams', 'ग्राम'),
      ],
      [
        const Words(
          'distance from the village to the city',
          'गावापासून शहरापर्यंतचे अंतर',
        ),
        const Words('kilometres', 'किलोमीटर'),
      ],
    ];
    final row = labels[i % labels.length];
    final right = row[1];
    final choices = [
      const Words('centimetres', 'सेंटीमीटर'),
      const Words('kilograms', 'किलोग्रॅम'),
      const Words('litres', 'लिटर'),
      const Words('kilometres', 'किलोमीटर'),
      const Words('grams', 'ग्राम'),
    ];
    return _choiceQuestion(
      c,
      i,
      seed,
      Words(
        'Choose a suitable unit for the ${(row[0]).en}.',
        '${(row[0]).mr} मोजण्यासाठी योग्य एकक निवडा.',
      ),
      right,
      choices.where((x) => x.en != right.en).take(3).toList(),
      Words(
        'We measure the ${(row[0]).en} in ${right.en}.',
        '${(row[0]).mr} ${right.mr} मध्ये मोजतात.',
      ),
      const Words(
        'Decide whether it is length, mass, or capacity, then choose a scale.',
        'ते लांबी, वजन की धारकता आहे ते ठरवा आणि त्यानुसार एकक निवडा.',
      ),
      ['📏', '⚖️', '🫗'],
      'measurement',
    );
  }
  final count = 2 + i;
  final handspans = count;
  final objects = [
    const Words('desk', 'टेबल'),
    const Words('class mat', 'वर्गातील चटई'),
    const Words('garden path', 'बागेतील वाट'),
    const Words('blackboard', 'फळा'),
    const Words('window ledge', 'खिडकीचा कठडा'),
    const Words('bench', 'बाक'),
    const Words('doorway', 'दाराची चौकट'),
    const Words('flower bed', 'फुलांचा ताटवा'),
    const Words('playground line', 'मैदानावरील रेषा'),
    const Words('book shelf', 'पुस्तकांचा कप्पा'),
  ];
  final object = objects[i % objects.length];
  return _numericQuestion(
    c,
    i,
    seed,
    Words(
      'A ${object.en} is $handspans handspans long. How many handspans measure it?',
      '${object.mr} ${_mrDigits(handspans)} विती लांब आहे. त्याची लांबी किती विती?',
    ),
    Words(
      'Count the equal handspans: the ${object.en} is $handspans handspans long.',
      'समान विती मोजा: ${object.mr} ${_mrDigits(handspans)} विती लांब आहे.',
    ),
    const Words(
      'Use the same handspan each time so the units match.',
      'प्रत्येक वेळी तीच विती वापरा, म्हणजे एकके समान राहतील.',
    ),
    handspans,
    ['🖐️', '🪑'],
    'informalMeasure',
  );
}

ChapterQuestion _calendarQuestion(
  SchoolChapter c,
  int i,
  int seed,
  String mode,
) {
  const weekdays = [
    Words('Monday', 'सोमवार'),
    Words('Tuesday', 'मंगळवार'),
    Words('Wednesday', 'बुधवार'),
    Words('Thursday', 'गुरुवार'),
    Words('Friday', 'शुक्रवार'),
    Words('Saturday', 'शनिवार'),
    Words('Sunday', 'रविवार'),
  ];
  if (mode == 'dailyTime') {
    final dayIndex = i % weekdays.length;
    final day = weekdays[dayIndex];
    final offset = 1 + i % 2;
    final next = weekdays[(dayIndex + offset) % weekdays.length];
    return _choiceQuestion(
      c,
      i,
      seed,
      Words(
        'School cleaning is on ${day.en}. What day comes $offset${offset == 1 ? ' day' : ' days'} later?',
        '${day.mr} दिवशी शाळेची स्वच्छता आहे. ${_mrDigits(offset)} दिवसांनी कोणता वार येईल?',
      ),
      next,
      weekdays.where((x) => x.en != next.en).take(3).toList(),
      Words(
        'The weekday $offset${offset == 1 ? ' day' : ' days'} after ${day.en} is ${next.en}.',
        '${day.mr} पासून ${_mrDigits(offset)} दिवसांनी ${next.mr} येतो.',
      ),
      const Words(
        'Say the days in order and move forward one day.',
        'वारांचा क्रम म्हणा आणि एक दिवस पुढे जा.',
      ),
      ['📅', '🏫'],
      'calendar',
    );
  }
  final weeks = 1 + i;
  return _numericQuestion(
    c,
    i,
    seed,
    Words(
      'A calendar shows $weeks full weeks. How many days is that?',
      'दिनदर्शिकेत ${_mrDigits(weeks)} पूर्ण आठवडे आहेत. एकूण किती दिवस?',
    ),
    Words(
      'There are 7 days in a week: $weeks × 7 = ${weeks * 7} days.',
      'एका आठवड्यात ७ दिवस: ${_mrDigits(weeks)} × ७ = ${_mrDigits(weeks * 7)} दिवस.',
    ),
    const Words(
      'A full week has seven days. Multiply the number of weeks by seven.',
      'एका पूर्ण आठवड्यात सात दिवस असतात. आठवड्यांची संख्या सातने गुणा.',
    ),
    weeks * 7,
    ['📆', '🗓️'],
    'calendar',
  );
}

ChapterQuestion _clockQuestion(SchoolChapter c, int i, int seed, String mode) {
  if (mode == 'elapsedTime') {
    final start = 8 + i % 4;
    final minutes = (i % 3 + 1) * 15;
    final endMinutes = ((start % 12) * 60 + minutes) % 720;
    final hour = endMinutes ~/ 60;
    final minute = endMinutes % 60;
    final answerHour = hour == 0 ? 12 : hour;
    final text = _clockTime(answerHour, minute);
    return _clockChoiceQuestion(
      c,
      i,
      seed,
      Words(
        'A class starts at $start:00 and lasts $minutes minutes. When does it end?',
        'वर्ग ${_mrDigits(start)}:०० वाजता सुरू होतो आणि ${_mrDigits(minutes)} मिनिटे चालतो. तो कधी संपतो?',
      ),
      Words(
        'Add $minutes minutes to $start:00. The end time is $text.',
        '${_mrDigits(start)}:०० मध्ये ${_mrDigits(minutes)} मिनिटे मिळवा. संपण्याची वेळ ${_mrClockTime(answerHour, minute)}.',
      ),
      const Words(
        'Count the quarter-hour steps on the clock, regrouping 60 minutes as one hour.',
        'घड्याळावर पाव तासांच्या पायऱ्या मोजा; ६० मिनिटे झाली की एक तास करा.',
      ),
      answerHour,
      minute,
    );
  }
  final hour = 1 + i % 12;
  final minutes = [0, 15, 30, 45][i % 4];
  final nextHour = hour == 12 ? 1 : hour + 1;
  final hourPositionEn = minutes == 0
      ? 'at $hour'
      : 'between $hour and $nextHour';
  final hourPositionMr = minutes == 0
      ? '${_mrDigits(hour)} वर'
      : '${_mrDigits(hour)} आणि ${_mrDigits(nextHour)} यांच्या मध्ये';
  return _clockChoiceQuestion(
    c,
    i,
    seed,
    Words(
      'The short hand is $hourPositionEn and the long hand is at ${minutes == 0
          ? '12'
          : minutes == 15
          ? '3'
          : minutes == 30
          ? '6'
          : '9'}. What time is shown?',
      'लहान काटा $hourPositionMr आणि मोठा काटा ${minutes == 0
          ? '१२'
          : minutes == 15
          ? '३'
          : minutes == 30
          ? '६'
          : '९'} वर आहे. किती वाजले?',
    ),
    Words(
      'The clock shows ${_clockTime(hour, minutes)}.',
      'घड्याळात ${_mrClockTime(hour, minutes)} वाजले आहेत.',
    ),
    const Words(
      'Read the short hand for the hour and the long hand for minutes.',
      'तासासाठी लहान काटा आणि मिनिटांसाठी मोठा काटा वाचा.',
    ),
    hour,
    minutes,
  );
}

ChapterQuestion _clockChoiceQuestion(
  SchoolChapter c,
  int i,
  int seed,
  Words prompt,
  Words explanation,
  Words hint,
  int hour,
  int minute,
) {
  final current = (hour % 12) * 60 + minute;
  final choices = [
    current,
    (current + 15) % 720,
    (current + 705) % 720,
    (current + 60) % 720,
  ];
  final correct = _clockTimeWords(hour, minute);
  final wrong = choices.skip(1).map((time) {
    final normalizedHour = time ~/ 60 == 0 ? 12 : time ~/ 60;
    return _clockTimeWords(normalizedHour, time % 60);
  }).toList();
  return _choiceQuestion(
    c,
    i,
    seed,
    prompt,
    correct,
    wrong,
    explanation,
    hint,
    ['🕰️', '🕒'],
    'clock',
  );
}

Words _clockTimeWords(int hour, int minute) =>
    Words(_clockTime(hour, minute), _mrClockTime(hour, minute));

String _clockTime(int hour, int minute) =>
    '$hour:${minute.toString().padLeft(2, '0')}';

String _mrClockTime(int hour, int minute) =>
    '${_mrDigits(hour)}:${_mrDigits(minute).padLeft(2, '०')}';

ChapterQuestion _multiplicationQuestion(
  SchoolChapter c,
  int i,
  int seed,
  String mode,
) {
  late int a, b;
  if (mode == 'multiDigitMultiplication') {
    a = 21 + i * 7;
    b = 3 + i % 4;
  } else if (c.grade == 4) {
    a = 24 + i * 5;
    b = 3 + i % 5;
  } else if (c.grade == 3) {
    a = 12 + i * 4;
    b = 2 + i % 5;
  } else {
    a = 2 + i % 6;
    b = 3 + i % 5;
  }
  final answer = a * b;
  final prompt = mode == 'equalGroupsIntro'
      ? Words(
          'There are $a equal baskets with $b guavas in each. How many guavas?',
          '$a समान टोपल्यांत प्रत्येकी ${_mrDigits(b)} पेरू आहेत. पेरू एकूण किती?',
        )
      : Words(
          'A garden has $a rows with $b seedlings in each row. How many seedlings?',
          'बागेत ${_mrDigits(a)} ओळी आहेत आणि प्रत्येक ओळीत ${_mrDigits(b)} रोपे आहेत. एकूण रोपे किती?',
        );
  final explanation = Words(
    'Add $b for each of $a equal groups: $a × $b = $answer.',
    '$a समान गटांसाठी ${_mrDigits(b)} ची बेरीज करा: ${_mrDigits(a)} × ${_mrDigits(b)} = ${_mrDigits(answer)}.',
  );
  return _numericQuestion(
    c,
    i,
    seed,
    prompt,
    explanation,
    const Words(
      'Count the same number in each row, or multiply number of groups by items per group.',
      'प्रत्येक ओळीत तेवढ्याच वस्तू मोजा किंवा गटांची संख्या आणि प्रत्येक गटातील वस्तू गुणा.',
    ),
    answer,
    ['🌱', '🧺', '✖️'],
    'equalGroups',
  );
}

ChapterQuestion _divisionQuestion(
  SchoolChapter c,
  int i,
  int seed,
  String mode,
) {
  final divisor = 2 + i % 4;
  final quotient = 3 + i % 6;
  final remainder = mode == 'divisionRemainder' ? i % divisor : 0;
  final total = divisor * quotient + remainder;
  final askRemainder = mode == 'divisionRemainder' && i.isOdd;
  final answer = askRemainder ? remainder : quotient;
  final prompt = askRemainder
      ? Words(
          'Share $total berries equally among $divisor bowls. How many are left over?',
          '${_mrDigits(total)} जांभळे ${_mrDigits(divisor)} वाट्यांत समान वाटा. किती उरतील?',
        )
      : Words(
          'Share $total picture cards equally among $divisor friends. How many does each friend get?',
          '${_mrDigits(total)} चित्रांची कार्डे ${_mrDigits(divisor)} मित्रांत समान वाटा. प्रत्येकाला किती मिळतील?',
        );
  final explanation = Words(
    '$total = $divisor × $quotient${remainder > 0 ? ' + $remainder' : ''}. Each group gets $quotient${remainder > 0 ? ' and $remainder remain.' : '.'}',
    '${_mrDigits(total)} = ${_mrDigits(divisor)} × ${_mrDigits(quotient)}${remainder > 0 ? ' + ${_mrDigits(remainder)}' : ''}. प्रत्येक गटाला ${_mrDigits(quotient)}${remainder > 0 ? ' मिळतात आणि ${_mrDigits(remainder)} उरतात.' : '.'}',
  );
  return _numericQuestion(
    c,
    i,
    seed,
    prompt,
    explanation,
    const Words(
      'Make equal groups first. Check the total by multiplying the group size and number of groups.',
      'आधी समान गट करा. गटातील संख्या आणि गटांची संख्या गुणून एकूण तपासा.',
    ),
    answer,
    ['🫐', '🧺', '➗'],
    'sharing',
  );
}

ChapterQuestion _fractionQuestion(
  SchoolChapter c,
  int i,
  int seed,
  String mode,
) {
  final denominator = mode == 'mixedFractions'
      ? [2, 3, 4, 5, 2][i % 5]
      : [2, 4, 4, 3, 4][i % 5];
  final numerator = mode == 'mixedFractions' && i % 2 == 1
      ? denominator + 1
      : ([1, 1, 3, 2, 1][i % 5]);
  final correct = Words(
    '$numerator/$denominator',
    '${_mrDigits(numerator)}/${_mrDigits(denominator)}',
  );
  final alternatives = [
    Words(
      '${numerator + 1}/$denominator',
      '${_mrDigits(numerator + 1)}/${_mrDigits(denominator)}',
    ),
    Words(
      '$numerator/${denominator + 1}',
      '${_mrDigits(numerator)}/${_mrDigits(denominator + 1)}',
    ),
    Words(
      '$denominator/$numerator',
      '${_mrDigits(denominator)}/${_mrDigits(numerator)}',
    ),
  ];
  final shape = const [
    'paper roti',
    'fruit bar',
    'garden patch',
    'rangoli tile',
    'sharing plate',
    'paper kite',
    'sandwich square',
    'flower bed',
    'painted wall panel',
    'garden flag',
  ][i % 10];
  final mrShape = const [
    'पोळी',
    'फळाची पट्टी',
    'बागेचा तुकडा',
    'रांगोळीची फरशी',
    'वाटणीचे ताट',
    'कागदी पतंग',
    'सँडविचचा तुकडा',
    'फुलांचा ताटवा',
    'रंगवलेला भिंतीचा भाग',
    'बागेतील ध्वज',
  ][i % 10];
  return _choiceQuestion(
    c,
    i,
    seed,
    Words(
      'A $shape is cut into $denominator equal parts. $numerator parts are shaded. Which fraction is shaded?',
      'एक $mrShape ${_mrDigits(denominator)} समान भागांत विभागली. त्यांपैकी ${_mrDigits(numerator)} भाग रंगवले. रंगवलेला अपूर्णांक कोणता?',
    ),
    correct,
    alternatives,
    Words(
      'The numerator counts shaded parts and the denominator counts all equal parts: ${correct.en}.',
      'अंश रंगवलेले भाग मोजतो आणि छेद एकूण समान भाग मोजतो: ${correct.mr}.',
    ),
    const Words(
      'Count shaded parts for the top number and all equal parts for the bottom number.',
      'अंशासाठी रंगवलेले भाग आणि छेदासाठी एकूण समान भाग मोजा.',
    ),
    ['🫓', '◩', '🎨'],
    'fraction',
  );
}

ChapterQuestion _mapQuestion(SchoolChapter c, int i, int seed, String mode) {
  final rows = ['A', 'B', 'C'];
  final cols = [1, 2, 3, 4];
  final row = rows[i % rows.length];
  final col = cols[i % cols.length];
  final directions = [
    const Words('east', 'पूर्व'),
    const Words('west', 'पश्चिम'),
    const Words('north', 'उत्तर'),
    const Words('south', 'दक्षिण'),
  ];
  final direction = directions[i % 4];
  final object = const [
    Words('library', 'वाचनालय'),
    Words('well', 'विहीर'),
    Words('garden', 'बाग'),
    Words('school', 'शाळा'),
    Words('bridge', 'पूल'),
  ][i % 5];
  final answer = Words(row + col.toString(), '$row-${_mrDigits(col)}');
  final prompt = mode == 'sketchMap'
      ? Words(
          'On Mira’s sketch map, the ${object.en} is in row $row, column $col. What grid address should she read?',
          'मीराच्या नकाशात ${object.mr} $row ओळ आणि ${_mrDigits(col)} स्तंभात आहे. जाळीतील स्थान कोणते?',
        )
      : Words(
          'A map shows the ${object.en} at ${direction.en} of the pond. Which direction should you travel from the pond?',
          'नकाशात ${object.mr} तळ्याच्या ${direction.mr} बाजूला आहे. तळ्यापासून कोणत्या दिशेने जाल?',
        );
  if (mode == 'sketchMap') {
    final wrong = [
      Words(row + (col % 4 + 1).toString(), '$row-${_mrDigits(col % 4 + 1)}'),
      Words(
        rows[(i + 1) % 3] + col.toString(),
        '${rows[(i + 1) % 3]}-${_mrDigits(col)}',
      ),
      Words(
        rows[(i + 2) % 3] + (col % 4 + 1).toString(),
        '${rows[(i + 2) % 3]}-${_mrDigits(col % 4 + 1)}',
      ),
    ];
    return _choiceQuestion(
      c,
      i,
      seed,
      prompt,
      answer,
      wrong,
      Words(
        'Read the row $row first and the column $col next.',
        '$row ओळ आधी आणि ${_mrDigits(col)} स्तंभ नंतर वाचा.',
      ),
      const Words(
        'Use the row letter and column number where they meet.',
        'ओळ आणि स्तंभ जिथे भेटतात ते स्थान वापरा.',
      ),
      ['🗺️', '📍', '🧭'],
      'grid',
    );
  }
  final wrong = directions.where((x) => x.en != direction.en).take(3).toList();
  return _choiceQuestion(
    c,
    i,
    seed,
    prompt,
    direction,
    wrong,
    Words(
      'The map symbol is ${direction.en} of the pond.',
      'नकाशातील खूण तळ्याच्या ${direction.mr} आहे.',
    ),
    const Words(
      'Use the compass rose: north is up, south down, east right, and west left.',
      'दिशाचिन्ह वापरा: उत्तर वर, दक्षिण खाली, पूर्व उजवीकडे आणि पश्चिम डावीकडे.',
    ),
    ['🗺️', '🧭', '💧'],
    'map',
  );
}

ChapterQuestion _symmetryQuestion(
  SchoolChapter c,
  int i,
  int seed,
  String mode,
) {
  if (mode == 'symmetryAxes') {
    final counts = [1, 2, 4, 0, 2, 3, 5, 6, 0, 8][i % 10];
    final shape = [
      'isosceles triangle',
      'rectangle',
      'square',
      'scalene triangle',
      'non-square rhombus',
      'equilateral triangle',
      'regular pentagon',
      'regular hexagon',
      'slanted parallelogram',
      'regular octagon',
    ][i % 10];
    final mr = [
      'समद्विबाहू त्रिकोण',
      'आयत',
      'चौरस',
      'विषमबाहू त्रिकोण',
      'समचतुर्भुज',
      'समभुज त्रिकोण',
      'नियमित पंचभुज',
      'नियमित षट्भुज',
      'तिरका समांतरभुज',
      'नियमित अष्टभुज',
    ][i % 10];
    return _numericQuestion(
      c,
      i,
      seed,
      Words(
        'How many lines of symmetry does a $shape have?',
        '$mr आकाराला सममितीच्या किती रेषा असतात?',
      ),
      Words(
        'A $shape has $counts line${counts == 1 ? '' : 's'} of symmetry.',
        '$mr आकाराला ${_mrDigits(counts)} सममिती रेषा आहेत.',
      ),
      const Words(
        'Imagine folding along a line. Count the folds that make two matching halves.',
        'रेषेवरून घडी घातल्याचे कल्पना करा. जुळणारे दोन भाग करणाऱ्या घड्या मोजा.',
      ),
      counts,
      ['🔷', '🪞'],
      'symmetry',
    );
  }
  final examples = [
    [const Words('butterfly', 'फुलपाखरू'), true],
    [const Words('uneven clay shape', 'असम आकाराची मातीची वस्तू'), false],
    [
      const Words(
        'heart cut from folded paper',
        'घडीच्या कागदातून कापलेले हृदय',
      ),
      true,
    ],
    [
      const Words(
        'irregular leaf with a bent midrib',
        'वाकडी मध्यशीर असलेले अनियमित पान',
      ),
      false,
    ],
    [
      const Words(
        'mask with matching eye holes',
        'जुळणारी डोळ्यांची छिद्रे असलेला मुखवटा',
      ),
      true,
    ],
    [
      const Words(
        'paper leaf cut along its straight middle line',
        'सरळ मध्यरेषेवरून कापलेले कागदी पान',
      ),
      true,
    ],
    [
      const Words(
        'irregular cloud cut from paper',
        'कागदातून कापलेला अनियमित ढग',
      ),
      false,
    ],
    [
      const Words(
        'square tile with the same pattern on both sides',
        'दोन्ही बाजूंना समान नक्षी असलेली चौरस फरशी',
      ),
      true,
    ],
    [
      const Words(
        'one-sided arrow cut from card',
        'कार्डमधून कापलेला एकतर्फी बाण',
      ),
      false,
    ],
    [
      const Words(
        'five-point paper star folded down its middle',
        'मधोमध घडी घातलेला पाच टोकांचा कागदी तारा',
      ),
      true,
    ],
  ];
  final example = examples[i % examples.length];
  final shape = example[0] as Words;
  final symmetric = example[1] as bool;
  final answer = symmetric
      ? const Words('yes, the two sides match', 'हो, दोन्ही बाजू जुळतात')
      : const Words(
          'no, the two sides do not match',
          'नाही, दोन्ही बाजू जुळत नाहीत',
        );
  final wrong = symmetric
      ? [
          const Words(
            'no, the two sides do not match',
            'नाही, दोन्ही बाजू जुळत नाहीत',
          ),
          const Words('it has no sides', 'त्याला बाजू नाहीत'),
          const Words('it is a solid', 'तो घन आहे'),
        ]
      : [
          const Words('yes, the two sides match', 'हो, दोन्ही बाजू जुळतात'),
          const Words('it has four equal sides', 'त्याला चार समान बाजू आहेत'),
          const Words('it is a circle', 'तो वर्तुळ आहे'),
        ];
  return _choiceQuestion(
    c,
    i,
    seed,
    Words(
      'If you fold a picture of a ${shape.en} down its middle, do the two halves match?',
      '${shape.mr} चे चित्र मधोमध घडी घातल्यावर दोन्ही भाग जुळतील का?',
    ),
    answer,
    wrong,
    Words(
      symmetric
          ? 'The two halves of the ${shape.en} match across the fold.'
          : 'The two halves of the ${shape.en} do not match across the fold.',
      symmetric
          ? '${shape.mr} चे दोन्ही भाग घडीच्या रेषेवर जुळतात.'
          : '${shape.mr} चे दोन्ही भाग घडीच्या रेषेवर जुळत नाहीत.',
    ),
    const Words(
      'Imagine a mirror or a fold along the marked line.',
      'दिलेल्या रेषेवर आरसा किंवा घडी असल्याची कल्पना करा.',
    ),
    ['🦋', '🪞'],
    'symmetry',
  );
}

ChapterQuestion _areaQuestion(SchoolChapter c, int i, int seed) {
  final length = 3 + i % 4;
  final width = 2 + i % 3;
  final askPerimeter = i.isOdd;
  final answer = askPerimeter ? 2 * (length + width) : length * width;
  return _numericQuestion(
    c,
    i,
    seed,
    Words(
      'A rectangle is $length square units long and $width units wide. Find its ${askPerimeter ? 'perimeter in units.' : 'area in square units.'}',
      'आयताची लांबी ${_mrDigits(length)} एकक आणि रुंदी ${_mrDigits(width)} एकक आहे. त्याचे ${askPerimeter ? 'परिमिती एककांत शोधा.' : 'क्षेत्रफळ चौरस एककांत शोधा.'}',
    ),
    askPerimeter
        ? Words(
            'Perimeter = 2 × ($length + $width) = $answer units.',
            'परिमिती = २ × (${_mrDigits(length)} + ${_mrDigits(width)}) = ${_mrDigits(answer)} एकक.',
          )
        : Words(
            'Area = $length rows × $width squares = $answer square units.',
            'क्षेत्रफळ = ${_mrDigits(length)} ओळी × ${_mrDigits(width)} चौरस = ${_mrDigits(answer)} चौरस एकक.',
          ),
    askPerimeter
        ? const Words(
            'Add the four boundary sides.',
            'चारही सीमाबाजूंची बेरीज करा.',
          )
        : const Words(
            'Count the square units inside: rows times squares in each row.',
            'आतील चौरस एकके मोजा: ओळींची संख्या गुणिले प्रत्येक ओळीतील चौरस.',
          ),
    answer,
    ['▦', '📐'],
    'area',
  );
}
