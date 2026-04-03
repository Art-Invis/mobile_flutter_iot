import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/details_cubit.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';
import 'package:mobile_flutter_iot/utils/details_dialogs.dart';
import 'package:mobile_flutter_iot/widgets/common/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/devices/mini_stat_card.dart';
import 'package:mobile_flutter_iot/widgets/devices/sensor_chart.dart';

class SensorArguments {
  final String id;
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String status;
  final String ipAddress;

  SensorArguments({
    required this.id,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.status = 'Stable',
    this.ipAddress = '192.168.1.XXX',
  });
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? rawArgs = ModalRoute.of(context)?.settings.arguments;
    if (rawArgs == null || rawArgs is! SensorArguments) {
      return const Scaffold(
        body: Center(child: Text('Sensor data not found.')),
      );
    }
    final args = rawArgs;

    return BlocProvider(
      create: (context) => DetailsCubit(
        apiService: context.read<ApiService>(),
        userRepository: context.read<LocalUserRepository>(),
      ),
      child: Builder(
        builder: (context) {
          return BlocConsumer<DetailsCubit, DetailsState>(
            listener: (context, state) {
              if (state.alertMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.alertMessage!),
                    backgroundColor:
                        state.isError ? Colors.orange : const Color(0xFF4ADE80),
                  ),
                );
              }
              if (state.isDeleted) Navigator.pop(context);
            },
            builder: (context, state) {
              final displayValue = state.currentValue ?? args.value;
              final displayIp = state.customIp ?? args.ipAddress;

              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(
                    '${args.title.toUpperCase()} ANALYSIS',
                    style: const TextStyle(fontSize: 16),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.delete_sweep_outlined,
                        color: Colors.redAccent,
                      ),
                      onPressed: () =>
                          DetailsDialogs.showDeleteDevice(context, args.id),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${args.title} History',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                if (state.isSavingSnapshot)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF38BDF8),
                                    ),
                                  )
                                else
                                  IconButton(
                                    icon: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: Color(0xFF38BDF8),
                                      size: 20,
                                    ),
                                    onPressed: () => context
                                        .read<DetailsCubit>()
                                        .saveSnapshot(args.id, displayValue),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const SensorChart(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => DetailsDialogs.showEditIpAddress(
                          context,
                          args,
                          state.customIp,
                        ),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lan_outlined,
                                color: Colors.white38,
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'DEVICE IP / BROKER',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white38,
                                    ),
                                  ),
                                  Text(
                                    displayIp,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.edit_note,
                                color: Color(0xFF38BDF8),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => DetailsDialogs.showEditValue(
                                context,
                                args,
                                state.currentValue,
                              ),
                              child: MiniStatCard(
                                label: 'Current Value',
                                value: displayValue,
                                icon: args.icon,
                                color: args.color,
                                isEditable: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MiniStatCard(
                              label: 'Status',
                              value: args.status,
                              icon: Icons.check_circle_outline,
                              color: const Color(0xFF4ADE80),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GlassCard(
                        child: ListTile(
                          leading: Icon(
                            state.isManualControlOn
                                ? args.icon
                                : Icons.power_off_outlined,
                            color: state.isManualControlOn
                                ? args.color
                                : Colors.white24,
                          ),
                          title: Text('Manual ${args.title} Control'),
                          subtitle: Text(
                            state.isManualControlOn
                                ? 'System Active'
                                : 'System Paused',
                          ),
                          trailing: Switch(
                            value: state.isManualControlOn,
                            onChanged: (v) => context
                                .read<DetailsCubit>()
                                .toggleManualControl(v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
