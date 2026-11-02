part of 'main.dart';

/// Owns its controllers until the dialog's closing transition is disposed.
class ManagementRecordDialog extends StatefulWidget {
  final String title;
  final List<(String, String, String)> fields;
  final Map<String, String> values;
  final Set<String> secrets;
  const ManagementRecordDialog({
    super.key,
    required this.title,
    required this.fields,
    this.values = const {},
    this.secrets = const {},
  });
  @override
  State<ManagementRecordDialog> createState() => _ManagementRecordDialogState();
}

class _ManagementRecordDialogState extends State<ManagementRecordDialog> {
  final formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> controllers;
  @override
  void initState() {
    super.initState();
    controllers = {
      for (final f in widget.fields)
        f.$1: TextEditingController(text: widget.values[f.$1] ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in controllers.values) c.dispose();
    super.dispose();
  }

  String? validate(String key, String? value) {
    if (const {'name', 'email'}.contains(key) &&
        (value?.trim().isEmpty ?? true))
      return tr('This field is required.', 'ही माहिती आवश्यक आहे.');
    if (widget.secrets.contains(key) && (value?.length ?? 0) < 12)
      return tr('Use at least 12 characters.', 'किमान १२ अक्षरे वापरा.');
    return null;
  }

  void save() {
    if (formKey.currentState?.validate() != true) return;
    Navigator.pop(context, {
      for (final e in controllers.entries)
        e.key: widget.secrets.contains(e.key)
            ? e.value.text
            : e.value.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 620,
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final field in widget.fields)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: field.$1 == 'grade'
                      ? DropdownButtonFormField<String>(
                          initialValue: controllers['grade']!.text.isEmpty
                              ? '1'
                              : controllers['grade']!.text,
                          isExpanded: true,
                          itemHeight: 64,
                          decoration: InputDecoration(
                            labelText: tr(field.$2, field.$3),
                          ),
                          items: [
                            for (final grade in ['1', '2', '3', '4'])
                              DropdownMenuItem(
                                value: grade,
                                child: Text('${tr('Class', 'इयत्ता')} $grade'),
                              ),
                          ],
                          onChanged: (v) {
                            if (v != null) controllers['grade']!.text = v;
                          },
                        )
                      : TextFormField(
                          controller: controllers[field.$1],
                          obscureText: widget.secrets.contains(field.$1),
                          autocorrect: !widget.secrets.contains(field.$1),
                          enableSuggestions: !widget.secrets.contains(field.$1),
                          validator: (v) => validate(field.$1, v),
                          decoration: InputDecoration(
                            labelText: tr(field.$2, field.$3),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(tr('Cancel', 'रद्द करा')),
      ),
      FilledButton(onPressed: save, child: Text(tr('Save', 'जतन करा'))),
    ],
  );
}
