part of 'chapter_catalogue.dart';

// Contextual Class 4 classroom wording. Numerical variants, answer positions,
// content identities and source references stay in the original catalogue.
// The five improper-fraction prompts also clarify the original English's
// impossible single-whole context; no fraction or correct answer is changed.
ChapterQuestion _class4Question(
  SchoolChapter chapter,
  int index,
  ChapterQuestion original,
) {
  if (chapter.grade != 4) return original;
  final i = index % 10;
  String n(Object value) => class4Digits(value);
  var prompt = '', explanation = '', hint = '';
  String? englishPrompt, englishExplanation, englishHint;
  switch (chapter.number) {
    case 1:
      final thousands = 1 + i % 8,
          hundreds = (i * 3) % 10,
          tens = (i * 5) % 10,
          ones = (i * 7) % 10;
      final value = thousands * 1000 + hundreds * 100 + tens * 10 + ones;
      if (i % 3 == 0) {
        prompt =
            'हजाराच्या घरात ${n(thousands)}, शतकाच्या घरात ${n(hundreds)}, दशकाच्या घरात ${n(tens)} आणि एककाच्या घरात ${n(ones)} असलेली संख्या कोणती?';
        explanation =
            '${n(thousands * 1000)} + ${n(hundreds * 100)} + ${n(tens * 10)} + ${n(ones)} = ${n(value)}. प्रत्येक अंकाची स्थानिक किंमत मिळवल्यावर ही संख्या तयार होते.';
        hint =
            'डावीकडून हजार, शतक, दशक आणि एकक ही घरे पाहा. प्रत्येक अंक त्याच्या योग्य घरात लिहा.';
      } else {
        final parity = value.isEven ? 'सम' : 'विषम';
        prompt = '${n(value)} ही सम संख्या आहे की विषम संख्या?';
        explanation =
            'एककाच्या घरात ${n(ones)} आहे. म्हणून ${n(value)} ही $parity संख्या आहे.';
        hint =
            'एककाचा अंक पाहा. तो ०, २, ४, ६ किंवा ८ असेल तर संख्या सम असते; बाकीचे अंक असतील तर संख्या विषम असते.';
      }
    case 2:
      const scenes = [
        'वहीच्या कोपऱ्यातील कोन',
        'कात्री थोडी उघडल्यावर तयार झालेला कोन',
        'गोठ्याचा दरवाजा रुंद उघडल्यावर तयार झालेला कोन',
        'चौकोनी फरशीच्या कोपऱ्यातील कोन',
        'कागदी त्रिकोणाच्या टोकाचा कोन',
        'चौकोनी खिडकीच्या चौकटीतील कोन',
        'दोन अरुंद वाटा जिथे मिळतात तिथला कोन',
        'पाव वळणापेक्षा जास्त उघडलेल्या फाटकाचा कोन',
        'चौकोनी फोटोच्या चौकटीतील कोन',
        'घडीच्या कागदी पंख्याच्या अरुंद टोकाचा कोन',
      ];
      final answer = _class4Option(original.options[original.correctIndex].en);
      prompt =
          '${scenes[i]} पाहा. हा कोन कागदाच्या चौकोनी कोपऱ्याएवढा आहे, त्यापेक्षा लहान आहे की मोठा?';
      explanation =
          'कागदाच्या चौकोनी कोपऱ्याला काटकोन म्हणतात. ${scenes[i]} $answer आहे.';
      hint =
          'कागदाचा चौकोनी कोपरा त्या कोनावर ठेवला आहे, अशी कल्पना करा. कोन कमी उघडला आहे, तेवढाच उघडला आहे की जास्त उघडला आहे, ते पाहा.';
    case 3:
      final a = 1240 + i * 113, b = 357 + i * 41, total = a + b;
      const nouns = [
        'पाने',
        'आंबे',
        'गोट्या',
        'फुले',
        'शिंपले',
        'बिया',
        'बटणे',
        'पतंग',
        'पुस्तके',
        'पेरू',
      ];
      const collected = [
        'केली',
        'केले',
        'केल्या',
        'केली',
        'केले',
        'केल्या',
        'केली',
        'केले',
        'केली',
        'केले',
      ];
      const received = [
        'मिळाली',
        'मिळाले',
        'मिळाल्या',
        'मिळाली',
        'मिळाले',
        'मिळाल्या',
        'मिळाली',
        'मिळाले',
        'मिळाली',
        'मिळाले',
      ];
      prompt =
          'वर्गातील मुलांनी ${n(a)} ${nouns[i]} गोळा ${collected[i]}. नंतर आणखी ${n(b)} ${nouns[i]} ${received[i]}. आता एकूण किती ${nouns[i]} आहेत?';
      explanation =
          '${n(a)} + ${n(b)} = ${n(total)}. म्हणून एकूण ${n(total)} ${nouns[i]} आहेत.';
      hint =
          'दोन्ही मोजण्या मिळवण्यासाठी बेरीज करा. एककाखाली एकक, दशकाखाली दशक असे अंक लिहून एककांपासून बेरीज सुरू करा.';
    case 4:
      final denominator = [2, 3, 4, 5, 2][i % 5];
      final numerator = i.isOdd ? denominator + 1 : [1, 1, 3, 2, 1][i % 5];
      const genitives = [
        'कागदी पोळीचे',
        'फळांच्या वडीचे',
        'बागेतील एका भागाचे',
        'रांगोळी काढलेल्या फरशीचे',
        'वाटणीच्या ताटाचे',
        'कागदी पतंगाचे',
        'चौकोनी सँडविचचे',
        'फुलांच्या वाफ्याचे',
        'भिंतीवरील भागाचे',
        'बागेतील झेंड्याचे',
      ];
      const wholeNames = [
        'कागदी पोळी',
        'फळांची वडी',
        'बागेतील एक भाग',
        'रांगोळी काढलेली फरशी',
        'वाटणीचे ताट',
        'कागदी पतंग',
        'चौकोनी सँडविच',
        'फुलांचा वाफा',
        'भिंतीवरील भाग',
        'बागेतील झेंडा',
      ];
      final shaded = numerator == 1
          ? '१ भाग रंगवला आहे'
          : '${n(numerator)} भाग रंगवले आहेत';
      if (numerator > denominator) {
        const shapes = [
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
        ];
        englishPrompt =
            'Each identical ${shapes[i]} is cut into $denominator equal parts. $numerator parts are shaded across the shapes. Which fraction of one whole shape is shaded?';
        englishExplanation =
            'Each whole has $denominator equal parts, so the denominator is $denominator. The $numerator shaded parts give the numerator: $numerator/$denominator.';
        englishHint =
            'Count all shaded parts for the top number. Count the equal parts in one whole for the bottom number.';
        prompt =
            '${wholeNames[i]} पाहा. अशा प्रत्येक पूर्ण आकाराचे ${n(denominator)} समान भाग केले आहेत. त्यांपैकी एकूण $shaded. रंगवलेले भाग कोणत्या अपूर्णांकाने दाखवता येतील?';
      } else {
        prompt =
            '${genitives[i]} ${n(denominator)} समान भाग केले आहेत. त्यांपैकी $shaded. रंगवलेला भाग कोणत्या अपूर्णांकाने दाखवता येईल?';
      }
      explanation =
          'एका पूर्ण आकाराचे ${n(denominator)} समान भाग केले आहेत, म्हणून छेद ${n(denominator)}. रंगवलेले भाग ${n(numerator)}, म्हणून अंश ${n(numerator)}. अपूर्णांक ${n(numerator)}/${n(denominator)}.';
      hint =
          'रंगवलेले सगळे भाग मोजा; तो अंश, म्हणजे वरचा अंक. एका पूर्ण आकाराचे किती समान भाग केले आहेत ते मोजा; तो छेद, म्हणजे खालचा अंक.';
    case 5:
      final mode = i % 3;
      final value = mode == 1 ? 3 + i : 2 + i;
      final total =
          value *
          (mode == 0
              ? 100
              : mode == 1
              ? 10
              : 1000);
      final from = mode == 0
          ? 'मीटर'
          : mode == 1
          ? 'सेंटीमीटर'
          : 'किलोग्रॅम';
      final to = mode == 0
          ? 'सेंटीमीटर'
          : mode == 1
          ? 'मिलीमीटर'
          : 'ग्राम';
      prompt = '${n(value)} $from म्हणजे किती $to?';
      final relation = mode == 0
          ? '१ मीटर = १०० सेंटीमीटर'
          : mode == 1
          ? '१ सेंटीमीटर = १० मिलीमीटर'
          : '१ किलोग्रॅम = १००० ग्राम';
      explanation = '$relation. म्हणून ${n(value)} $from = ${n(total)} $to.';
      hint =
          'आधी दोन्ही एककांचा संबंध आठवा. एका मोठ्या एककात किती लहान एकके असतात, त्यावरून गुणाकार करा.';
    case 6:
      final symbols = 2 + i, total = symbols * 2;
      prompt =
          'वर्गाच्या चित्रालेखात लाल पतंगांसाठी सूर्याची ${n(symbols)} चिन्हे आहेत. प्रत्येक सूर्यचिन्ह २ पतंग दाखवते. लाल पतंग एकूण किती?';
      explanation =
          'प्रत्येक सूर्यचिन्ह म्हणजे २ पतंग. म्हणून ${n(symbols)} × २ = ${n(total)}. लाल पतंग एकूण ${n(total)} आहेत.';
      hint =
          'आधी चित्रालेखातील चिन्हासाठी दिलेली माहिती वाचा. इथे प्रत्येक चिन्ह २ पतंग दाखवते; त्यावरून एकूण मोजा.';
    case 7:
      const objects = ['वाचनालय', 'विहीर', 'बाग', 'शाळा', 'पूल'];
      const directions = ['पूर्व', 'पश्चिम', 'उत्तर', 'दक्षिण'];
      const locations = ['पूर्वेला', 'पश्चिमेला', 'उत्तरेला', 'दक्षिणेला'];
      final object = objects[i % 5],
          direction = directions[i % 4],
          location = locations[i % 4];
      prompt =
          'नकाशावर $object तळ्याच्या $location आहे. तळ्यापासून त्या ठिकाणी जाण्यासाठी कोणत्या दिशेने जावे लागेल?';
      explanation =
          'तळे हे सुरुवातीचे ठिकाण आहे. त्या ठिकाणाची खूण तळ्याच्या $location आहे. म्हणून $direction दिशेने जायचे.';
      hint =
          'नकाशातील दिशाचिन्ह पाहा: उत्तर वर, दक्षिण खाली, पूर्व उजवीकडे आणि पश्चिम डावीकडे आहे.';
    case 8:
      final rows = 21 + i * 7, each = 3 + i % 4, total = rows * each;
      prompt =
          'बागेत रोपांच्या ${n(rows)} ओळी आहेत. प्रत्येक ओळीत ${n(each)} रोपे आहेत. बागेत एकूण किती रोपे आहेत?';
      explanation =
          '${n(rows)} ओळींमध्ये प्रत्येकी ${n(each)} रोपे आहेत. म्हणून ${n(rows)} × ${n(each)} = ${n(total)}. एकूण ${n(total)} रोपे आहेत.';
      hint =
          'प्रत्येक ओळीत सारखीच रोपे आहेत. एका ओळीतील रोपांची संख्या आणि ओळींची संख्या गुणा.';
    case 9:
      final friends = 2 + i % 4, each = 3 + i % 6, total = friends * each;
      prompt =
          'चित्रांची ${n(total)} कार्डे ${n(friends)} मित्रांना समान वाटायची आहेत. प्रत्येक मित्राला किती कार्डे मिळतील?';
      explanation =
          '${n(total)} ÷ ${n(friends)} = ${n(each)}. प्रत्येक मित्राला ${n(each)} कार्डे मिळतील. तपासणी: ${n(friends)} × ${n(each)} = ${n(total)}.';
      hint =
          'प्रत्येकाला एकेक कार्ड देत वाटणी करा. सर्वांना तेवढीच कार्डे मिळाली पाहिजेत. शेवटी गुणाकार करून एकूण कार्डांची तपासणी करा.';
    case 10:
      const shapes = [
        'समद्विबाहू त्रिकोणाला, म्हणजे दोन समान बाजू असलेल्या त्रिकोणाला',
        'आयताला',
        'चौरसाला',
        'विषमबाहू त्रिकोणाला, म्हणजे तिन्ही बाजू वेगळ्या लांबीच्या त्रिकोणाला',
        'चारही बाजू समान असलेल्या, पण चौरस नसलेल्या चौकोनाला',
        'समभुज त्रिकोणाला, म्हणजे तिन्ही बाजू समान असलेल्या त्रिकोणाला',
        'पाचही बाजू आणि कोन समान असलेल्या पंचकोनाला',
        'सहाही बाजू आणि कोन समान असलेल्या षट्कोनाला',
        'तिरक्या समांतरभुज चौकोनाला',
        'आठही बाजू आणि कोन समान असलेल्या अष्टकोनाला',
      ];
      final count = [1, 2, 4, 0, 2, 3, 5, 6, 0, 8][i];
      prompt = '${shapes[i]} सममितीच्या किती रेषा असतात?';
      explanation = count == 0
          ? 'या आकाराला घडी घातल्यावर दोन्ही भाग तंतोतंत जुळतील अशी रेषा मिळत नाही. म्हणून सममितीच्या रेषांची संख्या ० आहे.'
          : 'या आकारात दोन्ही भाग तंतोतंत जुळतील अशा ${n(count)} रेषा मिळतात. म्हणून सममितीच्या रेषांची संख्या ${n(count)} आहे.';
      hint =
          'आकार असलेला कागद रेषेवरून दुमडला आहे, अशी कल्पना करा. दोन्ही भाग तंतोतंत जुळतात का ते पाहा. अशा रेषा मोजा.';
    case 11:
      englishPrompt = original.prompt.en.replaceFirst(
        'square units long',
        'units long',
      );
      final length = 3 + i % 4, width = 2 + i % 3;
      final perimeter = i.isOdd;
      final result = perimeter ? 2 * (length + width) : length * width;
      prompt =
          'एका आयताची लांबी ${n(length)} एकक आणि रुंदी ${n(width)} एकक आहे. ${perimeter ? 'त्याची परिमिती एककांत शोधा.' : 'त्याचे क्षेत्रफळ चौरस एककांत शोधा.'}';
      explanation = perimeter
          ? 'परिमिती म्हणजे चारही बाजूंच्या लांबीची बेरीज. २ × (${n(length)} + ${n(width)}) = ${n(result)} एकक.'
          : 'क्षेत्रफळ = लांबी × रुंदी. ${n(length)} × ${n(width)} = ${n(result)} चौरस एकक.';
      hint = perimeter
          ? 'आयताच्या कडेने पूर्ण फेरी घ्या. चारही बाजूंच्या लांबी मिळवा; समोरासमोरच्या बाजू समान असतात.'
          : 'आयताच्या आतले एकक चौरस मोजा. ओळींची संख्या आणि प्रत्येक ओळीतील चौरसांची संख्या गुणा.';
    case 12:
      final cubes = 2 + i;
      prompt =
          'एका पेटीत ${n(cubes)} एकक घन भरले आहेत. तिचे घनफळ किती घन एकक आहे?';
      explanation =
          'प्रत्येक एकक घन एक घन एकक जागा व्यापतो. असे ${n(cubes)} घन आहेत, म्हणून घनफळ ${n(cubes)} घन एकक आहे.';
      hint =
          'प्रत्येक लहान घन एकदा मोजा. घन मोजल्यावर घनफळ घन एककांत सांगता येते.';
    case 13:
      final start = 8 + i % 4, minutes = (i % 3 + 1) * 15;
      final answer = original.options[original.correctIndex].en;
      prompt =
          'वर्ग ${n(start)}:०० वाजता सुरू झाला. तो ${n(minutes)} मिनिटे चालला. वर्ग किती वाजता संपला?';
      explanation =
          '${n(start)}:०० या वेळेत ${n(minutes)} मिनिटे मिळवा. वर्ग ${n(answer)} वाजता संपला.';
      hint =
          'घड्याळावर १५ मिनिटांचा एक टप्पा मोजा. ${n(minutes)} मिनिटांसाठी असे ${n(minutes ~/ 15)} टप्पे पुढे जा. ६० मिनिटांचा एक तास होतो.';
    case 14:
      final jump = 1 + i % 4,
          start = 2 + i * 2,
          third = start + 2 * jump,
          answer = start + 3 * jump;
      prompt =
          '${n(start)}, ${n(start + jump)}, ${n(third)}, __. या मालिकेत पुढची संख्या कोणती?';
      explanation =
          'प्रत्येक पुढची संख्या ${n(jump)} ने वाढते. म्हणून ${n(third)} + ${n(jump)} = ${n(answer)}. पुढची संख्या ${n(answer)} आहे.';
      hint =
          'एका संख्येत किती मिळवल्यावर पुढची संख्या येते, ते पाहा. शेवटच्या संख्येतही तेवढेच मिळवा.';
    default:
      return original;
  }
  return ChapterQuestion(
    id: original.id,
    prompt: class4Wording(original.prompt, prompt, english: englishPrompt),
    explanation: class4Wording(
      original.explanation,
      explanation,
      english: englishExplanation,
    ),
    hint: class4Wording(original.hint, hint, english: englishHint),
    options: List<Words>.unmodifiable([
      for (final option in original.options)
        class4Wording(option, _class4Option(option.en)),
    ]),
    correctIndex: original.correctIndex,
    objects: original.objects,
    visualKind: original.visualKind,
  );
}

