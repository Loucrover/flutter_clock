import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*

アプリを開いたときにタイマーを動かしていたいときは、
TimerStateNotifierクラスの、TimerStateNotifier() : super(TimerState(isRunning: false));
のfalseをtrueに変更します。

 */

//  ************************************************************************

dateExchangeJapnaese() {
  initializeDateFormatting("ja");
  return "${DateFormat.yMMMEd('ja').format(DateTime.now())} ${DateFormat.Hm().format(DateTime.now())}";
}

class TimeViewUp {
  final String time;
  TimeViewUp(this.time);
  @override
  String toString() {
    return time;
  }
}

//現在時刻を更新します
class TimeViewUpNotifier extends StateNotifier<TimeViewUp> {
  TimeViewUpNotifier() : super(TimeViewUp(dateExchangeJapnaese()));
  void updateTime() {
    state = TimeViewUp(dateExchangeJapnaese());
  }
}

final timeViewUpProvider =
    StateNotifierProvider<TimeViewUpNotifier, TimeViewUp>(
        (ref) => TimeViewUpNotifier());

//  ************************************************************************

class TimerState {
  TimerState({required this.isRunning});
  final bool isRunning;
}

//タイマーの稼働状態を更新します
class TimerStateNotifier extends StateNotifier<TimerState> {
  TimerStateNotifier() : super(TimerState(isRunning: false));

  void startTimer() {
    state = TimerState(isRunning: true);
  }

  void stopTimer() {
    state = TimerState(isRunning: false);
  }
}

final timerStateProvider =
    StateNotifierProvider<TimerStateNotifier, TimerState>(
        (ref) => TimerStateNotifier());

//  ************************************************************************

class NowTimer {
  final String nowTime;
  NowTimer(this.nowTime);
  @override
  String toString() {
    return nowTime;
  }
}

class NowTimerNotifier extends StateNotifier<NowTimer> {
  final Ref ref;
  bool isRunning = false;
  int _startTime = DateTime.now().millisecondsSinceEpoch;
  int _accumulatedStoppedTime = 0;
  int _lastStopTime = DateTime.now().millisecondsSinceEpoch;

  NowTimerNotifier(this.ref) : super(NowTimer('00:00')) {
    ref.listen<TimerState>(timerStateProvider, (previous, next) {
      isRunning = next.isRunning;
      if (isRunning) {
        // タイマーが動き始めた
        _accumulatedStoppedTime +=
            DateTime.now().millisecondsSinceEpoch - _lastStopTime;
      } else {
        // タイマーが止まった
        _lastStopTime = DateTime.now().millisecondsSinceEpoch;
      }
    });

    //最初に設定されているtimeStateProviderのinRunningはlistenでは取得できないので、readから取得する
    if (ref.read(timerStateProvider).isRunning) isRunning = true;
  }

  void showNowTime() {
    if (isRunning) {
      int _seconds = ((DateTime.now().millisecondsSinceEpoch -_startTime -_accumulatedStoppedTime)/1000).floor();
      int _minutes = _seconds ~/ 60;
      var _remainingSeconds = _seconds % 60;
      state = NowTimer('${_minutes.toString().padLeft(2, '0')}:${_remainingSeconds.toString().padLeft(2, '0')}');
    }
  }
}

final nowTimerProvider = StateNotifierProvider<NowTimerNotifier, NowTimer>(
    (ref) => NowTimerNotifier(ref));


//  ************************************************************************


final itemListProvider = StateNotifierProvider<ItemListNotifier, List<String>>((ref) {
  return ItemListNotifier([]);
});

class ItemListNotifier extends StateNotifier<List<String>> {
  ItemListNotifier(List<String> state) : super(state);

  void addItem(String item) {
    state = [...state, item];
  }
}