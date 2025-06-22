import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/deposit/deposit.dart';
import 'package:meal_hisab/model/deposit_model.dart';

class DepositProvider extends ChangeNotifier{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  DepositModel? _depositModel;
  double _totalDeposit = -1;
  double _totalDepositOfMess = -1;

  //set -------------

  setIsLoading({required bool value}){
    _isLoading = value;
    notifyListeners();
  }

  setTotalDeposit({required double amount}){
    _totalDeposit = amount;
    notifyListeners();
  }
  setTotalDepositOfMess({required double amount}){
    _totalDepositOfMess = amount;
    notifyListeners();
  }


  // get ------------

  bool get isLoading => _isLoading;
  
  DepositModel? get getDepositModel => _depositModel;
  double get getTotalDeposit => _totalDeposit;
  double get getTotalDepositOfMess => _totalDepositOfMess;


  void reset(){
    _depositModel = null;
  }

  // function -----------

  // get all deposit transaction list 
  Future<void> getDepositAmount({required String messId, String? uId, required Function(String) onFail, Function()? onSuccess,})async{
    double depositOfMember = 0; 
    double depositOfmess = 0;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await firebaseFirestore.collection(Constants.deposit).doc(messId).collection(Constants.member).get();
      List<QueryDocumentSnapshot> memberUidDocList = snapshot.docs;
      for(var memberUidDoc in memberUidDocList){
        
        // for hole mess
        if(memberUidDoc.exists && memberUidDoc.data()!=null){
          depositOfmess += (memberUidDoc.data() as Map<String, dynamic> )[Constants.deposit];
        }

        // for member 
        if(uId!=null){
          if(uId==memberUidDoc.id){
            if (memberUidDoc.exists && (memberUidDoc.data() != null)){
              depositOfMember = (memberUidDoc.data() as Map<String,dynamic>)[Constants.deposit];
            }
          }
        }
      }
      _totalDepositOfMess = depositOfmess;
      _totalDeposit =depositOfMember ;

      onSuccess!=null? onSuccess():(){};
    
    } catch (e) {
      onFail(e.toString());
      debugPrint("getDepositAmount");
    }  
    _isLoading  = false;
    
  }

  // get member list 
  Future<List<DepositModel>?> getMemberDepositList({required String messId, String? uId, required Function(String) onFail, Function()? onSuccess,})async{
    List<DepositModel>? list;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await firebaseFirestore.collection(Constants.deposit).doc(messId).collection(Constants.member).doc(uId).collection(Constants.listOfDepositTransactions).get();
      if(snapshot.docs.isNotEmpty){
        for(var x in snapshot.docs){
          list??=[];
          list.add(DepositModel.fromMap(x.data() as Map<String, dynamic>));
        }
      }
      
      onSuccess!=null? onSuccess():(){};
      return list?.reversed.toList();
    
    } catch (e) {
      onFail(e.toString());
      debugPrint("getDepositAmount");
    }  
    _isLoading  = false;
    return null;
  }

  // get total deposit of a member 
  Future<double> getTotalDepositOfAMember({required String messId, required String uId, required Function(String) onFail, Function()? onSuccess,})async{
    double amount = 0.0;
    try {
      DocumentSnapshot snapshot =  await firebaseFirestore.collection(Constants.deposit).doc(messId).collection(Constants.member).doc(uId).get();
      if(snapshot.exists && snapshot.data() != null){
        amount = (snapshot.data() as Map<String, dynamic>)[Constants.deposit];
      }
      onSuccess!=null? onSuccess():(){};    
    } catch (e) {
      onFail(e.toString());
      debugPrint("getDepositAmount");
    }  
    _isLoading  = false;
    return amount;
  }

  // get all deposit list 
  // {DepositModel,{fname,uid}}
  Future<List<Map<String, dynamic>>?> getAllDepositList({required String messId, required Function(String) onFail, Function()? onSuccess,})async{
    List<Map<String, dynamic>>? list;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await firebaseFirestore.collection(Constants.deposit).doc(messId).collection(Constants.member).get();
      for(var member in snapshot.docs){// here member contain uid doc

        QuerySnapshot dipositListOfTheMember = await firebaseFirestore.collection(Constants.deposit).doc(messId).collection(Constants.member).doc(member.id).collection(Constants.listOfDepositTransactions).get();
        DocumentSnapshot userData = await firebaseFirestore.collection(Constants.users).doc(member.id).get();
        if(dipositListOfTheMember.docs.isNotEmpty){
          for(var x in dipositListOfTheMember.docs){
            list??=[];
            list.add({
              Constants.deposit : DepositModel.fromMap(x.data() as Map<String, dynamic>),
              Constants.userData : {
                Constants.uId : (userData.data()as Map<String,dynamic>)[Constants.uId],
                Constants.fname : (userData.data()as Map<String,dynamic>)[Constants.fname],
              },
            });
          }
        }
      }

      onSuccess!=null? onSuccess():(){};
      _isLoading = false;
      return list;
    
    } catch (e) {
      onFail(e.toString());
      debugPrint("getDepositAmount");
    }  
    _isLoading  = false;
    return null;
  }

  // add a fand transaction to database 
  Future<void> addADepositTransaction({required DepositModel depositModel, required String uId,  required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
        try {

          // add member diposite transaction
          batch.set(
            firebaseFirestore.collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.member)
            .doc(uId)
            .collection(Constants.listOfDepositTransactions)
            .doc(depositModel.transactionId),
            
            depositModel.toMap()
          );

          // add total diposite
          batch.set( // we can't use update here because initially the document was not exist
            firebaseFirestore.collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.member)
            .doc(uId),
            
            depositModel.type==Constants.deposit? 
            {Constants.deposit : FieldValue.increment( depositModel.amount)}
            :
            {Constants.deposit : FieldValue.increment(-depositModel.amount)},
            SetOptions(
              mergeFields: [
                Constants.deposit
              ]
            )
          );
          
          batch.set( // we can't use update here because initially the document was not exist
            firebaseFirestore.collection(Constants.deposit)
            .doc(messId),
            
            depositModel.type==Constants.deposit? 
            {Constants.deposit : FieldValue.increment( depositModel.amount)}
            :
            {Constants.deposit : FieldValue.increment(-depositModel.amount)},
            SetOptions(
              mergeFields: [
                Constants.deposit
              ]
            )
          );

          await batch.commit();
          onSuccess!=null? onSuccess() : (){};
        } catch (e) {
          onFail(e.toString());
        } 
  }

  // update a deposit transaction to database 
  Future<void> updateADepositTransaction({required DepositModel depositModel, required String uId,required double extraAmount, required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
        try {
          
          // add new data data 
          batch.set(
            firebaseFirestore.collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.member)
            .doc(uId)
            .collection(Constants.listOfDepositTransactions)
            .doc(depositModel.transactionId),
            
            depositModel.toMap(),

            SetOptions(
              mergeFields: [
                Constants.amount, 
                Constants.description, 
              ]
            )
          );

          // increment my total diposite
          batch.set( // we can't use update here because initially the document was not exist
            firebaseFirestore.collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.member)
            .doc(uId),
            
            depositModel.type==Constants.deposit? 
            {Constants.deposit : FieldValue.increment(extraAmount)}
            :
            {Constants.deposit : FieldValue.increment(-extraAmount)},
            SetOptions(
              mergeFields: [
                Constants.deposit
              ]
            )
          );
          
          // increment mess total diposite
          batch.set(
            firebaseFirestore.collection(Constants.deposit)
            .doc(messId),
            
            depositModel.type==Constants.deposit? 
            {Constants.deposit : FieldValue.increment( extraAmount)}
            :
            {Constants.deposit : FieldValue.increment(-extraAmount)},
            SetOptions(
              mergeFields: [
                Constants.deposit
              ]
            )

          );

          await batch.commit();
          onSuccess!=null? onSuccess() : (){};
        } catch (e) {
          onFail(e.toString());
        } 
  }

  // delete a deposit transaction to database 
  Future<void> deleteADepositTransaction({required DepositModel depositModel, required String uId,  required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
        try {

          // delete the pre data 
          batch.delete(
            firebaseFirestore.collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.member)
            .doc(uId)
            .collection(Constants.listOfDepositTransactions)
            .doc(depositModel.transactionId)
          );

          // decrement my total diposite
          batch.update( // we can't use update here because initially the document was not exist
            firebaseFirestore.collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.member)
            .doc(uId),
            
            depositModel.type==Constants.deposit? 
            {Constants.deposit : FieldValue.increment(-depositModel.amount)}
            :
            {Constants.deposit : FieldValue.increment( depositModel.amount)}
          );
          
          // decrement mess total diposite
          batch.update(
            firebaseFirestore.collection(Constants.deposit)
            .doc(messId),
            
            depositModel.type==Constants.deposit? 
            {Constants.deposit : FieldValue.increment(-depositModel.amount)}
            :
            {Constants.deposit : FieldValue.increment( depositModel.amount)}
          );

          await batch.commit();
          onSuccess!=null? onSuccess() : (){};
        } catch (e) {
          onFail(e.toString());
        } 
  }


}