import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tournament_provider.dart';

class ScoreboardScreen extends StatelessWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tournament = context.watch<TournamentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Scoreboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (tournament.isTournamentActive) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1040),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF7c3aed)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Color(0xFFFBBF24), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tournament Active',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Round ${tournament.currentRound} · Best of ${tournament.targetWins}',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/tournament_dashboard'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7c3aed),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Text(
                'ALL TIME STANDINGS',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: tournament.playerScores.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events_outlined, size: 64, color: Colors.white.withValues(alpha: 0.15)),
                            const SizedBox(height: 16),
                            Text(
                              'No scores yet',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Start a tournament to see scores',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: tournament.rankings.length,
                        itemBuilder: (context, index) {
                          final pIdx = tournament.rankings[index];
                          final player = tournament.playerScores[pIdx];
                          final color = player['color'] as Color;
                          final wins = player['wins'] as int;
                          final totalCuts = player['totalCuts'] as int;
                          final gamesPlayed = player['gamesPlayed'] as int;
                          final isChampion = tournament.tournamentWinner == pIdx;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isChampion ? const Color(0xFF1a1040) : const Color(0xFF12122a),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isChampion ? const Color(0xFF7c3aed) : const Color(0xFF1f1f3a),
                                width: isChampion ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? const Color(0xFFFBBF24).withValues(alpha: 0.2)
                                        : color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: index == 0
                                        ? const Text('👑', style: TextStyle(fontSize: 16))
                                        : Text(
                                            '#${index + 1}',
                                            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        player['name'] as String,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: isChampion ? FontWeight.bold : FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$wins wins · $totalCuts cuts · $gamesPlayed played',
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isChampion)
                                  const Icon(Icons.emoji_events, color: Color(0xFFFBBF24), size: 20),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Match history
              if (tournament.matchHistory.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'MATCH HISTORY',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tournament.matchHistory.length,
                    itemBuilder: (context, index) {
                      final match = tournament.matchHistory[tournament.matchHistory.length - 1 - index];
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12122a),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1f1f3a)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: match.winnerColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              match.winnerName,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 8),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'R${match.round}',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 8),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
