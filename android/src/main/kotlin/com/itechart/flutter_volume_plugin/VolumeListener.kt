package com.itechart.flutter_volume_plugin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter

internal abstract class VolumeListener : BroadcastReceiver() {
    final override fun onReceive(context: Context?, intent: Intent?) {
        if (context != null && intent != null && intent.action == VOLUME_CHANGE_ACTION) {
            val volume = intent.extras?.getInt(EXTRA_VOLUME_STREAM_VALUE, 0) ?: return
            onVolumeChanged(volume)
        }
    }
    
    abstract fun onVolumeChanged(volume: Int)
    
    fun register(context: Context) {
        val intentFilter = IntentFilter().apply { addAction(VOLUME_CHANGE_ACTION) }
        context.registerReceiver(this, intentFilter)
    }
    
    fun unregister(context: Context) {
        context.unregisterReceiver(this)
    }
    
    companion object {
        private const val VOLUME_CHANGE_ACTION = "android.media.VOLUME_CHANGED_ACTION"
        private const val EXTRA_VOLUME_STREAM_VALUE = "android.media.EXTRA_VOLUME_STREAM_VALUE"
    }
}