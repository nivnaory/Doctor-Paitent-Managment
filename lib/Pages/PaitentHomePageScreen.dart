import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:homephiys/Controller/DoctorController.dart';
import 'package:homephiys/Controller/PaitentController.dart';
import 'package:homephiys/Entitys/Doctor.dart';
import 'package:homephiys/Entitys/Paitnet.dart';
import 'package:homephiys/Entitys/WaitingPaitent.dart';
import 'package:homephiys/Pages/WaitingForAppointmentScreen.dart';
import 'package:homephiys/utilitis/constant.dart';

class PaitnetHomePageScreen extends StatefulWidget {
  //StreamController<Doctor> streamController = StreamController();
  StreamController<bool> streamControllerNotification =
      StreamController<bool>.broadcast();
  _PaitnetHomePageScreen createState() => _PaitnetHomePageScreen();
  final CollectionReference doctorCollection =
      Firestore.instance.collection("Doctors");
  List<Doctor> doctors = [];
  List<Doctor> dynamicListOfDoctors = [];
  List<bool> is_in_waiting_list = [false, false, false, false, true, true];
  Paitent currentPaitent;
  int paitentCounter = 0;
  final DoctorController dcontroller = DoctorController();
  final PaitentController pcontroller = PaitentController();
  PaitnetHomePageScreen(
      {@required this.doctors, @required this.currentPaitent});
}

class _PaitnetHomePageScreen extends State<PaitnetHomePageScreen> {
  final List<ListItem> _dropdownItems = [
    ListItem(1, "All"),
    ListItem(2, "Available"),
  ];
  List<DropdownMenuItem<ListItem>> _dropdownMenuItems;
  ListItem _selectedItem;
  String dropdownValue = 'One';

