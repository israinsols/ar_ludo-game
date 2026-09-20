import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

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
                    'Settings',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSettingCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          settings.soundEnabled ? Icons.volume_up : Icons.volume_off,
                          color: const Color(0xFF7c3aed),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Sound Effects',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    Switch(
                      value: settings.soundEnabled,
                      onChanged: (_) => settings.toggleSound(),
                      activeThumbColor: const Color(0xFF7c3aed),
                      inactiveTrackColor: const Color(0xFF1a1a35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'About',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ludo Game',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Offline Multiplayer Ludo',
                      style: TextStyle(color: Color(0xFF8888AA), fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(color: Color(0xFF555577), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/privacy_policy'),
                  behavior: HitTestBehavior.opaque,
                  child: const Row(
                    children: [
                      Icon(Icons.privacy_tip_outlined, color: Color(0xFF7c3aed), size: 22),
                      SizedBox(width: 12),
                      Text(
                        'Privacy Policy',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right, color: Color(0xFF555577), size: 22),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF12122a),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1f1f3a)),
      ),
      child: child,
    );
  }
}
