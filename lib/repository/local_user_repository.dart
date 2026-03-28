import 'dart:convert';
import 'package:mobile_flutter_iot/models/device_model.dart';
import 'package:mobile_flutter_iot/models/user_model.dart';
import 'package:mobile_flutter_iot/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserRepository implements UserRepository {
  static const String _userKey = 'user_data';
  static const String _devicesKey = 'devices_list';

  @override
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final String userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  @override
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_userKey);
    if (userJson == null) return null;

    final Map<String, dynamic> userMap =
        jsonDecode(userJson) as Map<String, dynamic>;
    return UserModel.fromJson(userMap);
  }

  @override
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_devicesKey);
    await prefs.setBool('isLoggedIn', false);
  }

  @override
  Future<void> saveDevices(List<DeviceModel> devices) async {
    final prefs = await SharedPreferences.getInstance();
    final String devicesJson = jsonEncode(
      devices.map((d) => d.toMap()).toList(),
    );
    await prefs.setString(_devicesKey, devicesJson);
  }

  @override
  Future<List<DeviceModel>> getDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? devicesJson = prefs.getString(_devicesKey);

    if (devicesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(devicesJson) as List<dynamic>;
    return decoded
        .map((item) => DeviceModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
