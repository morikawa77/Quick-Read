import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;

  const GradientContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xff130059),
            Color(0xff18006f),
            Color(0xff1e0085),
            Color(0xff23009c),
            Color(0xff2900b4),
            Color(0xff2e00cc),
            Color(0xff3300e5),
            Color(0xff3800ff),
          ],
          tileMode: TileMode.mirror,
        ),
      ),
      child: child,
    );
  }
}
