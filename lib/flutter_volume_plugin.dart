import 'dart:async';

import 'package:flutter/services.dart';

typedef void VolumeListener(int volume);

class FlutterVolumePlugin {

  static const VOLUME_UNAVAILABLE = -1;

  static const MethodChannel _channel =
      const MethodChannel('itech-art.com/flutter_volume_plugin');

  static const _getVolume = 'getVolume';
  static const _setVolume = 'setVolume';
  static const _volumeUp = 'volumeUp';
  static const _volumeDown = 'volumeDown';
  static const _startListener = 'startVolumeListener';
  static const _stopListener = 'stopVolumeListener';

  static const _volumeChanged = 'volumeChanged';

  static const _parameterVolume = 'volume';

  List<VolumeListener> _listeners = new List();

  FlutterVolumePlugin() {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case _volumeChanged:
          final int volume = call.arguments as int;
          _listeners.forEach((listener) => listener(volume));
          return null;
        default:
          throw Exception('Method ' + call.method + ' not implemented');
      }
    });
  }

  void _startVolumeListener() async {
      _channel.invokeMethod(_startListener);
  }

  void _stopVolumeListener() {
      _channel.invokeMethod(_stopListener);
  }

  void addVolumeListener(VolumeListener listener) {
    _listeners.add(listener);
    // start listening on first registrant
    if (_listeners.length == 1) {
      _startVolumeListener();
    }
  }

  void removeVolumeListener(VolumeListener listener) {
    _listeners.remove(listener);
    // stop listening when there are no listeners
    if (_listeners.isEmpty) {
      _stopVolumeListener();
    }
  }

  Future<int> get volume async {
      return await _channel.invokeMethod(_getVolume);
  }

  Future<void> setVolume(int volume) async {
    await _channel.invokeMethod(_setVolume, {_parameterVolume: volume});
  }

  Future<void> volumeUp() async {
      await _channel.invokeMethod(_volumeUp);
  }

  Future<void> volumeDown() async {
    await _channel.invokeMethod(_volumeDown);
  }
}
