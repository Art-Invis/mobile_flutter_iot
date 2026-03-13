import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/widgets/blur_blob.dart'; // Використання винесеного BlurBlob
import 'package:mobile_flutter_iot/widgets/fan_widget.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/tech_node.dart'; // Імпорт нового віджета

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSystemOn = true;

  void _toggleSystemPower() {
    setState(() => _isSystemOn = !_isSystemOn);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSystemOn ? 'SYSTEM INITIALIZED' : 'SYSTEM SHUTDOWN'),
        backgroundColor: _isSystemOn
            ? const Color(0xFF38BDF8)
            : Colors.redAccent,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: BlurBlob(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
              size: 200,
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: BlurBlob(
              color: const Color(0xFF4ADE80).withValues(alpha: 0.05),
              size: 250,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'SYSTEM SCHEMATIC',
                  style: TextStyle(
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: GlassCard(
                      width: 320,
                      height: 500,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildConnectionLine(),
                          _buildVentilationUnit(),
                          _buildIlluminationUnit(),
                          _buildPowerButton(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildStatusText(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionLine() {
    return Positioned(
      top: 100,
      bottom: 100,
      child: Container(width: 1, color: Colors.white10),
    );
  }

  Widget _buildVentilationUnit() {
    return Positioned(
      top: 40,
      child: TechNode(
        label: 'VENTILATION UNIT',
        accentColor: _isSystemOn ? const Color(0xFF38BDF8) : Colors.transparent,
        child: _isSystemOn
            ? const RotatingFan(size: 100)
            : const Icon(Icons.cyclone, size: 100, color: Colors.white10),
      ),
    );
  }

  Widget _buildIlluminationUnit() {
    return Positioned(
      bottom: 60,
      child: TechNode(
        label: 'ILLUMINATION',
        accentColor: _isSystemOn ? Colors.yellow : Colors.transparent,
        child: Icon(
          Icons.lightbulb,
          size: 70,
          color: _isSystemOn ? Colors.yellow : Colors.white10,
        ),
      ),
    );
  }

  Widget _buildPowerButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTap: _toggleSystemPower,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isSystemOn
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.white10,
            boxShadow: _isSystemOn
                ? [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            Icons.power_settings_new,
            color: _isSystemOn ? Colors.redAccent : Colors.white38,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    return Text(
      _isSystemOn ? 'LIVE SYSTEM PREVIEW' : 'SYSTEM OFFLINE',
      style: TextStyle(
        letterSpacing: 2,
        color: _isSystemOn ? Colors.white24 : Colors.red.withValues(alpha: 0.3),
        fontSize: 10,
      ),
    );
  }
}
