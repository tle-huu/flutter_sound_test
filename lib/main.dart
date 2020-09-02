
// ignore: avoid_web_libraries_in_flutter
import 'dart:io';
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_visualizers/flutter_visualizers.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

/// demonstrates the recording widget linked to a playback widget.
void main() {
  runApp(MyApp());
}

/// Example app.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool _recording = false;
  bool _playing = false;
  var _player;
  var _recorder;
  File _file = null;
  var recorder;

  AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Sound'),
        ),
        body: Center(
          child: Column (
              children: [buildStartStopButton(), buildPlayButton()]
          )
        ),
      ),
    );
  }

  void initializePlayer () async {
    _player = await FlutterSoundPlayer().openAudioSession();
  }

  void initializeRecorder () async {
    _recorder = await FlutterSoundRecorder().openAudioSession();
  }

  void startStopRecord () async {
    if (!_recording) {
      // initializeRecorder();

      // _player = await FlutterSoundPlayer().openAudioSession();

      _recorder = await FlutterSoundRecorder().openAudioSession();



      print("xxx startStopRecord: After recorder initialization");

      // Request Microphone permission if needed
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print("xxx startStopRecord: Permission not granted dude");
        throw RecordingPermissionException("Microphone permission not granted");
      }
      Directory tempDir = await getTemporaryDirectory();
      File outputFile = await File ('${tempDir.path}/flutter_sound-tmp.aac');

      if (await outputFile.exists()) {
        await File(outputFile.path).delete();
        print('Preview has been deleted $outputFile');
      }

      _file = outputFile;

      print("xxx startStopRecord: Preparing to start record");
      print("xxx startRecord ici: $tempDir");
      print("xxx startRecord ici: $outputFile");

      // recorder = FlutterAudioRecorder(outputFile.path, audioFormat: AudioFormat.WAV, sampleRate: 22000); // .wav .aac .m4a
      // await recorder.initialized;
      // await recorder.start();
      // var recording = await recorder.current(channel: 0);
      final path = await _recorder.startRecorder(toFile: outputFile.path, sampleRate: 16000, bitRate: 16000, codec: Codec.amrWB);

      print("xxx =. path: $path");

    }
    else {
      if (recorder != null) {
        print("xxx Closing audio session");
        await _recorder.stopRecorder();
        _recorder.closeAudioSession();

        // var result = await recorder.stop();
        // File file = File(result.path);
        // print("xxxx apres => $file");
        _recorder = null;
      }
    }
  }

  void playLocal() async {
    int result = await audioPlayer.play(_file.path, isLocal: true);
  }


  void startStopPlay () async {

      if (!_playing && _file != null) {
        // await initializePlayer();

        print("StartStopPlay: after initializion");
        playLocal();
        // await _player.startPlayer(fromURI: _file.path);
        print("Right after playing");
      }
      else {

        if (_player == null) {
          int result = await audioPlayer.stop();
          // await _player.stopPlay();
          _player.closeAudioSession();
          _player = null;
        }
      }
  }


  Container buildPlayButton() {

    var playText = _playing ? "Stop Play" : "Play";
    var buttonColor = _playing ? Colors.green : Colors.blue;

    return Container(
      child: ClipOval(
        child: FlatButton(
          color: buttonColor,
          textColor: Colors.white,
          disabledColor: Colors.green,
          disabledTextColor: Colors.grey,
          padding: EdgeInsets.all(8.0),
          splashColor: Colors.green,
          onPressed: () => {
            print("on pressed"),
            startStopPlay(),
            setState(() {_playing = !_playing; }),
          },
          child: Text(playText),
        ),
      ),
    );
  }

  Container buildStartStopButton() {

    var recordButtonText = _recording ? "Stop Record" : "Record";

    print("Button is on$recordButtonText");

    return Container(
      child: ClipOval(
            child: FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: EdgeInsets.all(8.0),
              splashColor: Colors.blueAccent,
              onPressed: () => {
                  setState( () {
                    startStopRecord();
                    _recording = !_recording; }
                  )
              },
              child: Text(recordButtonText),
              ),
          ),
    );
  }

}


