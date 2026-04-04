import 'package:flutter_bloc/flutter_bloc.dart';

class HomeState {
  final bool isSystemOn;
  final String? alertMessage;

  const HomeState({
    this.isSystemOn = true,
    this.alertMessage,
  });

  HomeState copyWith({
    bool? isSystemOn,
    String? alertMessage,
  }) {
    return HomeState(
      isSystemOn: isSystemOn ?? this.isSystemOn,
      alertMessage: alertMessage,
    );
  }
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void toggleSystemPower() {
    final newState = !state.isSystemOn;
    emit(
      state.copyWith(
        isSystemOn: newState,
        alertMessage: newState ? 'SYSTEM INITIALIZED' : 'SYSTEM SHUTDOWN',
      ),
    );
  }
}
