import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/game_provider.dart';
import '../providers/tournament_provider.dart';

class WinScreen extends StatefulWidget {
  const WinScreen({super.key});

  @override
  State<WinScreen> createState() => _WinScreenState();
}

class _WinScreenState extends State<WinScreen> with TickerProviderStateMixin {
  late AnimationController _trophyController;
  late Animation<double> _trophyScale;
  late AnimationController _starsController;
  late List<Animation<double>> _starScales = [];

  @override
  void initState() {
    super.initState();
    _trophyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _trophyScale = Tween<double>(begin: 0, end: 1.2).animate(
      CurvedAnimation(parent: _trophyController, curve: Curves.easeOutBack),
    );
    _trophyController.forward().then((_) {
      _trophyController.animateTo(1.0,
          duration: const Duration(milliseconds: 200));
    });

    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _starScales = List.generate(3, (i) {
      return Tween<double>(begin: 0, end: 1.0).animate(
        CurvedAnimation(
          parent: _starsController,
          curve: Interval(
            i * 0.15,
            i * 0.15 + 0.5,
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _starsController.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tournament = context.read<TournamentProvider>();
      if (tournament.isTournamentActive) {
        final game = context.read<GameProvider>();
        if (game.winnerIndex != -1) {
          tournament.recordWin(
            game.winnerIndex,
            turns: game.turnCount,
            cuts: game.totalCuts,
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            if (tournament.tournamentWinner != null) {
              Navigator.pushReplacementNamed(context, '/tournament_winner');
            } else {
              Navigator.pushReplacementNamed(context, '/tournament_dashboard');
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _trophyController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  void _shareResult(String winnerName, int turns, int cuts) {
    final text = '🏆 $winnerName won the Ludo game!\n'
        '📊 $turns turns | $cuts captures\n'
        '🎮 Play Ludo Offline - Multiplayer';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Result copied to clipboard!'),
        backgroundColor: Color(0xFF7c3aed),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tournament = context.watch<TournamentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: Consumer<GameProvider>(
        builder: (context, game, _) {
          if (game.winnerIndex == -1) {
            return const SizedBox();
          }
          final winner = game.players[game.winnerIndex];
          final winnerName = winner.name;
          final colorName = LudoColors.playerName(winner.id);
          final turns = game.turnCount;
          final cuts = game.totalCuts;

          return SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 80,
                  left: MediaQuery.of(context).size.width / 2 - 100,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF7c3aed).withValues(alpha: 0.2),
                          const Color(0xFF7c3aed).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      AnimatedBuilder(
                        animation: _trophyScale,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _trophyScale.value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF12122a),
                            border: Border.all(
                              color: const Color(0xFF7c3aed),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '🏆',
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7c3aed),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'WINNER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        winnerName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12122a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1f1f3a)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (winner.avatar.isNotEmpty) ...[
                              Text(winner.avatar, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                            ] else ...[
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: winner.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              '$colorName · $turns turns · $cuts cuts',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedBuilder(
                        animation: _starsController,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) {
                              return Transform.scale(
                                scale: _starScales[i].value,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    '⭐',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      if (tournament.isTournamentActive) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1a1040),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF7c3aed)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: Color(0xFFFBBF24),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Round ${tournament.currentRound - 1} of ${tournament.targetWins * 2 - 1}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(flex: 2),
                      Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                              label: 'Play\nagain',
                              isPrimary: false,
                              onPressed: () {
                                game.resetGame();
                                Navigator.pushReplacementNamed(
                                    context, '/player_setup');
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildButton(
                              label: 'Share',
                              isPrimary: false,
                              onPressed: () =>
                                  _shareResult(winnerName, turns, cuts),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildButton(
                              label: 'Home',
                              isPrimary: true,
                              onPressed: () {
                                game.resetGame();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/', (route) => false);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPrimary ? const Color(0xFF7c3aed) : const Color(0xFF12122a),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: Color(0xFF1f1f3a)),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, height: 1.2),
        ),
      ),
    );
  }
}
