import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/permission_repository.dart';
import '../domain/permission_state.dart';

class PermissionHandlerRepository implements PermissionRepository {
  @override
  Future<PermissionState> getStatus() async {
    final microphoneStatus = await Permission.microphone.status;

    final callStatus = Platform.isAndroid
        ? await Permission.phone.status
        : PermissionStatus.granted;

    final smsStatus = Platform.isAndroid
        ? await Permission.sms.status
        : PermissionStatus.granted;

    final locationStatus = await Permission.locationWhenInUse.status;

    final notificationStatus = Platform.isAndroid
        ? await Permission.notification.status
        : PermissionStatus.granted;

    return PermissionState(
      microphoneGranted: microphoneStatus.isGranted,
      callGranted: callStatus.isGranted,
      smsGranted: smsStatus.isGranted,
      locationGranted: _isLocationGranted(locationStatus),
      notificationGranted: notificationStatus.isGranted,
      loading: false,
    );
  }

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }

  @override
  Future<PermissionState> requestCall() async {
    if (Platform.isAndroid) {
      await Permission.phone.request();
    }
    return getStatus();
  }

  @override
  Future<PermissionState> requestLocation() async {
    await Permission.locationWhenInUse.request();
    return getStatus();
  }

  @override
  Future<PermissionState> requestMicrophone() async {
    await Permission.microphone.request();
    return getStatus();
  }

  @override
  Future<PermissionState> requestSms() async {
    if (Platform.isAndroid) {
      await Permission.sms.request();
    }
    return getStatus();
  }

  @override
  Future<PermissionState> requestNotifications() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
    return getStatus();
  }
}

bool _isLocationGranted(PermissionStatus status) {
  return status == PermissionStatus.granted ||
      status == PermissionStatus.limited;
}

final permissionRepositoryProvider = Provider<PermissionRepository>(
  (ref) => PermissionHandlerRepository(),
);
