import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homephiys/Entitys/Paitnet.dart';
import 'package:homephiys/Entitys/WaitingPaitent.dart';
//this function  handel the connection to database

class PaitentController {
  final CollectionReference doctorCollection =
      Firestore.instance.collection("Doctors");
  final CollectionReference paitentCollection =
      Firestore.instance.collection("Paitents");
  PaitentController();

  Future<bool> registerPaitnet(
      String email, String password, String fullName) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await paitentCollection.document(email).setData({
        'email': email,
        'name': fullName,
      });
      return Future.value(true);
    } catch (e) {
      print(e);
      return Future.value(false);
    }
  }

  Future<bool> loginPaitent(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return Future.value(true);
    } catch (e) {
      print(e);
      return Future.value(false);
    }
  }

  Future<Paitent> getPaitent(String email) async {
    try {
      Paitent newPaitetn;
      await paitentCollection.document(email).get().then((paitent) {
        newPaitetn = new Paitent(
            paitent.data['email'].toString(), paitent.data['name'].toString());
      });

      return Future.value(newPaitetn);
    } catch (e) {
      print(e);
      return Future.value(null);
    }
  }

  Future<List<WaitingPaitent>> getPaitnetWaitingList(String doctorEmail) async {
    try {
      List<WaitingPaitent> waitingList = [];
      var snapshotWaitingPaitent = await doctorCollection
          .document(doctorEmail)
          .collection("paitents_waiting")
          .orderBy("time")
          .getDocuments();

      snapshotWaitingPaitent.documents.forEach((element) {
        DateTime arrivalTime = element['time'].toDate();

        WaitingPaitent waitingPaitent = WaitingPaitent(
            new Paitent(
                element['paitent'].toString(), (element['name'].toString())),
            arrivalTime);

        waitingList.add(waitingPaitent);
      });

      return Future.value(waitingList);
    } catch (e) {
      print(e);
      return Future.value(null);
    }
  }
}
