import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/deposit/deposit.dart';
import 'package:mess_management/model/deposit_model.dart';

class DepositProvider extends ChangeNotifier{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  DepositModel? _depositModel;
  double _totalDeposit = 0;
  double _totalDepositOfMess = 0;

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
    _totalDeposit = 0;
    _totalDepositOfMess = 0;
  }

  // function -----------


  // get all deposit transaction list 
  Future<void> getDepositAmount({required String messId,required String mealSessionId, String? uId, required Function(String) onFail, Function()? onSuccess,})async{
    double depositOfMember = 0; 
    double depositOfmess = 0;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await 
        firebaseFirestore
        .collection(Constants.deposit)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .collection(Constants.members)
        .get();
      List<QueryDocumentSnapshot> memberUidDocList = snapshot.docs;
      for(var memberUidDoc in memberUidDocList){
        
        // for hole mess
        if(memberUidDoc.exists && memberUidDoc.data()!=null){
          depositOfmess += (memberUidDoc.data() as Map<String, dynamic> )[Constants.blance];
        }

        // for member 
        if(uId!=null){
          if(uId==memberUidDoc.id){
            if (memberUidDoc.exists && (memberUidDoc.data() != null)){
              depositOfMember = (memberUidDoc.data() as Map<String,dynamic>)[Constants.blance];
            }
          }
        }
      }
      _totalDepositOfMess = depositOfmess;
      _totalDeposit =depositOfMember ;

      onSuccess?.call();
    
    } catch (e) {
      onFail(e.toString());
      debugPrint("getDepositAmount");
    }  
    _isLoading  = false;
    
  }

  // get member list 
  Future<List<DepositModel>?> getMemberDepositList({required String messId,required String mealSessionId,required String uId, required Function(String) onFail, Function()? onSuccess,})async{
    List<DepositModel>? list;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await 
        firebaseFirestore
        .collection(Constants.deposit)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .collection(Constants.members)
        .doc(uId)
        .collection(Constants.listOfDepositTnx)
        .get();
      if(snapshot.docs.isNotEmpty){
        for(var x in snapshot.docs){
          list??=[];
          list.add(DepositModel.fromMap(x.data() as Map<String, dynamic>));
        }
      }
      
      onSuccess?.call();    
    } catch (e) {
      onFail(e.toString());
      debugPrint("getDepositAmount");
    }  
    _isLoading  = false;
    return list?.reversed.toList();
  }

  // get total deposit of a member 
  Future<double> getTotalDepositOfAMember({required String messId,required String mealSessionId, required String uId, required Function(String) onFail, Function()? onSuccess,})async{
    double amount = 0.0;
    try {
      DocumentSnapshot snapshot =  await 
        firebaseFirestore
        .collection(Constants.deposit)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .collection(Constants.members)
        .doc(uId)
        .get();
      if(snapshot.exists && snapshot.data() != null){
        amount = (snapshot.data() as Map<String, dynamic>)[Constants.blance];
      }
      onSuccess?.call();    
    } catch (e) {
      onFail(e.toString());
      debugPrint("getDepositAmount");
    }  
    _isLoading  = false;
    return amount;
  }

  // get all deposit list 
  // {DepositModel,{fname,uid}}
  Future<List<Map<String, dynamic>>?> getAllDepositList({required String messId,required String mealSessionId, required Function(String) onFail, Function()? onSuccess,})async{
    List<Map<String, dynamic>>? list;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await 
        firebaseFirestore
        .collection(Constants.deposit)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .collection(Constants.members)
        .get();

      for(var member in snapshot.docs){// here member contain uid doc
        // the member all deposit list
        QuerySnapshot dipositListOfTheMember = await 
          firebaseFirestore
          .collection(Constants.deposit)
          .doc(messId)
          .collection(Constants.mealSessionList)
          .doc(mealSessionId)
          .collection(Constants.members)
          .doc(member.id)
          .collection(Constants.listOfDepositTnx)
          .get();

        // get the member data
        DocumentSnapshot userData = await 
          firebaseFirestore
          .collection(Constants.users)
          .doc(member.id)
          .get();

        if(dipositListOfTheMember.docs.isNotEmpty){
          for(var x in dipositListOfTheMember.docs){
            list??=[];
            list.add({
              Constants.depositModel : DepositModel.fromMap(x.data() as Map<String, dynamic>),
              Constants.userData : {
                Constants.uId : (userData.data()as Map<String,dynamic>)[Constants.uId],
                Constants.fname : (userData.data()as Map<String,dynamic>)[Constants.fname],
              },
            });
          }
        }
      }

      onSuccess?.call();
      _isLoading = false;
      return list?.reversed.toList();
    
    } catch (e) {
      onFail(e.toString());
      debugPrint("getDepositAmount");
    }  
    _isLoading  = false;
    return null;
  }

  // add a deposit transaction to database 
  Future<void> addADepositTransaction({required DepositModel depositModel, required String uId,  required String messId,required String mealSessionId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    setIsLoading(value: true);
        try {

          // add member diposite transaction
          batch.set(
            firebaseFirestore
            .collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId)
            .collection(Constants.members)
            .doc(uId)
            .collection(Constants.listOfDepositTnx)
            .doc(depositModel.tnxId),
            
            depositModel.toMap()
          );

          // add total diposite
          batch.set( // we can't use update here because initially the document was not exist
            firebaseFirestore.collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId)
            .collection(Constants.members)
            .doc(uId),
            
            depositModel.type==Constants.deposit? 
            {Constants.blance : FieldValue.increment( depositModel.amount)}
            :
            {Constants.blance : FieldValue.increment(-depositModel.amount)},
            SetOptions(
              merge: true
            )
          );
          
          batch.set( // we can't use update here because initially the document was not exist
            firebaseFirestore
            .collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId),
            
            depositModel.type==Constants.deposit? 
            {Constants.blance : FieldValue.increment( depositModel.amount)}
            :
            {Constants.blance : FieldValue.increment(-depositModel.amount)},
            SetOptions(
              merge: true
            )
          );

          await batch.commit();
          onSuccess!=null? onSuccess() : (){};
        } catch (e) {
          onFail(e.toString());
        } 
        setIsLoading(value: false);
  }

  // update a deposit transaction to database 
  Future<void> updateADepositTransaction({required DepositModel depositModel, required String uId,required double extraAmount, required String messId,required String mealSessionId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    setIsLoading(value: true);
        try {
          
          // add new data data 
          batch.set(
            firebaseFirestore.collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId)
            .collection(Constants.members)
            .doc(uId)
            .collection(Constants.listOfDepositTnx)
            .doc(depositModel.tnxId),
            
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
            .collection(Constants.mealSessionList)
            .doc(mealSessionId)
            .collection(Constants.members)
            .doc(uId),
            
            depositModel.type==Constants.deposit? 
            {Constants.blance : FieldValue.increment(extraAmount)}
            :
            {Constants.blance : FieldValue.increment(-extraAmount)},
            SetOptions(
              merge: true
            )
          );
          
          // increment mess total diposite
          batch.set(
            firebaseFirestore
            .collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId),
            
            depositModel.type==Constants.deposit? 
            {Constants.blance : FieldValue.increment( extraAmount)}
            :
            {Constants.blance : FieldValue.increment(-extraAmount)},
            SetOptions(
              merge: true
            )

          );

          await batch.commit();
          onSuccess!=null? onSuccess() : (){};
        } catch (e) {
          onFail(e.toString());
        } 
        setIsLoading(value: false);
  }

  // delete a deposit transaction to database 
  Future<void> deleteADepositTransaction({required DepositModel depositModel, required String uId,  required String messId,required String mealSessionId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
        try {

          // delete the pre data 
          batch.delete(
            firebaseFirestore.collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId)
            .collection(Constants.members)
            .doc(uId)
            .collection(Constants.listOfDepositTnx)
            .doc(depositModel.tnxId)
          );

          // decrement my total diposite
          batch.update( // we can't use update here because initially the document was not exist
            firebaseFirestore
            .collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId)
            .collection(Constants.members)
            .doc(uId),
            
            depositModel.type==Constants.deposit? 
            {Constants.blance : FieldValue.increment(-depositModel.amount)}
            :
            {Constants.blance : FieldValue.increment( depositModel.amount)}
          );
          
          // decrement mess total diposite
          batch.update(
            firebaseFirestore
            .collection(Constants.deposit)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId),
            
            depositModel.type==Constants.deposit? 
            {Constants.blance : FieldValue.increment(-depositModel.amount)}
            :
            {Constants.blance : FieldValue.increment( depositModel.amount)}
          );

          await batch.commit();
          onSuccess!=null? onSuccess() : (){};
        } catch (e) {
          onFail(e.toString());
        } 
  }


}