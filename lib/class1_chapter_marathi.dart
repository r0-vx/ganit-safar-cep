part of 'chapter_catalogue.dart';

// Class 1 wording uses short classroom instructions and familiar objects.
// Original English, identifiers and drafts stay available for comparison.
ChapterQuestion _class1Question(
  SchoolChapter chapter,
  int index,
  ChapterQuestion original,
) {
  if (chapter.grade != 1) return original;
  final i = index % 10;
  String n(Object value) => marathiDigits(value);
  var prompt = '', explanation = '', hint = '';
  String? englishExplanation;
  switch (chapter.number) {
    case 1:
      const places = [
        'विहिरीच्या वर',
        'झाडाच्या फांदीखाली',
        'शाळेच्या फाटकाच्या आत',
        'बागेच्या बाहेर',
        'पुलाच्या शेजारी',
      ];
      prompt = 'निळा पतंग ${places[i % 5]} आहे. तो कुठे आहे?';
      explanation =
          'पतंग ${places[i % 5]} आहे. जवळची वस्तू पाहून त्याची जागा सांगता येते.';
      hint = 'आधी जवळची वस्तू पाहा. मग पतंग तिच्या कुठल्या बाजूला आहे ते सांग.';
    case 2:
      const places = [
        'छपरावर',
        'कुंडीच्या मागे',
        'गाडीच्या पुढे',
        'खुराड्याच्या आत',
        'कुंपणाच्या शेजारी',
      ];
      prompt = 'कोंबडा ${places[i % 5]} आहे. तो कुठे आहे ते निवड.';
      explanation = 'कोंबडा ${places[i % 5]} आहे. हे शब्द त्याची जागा सांगतात.';
      hint =
          'कोंबडा आणि त्याच्या जवळची वस्तू पाहा. तो वर, मागे, पुढे की आत आहे?';
    case 3:
      const before = [
        'फळे धुणे',
        'बूट घालणे',
        'बी पेरणे',
        'पुस्तक उघडणे',
        'पीठ कालवणे',
      ];
      const after = [
        'फळे खाणे',
        'शाळेत चालत जाणे',
        'रोपाला पाणी देणे',
        'पान वाचणे',
        'पाव भाजणे',
      ];
      const sentences = [
        'आधी फळे धुवायची, मग खायची. आधी काय करायचे?',
        'आधी बूट घालायचे, मग शाळेत चालत जायचे. आधी काय करायचे?',
        'आधी बी पेरायचे, मग रोपाला पाणी द्यायचे. आधी काय करायचे?',
        'आधी पुस्तक उघडायचे, मग पान वाचायचे. आधी काय करायचे?',
        'आधी पीठ कालवायचे, मग पाव भाजायचा. आधी काय करायचे?',
      ];
      prompt = sentences[i % 5];
      explanation =
          'आधी ${before[i % 5]}, मग ${after[i % 5]}. म्हणून पहिले काम: ${before[i % 5]}.';
      hint = 'दोन्ही कामे मनात करून पाहा. कोणते काम आधी करावे लागेल?';
    case 4:
      const close = ['आंब्याचे झाड', 'विहीर', 'शाळेचे फाटक', 'बाग', 'वाचनालय'];
      const far = ['डोंगर', 'बाजार', 'नदी', 'बस थांबा', 'शेत'];
      final a = 2 + i, b = a + 5 + i;
      prompt =
          'गावच्या फाटकापासून ${close[i % 5]} ${n(a)} पावले दूर आहे. ${far[i % 5]} ${n(b)} पावले दूर आहे. कोणते ${i.isEven ? 'जवळ' : 'दूर'} आहे?';
      final target = i.isEven ? close[i % 5] : far[i % 5];
      explanation = i.isEven
          ? 'कमी पावले चालावे लागतात ते ठिकाण जवळ असते. म्हणून $target जवळ आहे.'
          : 'जास्त पावले चालावे लागतात ते ठिकाण दूर असते. म्हणून $target दूर आहे.';
      hint =
          'एकाच फाटकापासून चालायला सुरुवात कर. दोन्ही ठिकाणी पोहोचायला किती पावले लागतात ते पाहा.';
    case 5:
      const prompts = [
        'या फलकाला तीन सरळ बाजू आहेत. हा कोणता आकार?',
        'या फरशीच्या चारही बाजू समान आहेत. कोपरे चौकोनी आहेत. हा कोणता आकार?',
        'पुस्तकाच्या कव्हरला चार बाजू आहेत. समोरासमोरच्या बाजू समान आहेत. हा कोणता आकार?',
        'गोल ताटाला सरळ बाजू नाहीत. हा कोणता आकार?',
        'हा आरसा अंड्यासारखा लांबट गोल आहे. सरळ बाजू नाहीत. हा कोणता आकार?',
        'छतावरील या फलकाला तीन सरळ बाजू आहेत. हा कोणता आकार?',
        'खिडकीच्या चारही बाजू समान आहेत. कोपरे चौकोनी आहेत. हा कोणता आकार?',
        'वर्गाच्या दाराला चार बाजू आहेत. समोरासमोरच्या बाजू समान आहेत. हा कोणता आकार?',
        'सायकलच्या चाकाची कड पूर्ण गोल आहे. सरळ बाजू नाहीत. हा कोणता आकार?',
        'हे चित्र अंड्यासारखे लांबट गोल आहे. सरळ बाजू नाहीत. हा कोणता आकार?',
      ];
      const explanations = {
        'triangle': 'त्रिकोणाला तीन सरळ बाजू असतात.',
        'square':
            'चौरसाच्या चारही बाजू समान असतात. त्याचे चारही कोपरे चौकोनी असतात.',
        'rectangle': 'आयताला चार बाजू असतात. समोरासमोरच्या बाजू समान असतात.',
        'circle': 'वर्तुळ पूर्ण गोल असते. त्याला सरळ बाजू किंवा कोपरे नसतात.',
        'oval': 'लंबवर्तुळ अंड्यासारखे लांबट गोल असते. त्याला सरळ बाजू नसतात.',
      };
      prompt = prompts[i];
      explanation = explanations[original.options[original.correctIndex].en]!;
      hint = 'कडेवरून बोट फिरव. सरळ बाजू आणि कोपरे मोज.';
    case 6:
      const items = [
        'गुळगुळीत चेंडू',
        'सपाट पुस्तक',
        'पत्र्याचा डबा',
        'लाकडी ठोकळा',
        'गोल संत्रे',
        'लाकडी चेंडू',
        'सपाट खोडरबर',
        'काचेची बरणी',
        'काडेपेटी',
        'गोल नाणे',
      ];
      final action = original.options[original.correctIndex].en;
      prompt = 'थोडासा उतार असलेल्या फळीवर ${items[i]} काय करू शकेल?';
      explanation = action == 'rolls'
          ? 'गोल बाजू असल्यामुळे ही वस्तू घरंगळेल.'
          : action == 'slides'
          ? 'सपाट बाजू असल्यामुळे ही वस्तू घसरेल.'
          : 'या वस्तूला गोल बाजू आणि सपाट बाजूही आहे. म्हणून ती घरंगळूही शकते आणि घसरूही शकते.';
      hint =
          'वस्तूची बाजू गोल आहे, सपाट आहे की दोन्ही प्रकारच्या बाजू आहेत, ते पाहा.';
    case 7:
      const things = [
        _C1Thing('आंबा', 'आंबे', 'm', 'm'),
        _C1Thing('गोटी', 'गोट्या', 'f', 'f'),
        _C1Thing('फूल', 'फुले', 'n', 'n'),
        _C1Thing('शिंपला', 'शिंपले', 'm', 'm'),
        _C1Thing('बटण', 'बटणे', 'n', 'n'),
        _C1Thing('पेरू', 'पेरू', 'm', 'm'),
        _C1Thing('पतंग', 'पतंग', 'm', 'm'),
        _C1Thing('पुस्तक', 'पुस्तके', 'n', 'n'),
        _C1Thing('कप', 'कप', 'm', 'm'),
        _C1Thing('पान', 'पाने', 'n', 'n'),
      ];
      final count = 1 + i % 9, item = things[i];
      prompt =
          'टोपलीत ${n(count)} ${item.name(count)} ${count == 1 ? 'आहे' : 'आहेत'}. योग्य अंक निवड.';
      explanation = 'प्रत्येक वस्तू एकदा मोजली. एकूण संख्या ${n(count)} आहे.';
      hint = 'एकेका वस्तूला बोट लावून मोज. शेवटी म्हटलेली संख्या लक्षात ठेव.';
    case 8:
      const things = [
        'गोट्या',
        'आंबे',
        'पतंग',
        'पुस्तके',
        'कप',
        'मणी',
        'रंगीत खडू',
        'चेंडू',
        'चमचे',
        'बिया',
      ];
      prompt = 'रिकाम्या टोपलीत किती ${things[i]} आहेत?';
      explanation = 'टोपली रिकामी आहे. एकही वस्तू नाही, म्हणजे संख्या ०.';
      hint = 'काहीच नाही हे दाखवणारा अंक निवड.';
    case 9:
      final a = 4 + i % 4, b = 10 - a;
      const things = ['शिंपले', 'गोट्या', 'फुलांच्या कळ्या', 'बटणे', 'पाने'];
      prompt = '${n(a)} ${things[i % 5]} आहेत. १० होण्यासाठी आणखी किती लागतील?';
      explanation = '${n(a)} + ${n(b)} = १०. आणखी ${n(b)} लागतील.';
      hint =
          'आधीच्या मोजणीपासून पुढे मोज. दहा होण्यासाठी किती वाढवावे लागले ते पाहा.';
    case 10:
    case 25:
      final a = chapter.number == 10 ? 1 + i % 4 : 6 + i % 8;
      final cap = chapter.number == 10 ? 9 : 18;
      final b = chapter.number == 10
          ? 1 + (i * 3) % (cap - a)
          : 1 + (i * 5) % (cap - a);
      final total = a + b, item = _c1Collections[i];
      prompt =
          'वर्गातील मुलांनी ${n(a)} ${item.name(a)} गोळा ${item.verb(a, 'के')}. आणखी ${n(b)} ${item.name(b)} ${item.verb(b, 'मिळा')}. एकूण किती ${item.many} आहेत?';
      explanation =
          '${n(a)} + ${n(b)} = ${n(total)}. एकूण ${n(total)} ${item.name(total)} आहेत.';
      hint = 'दोन्ही गट एकत्र ठेव. प्रत्येक वस्तू एकदा मोज.';
    case 11:
      final a = 9, b = 1 + i % 8, answer = a - b;
      const things = [
        _C1Thing('शेंग', 'शेंगा', 'f', 'f'),
        _C1Thing('आंबा', 'आंबे', 'm', 'm'),
        _C1Thing('शिंपला', 'शिंपले', 'm', 'm'),
        _C1Thing('चित्राचे कार्ड', 'चित्रांची कार्डे', 'n', 'n'),
        _C1Thing('बटण', 'बटणे', 'n', 'n'),
      ];
      final item = things[i % 5];
      prompt =
          '${n(a)} ${item.many} आहेत. त्यांपैकी ${n(b)} ${item.name(b)} ${item.verb(b, 'वापर')}. किती ${item.many} उरल्या?';
      // The final question uses a noun-appropriate form below.
      prompt = prompt.replaceFirst('उरल्या?', '${item.verb(2, 'उर')}?');
      explanation =
          '${n(a)} − ${n(b)} = ${n(answer)}. ${n(answer)} ${item.name(answer)} ${item.verb(answer, 'उर')}.';
      hint = 'वापरलेल्या वस्तू बाजूला ठेव. आता उरलेल्या वस्तू मोज.';
    case 12:
      final ones = 1 + (i * 2 % 9), value = 10 + ones;
      prompt =
          'दहाचा १ गट आणि ${n(ones)} ${ones == 1 ? 'सुटी वस्तू' : 'सुट्या वस्तू'}. एकूण किती?';
      explanation =
          '१० + ${n(ones)} = ${n(value)}. दहात सुट्या वस्तू मिळवल्या की ही संख्या होते.';
      hint = 'दहाचा एक गट म्हणजे दहा वस्तू. त्यात सुट्या वस्तू मिळव.';
    case 13:
      final middle = 5 + i * 3, ask = i % 3;
      prompt = ask == 0
          ? '${n(middle)} च्या लगेच आधी कोणती संख्या येते?'
          : ask == 1
          ? '${n(middle)} च्या लगेच नंतर कोणती संख्या येते?'
          : 'मधली संख्या भर: ${n(middle - 1)}, __, ${n(middle + 1)}.';
      explanation =
          'क्रमाने मोज: ${n(middle - 1)}, ${n(middle)}, ${n(middle + 1)}. या शेजारी असलेल्या संख्या आहेत.';
      hint = ask == 0
          ? 'एक पाऊल मागे मोज.'
          : ask == 1
          ? 'एक पाऊल पुढे मोज.'
          : 'क्रमाने मोजून मधली संख्या शोध.';
    case 14:
      final a = 3 + i * 2, b = a + (i.isEven ? 3 : -2);
      final relation = a > b
          ? 'मोठी'
          : a < b
          ? 'लहान'
          : 'समान';
      prompt = 'योग्य चिन्ह निवड: ${n(a)} __ ${n(b)}.';
      explanation = '${n(a)} ही ${n(b)} पेक्षा $relation संख्या आहे.';
      hint = 'आधी दहाचे गट पाहा. ते सारखे असतील तर सुट्या वस्तू पाहा.';
    case 15:
      final numbers = [12 + i * 5, 4 + i * 3, 21 + i * 2];
      final ordered = List<int>.from(numbers)..sort();
      final answer = i.isOdd ? ordered.reversed.toList() : ordered;
      prompt =
          '${numbers.map(n).join(', ')} या संख्या ${i.isOdd ? 'मोठ्या ते लहान' : 'लहान ते मोठ्या'} क्रमाने लाव.';
      explanation =
          'प्रत्येक संख्या पाहा. योग्य क्रम: ${answer.map(n).join(' → ')}.';
      hint = i.isOdd
          ? 'आधी सर्वांत मोठी संख्या शोध. मग उरलेल्या लाव.'
          : 'आधी सर्वांत लहान संख्या शोध. मग उरलेल्या लाव.';
      englishExplanation = original.explanation.en.replaceAll(
        RegExp(r'\s*<\s*'),
        ' → ',
      );
    case 16:
      final count = 2 + i;
      prompt =
          'चित्रालेखात सूर्याची ${n(count)} चिन्हे आहेत. एक चिन्ह म्हणजे १ लाल पतंग. लाल पतंग एकूण किती?';
      explanation =
          'प्रत्येक चिन्ह म्हणजे १ पतंग. ${n(count)} चिन्हे आहेत, म्हणून ${n(count)} लाल पतंग आहेत.';
      hint = 'एक चिन्ह किती पतंग दाखवते ते आधी पाहा. मग चिन्हे मोज.';
    case 17:
      final a = 4 + i % 5, b = 1 + i % 4, answer = a + b;
      prompt =
          '${n(a)} पासून ${n(b)} ${b == 1 ? 'पाऊल' : 'पावले'} पुढे मोज. कोणती संख्या येईल?';
      explanation =
          '${n(a)} + ${n(b)} = ${n(answer)}. पुढे मोजल्यावर ${n(answer)} येते.';
      hint =
          'पहिली संख्या लक्षात ठेव. तिच्या पुढच्या संख्येपासून मोजायला सुरुवात कर.';
    case 18:
      final a = 9 - i % 3, b = 1 + i % (a - 1), answer = a - b;
      prompt =
          '${n(a)} पासून ${n(b)} ${b == 1 ? 'पाऊल' : 'पावले'} मागे मोज. कोणती संख्या येईल?';
      explanation =
          '${n(a)} − ${n(b)} = ${n(answer)}. मागे मोजल्यावर ${n(answer)} येते.';
      hint =
          'पहिल्या संख्येच्या मागची संख्या म्हण. मग दिलेल्या पावलांइतके मागे मोज.';
    case 19:
      final value = 21 + i % 10, tens = value ~/ 10, ones = value % 10;
      prompt =
          'दहाचे ${n(tens)} गट आणि ${n(ones)} ${ones == 1 ? 'सुटी वस्तू' : 'सुट्या वस्तू'}. ही कोणती संख्या?';
      explanation =
          '${n(tens)} दशके आणि ${n(ones)} ${ones == 1 ? 'एकक' : 'एकके'} म्हणजे ${n(value)}.';
      hint = 'आधी दहाचे गट मोज. मग सुट्या वस्तू मिळव.';
    case 20:
      final value = 31 + (i * 13) % 69, tens = value ~/ 10, ones = value % 10;
      prompt =
          'दहाचे ${n(tens)} गट आणि ${n(ones)} ${ones == 1 ? 'सुटी वस्तू' : 'सुट्या वस्तू'} मिळून कोणती संख्या होते?';
      explanation =
          '${n(value)} मध्ये ${n(tens)} दशके आणि ${n(ones)} ${ones == 1 ? 'एकक' : 'एकके'} आहेत.';
      hint = 'दशक म्हणजे दहाचा गट. एकके म्हणजे उरलेल्या सुट्या वस्तू.';
    case 21:
      final start = 4 + i, answer = start + 3;
      prompt =
          '${n(start)}, ${n(start + 1)}, ${n(start + 2)}, __. पुढची संख्या भर.';
      explanation = 'प्रत्येक वेळी १ मिळव. पुढची संख्या ${n(answer)} आहे.';
      hint = 'एकेकाने मोजत पुढे जा.';
    case 22:
      final jump = 1 + i % 4,
          start = 2 + i * 2,
          third = start + 2 * jump,
          answer = start + 3 * jump;
      prompt =
          '${n(start)}, ${n(start + jump)}, ${n(third)}, __. पुढे कोणती संख्या येईल?';
      explanation =
          'प्रत्येक वेळी ${n(jump)} मिळव. ${n(third)} + ${n(jump)} = ${n(answer)}.';
      hint = 'प्रत्येक वेळी किती वाढते ते पाहा. पुढेही तेवढेच वाढव.';
    case 23:
      final count = 2 + i;
      const objects = [
        'टेबलाची',
        'वर्गातील चटईची',
        'बागेतील वाटेची',
        'फळ्याची',
        'खिडकीच्या कठड्याची',
        'बाकाची',
        'दाराच्या चौकटीची',
        'फुलांच्या वाफ्याची',
        'मैदानावरील रेषेची',
        'पुस्तकांच्या कप्प्याची',
      ];
      prompt =
          '${objects[i]} लांबी ${n(count)} विती आहे. मोजायला किती विती लागल्या?';
      explanation =
          '${n(count)} सारख्या विती मोजल्या. म्हणून लांबी ${n(count)} विती आहे.';
      hint = 'मोजताना हाताचा पसारा प्रत्येक वेळी सारखाच ठेव.';
    case 24:
      const days = [
        'सोमवार',
        'मंगळवार',
        'बुधवार',
        'गुरुवार',
        'शुक्रवार',
        'शनिवार',
        'रविवार',
      ];
      final day = days[i % 7],
          offset = 1 + i % 2,
          next = days[(i % 7 + offset) % 7];
      prompt =
          '$dayी शाळेची स्वच्छता आहे. ${n(offset)} ${offset == 1 ? 'दिवसानंतर' : 'दिवसांनंतर'} कोणता वार येईल?';
      explanation =
          '$dayी सुरुवात करून ${n(offset)} दिवस पुढे मोज. $next येतो.';
      hint = 'वार क्रमाने म्हण. दिलेल्या दिवसापुढचे वार मोज.';
    case 26:
      final count = 1 + i ~/ 3,
          value = [1, 2, 5, 10][i % 4],
          extra = [1, 2, 5][i % 3],
          total = count * value + extra;
      prompt =
          'प्रत्येकी ₹${n(value)} चे ${n(count)} ${count == 1 ? 'नाणे आहे' : 'नाणी आहेत'}. आणखी ₹${n(extra)} चे एक नाणे आहे. एकूण किती रुपये?';
      explanation =
          '${n(count)} × ₹${n(value)} + ₹${n(extra)} = ₹${n(total)}. एकूण ₹${n(total)} आहेत.';
      hint = 'प्रत्येक नाण्यावरची किंमत वाच. सगळ्या किंमती मिळव.';
    case 27:
      final groups = 2 + i % 6, each = 3 + i % 5, total = groups * each;
      prompt =
          '${n(groups)} टोपल्या आहेत. प्रत्येक टोपलीत ${n(each)} पेरू आहेत. एकूण किती पेरू?';
      explanation =
          '${n(each)} ची ${n(groups)} वेळा बेरीज केली की ${n(total)} होतात. ${n(groups)} × ${n(each)} = ${n(total)}.';
      hint =
          'एका टोपलीतले पेरू मोज. प्रत्येक टोपलीत तेवढेच आहेत. सगळे गट मिळव.';
    case 28:
      final friends = 2 + i % 4, each = 3 + i % 6, total = friends * each;
      prompt =
          'चित्रांची ${n(total)} कार्डे ${n(friends)} मित्रांना समान वाट. प्रत्येकाला किती कार्डे मिळतील?';
      explanation =
          'प्रत्येक मित्राला ${n(each)} कार्डे मिळतील. तपासणी: ${n(friends)} × ${n(each)} = ${n(total)}.';
      hint =
          'प्रत्येकाला एकेक कार्ड देत जा. सगळ्यांकडे तेवढीच कार्डे झाली पाहिजेत.';
    case 29:
      final added = 2 + i, shown = 3 + i * 2, answer = shown - added;
      prompt =
          'हे यंत्र आत गेलेल्या संख्येत ${n(added)} मिळवते. बाहेर ${n(shown)} दिसते. आत कोणती संख्या गेली?';
      explanation =
          'बाहेरच्या संख्येतून ${n(added)} वजा कर. ${n(shown)} − ${n(added)} = ${n(answer)}. आत ${n(answer)} गेली.';
      hint = 'यंत्राने बेरीज केली. सुरुवातीची संख्या शोधायला वजाबाकी कर.';
    default:
      return original;
  }
  return ChapterQuestion(
    id: original.id,
    prompt: classroomWording(original.prompt, prompt, grade: 1),
    explanation: classroomWording(
      original.explanation,
      explanation,
      grade: 1,
      english: englishExplanation,
    ),
    hint: classroomWording(original.hint, hint, grade: 1),
    options: List<Words>.unmodifiable([
      for (final option in original.options)
        classroomWording(
          option,
          _class1Option(option.en, chapter.number),
          grade: 1,
          english: _class1EnglishOption(option.en, chapter.number),
        ),
    ]),
    correctIndex: original.correctIndex,
    objects: original.objects,
    visualKind: original.visualKind,
  );
}

