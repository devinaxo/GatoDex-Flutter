import 'package:flutter/material.dart';
import 'dart:math' as math;

class PawLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;

  const PawLoadingIndicator({
    Key? key,
    this.size = 50.0,
    this.color = Colors.orange,
  }) : super(key: key);

  @override
  State<PawLoadingIndicator> createState() => _PawLoadingIndicatorState();
}

class _PawLoadingIndicatorState extends State<PawLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: List.generate(4, (index) {
                final angle = (index * 90.0) * (3.14159 / 180);
                return Transform.rotate(
                  angle: angle + (_animation.value * 2 * 3.14159),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: widget.size * 0.15,
                      height: widget.size * 0.15,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(
                          0.3 + (0.7 * ((index + _animation.value * 4) % 4) / 4),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class WaveLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;

  const WaveLoadingIndicator({
    Key? key,
    this.size = 60.0,
    this.color = Colors.orange,
  }) : super(key: key);

  @override
  State<WaveLoadingIndicator> createState() => _WaveLoadingIndicatorState();
}

class _WaveLoadingIndicatorState extends State<WaveLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size * 0.5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = index * 0.1;
                final animationValue = (_controller.value - delay) % 1.0;
                final height = widget.size * 0.1 + 
                    (widget.size * 0.3 * (0.5 + 0.5 * 
                    math.sin(animationValue * 2 * math.pi)));
                
                return Container(
                  width: widget.size * 0.1,
                  height: height,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(widget.size * 0.05),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class CatLoadingIndicator extends StatefulWidget {
  final double size;

  const CatLoadingIndicator({
    Key? key,
    this.size = 80.0,
  }) : super(key: key);

  @override
  State<CatLoadingIndicator> createState() => _CatLoadingIndicatorState();
}

class _CatLoadingIndicatorState extends State<CatLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_bounceAnimation.value),
                child: Icon(
                  Icons.pets,
                  size: widget.size,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Cargando gatitos...',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
