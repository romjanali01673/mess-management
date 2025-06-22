import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/model/fand_model.dart';

class FandProvider extends ChangeNotifier{

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


  void reset(){
    _fandModel = null;
  }


  // function -----------

  Future<double> getFandBlance({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    print("called total fand");
    double blance = 0.0;
    try {
      DocumentSnapshot snapshot =  await firebaseFirestore.collection(Constants.fand).doc(messId).get();
      if(snapshot.exists && snapshot.data() != null){
        blance = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.blance]).toString());
        setBlance(amount: blance);
      }
        print(blance);
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
    return blance;
  }

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

          if(fandModel.type ==Constants.add){
            batch.set(
              firebaseFirestore.collection(Constants.fand)
              .doc(messId),
              
              {Constants.blance:FieldValue.increment(fandModel.amount)},
              SetOptions(
                mergeFields: [
                  Constants.blance
                ]
              )            
            );
          }
          else{
            batch.set(
              firebaseFirestore.collection(Constants.fand)
              .doc(messId),
              {Constants.blance:FieldValue.increment(-fandModel.amount)},
              SetOptions(
                mergeFields: [
                  Constants.blance
                ]
              )
            );
          }

          await batch.commit();

          onSuccess!=null? onSuccess() : (){};
        } catch (e) {
          onFail(e.toString());
        } 
  }

  // update a fand transaction to database 
  Future<void> updateAFandTransaction({required FandModel fandModel,required String messId,required double extraAmount, required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();

    try {

      batch.set(
        firebaseFirestore.collection(Constants.fand)
        .doc(messId)
        .collection(Constants.listOfFandTransaction)
        .doc(fandModel.transactionId),
        fandModel.toMap(),
        SetOptions(
          mergeFields: [
            Constants.amount, 
            Constants.title,  
            Constants.description,
          ]
        )
      );

      fandModel.type==Constants.add?
      batch.update(
        firebaseFirestore.collection(Constants.fand)
        .doc(messId),
        {Constants.blance: FieldValue.increment(extraAmount)}
      )
      :
      batch.update(
        firebaseFirestore.collection(Constants.fand)
        .doc(messId),
        {Constants.blance: FieldValue.increment(-extraAmount)}
      );
        
      await batch.commit();
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    } 
  }
    
  



  // delete a fand transaction
  Future<void> deleteAFandTransaction({required String messId, required String tnxId,required double extraAmount, required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    try {
      batch.delete(
        firebaseFirestore.collection(Constants.fand).doc(messId).collection(Constants.listOfFandTransaction).doc(tnxId),
      );

      batch.update(firebaseFirestore.
        collection(Constants.fand)
        .doc(messId),
        {Constants.blance : FieldValue.increment(extraAmount)}
      );
      onSuccess!=null? onSuccess(): (){};
      await batch.commit();
    } catch (e) {
      onFail(e.toString());
    }
  }
  
}