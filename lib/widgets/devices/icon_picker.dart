import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/add_device_cubit.dart';

class IconPicker extends StatelessWidget {
  final AddDeviceState state;
  final List<IconData> icons;

  const IconPicker({
    required this.state,
    required this.icons,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: icons.map((icon) {
        return GestureDetector(
          onTap: () => context.read<AddDeviceCubit>().selectIcon(icon),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: state.selectedIcon == icon
                  ? state.selectedColor.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: state.selectedIcon == icon
                    ? state.selectedColor
                    : Colors.transparent,
              ),
            ),
            child: Icon(
              icon,
              color: state.selectedIcon == icon
                  ? state.selectedColor
                  : Colors.white38,
            ),
          ),
        );
      }).toList(),
    );
  }
}
