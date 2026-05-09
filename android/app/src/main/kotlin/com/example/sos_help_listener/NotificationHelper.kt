package com.example.sos_help_listener

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

class NotificationHelper(private val context: Context) {
    private val manager: NotificationManager =
        context.getSystemService(NotificationManager::class.java)

    fun createChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val foregroundChannel = NotificationChannel(
            FOREGROUND_CHANNEL_ID,
            "SOS Listener Service",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Persistent notification for SOS listening"
        }

        val alertChannel = NotificationChannel(
            ALERT_CHANNEL_ID,
            "SOS Alerts",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Emergency trigger and call notifications"
        }

        manager.createNotificationChannel(foregroundChannel)
        manager.createNotificationChannel(alertChannel)
    }

    fun buildForegroundNotification(contentText: String): Notification {
        val launchIntent =
            context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?: Intent(context, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
        val pendingIntent = PendingIntent.getActivity(
            context,
            10,
            launchIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        return NotificationCompat.Builder(context, FOREGROUND_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("SOS Listening")
            .setContentText(contentText)
            .setOngoing(true)
            .setSilent(true)
            .setContentIntent(pendingIntent)
            .build()
    }

    fun updateForeground(contentText: String) {
        manager.notify(FOREGROUND_NOTIFICATION_ID, buildForegroundNotification(contentText))
    }

    fun showAlert(title: String, message: String) {
        val notification = NotificationCompat.Builder(context, ALERT_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()

        manager.notify((System.currentTimeMillis() % Int.MAX_VALUE).toInt(), notification)
    }

    companion object {
        const val FOREGROUND_CHANNEL_ID = "sos_listener_foreground"
        const val ALERT_CHANNEL_ID = "sos_listener_alerts"
        const val FOREGROUND_NOTIFICATION_ID = 443001
    }
}