  void initState() {
    this.widget.dynamicListOfDoctors = List.from(this.widget.doctors);
    listinerToDBChange();

    super.initState();
    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    _selectedItem = _dropdownMenuItems[0].value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent,
      child: Column(
        children: <Widget>[
          SizedBox(height: 10.0),
          _builDropDownMenu(),
          _builListOfDoctors(),
        ],
      ),
    );
  }

  Widget _builDropDownMenu() {
    return Card(
      color: Colors.white,
      elevation: 15.0,
      margin: const EdgeInsets.only(top: 50.0),
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: DropdownButton<ListItem>(
            value: _selectedItem,
            items: _dropdownMenuItems,
            onChanged: (value) {
              setState(() {
                _selectedItem = value;
                if (_selectedItem.name == "Available") {
                  this.widget.dynamicListOfDoctors.clear();
                  for (int i = 0; i < this.widget.doctors.length; i++) {
                    if (this.widget.doctors[i].isAvilable) {
                      this
                          .widget
                          .dynamicListOfDoctors
                          .add(this.widget.doctors[i]);
                    }
                  }
                } else {
                  this.widget.dynamicListOfDoctors =
                      List.from(this.widget.doctors);
                }
              });
            }),
      ),
    );
  }

  Widget _builListOfDoctors() {
    return Expanded(
      child: Center(
        child: ListView.builder(
          itemCount: this.widget.dynamicListOfDoctors.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) => Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Card(
              elevation: 70.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 55.0,
                          height: 55.0,
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.green,
                            backgroundImage: NetworkImage(
                                "https://cdn.sanity.io/images/0vv8moc6/hcplive/0ebb6a8f0c2850697532805d09d4ff10e838a74b-200x200.jpg?auto=format"),
                          ),
                        ),
                        SizedBox(width: 5.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(this.widget.dynamicListOfDoctors[index].name,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: FlatButton(
                        onPressed: () {
                          if (this
                              .widget
                              .dynamicListOfDoctors[index]
                              .isAvilable) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.SUCCES,
                              animType: AnimType.BOTTOMSLIDE,
                              title: ' you choose  ' +
                                  this
                                      .widget
                                      .dynamicListOfDoctors[index]
                                      .name
                                      .toString(),
                              desc: 'for making  an appointment press OK',
                              btnOkOnPress: () {
                                this
                                    .widget
                                    .dynamicListOfDoctors[index]
                                    .isAvilable = false;
                                this.widget.dcontroller.updateDoctor(
                                    this
                                        .widget
                                        .dynamicListOfDoctors[index]
                                        .email,
                                    false);
                              },
                            )..show();
                          } else {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.INFO,
                              animType: AnimType.BOTTOMSLIDE,
                              title: ' Sorry',
                              desc:
                                  'this Doctor is Unavilable right now,to enter to the waiting list  press ok or chancel',
                              btnOkOnPress: () {
                                //update the db
                                Future<bool> f = this
                                    .widget
                                    .dcontroller
                                    .updateWaitingList(
                                        this
                                            .widget
                                            .dynamicListOfDoctors[index]
                                            .email,
                                        this.widget.currentPaitent.email,
                                        this.widget.currentPaitent.name);

                                //read the new waitingList
                                Future<List<WaitingPaitent>> futureWaiting =
                                    this
                                        .widget
                                        .pcontroller
                                        .getPaitnetWaitingList(
                                            this.widget.doctors[index].email);
                                futureWaiting.then((value) {
                                  this
                                      .widget
                                      .doctors[index]
                                      .waitingPaitentList = value;
                                });

                                f.then((value) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              WaitingForAppointmentScreen(
                                                  doctorEmail: this
                                                      .widget
                                                      .dynamicListOfDoctors[
                                                          index]
                                                      .email,
                                                  currentPaitent: this
                                                      .widget
                                                      .currentPaitent,
                                                  streamController: this
                                                      .widget
                                                      .streamControllerNotification)));
                                });
                              },
                              btnCancelOnPress: () {},
                            )..show();
                          }
                        },
                        color: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          "choose",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<ListItem>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ListItem>> items = List();
    for (ListItem listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.name),
          value: listItem,
        ),
      );
    }
    return items;
  }

  void listinerToDBChange() {
    this.widget.doctorCollection.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((element) {
        // if db modifed
        if (element.type.index == modifed) {
          for (int i = 0; i < this.widget.doctors.length; i++) {
            if (element.document.data['email'] ==
                    this.widget.doctors[i].email &&
                element.document.data['isAvailable'] == true) {
              this.widget.doctors[i].isAvilable = true;

              if (this.widget.doctors[i].waitingPaitentList.isNotEmpty &&
                  this.widget.doctors[i].waitingPaitentList[0].paitent.email ==
                      this.widget.currentPaitent.email) showDialog(i);
            } else if (element.document.data['isAvailable'] == false) {
              this.widget.doctors[i].isAvilable = false;
            }
          }
        }
      });
    });
  }

  void showDialog(int index) {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.INFO,
        animType: AnimType.BOTTOMSLIDE,
        title: 'hello',
        desc: 'your  appointment is ready press ok to start',
        btnOkOnPress: () {
          //this is need to return a new watinigPaitentList
          //so need to find the current doctor and to update his list
          this.widget.dcontroller.removerPaitnetFromWaitingList(
              this.widget.doctors[index].email,
              this.widget.currentPaitent.email);
          this
              .widget
              .dcontroller
              .updateDoctor(this.widget.doctors[index].email, false);
          Future<List<WaitingPaitent>> futureWaiting = this
              .widget
              .pcontroller
              .getPaitnetWaitingList(this.widget.doctors[index].email);
          futureWaiting.then((value) {
            if (value.isNotEmpty)
              this.widget.doctors[index].waitingPaitentList = value;
            else {
              this.widget.doctors[index].waitingPaitentList.clear();
            }
          });

          //find doctor by email

          //user press ok and now to doctor is again unavailable
          // for x period of time!
        })
      ..show();
  }

  Doctor findDoctorByEmail(String _email) {
    for (int i = 0; i < this.widget.doctors.length; i++) {
      if (this.widget.doctors[i].email == _email) {
        return this.widget.doctors[i];
      }
    }
  }
}

class ListItem {
  int value;
  String name;

  ListItem(this.value, this.name);
}
