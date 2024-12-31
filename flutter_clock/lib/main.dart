import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_clock/stateclass.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeViewUp = ref.watch(timeViewUpProvider);
    final showNowTime = ref.watch(nowTimerProvider);
    final bool exchaButton = ref.watch(timerStateProvider).isRunning;
    final items = ref.watch(itemListProvider);

    Timer.periodic(Duration(microseconds: 1000), (timer) {
      ref.read(timeViewUpProvider.notifier).updateTime();
      ref.read(nowTimerProvider.notifier).showNowTime();
    });

    return MaterialApp(
      title: 'My Stopwatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('My Stopwatch')),
        body: Center(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  width: 335,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 188, 188, 188),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text('$timeViewUp'))),
              Stack(alignment: Alignment.center, children: [
                ClipPath(
                  clipper: MyTimeFrame(),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 188, 188, 188),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  child: Text('$showNowTime',
                      style: TextStyle(fontSize: 48, color: Colors.white)),
                ),
                Positioned(
                    top: 150,
                    child: GestureDetector(
                      onTap: () {
                        exchaButton ? stopTimer(ref) : startTimer(ref);
                      },
                      child: Icon(
                          !exchaButton ? Icons.play_circle : Icons.pause_circle,
                          size: 48),
                    ))
              ]),
              GestureDetector(
                onTap: () {
                  exchaButton ? stopTimer(ref) : startTimer(ref);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  width: 335,
                  height: 48,
                  decoration: BoxDecoration(
                    color: exchaButton
                        ? const Color.fromARGB(255, 233, 146, 144)
                        : const Color.fromARGB(255, 166, 144, 233),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                      child: Text(exchaButton ? 'タイマーを停止する' : 'タイマーを開始する')),
                ),
              ),
              GestureDetector(
                onTap: () {
                  //ラップリストに保存する処理
                  ref.read(itemListProvider.notifier).addItem('$showNowTime');
                },
                child: Container(
                  margin: EdgeInsets.only(top: 0, right: 8, left: 8, bottom: 16),
                  width: 335,
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(child: Text('ラップを記録する')),
                ),
              ),
              Container(
                width: 400,
                child: Divider(),
              ),
              Expanded(
                child: Container(
                  width: 335,
                  child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical:0, horizontal: 0),
                      child: Row(
                        children: [
                          Text('ラップ${items.length-index}'),
                          Expanded(
                            child: Text('${items.reversed.toList()[index]}',textAlign: TextAlign.right),
                          ),
                        ]
                      ),
                    );
                  },
              )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyTimeFrame extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 1),
        radius: size.width / 3,
      ))
      ..fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

void stopTimer(dynamic ref) {
  ref.read(timerStateProvider.notifier).stopTimer();
}

void startTimer(dynamic ref) {
  ref.read(timerStateProvider.notifier).startTimer();
}
