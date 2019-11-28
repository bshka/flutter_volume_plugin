import 'package:flutter/material.dart';
import 'package:flutter_volume_plugin/flutter_volume_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _volumeLevel = 0;

  FlutterVolumePlugin _volumePlugin = new FlutterVolumePlugin();

  @override
  void initState() {
    super.initState();
    _getSystemVolume();
    _volumePlugin.addVolumeListener(_onVolumeChanged);
  }

  @override
  void deactivate() {
    super.deactivate();
    _volumePlugin.removeVolumeListener(_onVolumeChanged);
  }

  void _onVolumeChanged(int volume) {
    setState(() {
      _volumeLevel = volume;
    });
  }

  void _getSystemVolume() async {
    var volume = await _volumePlugin.volume;
    setState(() {
      _volumeLevel = volume;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 40),
              Slider(
                value: _volumeLevel / 100.0,
                onChanged: (value) {
                  var newVol = (value * 100).toInt();
                  _volumePlugin.setVolume(newVol);
                },
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Text('Current volume level = ' + _volumeLevel.toString() ??
                  'unknown'),
              SizedBox(height: 10),
              RaisedButton(
                onPressed: _getSystemVolume,
                child: Text('Get volume'),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: _volumePlugin.volumeDown,
                    child: Text('DOWN'),
                  ),
                  SizedBox(width: 10),
                  RaisedButton(
                    onPressed: _volumePlugin.volumeUp,
                    child: Text('UP'),
                  ),
                ],
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
