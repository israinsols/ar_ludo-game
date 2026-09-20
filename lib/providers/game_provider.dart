import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/board_data.dart';
import '../constants/colors.dart';
import '../models/game_models.dart';

class GameProvider extends ChangeNotifier {
  List<Player> players = [];
  int currentPlayerIndex = 0;
  int diceValue = 0;
  bool hasRolledDice = false;
  bool hasMovedToken = false;
  List<int> movableTokens = [];
  int winnerIndex = -1;
  List<int> finishOrder = [];
  bool gameStarted = false;
  int turnCount = 0;
  int totalCuts = 0;
  bool _capturedThisTurn = false;
  bool _tokenReachedHomeThisTurn = false;

  UndoSnapshot? _lastSnapshot;
  bool get canUndo => _lastSnapshot != null && gameSettings.undoEnabled;

  GameSettings gameSettings = GameSettings();

  List<DiceHistoryEntry> diceHistory = [];
  static const int maxDiceHistory = 5;

  final List<int> _safeZoneIndicators = [];
  List<int> get safeZoneIndicators => _safeZoneIndicators;

  final Map<int, List<int>> _movePreviews = {};
  Map<int, List<int>> get movePreviews => _movePreviews;

  int _timerRemaining = 0;
  int get timerRemaining => _timerRemaining;
  bool _timerActive = false;
  bool get timerActive => _timerActive;

  bool _capturedAnimation = false;
  bool get capturedAnimation => _capturedAnimation;

  int _consecutiveSixCount = 0;
  int get consecutiveSixCount => _consecutiveSixCount;

  bool _hasSavedGame = false;
  bool get hasSavedGame => _hasSavedGame;

  void setupPlayers(List<String> names, {List<String>? avatars, List<Color>? tokenColors}) {
    players.clear();
    finishOrder.clear();
    winnerIndex = -1;
    currentPlayerIndex = 0;
    turnCount = 0;
    totalCuts = 0;
    diceHistory.clear();
    _lastSnapshot = null;
    _consecutiveSixCount = 0;

    const startIndices = [42, 3, 29, 16];
    const exitIndices = [41, 2, 28, 15];

    const baseData = [
      BoardData.redBase,
      BoardData.blueBase,
      BoardData.greenBase,
      BoardData.yellowBase,
    ];

    final homeColData = [
      BoardData.homeColumns[0],
      BoardData.homeColumns[1],
      BoardData.homeColumns[2],
      BoardData.homeColumns[3],
    ];

    for (int i = 0; i < names.length; i++) {
      final tokens = List.generate(4, (j) => PlayerToken(id: j));
      players.add(Player(
        id: i,
        name: names[i].isEmpty ? LudoColors.playerName(i) : names[i],
        color: LudoColors.playerColor(i),
        darkColor: LudoColors.playerDimColor(i),
        tokens: tokens,
        startIndex: startIndices[i],
        exitIndex: exitIndices[i],
        basePositions: baseData[i].map((e) => List<double>.from(e)).toList(),
        homeColumn: homeColData[i].map((e) => List<int>.from(e)).toList(),
        avatar: avatars != null && i < avatars.length ? avatars[i] : '',
        tokenColor: tokenColors != null && i < tokenColors.length ? tokenColors[i] : null,
      ));
    }
    gameStarted = true;
    notifyListeners();
  }

  GameProvider() {
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSavedGame = prefs.containsKey('lastGameKey');
    notifyListeners();
  }

  Player get currentPlayer => players[currentPlayerIndex];

  void rollDice() {
    if (hasRolledDice) return;

    final rng = Random();
    diceValue = rng.nextInt(6) + 1;
    hasRolledDice = true;
    hasMovedToken = false;

    if (diceValue == 6) {
      _consecutiveSixCount++;
      currentPlayer.consecutiveSixes++;
      if (gameSettings.threeSixesSkip && currentPlayer.consecutiveSixes >= 3) {
        currentPlayer.consecutiveSixes = 0;
        _consecutiveSixCount = 0;
        endTurn();
        return;
      }
    } else {
      currentPlayer.consecutiveSixes = 0;
      _consecutiveSixCount = 0;
    }

    calculateMovableTokens();

    if (gameSettings.timerMode) {
      _startTimer();
    }

    notifyListeners();
  }

  void _addToDiceHistory(int value) {
    diceHistory.insert(0, DiceHistoryEntry(
      playerId: currentPlayerIndex,
      value: value,
      playerName: currentPlayer.name,
    ));
    if (diceHistory.length > maxDiceHistory) {
      diceHistory.removeLast();
    }
  }

