package com.itechart.flutter_volume_plugin

import android.content.Context
import android.database.ContentObserver
import android.media.AudioManager
import android.os.Handler
import io.flutter.Log

internal class SettingsContentObserver(
        private val context: Context,
        private val volumeChangeListener: VolumeChangeListener,
        handler: Handler
) : ContentObserver(handler) {

    private var previousVolume: Int

    init {
        val audio = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        previousVolume = audio.getStreamVolume(AudioManager.STREAM_MUSIC)
    }

    override fun onChange(selfChange: Boolean) {
        super.onChange(selfChange)
        Log.d("SettingsObserver", "onChange called")
        (context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager)?.let { audio ->
            val currentVolume = audio.getStreamVolume(AudioManager.STREAM_MUSIC)
            val delta = previousVolume - currentVolume
            Log.d("SettingsObserver", "Current volume = $currentVolume")

            if (delta != 0) {
                previousVolume = currentVolume
                volumeChangeListener.onVolumeChanged(currentVolume)
            }
        }
    }
}

interface VolumeChangeListener {
    fun onVolumeChanged(volume: Int)
}