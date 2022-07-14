import 'package:creta01/widgets/abs_anime.dart';
import 'package:flutter/material.dart';

class ScaleAnime extends AbsAnime {
  final Widget child;
  const ScaleAnime({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ScaleAnime> createState() => _ScaleAnimeState();

  @override
  void action(params) {
    return;
  }
}

/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class _ScaleAnimeState extends State<ScaleAnime> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  ); //)..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: widget.child,
        ),
      ),
    );
  }
}
