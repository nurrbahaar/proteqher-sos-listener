package com.example.sos_help_listener

import android.content.Intent
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val methodChannelName = "com.sos_help_listener/service"
    private val eventChannelName = "com.sos_help_listener/service/events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName)
            .setStreamHandler(ListenerEventStreamHandler())

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
            .setMethodCallHandler { call, result ->
                handleMethodCall(call, result)
            }
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val emergencyExecutor = EmergencyWorkflowExecutor(this)

        when (call.method) {
            "startService" -> {
                val primaryNumber = call.argument<String>("primaryNumber").orEmpty().trim()
                if (primaryNumber.isEmpty()) {
                    result.error("INVALID_ARGUMENT", "primaryNumber is required", null)
                    return
                }

                val numbers = EmergencyWorkflowExecutor.parseNumbers(call.argument<List<*>>("allNumbers"))
                    .ifEmpty { listOf(primaryNumber) }

                val intent =
                    Intent(this, SosListenerService::class.java).apply {
                        action = SosListenerService.ACTION_START
                        putExtra(SosListenerService.EXTRA_PRIMARY_NUMBER, primaryNumber)
                        putStringArrayListExtra(
                            SosListenerService.EXTRA_ALL_NUMBERS,
                            ArrayList(numbers),
                        )
                    }
                ContextCompat.startForegroundService(this, intent)
                result.success(null)
            }

            "stopService" -> {
                val intent =
                    Intent(this, SosListenerService::class.java).apply {
                        action = SosListenerService.ACTION_STOP
                    }
                startService(intent)
                stopService(Intent(this, SosListenerService::class.java))
                result.success(null)
            }

            "updatePrimaryNumber" -> {
                val primaryNumber = call.argument<String>("primaryNumber").orEmpty().trim()
                if (primaryNumber.isEmpty()) {
                    result.error("INVALID_ARGUMENT", "primaryNumber is required", null)
                    return
                }

                val numbers = EmergencyWorkflowExecutor.parseNumbers(call.argument<List<*>>("allNumbers"))
                    .ifEmpty { listOf(primaryNumber) }

                if (SosListenerService.isServiceRunning()) {
                    val intent =
                        Intent(this, SosListenerService::class.java).apply {
                            action = SosListenerService.ACTION_UPDATE_PRIMARY
                            putExtra(SosListenerService.EXTRA_PRIMARY_NUMBER, primaryNumber)
                            putStringArrayListExtra(
                                SosListenerService.EXTRA_ALL_NUMBERS,
                                ArrayList(numbers),
                            )
                        }
                    startService(intent)
                }

                result.success(null)
            }

            "getServiceStatus" -> {
                result.success(
                    mapOf(
                        "running" to SosListenerService.isServiceRunning(),
                        "cooldownRemaining" to SosListenerService.cooldownRemainingSeconds(),
                    ),
                )
            }

            "makeEmergencyCall" -> {
                val phoneNumber = call.argument<String>("phoneNumber").orEmpty().trim()
                if (phoneNumber.isEmpty()) {
                    result.error("INVALID_ARGUMENT", "phoneNumber is required", null)
                    return
                }

                val started = emergencyExecutor.makeEmergencyCall(phoneNumber)
                result.success(started)
            }

            "sendEmergencySms" -> {
                val numbers = EmergencyWorkflowExecutor.parseNumbers(call.argument<List<*>>("numbers"))
                val message = call.argument<String>("message").orEmpty().trim()

                if (numbers.isEmpty() || message.isEmpty()) {
                    result.error("INVALID_ARGUMENT", "numbers and message are required", null)
                    return
                }

                val sent = emergencyExecutor.sendSms(numbers, message)
                result.success(sent)
            }

            "triggerEmergencyWorkflow" -> {
                val primaryNumber = call.argument<String>("primaryNumber").orEmpty().trim()
                val numbers = EmergencyWorkflowExecutor.parseNumbers(call.argument<List<*>>("allNumbers"))
                val message = call.argument<String>("message")

                if (primaryNumber.isEmpty()) {
                    result.error("INVALID_ARGUMENT", "primaryNumber is required", null)
                    return
                }

                val response =
                    emergencyExecutor
                        .execute(
                            primaryNumber = primaryNumber,
                            allNumbers = numbers.ifEmpty { listOf(primaryNumber) },
                            providedMessage = message,
                        ).toMap()

                result.success(response)
            }

            else -> result.notImplemented()
        }
    }
}
