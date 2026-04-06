import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/add_device_cubit.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';
import 'package:mobile_flutter_iot/widgets/common/glass_input.dart';
import 'package:mobile_flutter_iot/widgets/common/primary_button.dart';
import 'package:mobile_flutter_iot/widgets/devices/color_picker.dart';
import 'package:mobile_flutter_iot/widgets/devices/icon_picker.dart';

class AddDeviceScreen extends StatefulWidget {
  final DeviceModel? device;

  const AddDeviceScreen({super.key, this.device});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  late TextEditingController _titleController;

  static const List<Color> _colors = [
    Color(0xFF4ADE80),
    Color(0xFF38BDF8),
    Color(0xFFFACC15),
    Color(0xFFF87171),
    Color(0xFFC084FC),
  ];

  static const List<IconData> _icons = [
    Icons.air,
    Icons.ac_unit,
    Icons.sensors,
    Icons.lightbulb_outline,
    Icons.water_drop_outlined,
    Icons.thermostat,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.device?.title ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _handleSave(BuildContext context, AddDeviceState state) {
    if (_titleController.text.trim().isEmpty) return;

    final deviceToSave = DeviceModel(
      id: widget.device?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      value: widget.device?.value ?? '0 units',
      status: widget.device?.status ?? 'INITIALIZING',
      icon: state.selectedIcon,
      color: state.selectedColor,
    );

    context
        .read<AddDeviceCubit>()
        .saveDevice(deviceToSave, widget.device == null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddDeviceCubit(
        apiService: context.read<ApiService>(),
        initialColor: widget.device?.color ?? _colors[0],
        initialIcon: widget.device?.icon ?? _icons[0],
      ),
      child: Builder(
        builder: (context) {
          return BlocConsumer<AddDeviceCubit, AddDeviceState>(
            listener: (context, state) {
              if (state.isSuccess != null) {
                if (state.isSuccess == false && state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }

                final deviceToSave = DeviceModel(
                  id: widget.device?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text.trim(),
                  value: widget.device?.value ?? '0 units',
                  status: widget.device?.status ?? 'INITIALIZING',
                  icon: state.selectedIcon,
                  color: state.selectedColor,
                );

                Navigator.pop(context, deviceToSave);
              }
            },
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    widget.device == null ? 'ADD SENSOR' : 'EDIT SENSOR',
                  ),
                  backgroundColor: Colors.transparent,
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassInput(
                        hintText: 'Sensor Name',
                        icon: Icons.edit,
                        controller: _titleController,
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'SELECT COLOR',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ColorPicker(state: state, colors: _colors),
                      const SizedBox(height: 32),
                      const Text(
                        'SELECT ICON',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      IconPicker(state: state, icons: _icons),
                      const SizedBox(height: 48),
                      if (state.isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF38BDF8),
                          ),
                        )
                      else
                        PrimaryButton(
                          text: widget.device == null
                              ? 'CREATE DEVICE'
                              : 'SAVE CHANGES',
                          onPressed: () => _handleSave(context, state),
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

/* ============================================================
[ADVANCED ARCHITECTURE OPTION: BLoC IMPLEMENTATION]
Щоб переключити екран на BLoC, розкоментуйте код нижче 
та закоментуйте секцію з Cubit вище.
============================================================*/

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mobile_flutter_iot/blocs/add_device/add_device_bloc.dart';
// import 'package:mobile_flutter_iot/blocs/add_device/add_device_event.dart';
// import 'package:mobile_flutter_iot/blocs/add_device/add_device_state.dart';
// import 'package:mobile_flutter_iot/models/device_model.dart';
// import 'package:mobile_flutter_iot/services/api_service.dart';
// import 'package:mobile_flutter_iot/widgets/common/glass_input.dart';
// import 'package:mobile_flutter_iot/widgets/common/primary_button.dart';
// import 'package:mobile_flutter_iot/widgets/devices/color_picker.dart';
// import 'package:mobile_flutter_iot/widgets/devices/icon_picker.dart';

// class AddDeviceScreen extends StatefulWidget {
//   final DeviceModel? device;

//   const AddDeviceScreen({super.key, this.device});

//   @override
//   State<AddDeviceScreen> createState() => _AddDeviceScreenState();
// }

// class _AddDeviceScreenState extends State<AddDeviceScreen> {
//   late TextEditingController _titleController;

//   static const List<Color> _colors = [
//     Color(0xFF4ADE80),
//     Color(0xFF38BDF8),
//     Color(0xFFFACC15),
//     Color(0xFFF87171),
//     Color(0xFFC084FC),
//   ];

//   static const List<IconData> _icons = [
//     Icons.air,
//     Icons.ac_unit,
//     Icons.sensors,
//     Icons.lightbulb_outline,
//     Icons.water_drop_outlined,
//     Icons.thermostat,
//   ];

//   @override
//   void initState() {
//     super.initState();
//   _titleController = TextEditingController(text: widget.device?.title ?? '');
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     super.dispose();
//   }

//   void _handleSave(BuildContext context, AddDeviceState state) {
//     if (_titleController.text.trim().isEmpty) return;

//     final deviceToSave = DeviceModel(
//    id: widget.device?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       title: _titleController.text.trim(),
//       value: widget.device?.value ?? '0 units',
//       status: widget.device?.status ?? 'INITIALIZING',
//       icon: state.selectedIcon,
//       color: state.selectedColor,
//     );

//     context.read<AddDeviceBloc>().add(
//           AddDeviceSaveRequested(
//             device: deviceToSave,
//             isNew: widget.device == null,
//           ),
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AddDeviceBloc(
//         apiService: context.read<ApiService>(),
//         initialColor: widget.device?.color ?? _colors[0],
//         initialIcon: widget.device?.icon ?? _icons[0],
//       ),
//       child: Builder(
//         builder: (context) {
//           return BlocConsumer<AddDeviceBloc, AddDeviceState>(
//             listener: (context, state) {
//               if (state.isSuccess != null) {
//                 if (state.isSuccess == false && state.errorMessage != null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(state.errorMessage!),
//                       backgroundColor: Colors.orange,
//                     ),
//                   );
//                 }

//                 final deviceToSave = DeviceModel(
//                   id: widget.device?.id ??
//                       DateTime.now().millisecondsSinceEpoch.toString(),
//                   title: _titleController.text.trim(),
//                   value: widget.device?.value ?? '0 units',
//                   status: widget.device?.status ?? 'INITIALIZING',
//                   icon: state.selectedIcon,
//                   color: state.selectedColor,
//                 );

//                 Navigator.pop(context, deviceToSave);
//               }
//             },
//             builder: (context, state) {
//               return Scaffold(
//                 appBar: AppBar(
//                   title: Text(
//                     widget.device == null ? 'ADD SENSOR' : 'EDIT SENSOR',
//                   ),
//                   backgroundColor: Colors.transparent,
//                 ),
//                 body: SingleChildScrollView(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       GlassInput(
//                         hintText: 'Sensor Name',
//                         icon: Icons.edit,
//                         controller: _titleController,
//                       ),
//                       const SizedBox(height: 32),
//                       const Text(
//                         'SELECT COLOR',
//                         style: TextStyle(color: Colors.white70),
//                       ),
//                       const SizedBox(height: 12),
//                       ColorPicker(state: state, colors: _colors),
//                       const SizedBox(height: 32),
//                       const Text(
//                         'SELECT ICON',
//                         style: TextStyle(color: Colors.white70),
//                       ),
//                       const SizedBox(height: 12),
//                       IconPicker(state: state, icons: _icons),
//                       const SizedBox(height: 48),
//                       if (state.isLoading)
//                         const Center(
//                           child: CircularProgressIndicator(
//                             color: Color(0xFF38BDF8),
//                           ),
//                         )
//                       else
//                         PrimaryButton(
//                           text: widget.device == null
//                               ? 'CREATE DEVICE'
//                               : 'SAVE CHANGES',
//                           onPressed: () => _handleSave(context, state),
//                         ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