  void addToDiceHistory() {
    _addToDiceHistory(diceValue);
    notifyListeners();
  }

  void calculatePreviewsAfterDice() {
    _calculateSafeZones();
    _calculateMovePreviews();
    notifyListeners();
  }

  void _calculateSafeZones() {
    _safeZoneIndicators.clear();
    if (movableTokens.isEmpty) return;

    final player = currentPlayer;
    for (var tokenId in movableTokens) {
      final token = player.tokens.firstWhere((t) => t.id == tokenId);
      if (token.state == TokenState.mainPath) {
        final distance = BoardData.getDistanceFromStart(token.pathIndex, player.startIndex);
        final newDistance = distance + diceValue;
        if (newDistance < BoardData.mainPathLength) {
          final newPos = BoardData.getPositionAtDistance(player.startIndex, newDistance);
          if (BoardData.isSafePosition(newPos)) {
            _safeZoneIndicators.add(newPos);
          }
        }
      }
    }
  }

  void _calculateMovePreviews() {
    _movePreviews.clear();
    final player = currentPlayer;

    for (var tokenId in movableTokens) {
      final token = player.tokens.firstWhere((t) => t.id == tokenId);
      List<int> path = [];

      switch (token.state) {
        case TokenState.base:
          if (diceValue == 6) {
            path = [player.startIndex];
          }
          break;
        case TokenState.mainPath:
          final distance = BoardData.getDistanceFromStart(token.pathIndex, player.startIndex);
          final newDistance = distance + diceValue;
          if (newDistance < BoardData.mainPathLength) {
            for (int d = 1; d <= diceValue; d++) {
              path.add(BoardData.getPositionAtDistance(player.startIndex, distance + d));
            }
          } else if (newDistance == BoardData.mainPathLength) {
            for (int d = 1; d <= diceValue; d++) {
              final pos = BoardData.getPositionAtDistance(player.startIndex, distance + d);
              path.add(pos);
            }
          } else if (newDistance < BoardData.mainPathLength + BoardData.homeColumnLength) {
            for (int d = 1; d <= diceValue; d++) {
              final pos = BoardData.getPositionAtDistance(player.startIndex, distance + d);
              path.add(pos);
            }
          }
          break;
        case TokenState.homeColumn:
          for (int d = 1; d <= diceValue; d++) {
            path.add(-1);
          }
          break;
        case TokenState.home:
          break;
      }
      if (path.isNotEmpty) {
        _movePreviews[tokenId] = path;
      }
    }
  }

  void _startTimer() {
    _timerRemaining = gameSettings.timerSeconds;
    _timerActive = true;
    notifyListeners();
  }

  void tickTimer() {
    if (!_timerActive || _timerRemaining <= 0) return;
    _timerRemaining--;
    if (_timerRemaining <= 0) {
      _timerActive = false;
      if (hasRolledDice && !hasMovedToken) {
        endTurn();
      }
    }
    notifyListeners();
  }

  void stopTimer() {
    _timerActive = false;
    notifyListeners();
  }

  void calculateMovableTokens() {
    movableTokens.clear();
    final player = currentPlayer;

    for (var token in player.tokens) {
      switch (token.state) {
        case TokenState.base:
          if (diceValue == 6) {
            movableTokens.add(token.id);
          }
          break;
        case TokenState.mainPath:
          final distance =
              BoardData.getDistanceFromStart(token.pathIndex, player.startIndex);
          final newDistance = distance + diceValue;

          if (newDistance < BoardData.mainPathLength) {
            movableTokens.add(token.id);
          } else if (newDistance == BoardData.mainPathLength) {
            movableTokens.add(token.id);
          } else if (newDistance <
              BoardData.mainPathLength + BoardData.homeColumnLength) {
            movableTokens.add(token.id);
          }
          break;
        case TokenState.homeColumn:
          final newIdx = token.homeColumnIndex + diceValue;
          if (newIdx <= BoardData.homeColumnLength) {
            movableTokens.add(token.id);
          }
          break;
        case TokenState.home:
          break;
      }
    }
  }

