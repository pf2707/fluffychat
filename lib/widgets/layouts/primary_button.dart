
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final bool enableStatus;
  final Function action;
  const PrimaryButton({super.key, required this.title, required this.enableStatus, required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (enableStatus) {
          action();
        }
      },
      child: Container(
        width: double.infinity, height: 50,
        decoration: BoxDecoration(
          color: enableStatus ? theme.primaryColor : theme.primaryColor.withOpacity(0.4),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