String _class1EnglishOption(String original, int chapter) {
  if (chapter != 14 && chapter != 15) return original;
  if (original == 'Option 1') return 'None of these choices';
  if (original == 'Option 2') return 'All numbers are equal';
  return chapter == 15
      ? original.replaceAll(RegExp(r'\s*<\s*'), ' → ')
      : original;
}

String _class1Option(String english, int chapter) {
  if (RegExp(r'^\d+$').hasMatch(english)) return marathiDigits(english);
  if (const ['<', '>', '='].contains(english)) return english;
  if (chapter == 15 && english.contains('<'))
    return marathiDigits(english.replaceAll(RegExp(r'\s*<\s*'), ' → '));
  if (english == 'Option 1') return 'यांपैकी एकही नाही';
  if (english == 'Option 2') return 'सर्व संख्या समान आहेत';
  const choices = {
    'above the well': 'विहिरीच्या वर',
    'below the tree branch': 'झाडाच्या फांदीखाली',
    'inside the school gate': 'शाळेच्या फाटकाच्या आत',
    'outside the garden': 'बागेच्या बाहेर',
    'beside the bridge': 'पुलाच्या शेजारी',
    'on the roof': 'छपरावर',
    'behind the pot': 'कुंडीच्या मागे',
    'in front of the cart': 'गाडीच्या पुढे',
    'inside the coop': 'खुराड्याच्या आत',
    'beside the fence': 'कुंपणाच्या शेजारी',
    'Wash the fruit': 'फळे धुणे',
    'Eat the fruit': 'फळे खाणे',
    'Put on shoes': 'बूट घालणे',
    'Walk to school': 'शाळेत चालत जाणे',
    'Plant a seed': 'बी पेरणे',
    'Water the plant': 'रोपाला पाणी देणे',
    'Open the book': 'पुस्तक उघडणे',
    'Read a page': 'पान वाचणे',
    'Mix the batter': 'पीठ कालवणे',
    'Bake the bread': 'पाव भाजणे',
    'Both at the same time': 'दोन्ही एकाच वेळी',
    'There is no order': 'कुठलाही क्रम नाही',
    'They are equally far.': 'दोन्ही ठिकाणे सारखी दूर आहेत.',
    'Neither is a place.': 'यांपैकी एकही ठिकाण नाही.',
    'triangle': 'त्रिकोण',
    'square': 'चौरस',
    'rectangle': 'आयत',
    'circle': 'वर्तुळ',
    'oval': 'लंबवर्तुळ',
    'rolls': 'घरंगळेल',
    'slides': 'घसरेल',
    'rolls and slides': 'घरंगळेल आणि घसरेल',
    'stays balanced on every side': 'कोणत्याही बाजूवर स्थिर राहील',
    'Monday': 'सोमवार',
    'Tuesday': 'मंगळवार',
    'Wednesday': 'बुधवार',
    'Thursday': 'गुरुवार',
    'Friday': 'शुक्रवार',
    'Saturday': 'शनिवार',
    'Sunday': 'रविवार',
  };
  if (choices.containsKey(english)) return choices[english]!;
  final distance = RegExp(
    r'^The (.+) is (nearer|farther)\.$',
  ).firstMatch(english);
  if (distance != null) {
    const places = {
      'mango tree': 'आंब्याचे झाड',
      'hill': 'डोंगर',
      'well': 'विहीर',
      'market': 'बाजार',
      'school gate': 'शाळेचे फाटक',
      'river': 'नदी',
      'garden': 'बाग',
      'bus stop': 'बस थांबा',
      'library': 'वाचनालय',
      'farm': 'शेत',
    };
    return '${places[distance[1]]} ${distance[2] == 'nearer' ? 'जवळ' : 'दूर'} आहे.';
  }
  throw StateError('Unreviewed Class 1 option: $english');
}

