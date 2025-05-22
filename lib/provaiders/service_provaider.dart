import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/model/mess_model.dart';

class ServiceProvaider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  
  bool _isOnline = true;
  bool _isLoading = false;

  ServiceProvaider(){
    _checkInitialConnection();
    _connectivity.onConnectivityChanged.listen((result) {
      
        _isOnline = (result == ConnectivityResult.none);
        notifyListeners();
      
    });
  }
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  MessModel? _messModel;

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
  MessModel get messModel =>_messModel!;
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;

  // function --------------

  // listen online ststus
    Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
      _isOnline = (result == ConnectivityResult.none);
      notifyListeners();
  }

  // insert mess data to firestore
  Future<void> storeMessDataToFirestore({required Function(String) onFail, Function()? onSuccess, required MessModel messModel})async{
    try{
      firebaseFirestore
      .collection(Constants.mess)
      // .doc(DateTime.now().millisecondsSinceEpoch.toString())
      .set(messModel.toMap());
      onSuccess!=null? onSuccess():(){};
    } catch(e){
      onFail(e.toString());
    }
  }



}