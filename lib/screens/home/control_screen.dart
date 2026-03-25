import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/widgets/blur_blob.dart';
import 'package:mobile_flutter_iot/widgets/control_title.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/primary_button.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool _isLightOn = true;
  double _brightness = 0.7;
  bool _isAcOn = true;
  bool _isVentOn = false;

  void _emergencyShutdown() {
    setState(() {
      _isLightOn = false;
      _isAcOn = false;
      _isVentOn = false;
      _brightness = 0.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚠️ EMERGENCY SHUTDOWN ACTIVATED'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BlurBlob(
            alignment: Alignment.bottomCenter,
            translation: const Offset(0, 0.5),
            color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
            size: 250,
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'MANUAL CONTROL',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Lighting System',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    _buildLightingCard(),
                    const SizedBox(height: 32),
                    const Text(
                      'Climate Control',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ControlTile(
                            title: 'AC Unit',
                            icon: Icons.ac_unit,
                            isOn: _isAcOn,
                            onTap: () => setState(() => _isAcOn = !_isAcOn),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ControlTile(
                            title: 'Ventilation',
                            icon: Icons.air,
                            isOn: _isVentOn,
                            onTap: () => setState(() => _isVentOn = !_isVentOn),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    PrimaryButton(
                      text: 'EMERGENCY SHUTDOWN',
                      onPressed: _emergencyShutdown,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightingCard() {
    return GlassCard(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              _isLightOn ? Icons.light_mode : Icons.light_mode_outlined,
              color: _isLightOn ? Colors.amber : Colors.white24,
            ),
            title: const Text('Main Office Light'),
            trailing: Switch(
              value: _isLightOn,
              activeThumbColor: const Color(0xFF38BDF8),
              onChanged: (v) => setState(() => _isLightOn = v),
            ),
          ),
          Slider(
            value: _brightness,
            activeColor: const Color(0xFF38BDF8),
            onChanged:
                _isLightOn ? (v) => setState(() => _brightness = v) : null,
          ),
        ],
      ),
    );
  }
}
