import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/board_data.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';
import '../widgets/ludo_board_painter.dart';
import '../widgets/dice_widget.dart';

class GameBoardScreen extends StatefulWidget {
  const GameBoardScreen({super.key});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen>
    with SingleTickerProviderStateMixin {
  bool _isRolling = false;
  int _displayDice = 0;
  Timer? _rollTimer;
  Timer? _autoEndTimer;
  Timer? _timerTick;
  bool _waitingForMove = false;
  bool _moveDone = false;
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;
  int? _pulsingTokenId;
  bool _capturedFlash = false;

  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
    _pulseController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController!.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController!.forward();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final game = context.read<GameProvider>();
      if (game.players.isEmpty) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    _autoEndTimer?.cancel();
    _timerTick?.cancel();
    _pulseController?.dispose();
    super.dispose();
  }

  void _onRollDice() async {
    final game = context.read<GameProvider>();
    if (game.hasRolledDice || _isRolling || _waitingForMove || _moveDone) return;

    _autoEndTimer?.cancel();
    game.rollDice();
    final targetValue = game.diceValue;

    setState(() {
      _isRolling = true;
      _displayDice = 0;
    });

    final rng = Random();
    int ticks = 0;
    _rollTimer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
      ticks++;
      if (ticks >= 8) {
        timer.cancel();
        setState(() {
          _isRolling = false;
          _displayDice = targetValue;
        });
        game.addToDiceHistory();
        game.calculatePreviewsAfterDice();
        _afterRoll(game);
      } else {
        setState(() {
          _displayDice = rng.nextInt(6) + 1;
        });
      }
    });
  }

  void _afterRoll(GameProvider game) {
    if (game.winnerIndex != -1) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/win');
      });
      return;
    }

    if (game.gameSettings.timerMode) {
      _timerTick?.cancel();
      _timerTick = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) { timer.cancel(); return; }
        game.tickTimer();
        if (game.timerRemaining <= 0) {
          timer.cancel();
        }
      });
    }

    if (game.movableTokens.isEmpty) {
      setState(() => _waitingForMove = false);
      _autoEndTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted) _endTurn();
      });
    } else {
      setState(() {
        _waitingForMove = true;
        _moveDone = false;
      });
      if (game.movableTokens.isNotEmpty) {
        _pulsingTokenId = game.movableTokens.first;
        _pulseController!.forward();
      }
    }
  }

  void _onTokenTap(int tokenId) async {
    final game = context.read<GameProvider>();
    if (_isRolling || !_waitingForMove) return;

    _autoEndTimer?.cancel();
    _timerTick?.cancel();
    game.stopTimer();
    _pulseController!.stop();
    setState(() {
      _waitingForMove = false;
      _moveDone = true;
      _pulsingTokenId = null;
    });

    final result = game.moveToken(tokenId);

    if (game.capturedAnimation) {
      setState(() => _capturedFlash = true);
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() => _capturedFlash = false);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (result == 2) {
      setState(() => _displayDice = 0);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.pushReplacementNamed(context, '/win');
      return;
    }

    if (result == 1) {
      setState(() {
        _moveDone = false;
        _displayDice = game.diceValue;
      });
      if (game.gameSettings.timerMode) {
        _timerTick?.cancel();
        _timerTick = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) { timer.cancel(); return; }
          game.tickTimer();
          if (game.timerRemaining <= 0) {
            timer.cancel();
          }
        });
      }
      return;
    }

    setState(() => _displayDice = game.diceValue);
    _autoEndTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) _endTurn();
    });
  }

  void _endTurn() {
    _autoEndTimer?.cancel();
    _timerTick?.cancel();
    _pulseController!.stop();
    final game = context.read<GameProvider>();
    setState(() {
      _displayDice = 0;
      _waitingForMove = false;
      _moveDone = false;
      _pulsingTokenId = null;
    });
    game.endTurn();
  }

  void _onUndo() {
    final game = context.read<GameProvider>();
    if (game.undoLastMove()) {
      setState(() {
        _waitingForMove = true;
        _moveDone = false;
        _displayDice = game.diceValue;
      });
      if (game.movableTokens.isNotEmpty) {
        _pulsingTokenId = game.movableTokens.first;
        _pulseController!.forward();
      }
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, game, _) {
            if (game.players.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                _buildTopBar(game),
                _buildPlayerMiniBar(game),
                if (game.gameSettings.timerMode && game.timerActive)
                  _buildTimerBar(game),
                const SizedBox(height: 4),
                _ludoChart(game),
                _buildBottomBar(game),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(GameProvider game) {
    return Container(
      height: 36,
      color: const Color(0xFF0d0d22),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Turn ${game.turnCount + 1}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
          // const Spacer(),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFF7c3aed),
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: Text(
          //     "${game.currentPlayer.name}'s turn",
          //     style: const TextStyle(
          //       color: Colors.white,
          //       fontSize: 11,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
          const Spacer(),
          if (game.canUndo && game.hasRolledDice && !game.hasMovedToken)
            GestureDetector(
              onTap: _onUndo,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1040),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.undo,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 16,
                ),
              ),
            ),
          GestureDetector(
            onTap: () => _showPauseMenu(game),
            child: Icon(
              Icons.menu_rounded,
              color: Colors.white.withValues(alpha: 0.4),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar(GameProvider game) {
    final total = game.gameSettings.timerSeconds;
    final remaining = game.timerRemaining;
    final fraction = remaining / total;

    return Container(
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a35),
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction,
          child: Container(
            height: 6,
            color: fraction > 0.3
                ? const Color(0xFF7c3aed)
                : const Color(0xFFE8475F),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerMiniBar(GameProvider game) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: game.players.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final p = game.players[index];
          final isActive = index == game.currentPlayerIndex;
          final finished = p.finishedTokens;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1a1040) : const Color(0xFF12122a),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF7c3aed)
                    : const Color(0xFF1f1f3a),
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (p.avatar.isNotEmpty) ...[
                  Text(p.avatar, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                ] else ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: p.tokenColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  p.name,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$finished',
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(GameProvider game) {
    final canRoll =
        !game.hasRolledDice && !_isRolling && !_waitingForMove && !_moveDone;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (game.diceHistory.isNotEmpty)
            Container(
              height: 32,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: game.diceHistory.length,
                itemBuilder: (context, index) {
                  final entry = game.diceHistory[index];
                  final player = game.players[entry.playerId];
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12122a),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: player.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.value}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          DiceWidget(
            value: _displayDice,
            isRolling: _isRolling,
            canRoll: canRoll,
            onRoll: _onRollDice,
          ),
        ],
      ),
    );
  }

  Widget _ludoChart(GameProvider game){
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxSize = constraints.maxWidth <
              (constraints.maxHeight - 160)
              ? constraints.maxWidth - 12
              : constraints.maxHeight - 160;
          return Center(
            child: GestureDetector(
              onScaleStart: (details) {
                _previousScale = _scale;
                _previousOffset = _offset;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _scale = (_previousScale * details.scale).clamp(1.0, 3.0);
                  _offset = _previousOffset + details.focalPointDelta;
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: maxSize,
                  height: maxSize,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..translate(_offset.dx, _offset.dy)
                      ..scale(_scale),
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTapUp: (details) {
                            if (!_waitingForMove) return;
                            final game = context.read<GameProvider>();
                            final cellW = maxSize / 15.0;
                            final cellH = maxSize / 15.0;
                            final tapX = details.localPosition.dx;
                            final tapY = details.localPosition.dy;
                            for (var player in game.players) {
                              if (player.id != game.currentPlayerIndex) continue;
                              for (var token in player.tokens) {
                                if (token.state != TokenState.base) continue;
                                if (!game.movableTokens.contains(token.id)) continue;
                                final bp = player.basePositions[token.id];
                                final cx = bp[1] * cellW + cellW / 2;
                                final cy = bp[0] * cellH + cellH / 2;
                                final dist = sqrt(pow(tapX - cx, 2) + pow(tapY - cy, 2));
                                if (dist < cellW * 0.5) {
                                  _onTokenTap(token.id);
                                  return;
                                }
                              }
                            }
                          },
                          child: CustomPaint(
                            size: Size(maxSize, maxSize),
                            painter: LudoBoardPainter(
                              players: game.players,
                              safeZoneIndicators: game.safeZoneIndicators,
                              movePreviews: game.movePreviews,
                              currentPlayerIndex: game.currentPlayerIndex,
                              movableTokenIds: game.movableTokens.toSet(),
                              currentMovablePlayerId: _waitingForMove ? game.currentPlayerIndex : -1,
                            ),
                            child: SizedBox(
                              width: maxSize,
                              height: maxSize,
                            ),
                          ),
                        ),
                        if (_capturedFlash)
                          Container(
                            width: maxSize,
                            height: maxSize,
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ..._buildTokens(game, maxSize),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildTokens(GameProvider game, double boardSize) {
    final cellW = boardSize / 15;
    final cellH = boardSize / 15;
    List<Widget> tokenWidgets = [];

    final Map<String, List<int>> positionTokens = {};

    for (var player in game.players) {
      for (var token in player.tokens) {
        if (token.state == TokenState.home || token.state == TokenState.base) continue;
        String posKey;
        switch (token.state) {
          case TokenState.mainPath:
            posKey = 'main_${token.pathIndex}';
            break;
          case TokenState.homeColumn:
            posKey = 'hc_${player.id}_${token.homeColumnIndex}';
            break;
          default:
            continue;
        }
        positionTokens.putIfAbsent(posKey, () => []);
        positionTokens[posKey]!.add(token.id);
      }
    }

    final Map<int, int> tokenOffsetIndex = {};
    final Map<int, int> tokenOffsetTotal = {};
    for (var entry in positionTokens.entries) {
      if (entry.value.length > 1) {
        for (int i = 0; i < entry.value.length; i++) {
          tokenOffsetIndex[entry.value[i]] = i;
          tokenOffsetTotal[entry.value[i]] = entry.value.length;
        }
      }
    }

    for (var player in game.players) {
      for (var token in player.tokens) {
        double cx, cy;
        bool isMovable = game.movableTokens.contains(token.id) &&
            player.id == game.currentPlayerIndex &&
            _waitingForMove;

        switch (token.state) {
          case TokenState.base:
            continue;
          case TokenState.mainPath:
            final pos = BoardData.mainPath[token.pathIndex];
            cx = pos[1] * cellW + cellW / 2;
            cy = pos[0] * cellH + cellH / 2;
            break;
          case TokenState.homeColumn:
            final hc = player.homeColumn[token.homeColumnIndex];
            cx = hc[1] * cellW + cellW / 2;
            cy = hc[0] * cellH + cellH / 2;
            break;
          case TokenState.home:
            continue;
        }

        final tokenSize = cellW * 0.85;
        final isPulsing = isMovable && _pulsingTokenId == token.id;

        if (tokenOffsetTotal.containsKey(token.id) && tokenOffsetTotal[token.id]! > 1) {
          final idx = tokenOffsetIndex[token.id]!;
          final total = tokenOffsetTotal[token.id]!;
          final offset = tokenSize * 0.42;
          if (total == 2) {
            cx += (idx == 0 ? -offset : offset);
            cy += (idx == 0 ? -offset : offset);
          } else if (total == 3) {
            if (idx == 0) { cx -= offset; cy -= offset * 0.5; }
            else if (idx == 1) { cx += offset; cy -= offset * 0.5; }
            else { cy += offset; }
          } else {
            final angle = (2 * pi * idx / total) - pi / 2;
            cx += offset * cos(angle);
            cy += offset * sin(angle);
          }
        }

        Widget tokenWidget = Container(
          width: tokenSize,
          height: tokenSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: player.tokenColor,
            border: Border.all(
              color: isMovable ? Colors.white : Colors.white.withValues(alpha: 0.2),
              width: isMovable ? 2 : 1.5,
            ),
            boxShadow: isMovable
                ? [
                    BoxShadow(
                      color: player.tokenColor.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    )
                  ],
          ),
        );

        if (isPulsing) {
          tokenWidget = AnimatedBuilder(
            animation: _pulseAnimation!,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation!.value,
                child: child,
              );
            },
            child: tokenWidget,
          );
        }

        tokenWidgets.add(
          Positioned(
            left: cx - tokenSize / 2,
            top: cy - tokenSize / 2,
            child: GestureDetector(
              onTap: isMovable ? () => _onTokenTap(token.id) : null,
              child: tokenWidget,
            ),
          ),
        );
      }
    }
    return tokenWidgets;
  }

  void _showPauseMenu(GameProvider game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12122a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Game Paused', style: TextStyle(color: Colors.white, fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _menuTile(Icons.play_arrow_rounded, 'Resume', () => Navigator.pop(ctx)),
            _menuTile(Icons.refresh_rounded, 'Restart', () {
              Navigator.pop(ctx);
              _autoEndTimer?.cancel();
              _rollTimer?.cancel();
              _timerTick?.cancel();
              _pulseController?.stop();
              context.read<GameProvider>().resetGame();
              Navigator.pushReplacementNamed(context, '/player_setup');
            }),
            _menuTile(Icons.home_rounded, 'Home', () {
              Navigator.pop(ctx);
              _autoEndTimer?.cancel();
              _rollTimer?.cancel();
              _timerTick?.cancel();
              _pulseController?.stop();
              context.read<GameProvider>().resetGame();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF7c3aed)),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
