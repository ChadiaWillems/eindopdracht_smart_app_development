import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GenericHeader extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  const GenericHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(middle: const Text('MedScan'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) => true;
}
