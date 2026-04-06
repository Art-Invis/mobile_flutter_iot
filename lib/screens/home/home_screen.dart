import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/home_cubit.dart';
import 'package:mobile_flutter_iot/widgets/common/blur_blob.dart';
import 'package:mobile_flutter_iot/widgets/common/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/devices/fan_widget.dart';
import 'package:mobile_flutter_iot/widgets/devices/tech_node.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<HomeCubit, HomeState>(
            listener: (context, state) {
              if (state.alertMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.alertMessage!),
                    backgroundColor: state.isSystemOn
                        ? const Color(0xFF38BDF8)
                        : Colors.redAccent,
                    duration: const Duration(seconds: 1),
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
                      alignment: Alignment.topLeft,
                      translation: const Offset(-0.2, -0.3),
                      color: const Color(0xFF4ADE80).withValues(alpha: 0.08),
                      size: 280,
                    ),
                    BlurBlob(
                      alignment: Alignment.bottomRight,
                      translation: const Offset(0.3, 0.2),
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                      size: 320,
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
                                    _buildVentilationUnit(state.isSystemOn),
                                    _buildIlluminationUnit(state.isSystemOn),
                                    _buildPowerButton(
                                      context,
                                      state.isSystemOn,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _buildStatusText(state.isSystemOn),
                          const SizedBox(height: 20),
                        ],
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

  Widget _buildConnectionLine() {
    return Positioned(
      top: 100,
      bottom: 100,
      child: Container(width: 1, color: Colors.white10),
    );
  }

  Widget _buildVentilationUnit(bool isSystemOn) {
    return Positioned(
      top: 40,
      child: TechNode(
        label: 'VENTILATION UNIT',
        accentColor: isSystemOn ? const Color(0xFF38BDF8) : Colors.transparent,
        child: isSystemOn
            ? const RotatingFan(size: 100)
            : const Icon(Icons.cyclone, size: 100, color: Colors.white10),
      ),
    );
  }

  Widget _buildIlluminationUnit(bool isSystemOn) {
    return Positioned(
      bottom: 60,
      child: TechNode(
        label: 'ILLUMINATION',
        accentColor: isSystemOn ? Colors.yellow : Colors.transparent,
        child: Icon(
          Icons.lightbulb,
          size: 70,
          color: isSystemOn ? Colors.yellow : Colors.white10,
        ),
      ),
    );
  }

  Widget _buildPowerButton(BuildContext context, bool isSystemOn) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTap: () => context.read<HomeCubit>().toggleSystemPower(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isSystemOn ? Colors.red.withValues(alpha: 0.1) : Colors.white10,
            boxShadow: isSystemOn
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
            color: isSystemOn ? Colors.redAccent : Colors.white38,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText(bool isSystemOn) {
    return Text(
      isSystemOn ? 'LIVE SYSTEM PREVIEW' : 'SYSTEM OFFLINE',
      style: TextStyle(
        letterSpacing: 2,
        color: isSystemOn ? Colors.white24 : Colors.red.withValues(alpha: 0.3),
        fontSize: 10,
      ),
    );
  }
}

/* ============================================================
[ADVANCED ARCHITECTURE OPTION: BLoC IMPLEMENTATION]
Щоб переключити екран на BLoC, розкоментуйте код нижче 
та закоментуйте секцію з Cubit вище.
============================================================*/

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:iot_flashlight/iot_flashlight.dart'; // ІМПОРТ НАШОГО ПЛАГІНУ
// import 'package:mobile_flutter_iot/cubits/home_cubit.dart';
// import 'package:mobile_flutter_iot/widgets/common/blur_blob.dart';
// import 'package:mobile_flutter_iot/widgets/common/glass_card.dart';
// import 'package:mobile_flutter_iot/widgets/devices/fan_widget.dart';
// import 'package:mobile_flutter_iot/widgets/devices/tech_node.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => HomeCubit(),
//       child: Builder(
//         builder: (context) {
//           return BlocConsumer<HomeCubit, HomeState>(
//             listener: (context, state) {
//               if (state.alertMessage != null) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(state.alertMessage!),
//                     backgroundColor: state.isSystemOn
//                         ? const Color(0xFF38BDF8)
//                         : Colors.redAccent,
//                     duration: const Duration(seconds: 1),
//                   ),
//                 );
//               }
//             },
//             builder: (context, state) {
//               return Scaffold(
//                 backgroundColor: Colors.transparent,
//                 body: Stack(
//                   children: [
//                     BlurBlob(
//                       alignment: Alignment.topLeft,
//                       translation: const Offset(-0.2, -0.3),
//                       color: const Color(0xFF4ADE80).withValues(alpha: 0.08),
//                       size: 280,
//                     ),
//                     BlurBlob(
//                       alignment: Alignment.bottomRight,
//                       translation: const Offset(0.3, 0.2),
//                       color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
//                       size: 320,
//                     ),
//                     SafeArea(
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 20),
//                           const Text(
//                             'SYSTEM SCHEMATIC',
//                             style: TextStyle(
//                               letterSpacing: 4,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white70,
//                             ),
//                           ),
//                           Expanded(
//                             child: Center(
//                               child: GlassCard(
//                                 width: 320,
//                                 height: 500,
//                                 child: Stack(
//                                   alignment: Alignment.center,
//                                   children: [
//                                     _buildConnectionLine(),
//                                     _buildVentilationUnit(state.isSystemOn),
//                                     // ПЕРЕДАЄМО CONTEXT ДЛЯ ДІАЛОГУ ПОМИЛКИ
//                                     _buildIlluminationUnit(
//                                         context, state.isSystemOn),
//                                     _buildPowerButton(
//                                       context,
//                                       state.isSystemOn,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           _buildStatusText(state.isSystemOn),
//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildConnectionLine() {
//     return Positioned(
//       top: 100,
//       bottom: 100,
//       child: Container(width: 1, color: Colors.white10),
//     );
//   }

