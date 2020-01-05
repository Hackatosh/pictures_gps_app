import 'dart:async';

class CustomTask {
  Duration _duration;
  void Function(Timer timer) _task;
  Timer _timer;

  CustomTask(this._duration,this._task);

  void start(){
    if(_timer == null){
      _timer = Timer.periodic(_duration, _task);
    }
  }

  void stop(){
    _timer?.cancel();
    _timer = null;
  }

  void dispose(){
    _timer?.cancel();
    _timer = null;
  }
}