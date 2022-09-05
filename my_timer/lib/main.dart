import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MY TIMER'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? _timer;
  final _limitController = TextEditingController(text: '300');
  final _delayController = TextEditingController(text: '30');
  final _player = AudioPlayer();

  late int _limit;
  late int _delay;
  var _time = 0;
  var _isPlaying = false;
  var _isWait = false;

  var _btnIcon = Icons.play_arrow;
  var _btnColor = Colors.blue;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void alarm() async {
    _isWait = !_isWait;
    _time = 0;
    await _player.play(AssetSource(_isWait ? 'end.mp3' : 'start.mp3'));
  }

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (!_isWait && _limit - 1 <= _time) {
          alarm();
        } else if (_isWait && _delay - 1 <= _time) {
          alarm();
        } else {
          _time++;
        }
      });
    });
  }

  void _reset() {
    setState(() {
      _isPlaying = false;
      _isWait = false;
      _timer?.cancel();
      _time = 0;
    });
  }

  void _click() {
    _isPlaying = !_isPlaying;
    _limitController.text =
        _limitController.text == '' ? '300' : _limitController.text;
    _delayController.text =
        _delayController.text == '' ? '30' : _delayController.text;
    _limit = int.parse(_limitController.text);
    _delay = int.parse(_delayController.text);
    if (_isPlaying) {
      _btnIcon = Icons.stop;
      _btnColor = Colors.red;
      _start();
    } else {
      _btnIcon = Icons.play_arrow;
      _btnColor = Colors.blue;
      _reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${_time ~/ 60 < 10 ? '0${_time ~/ 60}' : '${_time ~/ 60}'} ${_time % 60 < 10 ? '0${_time % 60}' : '${_time % 60}'}',
                          style: TextStyle(
                            fontSize: 100.0,
                            fontWeight: FontWeight.bold,
                            color: !_isWait ? Colors.black : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 4.0),
                          child: TextField(
                            controller: _limitController,
                            decoration: const InputDecoration(
                              labelText: 'LIMIT',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp("[0-9]")),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(4.0, 0.0, 8.0, 4.0),
                          child: TextField(
                            controller: _delayController,
                            decoration: const InputDecoration(
                              labelText: 'DELAY',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp("[0-9]")),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _click();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _btnColor,
                          minimumSize: const Size(double.infinity, 50.0)),
                      child: Icon(_btnIcon),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
