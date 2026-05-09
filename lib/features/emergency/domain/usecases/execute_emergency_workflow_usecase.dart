import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive_emergency_repository.dart';
import '../entities/emergency_execution_result.dart';
import '../entities/emergency_trigger_type.dart';

class ExecuteEmergencyWorkflowUseCase {
  const ExecuteEmergencyWorkflowUseCase(this._repository);

  final HiveEmergencyRepository _repository;

  Future<EmergencyExecutionResult> call({
    required EmergencyTriggerType triggerType,
    required String primaryNumber,
    required List<String> allNumbers,
    required bool callPermissionGranted,
    required bool smsPermissionGranted,
    required bool locationPermissionGranted,
  }) {
    return _repository.executeWorkflow(
      triggerType: triggerType,
      primaryNumber: primaryNumber,
      allNumbers: allNumbers,
      callPermissionGranted: callPermissionGranted,
      smsPermissionGranted: smsPermissionGranted,
      locationPermissionGranted: locationPermissionGranted,
    );
  }
}

final executeEmergencyWorkflowUseCaseProvider =
    Provider<ExecuteEmergencyWorkflowUseCase>(
      (ref) => ExecuteEmergencyWorkflowUseCase(
        ref.watch(hiveEmergencyRepositoryProvider),
      ),
    );
