import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AddDeviceState extends Equatable {
  final Color selectedColor;
  final IconData selectedIcon;
  final bool isLoading;
  final bool? isSuccess;
  final String? errorMessage;

  const AddDeviceState({
    required this.selectedColor,
    required this.selectedIcon,
    this.isLoading = false,
    this.isSuccess,
    this.errorMessage,
  });

  AddDeviceState copyWith({
    Color? selectedColor,
    IconData? selectedIcon,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return AddDeviceState(
      selectedColor: selectedColor ?? this.selectedColor,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [selectedColor, selectedIcon, isLoading, isSuccess, errorMessage];
}