String _class4Option(String english) {
  const text = {
    'odd': 'विषम संख्या',
    'even': 'सम संख्या',
    'neither': 'समही नाही, विषमही नाही',
    'both': 'सम आणि विषम दोन्ही',
    'smaller than a square corner': 'काटकोनापेक्षा लहान',
    'the same as a square corner': 'काटकोनाएवढा',
    'larger than a square corner': 'काटकोनापेक्षा मोठा',
    'a curved line, not an angle': 'वक्र रेषा आहे; कोन नाही',
    'east': 'पूर्व',
    'west': 'पश्चिम',
    'north': 'उत्तर',
    'south': 'दक्षिण',
  };
  if (text.containsKey(english)) return text[english]!;
  // Remaining Class 4 options are numbers, clock readings or fractions.
  // Their punctuation and value stay unchanged while digits are localised.
  if (RegExp(r'^\d+(?:[/\:]\d+)?$').hasMatch(english))
    return class4Digits(english);
  throw StateError('Unreviewed Class 4 answer option: $english');
}

ChapterLesson _class4Lesson(SchoolChapter chapter, ChapterLesson original) {
  if (chapter.grade != 4) return original;
  const concepts = [
    'एकक, दशक, शतक आणि हजार यांच्या स्थानिक किमती वापरून ९,९९९ पर्यंतच्या संख्या वाचूया. संख्येचा विस्तार करूया, तुलना करूया आणि सम-विषम संख्या ओळखूया.',
    'कागदाच्या चौकोनी कोपऱ्यासारखा कोन म्हणजे काटकोन. इतर कोन त्यापेक्षा लहान, तेवढेच किंवा मोठे आहेत का, ते पाहूया. त्रिकोण आणि चौकोन यांच्या बाजू व कोन पाहून त्यांचे प्रकार ओळखूया.',
    'मोठ्या संख्यांची बेरीज आणि वजाबाकी करूया. गोष्टीतील माहितीवरून योग्य क्रिया निवडूया आणि उलट क्रिया करून उत्तर तपासूया.',
    'पूर्ण आकाराचे समान भाग करूया. रंगवलेले भाग आणि एका पूर्ण आकारातील समान भाग यांवरून अपूर्णांक लिहूया. एक पूर्ण आणि उरलेला अपूर्णांक मिळून मिश्र संख्या कशी बनते, ते पाहूया.',
    'लांबी मिलीमीटर, सेंटीमीटर, मीटर आणि किलोमीटरमध्ये मोजूया. वजन ग्राम किंवा किलोग्रॅममध्ये मोजूया. एकके बदलून मोजमापांची तुलना करूया.',
    'चित्रालेखातील प्रत्येक चिन्ह किती वस्तू दाखवते, ते आधी वाचूया. त्या माहितीवरून प्रत्येक गटातील वस्तू मोजूया आणि गटांची तुलना करूया.',
    'नकाशातील ठिकाणे, खुणा आणि दिशा समजून घेऊया. जाळीतील स्थान आणि वेगवेगळ्या बाजूंनी दिसणारे दृश्य पाहून योग्य मार्ग शोधूया.',
    'मोठ्या संख्येचे शतक, दशक, एकक असे भाग करूया. प्रत्येक भागाचा गुणाकार वेगळा करून मिळालेली उत्तरे मिळवूया.',
    'वस्तू समान गटांत वाटूया. प्रत्येक गटाला मिळणारी संख्या म्हणजे भागाकारफल; उरलेल्या वस्तू म्हणजे बाकी. स्थानिक किमती वापरून भागाकार करूया आणि गुणाकाराने उत्तर तपासूया.',
    'ज्या रेषेवरून आकाराला घडी घातल्यावर दोन्ही भाग तंतोतंत जुळतात, ती सममितीची रेषा. अशा रेषा शोधूया आणि मोजूया.',
    'आकाराच्या कडेने पूर्ण फेरीचे अंतर म्हणजे परिमिती. आतला भाग किती जागा व्यापतो, ते क्षेत्रफळ सांगते. क्षेत्रफळासाठी समान आकाराचे एकक चौरस मोजूया.',
    'एकक घन मोजून वस्तूचे घनफळ समजते. भांड्यात किती द्रव मावतो, ती त्याची धारकता. लिटर आणि मिलीलीटरमध्ये धारकतेची तुलना करूया.',
    'घड्याळाच्या काट्यांवरून आणि अंकांवरून वेळ वाचूया. एखादी गोष्ट सुरू झाल्यापासून संपेपर्यंत किती वेळ गेला, ते मोजूया.',
    'आकार किंवा संख्या कोणत्या नियमाने पुढे जातात, ते शोधूया. तोच नियम वापरून पुढचे आकार किंवा संख्या ठरवूया.',
  ];
  const openings = [
    'मीरा आणि रवी संख्यांचा खेळ खेळत आहेत.',
    'मीरा आणि रवी आजूबाजूचे कोपरे पाहत आहेत.',
    'मीरा आणि रवी वर्गाने गोळा केलेल्या वस्तूंची मोजणी करत आहेत.',
    'मीरा आणि रवी समान भाग रंगवत आहेत.',
    'मीरा आणि रवी लांबी मोजताना एकके बदलून पाहत आहेत.',
    'मीरा आणि रवी वर्गाचा चित्रालेख वाचत आहेत.',
    'मीरा आणि रवी नकाशावरून रस्ता शोधत आहेत.',
    'मीरा आणि रवी बागेतील रोपे मोजत आहेत.',
    'मीरा आणि रवी चित्रांची कार्डे वाटत आहेत.',
    'मीरा आणि रवी कागदी आकारांना घड्या घालून पाहत आहेत.',
    'मीरा आणि रवी आयताच्या कडा आणि आतील जागा मोजत आहेत.',
    'मीरा आणि रवी छोट्या घनांनी भरलेली पेटी पाहत आहेत.',
    'मीरा आणि रवी घड्याळावर वर्ग संपण्याची वेळ शोधत आहेत.',
    'मीरा आणि रवी संख्यांची मालिका पूर्ण करत आहेत.',
  ];
  const recaps = [
    'प्रत्येक अंकाचे स्थान पाहून त्याची किंमत ठरते. एककाचा अंक पाहून संख्या सम आहे की विषम, ते ओळखता येते.',
    'कागदाचा चौकोनी कोपरा हा काटकोन दाखवतो. त्याच्याशी तुलना करून दुसरा कोन लहान, समान किंवा मोठा आहे, ते ठरवता येते.',
    'समान स्थानाचे अंक एकाखाली एक लिहा. बेरीज किंवा वजाबाकी केल्यावर उलट क्रियेने उत्तर तपासा.',
    'रंगवलेल्या भागांची संख्या हा अंश; एका पूर्ण आकारातील समान भागांची संख्या हा छेद. पूर्ण भाग आणि उरलेला अपूर्णांक वेगळा ओळखा.',
    'एकक बदलताना आधी दोन एककांचा संबंध आठवा. फक्त संख्या बदलू नका; उत्तरात योग्य एककही लिहा.',
    'चित्रालेखातील एक चिन्ह किती वस्तू दाखवते, हे लक्षात घेऊन एकूण मोजा. गटांची तुलना करतानाही तीच माहिती वापरा.',
    'आधी सुरुवातीचे ठिकाण शोधा. मग नकाशातील खुणा, दिशा आणि जाळीच्या मदतीने हवे त्या ठिकाणाचा मार्ग ठरवा.',
    'सारख्या गटांची वारंवार बेरीज गुणाकाराने करता येते. मोठी संख्या भागांत विभागून गुणाकार करा आणि मिळालेली उत्तरे मिळवा.',
    'समान वाटणीत प्रत्येक गटाला तेवढ्याच वस्तू मिळतात. गटांची संख्या × प्रत्येक गटातील वस्तूंची संख्या + बाकी = एकूण वस्तूंची संख्या.',
    'घडीच्या रेषेवर दोन्ही भाग तंतोतंत जुळले पाहिजेत. अशा प्रत्येक रेषेला सममितीची रेषा म्हणतात.',
    'परिमितीसाठी कडेच्या लांबी मिळवा. क्षेत्रफळासाठी आतले एकक चौरस मोजा. या दोन्हींची एकके वेगळी असतात.',
    'घनफळासाठी एकक घन मोजा. धारकतेसाठी भांड्यात किती द्रव मावतो, ते लिटर किंवा मिलीलीटरमध्ये मोजा.',
    'सुरुवातीच्या वेळेपासून दिलेली मिनिटे पुढे मोजा. ६० मिनिटांचा एक तास होतो.',
    'मालिकेतील संख्या किंवा आकार कसे बदलत जातात, ते पाहा. पुढची संख्या किंवा आकार ठरवताना तोच नियम वापरा.',
  ];
  final first = _class4Question(chapter, 0, _questionFor(chapter, 0));
  final number = chapter.number - 1;
  return ChapterLesson(
    story: class4Wording(
      original.story,
      '${openings[number]} ${first.prompt.mr}',
      english: chapter.number == 11
          ? original.story.en.replaceFirst('square units long', 'units long')
          : null,
    ),
    concept: class4Wording(original.concept, concepts[number]),
    workedExample: class4Wording(original.workedExample, first.explanation.mr),
    hint: class4Wording(original.hint, first.hint.mr),
    recap: class4Wording(original.recap, 'लक्षात ठेवूया: ${recaps[number]}'),
    objects: original.objects,
    visualKind: original.visualKind,
  );
}
