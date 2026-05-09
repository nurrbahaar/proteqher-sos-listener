import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/entities/emergency_event_log.dart';
import '../domain/entities/emergency_execution_result.dart';
import '../domain/entities/emergency_trigger_type.dart';
import '../domain/repositories/emergency_repository.dart';
import 'emergency_platform_datasource.dart';
import 'location_datasource.dart';

class HiveEmergencyRepository implements EmergencyRepository {
  HiveEmergencyRepository({
    required Box<EmergencyEventLog> logsBox,
    required EmergencyPlatformDatasource platformDatasource,
    required LocationDatasource locationDatasource,
  }) : _logsBox = logsBox,
       _platformDatasource = platformDatasource,
       _locationDatasource = locationDatasource;

  final Box<EmergencyEventLog> _logsBox;
  final EmergencyPlatformDatasource _platformDatasource;
  final LocationDatasource _locationDatasource;

  @override
  Future<EmergencyExecutionResult> executeWorkflow({
    required EmergencyTriggerType triggerType,
    required String primaryNumber,
    required List<String> allNumbers,
    required bool callPermissionGranted,
    required bool smsPermissionGranted,
    required bool locationPermissionGranted,
  }) async {
    final numbers = allNumbers
        .map((number) => number.trim())
        .where((number) => number.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final location = locationPermissionGranted
        ? await _locationDatasource.getCurrentOrLastKnown()
        : null;
    var locationIncluded = location != null;
    var message = _buildEmergencyMessage(location: location);

    bool smsAttempted = false;
    bool callAttempted = false;

    if (Platform.isAndroid) {
      final payload = await _platformDatasource.triggerEmergencyWorkflow(
        primaryNumber: primaryNumber,
        allNumbers: numbers,
        message: message,
      );

      smsAttempted = payload['smsSent'] as bool? ?? false;
      callAttempted = payload['callStarted'] as bool? ?? false;
      locationIncluded =
          payload['locationIncluded'] as bool? ?? locationIncluded;
      message = payload['message'] as String? ?? message;

      if (!smsAttempted && numbers.isNotEmpty) {
        smsAttempted = await _platformDatasource.openSmsComposer(
          numbers: numbers,
          message: message,
        );
      }

      if (!callAttempted) {
        callAttempted = await _platformDatasource.openDialer(primaryNumber);
      }
    } else {
      if (numbers.isNotEmpty) {
        smsAttempted = await _platformDatasource.openSmsComposer(
          numbers: numbers,
          message: message,
        );
      }
      callAttempted = await _platformDatasource.openDialer(primaryNumber);
    }

    final log = EmergencyEventLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: triggerType.value,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      callAttempted: callAttempted,
      smsAttempted: smsAttempted,
      locationIncluded: locationIncluded,
    );

    await _logsBox.put(log.id, log);

    return EmergencyExecutionResult(
      callAttempted: callAttempted,
      smsAttempted: smsAttempted,
      locationIncluded: locationIncluded,
      message: message,
    );
  }

  @override
  Stream<List<EmergencyEventLog>> watchLogs() {
    return _logsBox.watch().map((_) => _sortedLogs()).startWith(_sortedLogs());
  }

  List<EmergencyEventLog> _sortedLogs() {
    final logs = _logsBox.values.toList(growable: false);
    logs.sort((a, b) => b.timestampMs.compareTo(a.timestampMs));
    return logs.take(AppConstants.emergencyLogLimit).toList(growable: false);
  }

  String _buildEmergencyMessage({required LocationSnapshot? location}) {
    final timestamp = DateTime.now().toIso8601String();
    if (location == null) {
      return 'Emergency! I need immediate help. '
          'Location unavailable at the moment. '
          'Timestamp: $timestamp';
    }

    return 'Emergency! I need immediate help. '
        'This alert was triggered from my SOS app. '
        'My current location: ${location.mapsLink} '
        'Timestamp: $timestamp';
  }
}

final hiveEmergencyRepositoryProvider = Provider<HiveEmergencyRepository>(
  (ref) => HiveEmergencyRepository(
    logsBox: Hive.box<EmergencyEventLog>(AppConstants.emergencyLogsBoxName),
    platformDatasource: ref.watch(emergencyPlatformDatasourceProvider),
    locationDatasource: ref.watch(locationDatasourceProvider),
  ),
);

extension _StartWithExtension<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
