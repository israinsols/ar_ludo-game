import 'package:flutter/material.dart';

class MatchResult {
  final int round;
  final int winnerIndex;
  final String winnerName;
  final Color winnerColor;
  final int turns;
  final int cuts;

  MatchResult({
    required this.round,
    required this.winnerIndex,
    required this.winnerName,
    required this.winnerColor,
    required this.turns,
    required this.cuts,
  });
}

class TournamentProvider extends ChangeNotifier {
  int _targetWins = 3;
  int get targetWins => _targetWins;

  List<Map<String, dynamic>> _playerScores = [];
  List<Map<String, dynamic>> get playerScores => _playerScores;

  bool _isTournamentActive = false;
  bool get isTournamentActive => _isTournamentActive;

  int _currentRound = 0;
  int get currentRound => _currentRound;

  final List<MatchResult> _matchHistory = [];
  List<MatchResult> get matchHistory => _matchHistory;

  int _totalMatches = 0;
  int get totalMatches => _totalMatches;

  List<String> _playerNames = [];
  List<Color> _playerColors = [];

  void startTournament(List<String> names, List<Color> colors, {int targetWins = 3}) {
    _targetWins = targetWins;
    _isTournamentActive = true;
    _currentRound = 1;
    _totalMatches = 0;
    _matchHistory.clear();
    _playerNames = List.from(names);
    _playerColors = List.from(colors);
    _playerScores = List.generate(
      names.length,
      (i) => {
        'name': names[i],
        'color': colors[i],
        'wins': 0,
        'totalTurns': 0,
        'totalCuts': 0,
        'gamesPlayed': 0,
      },
    );
    notifyListeners();
  }

  void recordWin(int winnerIndex, {int turns = 0, int cuts = 0}) {
    if (!_isTournamentActive) return;

    _playerScores[winnerIndex]['wins']++;
    _playerScores[winnerIndex]['totalTurns'] += turns;
    _playerScores[winnerIndex]['totalCuts'] += cuts;
    _playerScores[winnerIndex]['gamesPlayed']++;

    for (int i = 0; i < _playerScores.length; i++) {
      if (i != winnerIndex) {
        _playerScores[i]['gamesPlayed']++;
      }
    }

    _matchHistory.add(MatchResult(
      round: _currentRound,
      winnerIndex: winnerIndex,
      winnerName: _playerScores[winnerIndex]['name'],
      winnerColor: _playerScores[winnerIndex]['color'],
      turns: turns,
      cuts: cuts,
    ));

    _totalMatches++;
    _currentRound++;

    if (_playerScores[winnerIndex]['wins'] >= _targetWins) {
      _isTournamentActive = false;
    }
    notifyListeners();
  }

  int? get tournamentWinner {
    for (int i = 0; i < _playerScores.length; i++) {
      if (_playerScores[i]['wins'] >= _targetWins) return i;
    }
    return null;
  }

  List<int> get rankings {
    final sorted = List<int>.generate(_playerScores.length, (i) => i);
    sorted.sort((a, b) {
      final winsA = _playerScores[a]['wins'] as int;
      final winsB = _playerScores[b]['wins'] as int;
      if (winsB != winsA) return winsB.compareTo(winsA);
      final cutsA = _playerScores[a]['totalCuts'] as int;
      final cutsB = _playerScores[b]['totalCuts'] as int;
      return cutsB.compareTo(cutsA);
    });
    return sorted;
  }

  void resetTournament() {
    _isTournamentActive = false;
    _playerScores.clear();
    _matchHistory.clear();
    _currentRound = 0;
    _totalMatches = 0;
    _playerNames.clear();
    _playerColors.clear();
    notifyListeners();
  }
}
