package com.example.taaaked_flutter

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.MethodChannel
import java.util.regex.Pattern

class NotificationListenerService : NotificationListenerService() {
    companion object {
        var channel: MethodChannel? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val extras = sbn.notification.extras
        val title = extras.getString("android.title") ?: ""
        val text = extras.getString("android.text") ?: ""
        val packageName = sbn.packageName

        if (text.contains("استلام") || text.contains("تم استلام") || text.contains("إيداع") || text.contains("تم التحويل")) {
            val amount = extractAmount(text) ?: return
            val sender = extractSender(text) ?: "عميل"
            val wallet = detectWallet(packageName, title, text)

            val args = mapOf(
                "amount" to amount,
                "sender" to sender,
                "wallet" to wallet
            )
            channel?.invokeMethod("onNewTransaction", args)
        }
    }

    private fun extractAmount(text: String): String? {
        val pattern = Pattern.compile("(\\d+(?:\\.\\d+)?)\\s*ر\\.?ي")
        val matcher = pattern.matcher(text)
        return if (matcher.find()) matcher.group(1) else null
    }

    private fun extractSender(text: String): String? {
        val pattern = Pattern.compile("من\\s+([^\\n]+)")
        val matcher = pattern.matcher(text)
        return if (matcher.find()) matcher.group(1).trim().take(30) else null
    }

    private fun detectWallet(packageName: String, title: String, text: String): String {
        return when {
            title.contains("جيب") || text.contains("جيب") || packageName.contains("jayb") -> "JAYB"
            title.contains("جوالي") || text.contains("جوالي") || packageName.contains("jawali") -> "JAWALI"
            title.contains("ام فلوس") || packageName.contains("umfulus") -> "UMFULUS"
            title.contains("ايزي") || packageName.contains("easy") -> "EASY"
            title.contains("يمن والت") || packageName.contains("yemenwallet") -> "YEMEN_WALLET"
            else -> "JAYB"
        }
    }
}
