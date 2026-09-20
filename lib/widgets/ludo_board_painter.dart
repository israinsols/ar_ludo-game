import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/board_data.dart';
import '../constants/colors.dart';
import '../models/game_models.dart';

class LudoBoardPainter extends CustomPainter {
  final List<Player> players;
  final List<int> safeZoneIndicators;
  final Map<int, List<int>> movePreviews;
  final int currentPlayerIndex;
  final Set<int> movableTokenIds;
  final int currentMovablePlayerId;

  LudoBoardPainter({
    required this.players,
    this.safeZoneIndicators = const [],
    this.movePreviews = const {},
    this.currentPlayerIndex = 0,
    this.movableTokenIds = const {},
    this.currentMovablePlayerId = -1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / 15;
    final cellH = size.height / 15;

    _drawBackground(canvas, size);
    _drawHomeBases(canvas, cellW, cellH);
    _drawPathCells(canvas, cellW, cellH);
    _drawMovePreviews(canvas, cellW, cellH);
    _drawSafeZoneHighlights(canvas, cellW, cellH);
    _drawHomeColumns(canvas, cellW, cellH);
    _drawCenter(canvas, cellW, cellH);
    _drawSafeStars(canvas, cellW, cellH);
    _drawStartMarkers(canvas, cellW, cellH);
    _drawTokens(canvas, cellW, cellH);
    _drawGridLines(canvas, cellW, cellH, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF12122a);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      paint,
    );
  }

  void _drawHomeBases(Canvas canvas, double cellW, double cellH) {
    final bases = [
      {
        'rect': Rect.fromLTWH(0, 0, 6 * cellW, 6 * cellH),
        'color': LudoColors.red,
        'dim': LudoColors.redDim
      },
      {
        'rect': Rect.fromLTWH(9 * cellW, 0, 6 * cellW, 6 * cellH),
        'color': LudoColors.blue,
        'dim': LudoColors.blueDim
      },
      {
        'rect': Rect.fromLTWH(0, 9 * cellW, 6 * cellW, 6 * cellH),
        'color': LudoColors.green,
        'dim': LudoColors.greenDim
      },
      {
        'rect': Rect.fromLTWH(9 * cellW, 9 * cellW, 6 * cellW, 6 * cellH),
        'color': LudoColors.yellow,
        'dim': LudoColors.yellowDim
      },
    ];

    for (var base in bases) {
      final rect = base['rect'] as Rect;
      final color = base['color'] as Color;
      final dim = base['dim'] as Color;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        Paint()..color = dim,
      );

      final borderPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        borderPaint,
      );

