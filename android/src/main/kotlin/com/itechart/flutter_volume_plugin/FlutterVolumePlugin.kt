package com.itechart.flutter_volume_plugin

import android.content.Context
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterVolumePlugin(
        private val context: Context,
        private val methodChannel: MethodChannel
) : MethodCallHandler, VolumeChangeListener {

    // If broadcast receiver will be broken, can use this content observer as fallback
//    private val volumeObserver = SettingsContentObserver(
//            context = context,
//            handler = Handler(Looper.getMainLooper()),
//            volumeChangeListener = this@FlutterVolumePlugin
//    )

    private val volumeListener = object : VolumeListener() {
        override fun onVolumeChanged(volume: Int) {
            (context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager)?.let {
                val resultVolume = convertToOutVolume(volume, it)
                methodChannel.invokeMethod(OUT_METHOD_VOLUME_CHANGED, resultVolume)
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {

        when (call.method) {
            METHOD_GET_VOLUME -> {
                val manager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
                assertAudioManager(manager, result) {
                    val volume = it.getStreamVolume(AudioManager.STREAM_MUSIC)
                    result.success(convertToOutVolume(volume, it))
                }
            }
            METHOD_SET_VOLUME -> {
                val manager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
                assertAudioManager(manager, result) {

                    val volume = call.argument<Int?>(PARAMETER_VOLUME)
                    if (volume == null) {
                        result.error("NullPointer", "Volume must not be null", null)
                        return@assertAudioManager
                    }

                    val resVolume = convertToInVolume(volume, it)

                    it.setStreamVolume(AudioManager.STREAM_MUSIC, resVolume, 0)
                    result.success(null)
                }
            }
            METHOD_VOLUME_UP -> {
                val manager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
                assertAudioManager(manager, result) {
                    it.adjustStreamVolume(
                            AudioManager.STREAM_MUSIC,
                            AudioManager.ADJUST_RAISE,
                            0
                    )
                    result.success(null)
                }
            }
            METHOD_VOLUME_DOWN -> {
                val manager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
                assertAudioManager(manager, result) {
                    it.adjustStreamVolume(
                            AudioManager.STREAM_MUSIC,
                            AudioManager.ADJUST_LOWER,
                            0
                    )
                    result.success(null)
                }
            }
            METHOD_START_VOLUME_LISTENER -> {
                volumeListener.register(context)
//                context.applicationContext.contentResolver.registerContentObserver(
//                        android.provider.Settings.System.CONTENT_URI,
//                        true,
//                        volumeObserver
//                )
            }
            METHOD_STOP_VOLUME_LISTENER -> {
                volumeListener.unregister(context)
//                context.applicationContext.contentResolver.unregisterContentObserver(volumeObserver)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onVolumeChanged(volume: Int) {
        (context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager)?.let {
            val resultVolume = convertToOutVolume(volume, it)
            methodChannel.invokeMethod(OUT_METHOD_VOLUME_CHANGED, resultVolume)
        }
    }

    private fun convertToOutVolume(volumeInner: Int, manager: AudioManager): Int {
        val maxVolume = manager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        return ((volumeInner / maxVolume.toFloat()) * 100).toInt()
    }

    private fun convertToInVolume(volumeOuter: Int, manager: AudioManager): Int {
        val maxVolume = manager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        return (maxVolume * volumeOuter / 100f).toInt()
    }

    private fun assertAudioManager(manager: AudioManager?, result: Result, positive: (am: AudioManager) -> Unit) {
        if (manager == null) {
            result.error("UNAVAILABLE", "AudioManager is not available", null)
        } else {
            positive(manager)
        }
    }

    companion object {

        private const val CHANNEL_NAME = "itech-art.com/flutter_volume_plugin"

        private const val METHOD_GET_VOLUME = "getVolume"
        private const val METHOD_SET_VOLUME = "setVolume"
        private const val METHOD_VOLUME_UP = "volumeUp"
        private const val METHOD_VOLUME_DOWN = "volumeDown"

        private const val METHOD_START_VOLUME_LISTENER = "startVolumeListener"
        private const val METHOD_STOP_VOLUME_LISTENER = "stopVolumeListener"

        private const val OUT_METHOD_VOLUME_CHANGED = "volumeChanged"

        private const val PARAMETER_VOLUME = "volume"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
            channel.setMethodCallHandler(FlutterVolumePlugin(registrar.context(), channel))
        }
    }

}
