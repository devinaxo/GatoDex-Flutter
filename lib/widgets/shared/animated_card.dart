import 'package:flutter/material.dart';

class AnimatedCatCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;

  const AnimatedCatCard({
    Key? key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  State<AnimatedCatCard> createState() => _AnimatedCatCardState();
}

class _AnimatedCatCardState extends State<AnimatedCatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 8.0,
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

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: widget.duration,
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class ShimmerCard extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerCard({
    Key? key,
    required this.child,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
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
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.grey,
                Colors.white,
                Colors.grey,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
