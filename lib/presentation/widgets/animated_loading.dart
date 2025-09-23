import 'package:flutter/material.dart';

class AnimatedLoading extends StatefulWidget {
  final String message;
  final Color? color;
  final double size;

  const AnimatedLoading({
    super.key,
    this.message = 'Yükleniyor...',
    this.color,
    this.size = 50.0,
  });

  @override
  State<AnimatedLoading> createState() => _AnimatedLoadingState();
}

class _AnimatedLoadingState extends State<AnimatedLoading>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        widget.color ?? Theme.of(context).colorScheme.primary,
                        (widget.color ?? Theme.of(context).colorScheme.primary)
                            .withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.color ?? 
                                Theme.of(context).colorScheme.primary)
                            .withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                    size: widget.size * 0.5,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          widget.message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: widget.color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class PulsingDots extends StatefulWidget {
  final Color? color;
  final double size;

  const PulsingDots({
    super.key,
    this.color,
    this.size = 8.0,
  });

  @override
  State<PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<PulsingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0.4, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ))
        .toList();

    // Start animations with staggered delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.2),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (widget.color ?? Theme.of(context).colorScheme.primary)
                    .withOpacity(_animations[index].value),
              ),
            );
          },
        );
      }),
    );
  }
}

class AnimatedSuccessIcon extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  final Color? color;
  final double size;

  const AnimatedSuccessIcon({
    super.key,
    this.onAnimationComplete,
    this.color,
    this.size = 60.0,
  });

  @override
  State<AnimatedSuccessIcon> createState() => _AnimatedSuccessIconState();
}

class _AnimatedSuccessIconState extends State<AnimatedSuccessIcon>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // Start animation
    _scaleController.forward().then((_) {
      if (mounted) {
        _rotationController.forward().then((_) {
          if (mounted) {
            widget.onAnimationComplete?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color ?? Colors.green,
                boxShadow: [
                  BoxShadow(
                    color: (widget.color ?? Colors.green).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: widget.size * 0.6,
              ),
            ),
          ),
        );
      },
    );
  }
}
