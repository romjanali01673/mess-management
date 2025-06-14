import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/model/bazer_model.dart';

class BazerProvaider extends ChangeNotifier{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  BazerModel? _bazerModel;
  double _cost = 0;

  //set -------------

  setIsLoading({required bool value}){
    _isLoading = value;
    notifyListeners();
  }

  setCost({required double amount}){
    _cost = amount;
    notifyListeners();
  }


  // get ------------

  bool get isLoading => _isLoading;
  BazerModel? get getBazerModel => _bazerModel;
  double get getCost => _cost;

  // function -----------

  // get all Bazer transaction list 
  Future<List<BazerModel>?> getBazerTransactions({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    List<BazerModel>? list;
    double cost=0;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await firebaseFirestore.collection(Constants.bazer).doc(messId).collection(Constants.listOfBazerTransaction).get();
      list = snapshot.docs.map(
        (doc){
          BazerModel bazerModel = BazerModel.fromMap(doc.data() as Map<String, dynamic>);
          print(bazerModel.bazerList);
          cost += bazerModel.amount;
          
          return bazerModel;
        }).toList();
      
      _cost = cost;
      debugPrint(_cost.toString());
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      debugPrint('FAILED');
      onFail(e.toString());
    }  
    _isLoading  = false;
    return list?.reversed.toList();
  }

  // add a fand transaction to database 
  Future<void> addABazerTransaction({required BazerModel bazerModel,required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    // fatch cost,
    await getBazerTransactions(
      messId: messId, 
      onFail: (message) {  
        onFail(message);
      }, 
      onSuccess: () async{
        try {
          batch.set(
            firebaseFirestore.collection(Constants.bazer)
            .doc(messId)
            .collection(Constants.listOfBazerTransaction)
            .doc(bazerModel.transactionId),
            bazerModel.toMap()
          );
         
          batch.set(
            firebaseFirestore.collection(Constants.bazer)
            .doc(messId),
            {Constants.cost:getCost+bazerModel.amount}
          );

          await batch.commit();
          setCost(amount: getCost+bazerModel.amount);
          onSuccess!=null? onSuccess() : (){};
        } catch (e) {
          onFail(e.toString());
        }  
      }
    );
  }
}