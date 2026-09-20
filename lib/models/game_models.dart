import 'package:flutter/material.dart';

enum TokenState { base, mainPath, homeColumn, home }

class PlayerToken {
  final int id;
  TokenState state;
  int pathIndex;
  int homeColumnIndex;

  PlayerToken({
    required this.id,
    this.state = TokenState.base,
    this.pathIndex = -1,
    this.homeColumnIndex = -1,
  });

  PlayerToken copy() {
    return PlayerToken(
      id: id,
      state: state,
      pathIndex: pathIndex,
      homeColumnIndex: homeColumnIndex,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'state': state.index,
    'pathIndex': pathIndex,
    'homeColumnIndex': homeColumnIndex,
  };

  factory PlayerToken.fromJson(Map<String, dynamic> json) => PlayerToken(
    id: json['id'],
    state: TokenState.values[json['state']],
    pathIndex: json['pathIndex'],
    homeColumnIndex: json['homeColumnIndex'],
  );
}

class Player {
  final int id;
  final String name;
  final Color color;
  final Color darkColor;
  Color tokenColor;
  final List<PlayerToken> tokens;
  final int startIndex;
  final int exitIndex;
  final List<List<double>> basePositions;
  final List<List<int>> homeColumn;
  int consecutiveSixes;
  bool isFinished;
  String avatar;
  int score;

  Player({
    required this.id,
    required this.name,
    required this.color,
    required this.darkColor,
    required this.tokens,
    required this.startIndex,
    required this.exitIndex,
    required this.basePositions,
    required this.homeColumn,
    this.consecutiveSixes = 0,
    this.isFinished = false,
    this.avatar = '',
    this.score = 0,
    Color? tokenColor,
  }) : tokenColor = tokenColor ?? color;

  int get finishedTokens => tokens.where((t) => t.state == TokenState.home).length;

  bool get allTokensHome => tokens.every((t) => t.state == TokenState.home);

  List<PlayerToken> get tokensOnPath =>
      tokens.where((t) => t.state == TokenState.mainPath).toList();

  List<PlayerToken> get tokensInBase =>
      tokens.where((t) => t.state == TokenState.base).toList();

  List<PlayerToken> get tokensInHomeColumn =>
      tokens.where((t) => t.state == TokenState.homeColumn).toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'consecutiveSixes': consecutiveSixes,
    'isFinished': isFinished,
    'avatar': avatar,
    'score': score,
    'tokens': tokens.map((t) => t.toJson()).toList(),
    'tokenColor': tokenColor.toARGB32(),
  };

  factory Player.fromJson(Map<String, dynamic> json, {
    required Color color,
    required Color darkColor,
    required int startIndex,
    required int exitIndex,
    required List<List<double>> basePositions,
    required List<List<int>> homeColumn,
  }) => Player(
    id: json['id'],
    name: json['name'],
    color: color,
    darkColor: darkColor,
    tokens: (json['tokens'] as List).map((t) => PlayerToken.fromJson(t)).toList(),
    startIndex: startIndex,
    exitIndex: exitIndex,
    basePositions: basePositions,
    homeColumn: homeColumn,
    consecutiveSixes: json['consecutiveSixes'] ?? 0,
    isFinished: json['isFinished'] ?? false,
    avatar: json['avatar'] ?? '',
    score: json['score'] ?? 0,
    tokenColor: json['tokenColor'] != null ? Color(json['tokenColor']) : null,
  );
}

class UndoSnapshot {
  final int playerId;
  final List<PlayerToken> tokenStates;
  final int diceValue;
  final bool capturedThisTurn;

  UndoSnapshot({
    required this.playerId,
    required this.tokenStates,
    required this.diceValue,
    required this.capturedThisTurn,
  });
}

class DiceHistoryEntry {
  final int playerId;
  final int value;
  final String playerName;

  DiceHistoryEntry({
    required this.playerId,
    required this.value,
    required this.playerName,
  });
}

class GameSettings {
  bool timerMode;
  int timerSeconds;
  bool quickMode;
  bool captureBonus;
  bool threeSixesSkip;
  bool undoEnabled;

  GameSettings({
    this.timerMode = false,
    this.timerSeconds = 30,
    this.quickMode = false,
    this.captureBonus = true,
    this.threeSixesSkip = true,
    this.undoEnabled = true,
  });

  Map<String, dynamic> toJson() => {
    'timerMode': timerMode,
    'timerSeconds': timerSeconds,
    'quickMode': quickMode,
    'captureBonus': captureBonus,
    'threeSixesSkip': threeSixesSkip,
    'undoEnabled': undoEnabled,
  };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
    timerMode: json['timerMode'] ?? false,
    timerSeconds: json['timerSeconds'] ?? 30,
    quickMode: json['quickMode'] ?? false,
    captureBonus: json['captureBonus'] ?? true,
    threeSixesSkip: json['threeSixesSkip'] ?? true,
    undoEnabled: json['undoEnabled'] ?? true,
  );
}
