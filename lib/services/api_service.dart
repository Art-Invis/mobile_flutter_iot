import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';
import 'package:mobile_flutter_iot/models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
    ),
  );

  final _storage = const FlutterSecureStorage();

  Future<bool> register(UserModel user) async {
    try {
      final response =
          await _dio.post<dynamic>('/auth/register', data: user.toJson());
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post<dynamic>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<bool> deleteAccount() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return false;

      final response = await _dio.delete<dynamic>(
        '/auth/account',
        options: Options(headers: {'Authorization': token}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<DeviceModel>?> fetchDevices() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return null;

      final response = await _dio.get<dynamic>(
        '/devices',
        options: Options(headers: {'Authorization': token}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as List<dynamic>;
        return data
            .map((json) => DeviceModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      log('Fetch error: $e');
      return null;
    }
    return null;
  }

  Future<bool> addDevice(DeviceModel device) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return false;

      final response = await _dio.post<dynamic>(
        '/devices',
        data: device.toJson(),
        options: Options(headers: {'Authorization': token}),
      );
      return response.statusCode == 201;
    } catch (e) {
      log('Add device error: $e');
      return false;
    }
  }

  Future<bool> updateDevice(DeviceModel device) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return false;

      final response = await _dio.put<dynamic>(
        '/devices/${device.id}',
        data: device.toJson(),
        options: Options(headers: {'Authorization': token}),
      );
      return response.statusCode == 200;
    } catch (e) {
      log('Update device error: $e');
      return false;
    }
  }

  Future<bool> deleteDevice(String deviceId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return false;

      final response = await _dio.delete<dynamic>(
        '/devices/$deviceId',
        options: Options(headers: {'Authorization': token}),
      );
      return response.statusCode == 200;
    } catch (e) {
      log('Delete device error: $e');
      return false;
    }
  }
}
