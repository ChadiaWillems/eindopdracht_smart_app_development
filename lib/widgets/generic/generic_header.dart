import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GenericHeader extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final String title;
  const GenericHeader({super.key, this.title = 'MedScan'});

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(middle: Text(title));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) => true;
}
