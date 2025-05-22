import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/model/mess_model.dart';
import 'package:meal_hisab/provaiders/authantication_provaider.dart';
import 'package:provider/provider.dart';

class ServiceProvaider extends ChangeNotifier {
    List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  bool _isOnline = true;
  bool _isLoading = false;
  MessModel? _messModel;

  ServiceProvaider(){
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  
  }
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;


  // set ------------------------------
  void setIsOnline(bool val){
    _isOnline = val;
    notifyListeners();
  }
  void setIsloading(bool val){
    _isLoading = val;
    notifyListeners();
  }
  

  // get -----------------------------
  MessModel? get getMessModel =>_messModel;
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;

  // function --------------


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status',);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    return _updateConnectionStatus(result);
  }

    Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    _connectionStatus = result;
    // ignore: avoid_print
    print('Connectivity changed: $_connectionStatus');
    if(_connectionStatus.contains(ConnectivityResult.none)){
      setIsOnline(false);
    }
    else{
      setIsOnline(true);
    }
  }

  // insert mess data to firestore
  Future<void> storeMessDataToFirestore({required Function(String) onFail, Function()? onSuccess, required MessModel messModel})async{
    try{
      String cratedMessId = DateTime.now().millisecondsSinceEpoch.toString();
      messModel.messId = cratedMessId;
      _messModel = messModel;

      firebaseFirestore
      .collection(Constants.mess)
      .doc(cratedMessId)
      .set(messModel.toMap());
      onSuccess!=null? onSuccess():(){};
    } catch(e){
      onFail(e.toString());
    }
  }

  // assign Mess- Id To Member Profile
  Future<void> assignMessIdToMemberProfile({required Function(String) onFail, Function()? onSuccess,required String memberUid})async{
    try{

      firebaseFirestore
      .collection(Constants.users)
      .doc(memberUid)
      .set(
        {
          Constants.currentMessId :getMessModel!.messId
        },
        SetOptions(merge: true),
        
      );
      onSuccess!=null? onSuccess():(){};
    } catch(e){
      onFail(e.toString());
    }
  }

  // assign Mess- Id To Member Profile
  Future<void> removeMessIdToMemberProfile({required Function(String) onFail, Function()? onSuccess,required String memberUid})async{
    try{
      firebaseFirestore
      .collection(Constants.users)
      .doc(memberUid)
      .set(
        {
          Constants.currentMessId : "",
        },
        SetOptions(merge: true),
        
      );
      onSuccess!=null? onSuccess():(){};
    } catch(e){
      onFail(e.toString());
    }
  }

}