class _C1Thing {
  final String one, many, oneGender, manyGender;
  const _C1Thing(this.one, this.many, this.oneGender, this.manyGender);
  String name(int count) => count == 1 ? one : many;
  String verb(int count, String stem) {
    final gender = count == 1 ? oneGender : manyGender;
    return '$stem${count == 1
        ? gender == 'm'
              ? 'ला'
              : gender == 'f'
              ? 'ली'
              : 'ले'
        : gender == 'm'
        ? 'ले'
        : gender == 'f'
        ? 'ल्या'
        : 'ली'}';
  }
}

const _c1Collections = [
  _C1Thing('पान', 'पाने', 'n', 'n'),
  _C1Thing('आंबा', 'आंबे', 'm', 'm'),
  _C1Thing('गोटी', 'गोट्या', 'f', 'f'),
  _C1Thing('फूल', 'फुले', 'n', 'n'),
  _C1Thing('शिंपला', 'शिंपले', 'm', 'm'),
  _C1Thing('बी', 'बिया', 'n', 'f'),
  _C1Thing('बटण', 'बटणे', 'n', 'n'),
  _C1Thing('पतंग', 'पतंग', 'm', 'm'),
  _C1Thing('पुस्तक', 'पुस्तके', 'n', 'n'),
  _C1Thing('पेरू', 'पेरू', 'm', 'm'),
];