//   Widget _buildVentilationUnit(bool isSystemOn) {
//     return Positioned(
//       top: 40,
//       child: TechNode(
//         label: 'VENTILATION UNIT',
//       accentColor: isSystemOn ? const Color(0xFF38BDF8) : Colors.transparent,
//         child: isSystemOn
//             ? const RotatingFan(size: 100)
//             : const Icon(Icons.cyclone, size: 100, color: Colors.white10),
//       ),
//     );
//   }

//   // ОНОВЛЕНИЙ ВУЗОЛ ОСВІТЛЕННЯ З ПАСХАЛКОЮ
//   Widget _buildIlluminationUnit(BuildContext context, bool isSystemOn) {
//     return Positioned(
//       bottom: 60,
//       child: GestureDetector(
//         // СЕКРЕТНИЙ ФУНКЦІОНАЛ: Подвійний тап вмикає реальний спалах
//         onDoubleTap: () async {
//           try {
//             final isOn = await IotFlashlight.toggle();

//             if (context.mounted) {
//               ScaffoldMessenger.of(context).hideCurrentSnackBar();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                     isOn
//                         ? '🔦 HARDWARE OVERRIDE: OPTICAL EMITTER ACTIVE'
//                         : '🔦 HARDWARE OVERRIDE: OPTICAL EMITTER OFFLINE',
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, letterSpacing: 1),
//                   ),
//                   backgroundColor:
//                       isOn ? Colors.amber.shade700 : Colors.blueGrey,
//                   duration: const Duration(milliseconds: 1500),
//                 ),
//               );
//             }
//           } catch (e) {
//             // ОБРОБКА iOS ТА ІНШИХ ПЛАТФОРМ
//             if (e.toString().contains('UNSUPPORTED_PLATFORM') &&
//                 context.mounted) {
//               showDialog(
//                 context: context,
//                 builder: (ctx) => AlertDialog(
//                   backgroundColor: const Color(0xFF1E293B),
//                   title: const Row(
//                     children: [
//                     Icon(Icons.warning_amber_rounded, color: Colors.orange),
//                       SizedBox(width: 10),
//                       Text('Platform Warning',
//                         style: TextStyle(color: Colors.white, fontSize: 16)),
//                     ],
//                   ),
//                   content: const Text(
//                     'Hardware flashlight control is currently only supported
//on native Android nodes.',
//                     style: TextStyle(color: Colors.white70),
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(ctx),
//                       child: const Text('ACKNOWLEDGE',
//                           style: TextStyle(color: Color(0xFF38BDF8))),
//                     ),
//                   ],
//                 ),
//               );
//             }
//           }
//         },
//         child: TechNode(
//           label: 'ILLUMINATION',
//           accentColor: isSystemOn ? Colors.yellow : Colors.transparent,
//           child: Icon(
//             Icons.lightbulb,
//             size: 70,
//             color: isSystemOn ? Colors.yellow : Colors.white10,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPowerButton(BuildContext context, bool isSystemOn) {
//     return Positioned(
//       bottom: 20,
//       right: 20,
//       child: GestureDetector(
//         onTap: () => context.read<HomeCubit>().toggleSystemPower(),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color:
//              isSystemOn ? Colors.red.withValues(alpha: 0.1) : Colors.white10,
//             boxShadow: isSystemOn
//                 ? [
//                     BoxShadow(
//                       color: Colors.red.withValues(alpha: 0.2),
//                       blurRadius: 10,
//                     ),
//                   ]
//                 : [],
//           ),
//           child: Icon(
//             Icons.power_settings_new,
//             color: isSystemOn ? Colors.redAccent : Colors.white38,
//             size: 28,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusText(bool isSystemOn) {
//     return Text(
//       isSystemOn ? 'LIVE SYSTEM PREVIEW' : 'SYSTEM OFFLINE',
//       style: TextStyle(
//         letterSpacing: 2,
//       color: isSystemOn ? Colors.white24 : Colors.red.withValues(alpha: 0.3),
//         fontSize: 10,
//       ),
//     );
//   }
// }
