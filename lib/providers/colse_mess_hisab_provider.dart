import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

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


      onFail("need to fixed, check in close mess hisab provaider");
       
      await batch.commit();
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());      
    }  
  }
}