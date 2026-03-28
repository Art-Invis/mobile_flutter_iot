import 'package:mobile_flutter_iot/models/device_model.dart';
import 'package:mobile_flutter_iot/models/user_model.dart';

abstract class UserRepository {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> deleteUser();

  Future<void> saveDevices(List<DeviceModel> devices);
  Future<List<DeviceModel>> getDevices();
}
