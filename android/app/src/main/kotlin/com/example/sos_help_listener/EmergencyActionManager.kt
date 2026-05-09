package com.example.sos_help_listener

import android.content.Context

class EmergencyActionManager(
    context: Context,
    logTag: String = "EmergencyActionManager",
) {
    private val executor = EmergencyWorkflowExecutor(context, logTag)

    fun execute(primaryNumber: String, allNumbers: List<String>): EmergencyWorkflowResult {
        return executor.execute(
            primaryNumber = primaryNumber,
            allNumbers = allNumbers,
            providedMessage = null,
        )
    }
}
