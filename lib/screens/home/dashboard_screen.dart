import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/device_cubit.dart';
import 'package:mobile_flutter_iot/cubits/mqtt_cubit.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';
import 'package:mobile_flutter_iot/screens/home/add_device_screen.dart';
import 'package:mobile_flutter_iot/widgets/devices/api_device_list.dart';
import 'package:mobile_flutter_iot/widgets/mqtt/mqtt_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _safelyConnectMQTT(BuildContext context) async {
    final mqttCubit = context.read<MqttCubit>();
    if (mqttCubit.state.client == null) {
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString('mqtt_ip') ?? '192.168.1.XXX';
      mqttCubit.initMqtt(savedIp, 'flutter_client_${Random().nextInt(100)}');
    }
    mqttCubit.connect();
  }

  void _showBanner(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _safelyConnectMQTT(context));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocConsumer<DeviceCubit, DeviceState>(
          listener: (context, state) {
            if (state is DeviceLoaded && state.alertMessage != null) {
              final color =
                  state.isError ? Colors.redAccent : const Color(0xFF4ADE80);
              _showBanner(context, state.alertMessage!, color);
            }
          },
          builder: (context, state) {
            return BlocBuilder<MqttCubit, MqttState>(
              builder: (context, mqttState) {
                return RefreshIndicator(
                  onRefresh: () => context.read<DeviceCubit>().loadDevices(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAppBar(),
                        MqttSection(mqttState: mqttState),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text(
                            'CLOUD & LOCAL NODES',
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 11,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        if (state is DeviceLoading || state is DeviceInitial)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                          )
                        else if (state is DeviceLoaded)
                          ApiDeviceList(
                            devices: state.devices,
                            mqttIp: mqttState.client?.server,
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<DeviceModel?>(
            context,
            MaterialPageRoute<DeviceModel?>(
              builder: (context) => const AddDeviceScreen(),
            ),
          );
          if (result != null && context.mounted) {
            context.read<DeviceCubit>().addOrUpdateDeviceLocally(result);
          }
        },
        backgroundColor: const Color(0xFF38BDF8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'DASHBOARD',
        style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/* ============================================================
[ADVANCED ARCHITECTURE OPTION: BLoC IMPLEMENTATION]
Щоб переключити екран на BLoC, розкоментуйте код нижче 
та закоментуйте секцію з Cubit вище.
============================================================*/

// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mobile_flutter_iot/blocs/device/device_bloc.dart';
// import 'package:mobile_flutter_iot/blocs/device/device_event.dart';
// import 'package:mobile_flutter_iot/blocs/device/device_state.dart';
// import 'package:mobile_flutter_iot/blocs/mqtt/mqtt_bloc.dart';
// import 'package:mobile_flutter_iot/blocs/mqtt/mqtt_event.dart';
// import 'package:mobile_flutter_iot/blocs/mqtt/mqtt_state.dart';
// import 'package:mobile_flutter_iot/models/device_model.dart';
// import 'package:mobile_flutter_iot/screens/home/add_device_screen.dart';
// import 'package:mobile_flutter_iot/widgets/devices/api_device_list.dart';
// import 'package:mobile_flutter_iot/widgets/mqtt/mqtt_section.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   Future<void> _safelyConnectMQTT(BuildContext context) async {
//     final mqttBloc = context.read<MqttBloc>(); // ЗМІНЕНО
//     if (mqttBloc.state.client == null) {
//       final prefs = await SharedPreferences.getInstance();
//       final savedIp = prefs.getString('mqtt_ip') ?? '192.168.1.XXX';

//       mqttBloc.add(MqttInitializeRequested(
//           savedIp, 'flutter_client_${Random().nextInt(100)}'));
//     }
//     mqttBloc.add(MqttConnectRequested()); // ЗМІНЕНО НА EVENT
//   }

//   void _showBanner(BuildContext context, String msg, Color color) {
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg, style: const TextStyle(color: Colors.white)),
//         backgroundColor: color.withValues(alpha: 0.9),
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance
//         .addPostFrameCallback((_) => _safelyConnectMQTT(context));

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: SafeArea(
//         child: BlocConsumer<DeviceBloc, DeviceState>(
//           listener: (context, state) {
//             if (state is DeviceError) {
//               _showBanner(context, state.message, Colors.redAccent);
//             } else if (state is DeviceLoaded && state.isOffline) {
//             _showBanner(context, 'Offline Mode: Local Cache', Colors.orange);
//             }
//           },
//           builder: (context, state) {
//             return BlocBuilder<MqttBloc, MqttState>(
//               builder: (context, mqttState) {
//                 return RefreshIndicator(
//                   onRefresh: () async =>
//                       context.read<DeviceBloc>().add(DeviceFetchRequested()),
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildAppBar(),
//                         MqttSection(mqttState: mqttState),
//                         const Padding(
//                           padding:
//                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                           child: Text(
//                             'CLOUD & LOCAL NODES',
//                             style: TextStyle(
//                               color: Colors.white30,
//                               fontSize: 11,
//                               letterSpacing: 1.5,
//                             ),
//                           ),
//                         ),
//                         if (state is DeviceLoading || state is DeviceInitial)
//                           const Center(
//                             child: Padding(
//                               padding: EdgeInsets.all(40),
//                               child: CircularProgressIndicator(
//                                 color: Color(0xFF38BDF8),
//                               ),
//                             ),
//                           )
//                         else if (state is DeviceLoaded)
//                           ApiDeviceList(
//                             devices: state.devices,
//                             mqttIp: mqttState.client?.server,
//                           ),
//                         const SizedBox(height: 80),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final result = await Navigator.push<DeviceModel?>(
//             context,
//             MaterialPageRoute<DeviceModel?>(
//               builder: (context) => const AddDeviceScreen(),
//             ),
//           );
//           if (result != null && context.mounted) {
//             context.read<DeviceBloc>().add(DeviceFetchRequested());
//           }
//         },
//         backgroundColor: const Color(0xFF38BDF8),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       centerTitle: true,
//       title: const Text(
//         'DASHBOARD',
//         style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }
