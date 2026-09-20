import 'dart:math';
import 'package:flutter/material.dart';

class DiceWidget extends StatefulWidget {
  final int value;
  final bool isRolling;
  final bool canRoll;
  final VoidCallback onRoll;

  const DiceWidget({
    super.key,
    required this.value,
    required this.isRolling,
    required this.canRoll,
    required this.onRoll,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _rotateController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(widget.isRolling ? _rotateAnimation.value : 0),
              child: child,
            );
          },
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFf5f5f5),
              borderRadius: BorderRadius.circular(12),
              boxShadow: widget.canRoll
                  ? [
                      const BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: widget.isRolling
                ? _buildRollingDice()
                : _buildDiceFace(widget.value),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: widget.canRoll ? widget.onRoll : null,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: widget.canRoll
                    ? const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF7c3aed)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: widget.canRoll ? null : const Color(0xFF1f1f3a),
                borderRadius: BorderRadius.circular(28),
                boxShadow: widget.canRoll
                    ? [
                        BoxShadow(
                          color: const Color(0xFF7c3aed).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  widget.canRoll ? 'Roll dice' : 'Got ${widget.value}',
                  style: TextStyle(
                    color: widget.canRoll
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRollingDice() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, progress, child) {
        final displayVal = (progress * 20).toInt() % 6 + 1;
        return _buildDiceFace(displayVal);
      },
    );
  }

  Widget _buildDiceFace(int val) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        painter: _DiceDotPainter(val),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DiceDotPainter extends CustomPainter {
  final int value;
  _DiceDotPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = const Color(0xFF1a1a2e);

    final double r = size.width * 0.095;
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double s = size.width * 0.28;

    List<Offset> dots;

    switch (value) {
      case 1:
        dots = [Offset(cx, cy)];
        break;
      case 2:
        dots = [Offset(cx - s, cy - s), Offset(cx + s, cy + s)];
        break;
      case 3:
        dots = [
          Offset(cx - s, cy - s),
          Offset(cx, cy),
          Offset(cx + s, cy + s)
        ];
        break;
      case 4:
        dots = [
          Offset(cx - s, cy - s),
          Offset(cx + s, cy - s),
          Offset(cx - s, cy + s),
          Offset(cx + s, cy + s),
        ];
        break;
      case 5:
        dots = [
          Offset(cx - s, cy - s),
          Offset(cx + s, cy - s),
          Offset(cx, cy),
          Offset(cx - s, cy + s),
          Offset(cx + s, cy + s),
        ];
        break;
      case 6:
        dots = [
          Offset(cx - s, cy - s),
          Offset(cx + s, cy - s),
          Offset(cx - s, cy),
          Offset(cx + s, cy),
          Offset(cx - s, cy + s),
          Offset(cx + s, cy + s),
        ];
        break;
      default:
        dots = [];
    }

    for (var dot in dots) {
      canvas.drawCircle(dot, r, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiceDotPainter old) => old.value != value;
}
