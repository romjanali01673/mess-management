import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/model/fand_model.dart';

class FandProvaider extends ChangeNotifier{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  FandModel? _fandModel;
  double _blance = -1;

  //set -------------

  setIsLoading({required bool value}){
    _isLoading = value;
    notifyListeners();
  }

  setBlance({required double amount}){
    _blance = amount;
    notifyListeners();
  }


  // get ------------

  bool get isLoading => _isLoading;
  FandModel? get getFandModel => _fandModel;
  double get getBlance => _blance;

  // function -----------

  // get all fand transaction list 
  Future<List<FandModel>?> getFandTransactions({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    List<FandModel>? list;
    double blance=0;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await firebaseFirestore.collection(Constants.fand).doc(messId).collection(Constants.listOfFandTransaction).get();
      list = snapshot.docs.map(
        (doc){
          FandModel fandModel = FandModel.fromMap(doc.data() as Map<String, dynamic>);
          
          if(fandModel.type==Constants.add) blance += fandModel.amount;
          else blance -= fandModel.amount;
          
          return fandModel;
        }).toList();
      
      _blance = blance;
      debugPrint(_blance.toString());
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
    _isLoading  = false;
    return list?.reversed.toList();
  }

  // add a fand transaction to database 
  Future<void> addAFandTransaction({required FandModel fandModel,required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    try {

      batch.set(
        firebaseFirestore.collection(Constants.fand)
        .doc(messId)
        .collection(Constants.listOfFandTransaction)
        .doc(fandModel.transactionId),
        fandModel.toMap()
      );

      await batch.commit();

      // await firebaseFirestore
      //   .collection(Constants.fand)
      //   .doc(messId)
      //   .collection(Constants.listOfFandTransaction)
      //   .doc(fandModel.transactionId)
      //   .set(fandModel.toMap());
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
  }

  //
  
}