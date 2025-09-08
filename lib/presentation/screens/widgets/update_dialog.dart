import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class UpdateWrapper extends StatelessWidget {
  final Widget child;

  const UpdateWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      dialogStyle: UpgradeDialogStyle.material, // Cupertino aussi dispo
      showReleaseNotes: true,
      showIgnore: true, // bouton "Plus tard"
      showLater: true,
      child: child,
    );
  }
}
