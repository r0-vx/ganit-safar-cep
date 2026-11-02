part of 'main.dart';

Future<void> showSchoolLogin(
  BuildContext context,
  Map<String, dynamic> login,
) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (ctx) => AlertDialog(
    title: Text(tr('School login is ready', 'शाळेचा प्रवेश तयार आहे')),
    content: SizedBox(
      width: 560,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              login['schoolName'].toString(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(tr('School ID', 'शाळेचा आयडी')),
            SelectableText(login['username'].toString()),
            const SizedBox(height: 16),
            Text(tr('Password', 'संकेतशब्द')),
            SelectableText(login['password'].toString()),
            const SizedBox(height: 20),
            Text(
              tr(
                'Save these details now. The password is shown only once. Use this same school login on the dashboard and on each classroom smartboard. No separate teacher accounts are needed.',
                'ही माहिती आता जतन करा. संकेतशब्द फक्त एकदाच दिसेल. निरीक्षण फलकावर आणि प्रत्येक वर्गाच्या स्मार्ट फळ्यावर हाच शाळेचा आयडी व संकेतशब्द वापरा. वेगळी शिक्षक खाती आवश्यक नाहीत.',
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton.icon(
        icon: const Icon(Icons.copy),
        onPressed: () async {
          await Clipboard.setData(
            ClipboardData(
              text:
                  '${login['schoolName']}\nSchool ID / शाळेचा आयडी: ${login['username']}\nPassword / संकेतशब्द: ${login['password']}\nhttps://ganit-safar-smartboard.vercel.app/sign-in\nhttps://ganit-safar-dashboard.vercel.app/sign-in',
            ),
          );
          if (ctx.mounted)
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(
                  tr(
                    'School login copied.',
                    'शाळेच्या प्रवेशाची माहिती कॉपी केली.',
                  ),
                ),
              ),
            );
        },
        label: Text(tr('Copy login details', 'प्रवेशाची माहिती कॉपी करा')),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(ctx),
        child: Text(tr('I have saved it', 'मी जतन केले आहे')),
      ),
    ],
  ),
);
