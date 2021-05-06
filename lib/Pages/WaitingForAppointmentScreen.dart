import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homephiys/Controller/DoctorController.dart';
import 'package:homephiys/Controller/PaitentController.dart';
import 'package:homephiys/Entitys/Paitnet.dart';
import 'package:homephiys/Entitys/WaitingPaitent.dart';
import 'package:toast/toast.dart';

class WaitingForAppointmentScreen extends StatefulWidget {
  _WaitingForAppointment createState() => _WaitingForAppointment();
  String doctorEmail;
  Paitent currentPaitent;
  StreamController<bool> streamController;
  bool is_got_notification = false;
  PaitentController controller = PaitentController();
  final DoctorController dcontroller = DoctorController();
  List<WaitingPaitent> patientNames = [];
  WaitingForAppointmentScreen(
      {@required this.doctorEmail,
      @required this.currentPaitent,
      @required this.streamController});
}

class _WaitingForAppointment extends State<WaitingForAppointmentScreen> {
  void initState() {
    Future<List<WaitingPaitent>> paitentFutureList =
        this.widget.controller.getPaitnetWaitingList(this.widget.doctorEmail);
    paitentFutureList.then((paitentList) {
      this.widget.patientNames = List.from(paitentList);
    });
    /*
    Stream stream = this.widget.streamController.stream;
    stream.listen((event) {
      this.widget.is_got_notification = event;
    });
    */

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "You are on the WaitingList!\n\npress on the watch list buttons  to see who is in line for the doctor in front of you ",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 100.0),
                      _buildCancelBtn(),
                      SizedBox(height: 20.0),
                      _buildWatchListBtn(context),
                      //  _builListOfPaitentWiting(this.widget.patientNames),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {
          if (this.widget.is_got_notification == false) {
            print(" implement remove this account from the waiting list");
          } else {
            Toast.show(
                "cannot cancel your appointment after you get a notification  ",
                context,
                duration: Toast.LENGTH_LONG,
                gravity: Toast.BOTTOM);
          }
          //if not get notifiaction so can remove the patient from the paitent Lisl
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.red,
        child: Text(
          'CANCEL',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  _buildWatchListBtn(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Paitnet Waiting List'),
                  content: setupAlertDialoadContainer(),
                );
              });
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.green,
        child: Text(
          'Watch List',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget setupAlertDialoadContainer() {
    return Container(
      height: 300.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: this.widget.patientNames.length,
        itemBuilder: (BuildContext context, int index) {
          return Text(this.widget.patientNames[index].paitent.name,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold));
        },
      ),
    );
  }
}
