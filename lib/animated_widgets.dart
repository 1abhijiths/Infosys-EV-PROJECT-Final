import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Animated gradient background widget
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key});

  @override
  _AnimatedGradientBackgroundState createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(Colors.green[700], Colors.blue[400], _animation.value)!,
                Color.lerp(Colors.orange[200], Colors.green[100], 1 - _animation.value)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }
}

// Animated Card for list items
class AnimatedCard extends StatelessWidget {
  final Widget child;
  final int index;
  const AnimatedCard({Key? key, required this.child, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: 100 * index), duration: 500.ms),
        SlideEffect(
            begin: const Offset(0, 50),
            delay: Duration(milliseconds: 100 * index),
            duration: 500.ms,
            curve: Curves.easeOutCubic),
      ],
      child: child,
    );
  }
}

// Animated search button with loading state
class AnimatedSearchButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const AnimatedSearchButton(
      {Key? key, required this.isLoading, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isLoading
          ? Row(
              key: const ValueKey('loading'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(width: 16),
                Text('Finding Sustainable Stations...',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold)),
              ],
            )
          : ElevatedButton(
              key: const ValueKey('search'),
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: Colors.green[200],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'search-btn',
                    child: Icon(FontAwesomeIcons.magnifyingGlass, size: 20),
                  ),
                  SizedBox(width: 10),
                  Text('Find Stations',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
    );
  }
}