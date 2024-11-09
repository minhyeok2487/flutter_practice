import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const defaultMinutes = 25;
  int minutes = defaultMinutes;
  int totalSeconds = defaultMinutes * 60;
  bool isRunning = false;
  int totalPomodoros = 0;
  late Timer timer;

  // 오디오 플레이어 초기화
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    // 배경음악 설정
    audioPlayer.setReleaseMode(ReleaseMode.loop); // 반복 재생
    audioPlayer.setVolume(0.5); // 볼륨 설정 (0.0 ~ 1.0)
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  // 배경음악 재생/정지
  Future<void> playBackgroundMusic() async {
    await audioPlayer
        .play(AssetSource('audio/campfire.mp3')); // 실제 파일 이름으로 변경하세요
  }

  Future<void> stopBackgroundMusic() async {
    await audioPlayer.stop();
  }

  // 음소거 토글
  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
      audioPlayer.setVolume(isMuted ? 0.0 : 0.5);
    });
  }

  void onTick(Timer timer) {
    if (totalSeconds == 0) {
      setState(() {
        totalPomodoros = totalPomodoros + 1;
        isRunning = false;
        totalSeconds = minutes * 60;
      });
      stopBackgroundMusic();
      timer.cancel();
    } else {
      setState(() {
        totalSeconds = totalSeconds - 1;
      });
    }
  }

  void onStartPressed() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      onTick,
    );
    setState(() {
      isRunning = true;
    });
    playBackgroundMusic();
  }

  void onPausePressed() {
    timer.cancel();
    setState(() {
      isRunning = false;
    });
    stopBackgroundMusic();
  }

  void onResetPressed() {
    timer.cancel();
    setState(() {
      isRunning = false;
      totalSeconds = minutes * 60;
    });
    stopBackgroundMusic();
  }

  void showTimePickerDialog() {
    if (isRunning) return;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 280,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        totalSeconds = minutes * 60;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('확인'),
                  ),
                ],
              ),
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: minutes - 1,
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      minutes = index + 1;
                    });
                  },
                  children: List<Widget>.generate(60, (int index) {
                    return Center(
                      child: Text(
                        '${index + 1}분',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String format(int seconds) {
    var duration = Duration(seconds: seconds);
    return duration.toString().split(".").first.substring(2, 7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: isRunning
                        ? const EdgeInsets.only(left: 50)
                        : EdgeInsets.zero,
                    child: GestureDetector(
                      onTap: showTimePickerDialog,
                      child: Text(
                        format(totalSeconds),
                        style: TextStyle(
                          color: Theme.of(context).cardColor,
                          fontSize: 89,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (isRunning)
                    IconButton(
                      icon: Icon(
                        isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Theme.of(context).cardColor,
                        size: 40,
                      ),
                      onPressed: toggleMute,
                    ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 120,
                    color: Theme.of(context).cardColor,
                    onPressed: isRunning ? onPausePressed : onStartPressed,
                    icon: Icon(isRunning
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline),
                  ),
                  if (isRunning)
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: ElevatedButton(
                        onPressed: onResetPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                          foregroundColor:
                              Theme.of(context).textTheme.displayLarge!.color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pomodoros',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.displayLarge!.color,
                          ),
                        ),
                        Text(
                          '$totalPomodoros',
                          style: TextStyle(
                            fontSize: 58,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.displayLarge!.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