ChapterLesson _class1Lesson(SchoolChapter chapter, ChapterLesson original) {
  if (chapter.grade != 1) return original;
  const concepts = [
    'वर, खाली, आत, बाहेर आणि शेजारी हे शब्द वापरून वस्तू कुठे आहे ते सांगूया.',
    'जवळची वस्तू पाहून कोंबडा कुठे आहे ते सांगूया.',
    'आधी कोणते काम होते आणि नंतर कोणते, ते पाहूया.',
    'एकाच ठिकाणापासून कोणते ठिकाण जवळ आणि कोणते दूर आहे, ते पाहूया.',
    'आकाराच्या कडेवरून बोट फिरवूया. बाजू आणि कोपरे पाहून आकार ओळखूया.',
    'वस्तूची बाजू गोल आहे की सपाट, ते पाहूया. ती घरंगळेल, घसरेल की दोन्ही करेल, ते सांगूया.',
    'एकेका वस्तूला बोट लावून मोजूया. एकूण मोजणी १ ते ९ मधल्या योग्य अंकाशी जोडूया.',
    'एकही वस्तू नाही, हे शून्य दाखवते. शून्याचा अंक ० आहे.',
    'दोन छोटे गट एकत्र ठेवूया. नेमक्या दहा वस्तू करूया.',
    'दोन गट एकत्र करून सगळ्या वस्तू मोजूया. यातली बेरीज ९ पर्यंत असेल.',
    'काही वस्तू बाजूला काढूया. उरलेल्या वस्तू मोजूया.',
    'दहाचा एक गट आणि काही सुट्या वस्तू घेऊया. त्यातून ११ ते २० मधल्या संख्या बनवूया.',
    'एखाद्या संख्येची आधीची, पुढची आणि दोन संख्यांमधली संख्या शोधूया.',
    'कोणती संख्या लहान, मोठी किंवा समान आहे, ते पाहूया. त्यासाठी योग्य चिन्ह निवडूया.',
    'संख्या लहान ते मोठ्या किंवा मोठ्या ते लहान क्रमाने लावूया. हाच चढता किंवा उतरता क्रम.',
    'चित्रातील खुणा मोजूया. कोणत्या गटात कमी किंवा जास्त आहे, ते पाहूया.',
    'पहिली संख्या लक्षात ठेवूया. तिच्या पुढच्या संख्येपासून मोजून बेरीज करूया.',
    'पहिल्या संख्येपासून मागे मोजूया. अशी वजाबाकी करून पाहूया.',
    'दहाचे गट आणि सुट्या वस्तू वापरून २१ ते ३० मधल्या संख्या बनवूया.',
    '३१ ते ९९ मधल्या संख्या वाचूया. दहाचे गट म्हणजे दशके; सुट्या वस्तू म्हणजे एकके.',
    'ठेक्यात संख्या म्हणूया. पुढे कोणती संख्या येते, ते ओळखूया.',
    'नक्षीत किंवा संख्यांत काय पुन्हा येते, ते पाहूया. पुढे काय येईल, ते ठरवूया.',
    'सारख्या वितीने किंवा पावलांनी लांबी मोजूया. हलके-जडही ओळखूया.',
    'रोजची कामे आधी-नंतरच्या क्रमाने सांगूया. वारांची नावेही क्रमाने म्हणूया.',
    'गट एकत्र करून १८ पर्यंत बेरीज करूया. गरज पडली तर आधी दहा पूर्ण करूया.',
    'नाणी आणि नोटांवरची किंमत वाचूया. किंमती मिळवून रक्कम बनवूया.',
    'प्रत्येक गटात सारख्याच वस्तू ठेवूया. गटांची बेरीज पुन्हा पुन्हा करूया. ती गुणाकाराच्या चिन्हानेही लिहिता येते.',
    'सगळ्यांना सारख्याच वस्तू वाटूया. प्रत्येकाला तेवढ्याच मिळाल्या का, ते पाहूया.',
    'खूण ओळखूया. मोजणी, संख्या किंवा आकार वापरून कोडे सोडवूया.',
  ];
  const openings = [
    'मीरा आणि रवी गावात फिरत आहेत.',
    'मीरा आणि रवी कोंबडा शोधत आहेत.',
    'मीरा आणि रवी कामांचा क्रम ठरवत आहेत.',
    'मीरा आणि रवी गावच्या फाटकाजवळ आहेत.',
    'मीरा आणि रवी आजूबाजूचे आकार पाहत आहेत.',
    'मीरा आणि रवी वस्तू फळीवर ठेवून पाहत आहेत.',
    'मीरा आणि रवी टोपलीतल्या वस्तू मोजत आहेत.',
    'मीरा आणि रवी रिकामी टोपली पाहत आहेत.',
    'मीरा आणि रवी दहा वस्तूंचा गट बनवत आहेत.',
    'मीरा आणि रवी दोन गट एकत्र करत आहेत.',
    'मीरा आणि रवी काही वस्तू वापरत आहेत.',
    'मीरा आणि रवी दहाचा गट आणि सुट्या वस्तू मोजत आहेत.',
    'मीरा आणि रवी संख्यांच्या रांगेत खेळत आहेत.',
    'मीरा आणि रवी दोन संख्या पाहत आहेत.',
    'मीरा आणि रवी संख्यांची रांग लावत आहेत.',
    'मीरा आणि रवी चित्रालेख वाचत आहेत.',
    'मीरा आणि रवी पुढे मोजत आहेत.',
    'मीरा आणि रवी मागे मोजत आहेत.',
    'मीरा आणि रवी दहाचे गट मोजत आहेत.',
    'मीरा आणि रवी दशके आणि एकके पाहत आहेत.',
    'मीरा आणि रवी ठेक्यात संख्या म्हणत आहेत.',
    'मीरा आणि रवी मालिकेतला नियम शोधत आहेत.',
    'मीरा आणि रवी लांबी मोजत आहेत.',
    'मीरा आणि रवी वारांचा खेळ खेळत आहेत.',
    'मीरा आणि रवी वस्तूंचे गट मिळवत आहेत.',
    'मीरा आणि रवी नाण्यांची किंमत मोजत आहेत.',
    'मीरा आणि रवी सारखे गट बनवत आहेत.',
    'मीरा आणि रवी चित्रांची कार्डे वाटत आहेत.',
    'मीरा आणि रवी संख्येचे कोडे सोडवत आहेत.',
  ];
  const recaps = [
    'जवळची वस्तू पाहा. मग वर, खाली, आत, बाहेर किंवा शेजारी असे ठिकाण सांग.',
    'कोंबडा कुठे आहे ते जवळच्या वस्तूवरून सांगता येते.',
    'कामांचा क्रम लक्षात ठेव: आधी काय, मग काय?',
    'कमी पावले म्हणजे जवळ. जास्त पावले म्हणजे दूर. सुरुवातीचे ठिकाण तेच ठेव.',
    'आकार ओळखताना त्याच्या बाजू, कोपरे आणि गोल कड पाहा.',
    'गोल बाजूवरून वस्तू घरंगळते. सपाट बाजूवरून घसरते.',
    'प्रत्येक वस्तू एकदाच मोज. शेवटची मोजणी एकूण संख्या सांगते.',
    'काहीच नाही म्हणजे शून्य: ०.',
    'दोन्ही गट मिळून दहा वस्तू झाल्या पाहिजेत.',
    'दोन गट मिळवून मोजले की बेरीज समजते.',
    'काही वस्तू काढल्यावर उरलेल्या मोज. ही वजाबाकी.',
    'दहाचा एक गट आणि सुट्या वस्तू मिळून संख्या बनते.',
    'क्रमाने मोजल्यावर आधीची, पुढची आणि मधली संख्या सापडते.',
    'दोन्ही संख्या पाहून लहान, मोठी किंवा समान हे ठरव.',
    'लहान संख्येपासून मोठ्या संख्येकडे म्हणजे चढता क्रम. उलटा क्रम म्हणजे उतरता क्रम.',
    'एक चिन्ह किती वस्तू दाखवते ते पाहा. मग चित्रातील चिन्हे मोज.',
    'पहिली संख्या पुन्हा मोजू नको. तिच्या पुढच्या संख्येपासून मोज.',
    'मागे मोजताना संख्या कमी होत जातात.',
    'आधी दहाचे गट, मग सुट्या वस्तू मोज.',
    'दशकाचा अंक दहाचे गट सांगतो. एककाचा अंक सुट्या वस्तू सांगतो.',
    'संख्या क्रमाने म्हणत पुढे जा.',
    'प्रत्येक वेळी काय बदलते, तो नियम पुढेही वापर.',
    'मोजताना हाताचा पसारा बदलू नको. सारख्या विती किंवा पावले वापर.',
    'वार क्रमाने म्हण. पुढचा किंवा मागचा वार शोध.',
    'दोन्ही गट मिळव. उपयोग झाला तर आधी दहा पूर्ण कर.',
    'नाणी किती आहेत एवढेच पाहू नको. त्यांची किंमत मिळव.',
    'प्रत्येक गटात सारख्याच वस्तू असतील, तर तीच संख्या पुन्हा पुन्हा मिळव.',
    'प्रत्येकाला तेवढ्याच वस्तू मिळाल्या की समान वाटणी झाली.',
    'खूण वाच. कोणती संख्या बसते ते शोध आणि उत्तर तपास.',
  ];
  final first = _class1Question(chapter, 0, _questionFor(chapter, 0)),
      position = chapter.number - 1;
  return ChapterLesson(
    story: classroomWording(
      original.story,
      '${openings[position]} ${first.prompt.mr}',
      grade: 1,
    ),
    concept: classroomWording(original.concept, concepts[position], grade: 1),
    workedExample: classroomWording(
      original.workedExample,
      first.explanation.mr,
      grade: 1,
      english: first.explanation.en,
    ),
    hint: classroomWording(original.hint, first.hint.mr, grade: 1),
    recap: classroomWording(
      original.recap,
      'लक्षात ठेवूया: ${recaps[position]}',
      grade: 1,
    ),
    objects: original.objects,
    visualKind: original.visualKind,
  );
}
