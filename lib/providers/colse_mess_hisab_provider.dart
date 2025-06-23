import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/model/bazer_model.dart';

class ColseMessHisabProvider extends ChangeNotifier{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  bool _isLoading = false;


  //set -------------




  // get ------------

  bool get isLoading => _isLoading;



  void reset(){
    // null;
  }


  // function -----------

  // add a bazer transaction to database 
  Future<void> closeMessHisab({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    // fatch cost,
    
    try {
      batch.delete(
        firebaseFirestore.collection(Constants.bazer)
        .doc(messId),
      );

      batch.delete(
        firebaseFirestore.collection(Constants.meal)
        .doc(messId),
      );

      batch.delete(
        firebaseFirestore.collection(Constants.deposit)
        .doc(messId),
      );
       
      await batch.commit();
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());      
    }  
  }
}