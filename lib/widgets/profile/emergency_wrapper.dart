import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_flashlight/iot_flashlight.dart';
import 'package:mobile_flutter_iot/cubits/profile_cubit.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';
import 'package:mobile_flutter_iot/widgets/profile/override_background.dart';
import 'package:mobile_flutter_iot/widgets/profile/profile_header.dart';
import 'package:mobile_flutter_iot/widgets/profile/profile_settings.dart';
import 'package:mobile_flutter_iot/widgets/profile/warning_dialog.dart';

class EmergencyOverrideWrapper extends StatefulWidget {
  final ProfileState profileState;
  final bool isLoggedIn;

  const EmergencyOverrideWrapper({
    required this.profileState,
    required this.isLoggedIn,
    super.key,
  });

  @override
  State<EmergencyOverrideWrapper> createState() =>
      _EmergencyOverrideWrapperState();
}

class _EmergencyOverrideWrapperState extends State<EmergencyOverrideWrapper> {
  int _tapCount = 0;
  DateTime? _lastTapTime;
  bool _isOverrideActive = false;

  void _handleSecretTap() async {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(milliseconds: 500)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;

    if (_tapCount == 5) {
      _tapCount = 0;
      try {
        final isOn = await IotFlashlight.toggle();

        debugPrint('\n=========================================');
        debugPrint('🔦 [IOT_FLASHLIGHT_PLUGIN] Triggered!');
        debugPrint('- Hardware Flashlight State: ${isOn ? "ON" : "OFF"}');
        debugPrint('=========================================\n');

        if (mounted) {
          context.read<ApiService>().saveLog(
                'HARDWARE_OVERRIDE',
                'Physical optical emitter toggled.'
                    'State: ${isOn ? "ON" : "OFF"}',
              );
        }

        setState(() => _isOverrideActive = isOn);

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isOn
                    ? '🔦 OVERRIDE: HARDWARE LIGHT ACTIVE '
                    : '✅ SYSTEM NORMALIZED: LIGHT OFF',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              backgroundColor:
                  isOn ? Colors.redAccent : const Color(0xFF4ADE80),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (e.toString().contains('UNSUPPORTED_PLATFORM') && mounted) {
          PlatformWarningDialog.show(context);
        } else {
          debugPrint('🔦 [FLASHLIGHT ERROR]: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          OverrideBackground(isOverrideActive: _isOverrideActive),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 100,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    _isOverrideActive ? 'SYSTEM OVERRIDE' : 'USER PROFILE',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          _isOverrideActive ? Colors.redAccent : Colors.white,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    GestureDetector(
                      onTap: _handleSecretTap,
                      behavior: HitTestBehavior.opaque,
                      child: ProfileHeader(state: widget.profileState),
                    ),
                    const SizedBox(height: 32),
                    ProfileSettings(
                      state: widget.profileState,
                      isLoggedIn: widget.isLoggedIn,
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
