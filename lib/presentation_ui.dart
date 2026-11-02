part of 'main.dart';

/// The mode is URL-scoped and starts a fresh page. Nothing is copied between
/// authentication, offline-lease or upload-queue namespaces.
class PresentationDataSwitch extends StatelessWidget {
  final bool presentation, compact;
  final ValueChanged<bool>? onChanged;
  const PresentationDataSwitch({
    super.key,
    required this.presentation,
    this.compact = false,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    label: tr('Presentation demo data', 'सादरीकरणासाठी नमुना माहिती'),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(value: presentation, onChanged: onChanged),
        Flexible(
          child: Text(
            presentation
                ? tr('Demo data ON', 'नमुना माहिती सुरू')
                : tr('Demo data OFF', 'नमुना माहिती बंद'),
            style: TextStyle(
              fontSize: compact ? 13 : 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
