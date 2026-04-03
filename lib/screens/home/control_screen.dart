import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/control_cubit.dart';
import 'package:mobile_flutter_iot/widgets/blur_blob.dart';
import 'package:mobile_flutter_iot/widgets/control_title.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/primary_button.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ControlCubit(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<ControlCubit, ControlState>(
            listener: (context, state) {
              if (state.isEmergencyTriggered) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ EMERGENCY SHUTDOWN ACTIVATED'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            builder: (context, state) {
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
                              _buildLightingCard(context, state),
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
                                      isOn: state.isAcOn,
                                      onTap: () => context
                                          .read<ControlCubit>()
                                          .toggleAc(!state.isAcOn),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ControlTile(
                                      title: 'Ventilation',
                                      icon: Icons.air,
                                      isOn: state.isVentOn,
                                      onTap: () => context
                                          .read<ControlCubit>()
                                          .toggleVent(!state.isVentOn),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 48),
                              PrimaryButton(
                                text: 'EMERGENCY SHUTDOWN',
                                onPressed: () => context
                                    .read<ControlCubit>()
                                    .emergencyShutdown(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLightingCard(BuildContext context, ControlState state) {
    return GlassCard(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              state.isLightOn ? Icons.light_mode : Icons.light_mode_outlined,
              color: state.isLightOn ? Colors.amber : Colors.white24,
            ),
            title: const Text('Main Office Light'),
            trailing: Switch(
              value: state.isLightOn,
              activeThumbColor: const Color(0xFF38BDF8),
              onChanged: (v) => context.read<ControlCubit>().toggleLight(v),
            ),
          ),
          Slider(
            value: state.brightness,
            activeColor: const Color(0xFF38BDF8),
            onChanged: state.isLightOn
                ? (v) => context.read<ControlCubit>().setBrightness(v)
                : null,
          ),
        ],
      ),
    );
  }
}