  int moveToken(int tokenId) {
    if (!hasRolledDice || !movableTokens.contains(tokenId)) return -1;

    _saveUndoSnapshot();

    final player = currentPlayer;
    final token = player.tokens.firstWhere((t) => t.id == tokenId);

    switch (token.state) {
      case TokenState.base:
        if (diceValue == 6) {
          token.state = TokenState.mainPath;
          token.pathIndex = player.startIndex;
          checkCapture(player, token);
          hasMovedToken = true;
          movableTokens.clear();
          _triggerHaptic();
        }
        break;

      case TokenState.mainPath:
        final distance =
            BoardData.getDistanceFromStart(token.pathIndex, player.startIndex);
        final newDistance = distance + diceValue;

        if (newDistance < BoardData.mainPathLength) {
          token.pathIndex =
              BoardData.getPositionAtDistance(player.startIndex, newDistance);
          checkCapture(player, token);
          hasMovedToken = true;
          movableTokens.clear();
        } else if (newDistance == BoardData.mainPathLength) {
          token.state = TokenState.homeColumn;
          token.homeColumnIndex = 0;
          token.pathIndex = -1;
          hasMovedToken = true;
          movableTokens.clear();
        } else if (newDistance <
            BoardData.mainPathLength + BoardData.homeColumnLength) {
          token.state = TokenState.homeColumn;
          token.homeColumnIndex = newDistance - BoardData.mainPathLength;
          token.pathIndex = -1;
          hasMovedToken = true;
          movableTokens.clear();
        }
        break;

      case TokenState.homeColumn:
        final newIdx = token.homeColumnIndex + diceValue;
        if (newIdx < BoardData.homeColumnLength) {
          token.homeColumnIndex = newIdx;
        } else if (newIdx == BoardData.homeColumnLength) {
          token.state = TokenState.home;
          _tokenReachedHomeThisTurn = true;
          _triggerHaptic();
        }
        hasMovedToken = true;
        movableTokens.clear();
        break;

      case TokenState.home:
        break;
    }

    if (player.allTokensHome && winnerIndex == -1) {
      winnerIndex = player.id;
      finishOrder.add(player.id);
      player.isFinished = true;
      _triggerHaptic();
      notifyListeners();
      return 2;
    }

    _safeZoneIndicators.clear();
    _movePreviews.clear();
    notifyListeners();

    if ((diceValue == 6 || _capturedThisTurn || _tokenReachedHomeThisTurn) && hasMovedToken && !player.allTokensHome) {
      final wasCapture = _capturedThisTurn;
      _capturedThisTurn = false;
      _tokenReachedHomeThisTurn = false;
      hasRolledDice = false;
      _consecutiveSixCount = diceValue == 6 ? _consecutiveSixCount : 0;
      if (wasCapture) {
        player.consecutiveSixes = 0;
      }
      notifyListeners();
      return 1;
    }

    return 0;
  }

  void _triggerHaptic() {
    HapticFeedback.heavyImpact();
  }

  void checkCapture(Player movingPlayer, PlayerToken movedToken) {
    if (BoardData.isSafePosition(movedToken.pathIndex)) return;

    bool captured = false;
    for (var otherPlayer in players) {
      if (otherPlayer.id == movingPlayer.id) continue;
      for (var otherToken in otherPlayer.tokens) {
        if (otherToken.state == TokenState.mainPath &&
            otherToken.pathIndex == movedToken.pathIndex) {
          otherToken.state = TokenState.base;
          otherToken.pathIndex = -1;
          totalCuts++;
          _capturedThisTurn = true;
          captured = true;
        }
      }
    }

    if (captured) {
      _capturedAnimation = true;
      _triggerHaptic();
      Future.delayed(const Duration(milliseconds: 500), () {
        _capturedAnimation = false;
        notifyListeners();
      });
    }
  }

  void _saveUndoSnapshot() {
    if (!gameSettings.undoEnabled) return;
    _lastSnapshot = UndoSnapshot(
      playerId: currentPlayerIndex,
      tokenStates: currentPlayer.tokens.map((t) => t.copy()).toList(),
      diceValue: diceValue,
      capturedThisTurn: _capturedThisTurn,
    );
  }

  bool undoLastMove() {
    if (_lastSnapshot == null || !gameSettings.undoEnabled) return false;

    final snapshot = _lastSnapshot!;
    final player = players[snapshot.playerId];

    for (int i = 0; i < player.tokens.length; i++) {
      player.tokens[i].state = snapshot.tokenStates[i].state;
      player.tokens[i].pathIndex = snapshot.tokenStates[i].pathIndex;
      player.tokens[i].homeColumnIndex = snapshot.tokenStates[i].homeColumnIndex;
    }

    diceValue = snapshot.diceValue;
    _capturedThisTurn = snapshot.capturedThisTurn;
    hasMovedToken = false;
    hasRolledDice = true;
    currentPlayerIndex = snapshot.playerId;

    calculateMovableTokens();
    _calculateSafeZones();
    _calculateMovePreviews();

    _lastSnapshot = null;
    notifyListeners();
    return true;
  }

