import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_flutter_iot/cubits/add_device_cubit.dart';

class ColorPicker extends StatelessWidget {
  final AddDeviceState state;
  final List<Color> colors;

  const ColorPicker({
    required this.state,
    required this.colors,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => context.read<AddDeviceCubit>().selectColor(color),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    state.selectedColor == color ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
