import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_volume_plugin/flutter_volume_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_volume_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterVolumePlugin.platformVersion, '42');
  });
}
