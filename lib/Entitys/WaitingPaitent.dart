import 'Paitnet.dart';

class WaitingPaitent {
  Paitent _paitent;
  DateTime _time;

  WaitingPaitent(Paitent paitent, DateTime time) {
    this._paitent = paitent;
    this._time = time;
  }

  Paitent get paitent => _paitent;
  DateTime get arrivalTime => _time;
}
