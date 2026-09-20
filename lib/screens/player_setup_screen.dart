import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int playerCount = 3;
  final List<TextEditingController> nameControllers =
      List.generate(4, (_) => TextEditingController());
  final List<int> _selectedColors = [0, 1, 2, 3]; // indices into colorOptions
  final List<bool> _editing = List.generate(4, (_) => false);
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  static const List<Color> _colorOptions = [
    Color(0xFFFF173B), // Red
    Color(0xFF33A0FF), // Blue
    Color(0xFF12E362), // Green
    Color(0xFFFFBB12), // Yellow
    Color(0xFFF472B6), // Pink
    Color(0xFFA78BFA), // Purple
    Color(0xFF38BDF8), // Cyan
    Color(0xFFFB923C), // Orange
    Color(0xFF34D399), // Teal
    Color(0xFFF87171), // Coral
  ];

  bool _timerMode = false;
  int _timerSeconds = 30;
  bool _quickMode = false;
  bool _captureBonus = true;
  bool _threeSixesSkip = true;
  bool _undoEnabled = true;
  bool _tournamentMode = false;
  int _targetWins = 3;

  @override
  void dispose() {
    for (var c in nameControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _toggleEdit(int index) {
    setState(() {
      _editing[index] = !_editing[index];
    });
    if (_editing[index]) {
      _focusNodes[index].requestFocus();
    }
  }

  void _showColorPicker(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12122a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Token Color',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(_colorOptions.length, (i) {
                  final color = _colorOptions[i];
                  final isSelected = _selectedColors[index] == i;
                  final isTaken = _selectedColors.asMap().entries
                      .any((e) => e.key != index && e.value == i);
                  return GestureDetector(
                    onTap: isTaken ? null : () {
                      setState(() => _selectedColors[index] = i);
                      setModalState(() {});
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : isTaken
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.transparent,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 22)
                          : isTaken
                              ? Icon(Icons.lock, color: Colors.white.withValues(alpha: 0.3), size: 16)
                              : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Players',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // const SizedBox(height: 6),
              // Text(
              //   'Kitne log khelenge?',
              //   style: TextStyle(
              //     fontSize: 15,
              //     color: Colors.white.withValues(alpha: 0.5),
              //   ),
              // ),
              const SizedBox(height: 20),
              Row(
                children: [2, 3, 4].map((count) {
                  final isSelected = playerCount == count;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => playerCount = count),
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF7c3aed)
                              : const Color(0xFF12122a),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF7c3aed)
                                : const Color(0xFF1f1f3a),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ...List.generate(playerCount, (index) {
                final defaultName = LudoColors.playerName(index);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12122a),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1f1f3a)),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showColorPicker(index),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: _colorOptions[_selectedColors[index]],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _editing[index]
                            ? TextField(
                                controller: nameControllers[index],
                                focusNode: _focusNodes[index],
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: defaultName,
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onSubmitted: (_) => _toggleEdit(index),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Text(
                                  nameControllers[index].text.isEmpty
                                      ? defaultName
                                      : nameControllers[index].text,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleEdit(index),
                        child: Icon(
                          _editing[index] ? Icons.check : Icons.edit,
                          color: Colors.white.withValues(alpha: 0.2),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              _buildGameOptions(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final names = List.generate(
                      playerCount,
                      (i) => nameControllers[i].text,
                    );
                    final colors = _selectedColors.sublist(0, playerCount)
                        .map((i) => _colorOptions[i])
                        .toList();
                    final settings = GameSettings(
                      timerMode: _timerMode,
                      timerSeconds: _timerSeconds,
                      quickMode: _quickMode,
                      captureBonus: _captureBonus,
                      threeSixesSkip: _threeSixesSkip,
                      undoEnabled: _undoEnabled,
                    );
                    context.read<GameProvider>().updateSettings(settings);
                    context.read<GameProvider>().setupPlayers(
                      names,
                      tokenColors: colors,
                    );

                    if (_tournamentMode) {
                      Navigator.pushReplacementNamed(context, '/tournament_setup');
                    } else {
                      Navigator.pushReplacementNamed(context, '/game_board');
                    }
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
                    'Start game',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOptions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12122a),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1f1f3a)),
      ),
      child: Column(
        children: [
          _buildSwitch('Timer Mode', _timerMode, (v) => setState(() => _timerMode = v)),
          if (_timerMode)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Text(
                    'Timer: ',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                  ),
                  ...[15, 30, 45, 60].map((s) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _timerSeconds = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _timerSeconds == s
                              ? const Color(0xFF7c3aed)
                              : const Color(0xFF1a1a35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${s}s',
                          style: TextStyle(
                            color: _timerSeconds == s
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          _buildSwitch('Quick Mode', _quickMode, (v) => setState(() => _quickMode = v)),
          _buildSwitch('Capture Bonus', _captureBonus, (v) => setState(() => _captureBonus = v)),
          _buildSwitch('3 Sixes Skip', _threeSixesSkip, (v) => setState(() => _threeSixesSkip = v)),
          _buildSwitch('Allow Undo', _undoEnabled, (v) => setState(() => _undoEnabled = v)),
          _buildSwitch('Tournament Mode', _tournamentMode, (v) => setState(() => _tournamentMode = v)),
          if (_tournamentMode)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Text(
                    'Best of: ',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                  ),
                  ...[3, 5, 7].map((w) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _targetWins = w),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _targetWins == w
                              ? const Color(0xFF7c3aed)
                              : const Color(0xFF1a1a35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$w',
                          style: TextStyle(
                            color: _targetWins == w
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
                    Switch(
                      value: value,
                      onChanged: onChanged,
                      activeThumbColor: const Color(0xFF7c3aed),
                      inactiveTrackColor: const Color(0xFF1a1a35),
                    ),
        ],
      ),
    );
  }
}
