import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tournament_provider.dart';

class TournamentWinnerScreen extends StatefulWidget {
  const TournamentWinnerScreen({super.key});

  @override
  State<TournamentWinnerScreen> createState() => _TournamentWinnerScreenState();
}

class _TournamentWinnerScreenState extends State<TournamentWinnerScreen>
    with TickerProviderStateMixin {
  late AnimationController _trophyController;
  late Animation<double> _trophyScale;
  late AnimationController _starsController;
  late List<Animation<double>> _starScales = [];

  @override
  void initState() {
    super.initState();
    _trophyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _trophyScale = Tween<double>(begin: 0, end: 1.3).animate(
      CurvedAnimation(parent: _trophyController, curve: Curves.easeOutBack),
    );
    _trophyController.forward();

    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _starScales = List.generate(5, (i) {
      return Tween<double>(begin: 0, end: 1.0).animate(
        CurvedAnimation(
          parent: _starsController,
          curve: Interval(i * 0.12, i * 0.12 + 0.4, curve: Curves.easeOutBack),
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _starsController.forward();
    });
  }

  @override
  void dispose() {
    _trophyController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tournament = context.watch<TournamentProvider>();
    final winnerIdx = tournament.tournamentWinner;
    if (winnerIdx == null) return const SizedBox();

    final winner = tournament.playerScores[winnerIdx];
    final color = winner['color'] as Color;
    final wins = winner['wins'] as int;
    final totalCuts = winner['totalCuts'] as int;
    final gamesPlayed = winner['gamesPlayed'] as int;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: Stack(
        children: [
          // Glow
          Positioned(
            top: 40,
            left: MediaQuery.of(context).size.width / 2 - 120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7c3aed).withValues(alpha: 0.25),
                    const Color(0xFF7c3aed).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Trophy
                  AnimatedBuilder(
                    animation: _trophyScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _trophyScale.value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF12122a),
                        border: Border.all(color: color, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🏆', style: TextStyle(fontSize: 36)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // CHAMPION badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7c3aed),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'CHAMPION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    winner['name'] as String,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$wins wins · $totalCuts cuts · $gamesPlayed matches',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stars
                  AnimatedBuilder(
                    animation: _starsController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          return Transform.scale(
                            scale: _starScales[i].value,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3),
                              child: Text('⭐', style: TextStyle(fontSize: 22)),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Final standings
                  Text(
                    'FINAL STANDINGS',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tournament.rankings.length,
                      itemBuilder: (context, index) {
                        final pIdx = tournament.rankings[index];
                        final p = tournament.playerScores[pIdx];
                        final pColor = p['color'] as Color;
                        final pWins = p['wins'] as int;
                        final isChampion = pIdx == winnerIdx;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isChampion
                                ? const Color(0xFF1a1040)
                                : const Color(0xFF12122a),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isChampion ? color : const Color(0xFF1f1f3a),
                              width: isChampion ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: index == 0
                                      ? const Color(0xFFFBBF24).withValues(alpha: 0.2)
                                      : pColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: index == 0
                                      ? const Text('👑', style: TextStyle(fontSize: 14))
                                      : Text(
                                          '#${index + 1}',
                                          style: TextStyle(
                                            color: pColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  p['name'] as String,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: isChampion ? 1.0 : 0.7),
                                    fontSize: 14,
                                    fontWeight: isChampion ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '$pWins W',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              tournament.resetTournament();
                              Navigator.pushReplacementNamed(context, '/player_setup');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF12122a),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: Color(0xFF1f1f3a)),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'New Tournament',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              tournament.resetTournament();
                              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7c3aed),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Home',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