  void endTurn() {
    _stopTimerInternal();
    hasRolledDice = false;
    hasMovedToken = false;
    _capturedThisTurn = false;
    _tokenReachedHomeThisTurn = false;
    _lastSnapshot = null;
    _safeZoneIndicators.clear();
    _movePreviews.clear();
    movableTokens.clear();
    diceValue = 0;
    turnCount++;

    int nextIndex = (currentPlayerIndex + 1) % players.length;
    int attempts = 0;
    while (players[nextIndex].isFinished && attempts < players.length) {
      nextIndex = (nextIndex + 1) % players.length;
      attempts++;
    }
    currentPlayerIndex = nextIndex;

    notifyListeners();
  }

  void _stopTimerInternal() {
    _timerActive = false;
  }

  void updateSettings(GameSettings settings) {
    gameSettings = settings;
    notifyListeners();
  }

  static const String _saveKey = 'ludo_saved_game';

  Future<void> saveGame() async {
    if (players.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final gameData = {
        'players': players.map((p) => p.toJson()).toList(),
        'currentPlayerIndex': currentPlayerIndex,
        'turnCount': turnCount,
        'totalCuts': totalCuts,
        'winnerIndex': winnerIndex,
        'finishOrder': finishOrder,
        'gameSettings': gameSettings.toJson(),
      };
      await prefs.setString(_saveKey, jsonEncode(gameData));
      _hasSavedGame = true;
      notifyListeners();
    } catch (e) {
      // save failed silently
    }
  }

  Future<bool> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_saveKey);
      if (dataStr == null || dataStr.isEmpty) {
        _hasSavedGame = false;
        return false;
      }

      final data = jsonDecode(dataStr) as Map<String, dynamic>;
      final playersList = data['players'] as List?;
      if (playersList == null || playersList.isEmpty) {
        _hasSavedGame = false;
        return false;
      }

      final playersData = <Player>[];
      for (var p in playersList) {
        final id = p['id'] as int;
        final color = LudoColors.playerColor(id);
        final darkColor = LudoColors.playerDimColor(id);
        const startIndices = [42, 3, 29, 16];
        const exitIndices = [41, 2, 28, 15];
        const baseData = [
          BoardData.redBase, BoardData.blueBase,
          BoardData.greenBase, BoardData.yellowBase,
        ];
        final homeColData = BoardData.homeColumns;
        playersData.add(Player.fromJson(p,
          color: color,
          darkColor: darkColor,
          startIndex: startIndices[id],
          exitIndex: exitIndices[id],
          basePositions: baseData[id].map((e) => List<double>.from(e)).toList(),
          homeColumn: homeColData[id].map((e) => List<int>.from(e)).toList(),
        ));
      }

      players = playersData;
      currentPlayerIndex = data['currentPlayerIndex'] ?? 0;
      turnCount = data['turnCount'] ?? 0;
      totalCuts = data['totalCuts'] ?? 0;
      winnerIndex = data['winnerIndex'] ?? -1;
      finishOrder = List<int>.from(data['finishOrder'] ?? []);
      gameSettings = GameSettings.fromJson(data['gameSettings'] ?? {});
      hasRolledDice = false;
      hasMovedToken = false;
      movableTokens.clear();
      diceValue = 0;
      gameStarted = true;
      _hasSavedGame = true;
      notifyListeners();
      return true;
    } catch (e) {
      _hasSavedGame = false;
      return false;
    }
  }

  Future<void> deleteSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
    _hasSavedGame = false;
  }

  void resetGame() {
    players.clear();
    currentPlayerIndex = 0;
    diceValue = 0;
    hasRolledDice = false;
    hasMovedToken = false;
    movableTokens.clear();
    winnerIndex = -1;
    finishOrder.clear();
    gameStarted = false;
    turnCount = 0;
    totalCuts = 0;
    _lastSnapshot = null;
    diceHistory.clear();
    _safeZoneIndicators.clear();
    _movePreviews.clear();
    _timerActive = false;
    _timerRemaining = 0;
    _capturedAnimation = false;
    _consecutiveSixCount = 0;
    deleteSavedGame();
    notifyListeners();
  }
}