      final inner = Rect.fromLTWH(
        rect.left + rect.width * 0.12,
        rect.top + rect.height * 0.12,
        rect.width * 0.76,
        rect.height * 0.76,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(inner, const Radius.circular(16)),
        Paint()..color = color.withValues(alpha: 0.08),
      );
    }
  }

  void _drawPathCells(Canvas canvas, double cellW, double cellH) {
    final cellPaint = Paint()..color = const Color(0xFF1a1a35);
    final borderPaint = Paint()
      ..color = const Color(0xFF222244)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var cell in BoardData.mainPath) {
      final rect =
          Rect.fromLTWH(cell[1] * cellW, cell[0] * cellH, cellW, cellH);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        cellPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        borderPaint,
      );
    }
  }

  void _drawMovePreviews(Canvas canvas, double cellW, double cellH) {
    if (movePreviews.isEmpty) return;

    final previewPaint = Paint()
      ..color = const Color(0xFF7c3aed).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final previewBorderPaint = Paint()
      ..color = const Color(0xFF7c3aed).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var entry in movePreviews.entries) {
      for (var pos in entry.value) {
        if (pos < 0 || pos >= BoardData.mainPath.length) continue;
        final cell = BoardData.mainPath[pos];
        final rect = Rect.fromLTWH(
          cell[1] * cellW + cellW * 0.15,
          cell[0] * cellH + cellH * 0.15,
          cellW * 0.7,
          cellH * 0.7,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          previewPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          previewBorderPaint,
        );
      }
    }
  }

  void _drawSafeZoneHighlights(Canvas canvas, double cellW, double cellH) {
    if (safeZoneIndicators.isEmpty) return;

    for (var pos in safeZoneIndicators) {
      if (pos < 0 || pos >= BoardData.mainPath.length) continue;
      final cell = BoardData.mainPath[pos];
      final cx = cell[1] * cellW + cellW / 2;
      final cy = cell[0] * cellH + cellH / 2;

      final glowPaint = Paint()
        ..color = const Color(0xFF4ade80).withValues(alpha: 0.3);
      canvas.drawCircle(Offset(cx, cy), cellW * 0.4, glowPaint);
    }
  }

  void _drawHomeColumns(Canvas canvas, double cellW, double cellH) {
    final borderPaint = Paint()
      ..color = const Color(0xFF222244)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int p = 0; p < 4; p++) {
      final col = BoardData.homeColumns[p];
      final color = LudoColors.playerColor(p);
      for (int i = 0; i < col.length; i++) {
        final rect =
            Rect.fromLTWH(col[i][1] * cellW, col[i][0] * cellH, cellW, cellH);
        final fillPaint = Paint()..color = color.withValues(alpha: 0.15 + (i * 0.06));
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          fillPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          borderPaint,
        );
      }
    }
  }

  void _drawCenter(Canvas canvas, double cellW, double cellH) {
    final rect = Rect.fromLTWH(6 * cellW, 6 * cellH, 3 * cellW, 3 * cellH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF1a1a35),
    );

    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final hw = 1.5 * cellW;
    final hh = 1.5 * cellH;

    final colors = [
      LudoColors.red,
      LudoColors.blue,
      LudoColors.green,
      LudoColors.yellow
    ];

    final trianglePositions = [
      Path()
        ..moveTo(cx, cy)
        ..lineTo(cx - hw, cy - hh)
        ..lineTo(cx - hw, cy + hh)
        ..close(),
      Path()
        ..moveTo(cx, cy)
        ..lineTo(cx - hw, cy - hh)
        ..lineTo(cx + hw, cy - hh)
        ..close(),
      Path()
        ..moveTo(cx, cy)
        ..lineTo(cx - hw, cy + hh)
        ..lineTo(cx + hw, cy + hh)
        ..close(),
      Path()
        ..moveTo(cx, cy)
        ..lineTo(cx + hw, cy - hh)
        ..lineTo(cx + hw, cy + hh)
        ..close(),
    ];

    for (int i = 0; i < 4; i++) {
      canvas.drawPath(
        trianglePositions[i],
        Paint()..color = colors[i].withValues(alpha: 0.5),
      );
    }

    final centerCircle =
        Paint()..color = const Color(0xFF7c3aed).withValues(alpha: 0.4);
    canvas.drawCircle(Offset(cx, cy), cellW * 0.4, centerCircle);

    final borderPaint = Paint()
      ..color = const Color(0xFF2a2a50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      borderPaint,
    );
  }

  void _drawSafeStars(Canvas canvas, double cellW, double cellH) {
    for (var posIdx in BoardData.safePositions) {
      final cell = BoardData.mainPath[posIdx];
      final cx = cell[1] * cellW + cellW / 2;
      final cy = cell[0] * cellH + cellH / 2;

      final bgPaint = Paint()..color = const Color(0xFF1a3d2a).withValues(alpha: 0.4);
      canvas.drawCircle(Offset(cx, cy), cellW * 0.35, bgPaint);

      _drawStar(
          canvas,
          cx,
          cy,
          cellW * 0.2,
          cellW * 0.08,
          5,
          Paint()..color = const Color(0xFF4ade80).withValues(alpha: 0.6));
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double outerR,
      double innerR, int points, Paint paint) {
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * pi / points) - pi / 2;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawStartMarkers(Canvas canvas, double cellW, double cellH) {
    final startData = [
      {'pos': BoardData.mainPath[42], 'color': LudoColors.red, 'dir': 1},
      {'pos': BoardData.mainPath[3], 'color': LudoColors.blue, 'dir': 2},
      {'pos': BoardData.mainPath[29], 'color': LudoColors.green, 'dir': 0},
      {'pos': BoardData.mainPath[16], 'color': LudoColors.yellow, 'dir': 3},
    ];

    for (var data in startData) {
      final cell = data['pos'] as List<int>;
      final color = data['color'] as Color;
      final dir = data['dir'] as int;

      final cx = cell[1] * cellW + cellW / 2;
      final cy = cell[0] * cellH + cellH / 2;
      final sz = cellW * 0.32;

      Path arrow;
      switch (dir) {
        case 0:
          arrow = Path()
            ..moveTo(cx, cy + sz)
            ..lineTo(cx - sz, cy - sz)
            ..lineTo(cx + sz, cy - sz)
            ..close();
          break;
        case 1:
          arrow = Path()
            ..moveTo(cx - sz, cy)
            ..lineTo(cx + sz, cy - sz)
            ..lineTo(cx + sz, cy + sz)
            ..close();
          break;
        case 2:
          arrow = Path()
            ..moveTo(cx, cy - sz)
            ..lineTo(cx - sz, cy + sz)
            ..lineTo(cx + sz, cy + sz)
            ..close();
          break;
        default:
          arrow = Path()
            ..moveTo(cx + sz, cy)
            ..lineTo(cx - sz, cy - sz)
            ..lineTo(cx - sz, cy + sz)
            ..close();
          break;
      }

      canvas.drawPath(
        arrow,
        Paint()..color = color.withValues(alpha: 0.7),
      );
    }
  }

  void _drawTokens(Canvas canvas, double cellW, double cellH) {
    for (var player in players) {
      for (var token in player.tokens) {
        if (token.state != TokenState.base) continue;

        final isMovable = movableTokenIds.contains(token.id) && player.id == currentMovablePlayerId;
        final tokenSize = cellW * 0.85;

        final bp = player.basePositions[token.id];
        final cx = bp[1] * cellW + cellW / 2;
        final cy = bp[0] * cellH + cellH / 2;

        final paint = Paint()..color = player.tokenColor;

        if (isMovable) {
          final glowPaint = Paint()
            ..color = player.tokenColor.withValues(alpha: 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
          canvas.drawCircle(Offset(cx, cy), tokenSize / 2 + 3, glowPaint);
        }

        canvas.drawCircle(Offset(cx, cy), tokenSize / 2, paint);

        final borderPaint = Paint()
          ..color = isMovable ? Colors.white : Colors.white.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isMovable ? 2.5 : 1.5;
        canvas.drawCircle(Offset(cx, cy), tokenSize / 2, borderPaint);
      }
    }
  }

  void _drawGridLines(Canvas canvas, double cellW, double cellH, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1a1a35)
      ..strokeWidth = 0.3;

    for (int i = 0; i <= 15; i++) {
      canvas.drawLine(
          Offset(i * cellW, 0), Offset(i * cellW, size.height), paint);
      canvas.drawLine(
          Offset(0, i * cellH), Offset(size.width, i * cellH), paint);
    }
  }

  @override
  bool shouldRepaint(covariant LudoBoardPainter old) => true;
}
