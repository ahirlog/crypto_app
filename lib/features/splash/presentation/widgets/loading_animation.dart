import 'package:flutter/material.dart';

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({Key? key}) : super(key: key);

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RotationTransition(
          turns: _animation,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.currency_bitcoin,
              color: Colors.black,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading crypto data...',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
