import 'package:homephiys/Entitys/WaitingPaitent.dart';

class Doctor {
  String _email;
  String _name;
  int _doctorId;
  bool _isAvilable;
  List<WaitingPaitent> _waitingPaitentList;
  Doctor(String email, String name, bool isAvilable) {
    this._email = email;
    this._name = name;
    this._isAvilable = isAvilable;
    _waitingPaitentList = [];
  }
  String get email => _email;
  String get name => _name;
  bool get isAvilable => _isAvilable;
  int get doctorId => _doctorId;
  List<WaitingPaitent> get waitingPaitentList => _waitingPaitentList;

  set doctorId(int value) {
    _doctorId = value;
  }

  set userName(String value) {
    _name = value;
  }

  set isAvilable(bool value) {
    _isAvilable = value;
  }

  set waitingPaitentList(List<WaitingPaitent> list) {
    _waitingPaitentList = list;
  }

/*
  factory Doctor.fromJson(json) {
    bool is_Available = json['is_Available'];

    Doctor newDoctor = new Doctor(json['username'].toString(), is_Available);
    return newDoctor;
  }
  */
}
