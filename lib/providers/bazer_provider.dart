import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/model/bazer_model.dart';

class BazerProvider extends ChangeNotifier{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  StreamSubscription? bazerListener;


  bool _isLoading = false;
  BazerModel? _bazerModel;
  double _cost = 0;

  int limit = 50;
  List<BazerModel> currentDocs = [];
  DocumentSnapshot? _firstDoc;
  DocumentSnapshot? _lastDoc;

  bool _hasMoreForward = true;
  bool _hasMoreBackward = false;

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

  bool get getHasMoreBackword=>_hasMoreBackward;
  bool get getHasMoreForword=>_hasMoreForward;


  void reset(){
    bazerListener= null;

    _isLoading = false;
    _bazerModel= null;
    _cost = 0;

    limit = 50;
    currentDocs = [];
    _firstDoc= null;
    _lastDoc= null;

    _hasMoreForward = true;
    _hasMoreBackward = false;
  }


  // function -----------
  void listenBazerDocChanges({required String messId, required String mealSessionId}){
    bazerListener?.cancel();

    try {
      bazerListener = firebaseFirestore
      .collection(Constants.bazer)
      .doc(messId)
      .collection(Constants.mealSessionList)
      .doc(mealSessionId)
      .collection(Constants.listOfBazerTnx)
      .orderBy(Constants.createdAt, descending: true)
      .limit(limit)
      .snapshots()
      .listen((snapshot){
        for(var change in snapshot.docChanges){
          
          if(change.type == DocumentChangeType.added){
            final data = change.doc.data();
            if (data != null) {
              debugPrint('add found');
              final bazerModel = BazerModel.fromMap(data);
              //Note: bazerModel.createdAt == null because firebase firestore send to listener new model before inserting. that's why we can see createdAt == null
              // "listen" at first take few doc. for this moment we are already added by "initialload" function so we did not need to add the that's why we are ignoring the value.

              if(!(currentDocs.any((doc) => doc.tnxId == bazerModel.tnxId))){ 
                currentDocs.insert(0, bazerModel);// নতুন  উপরে বসাও
                if(currentDocs.length>limit){
                  currentDocs.removeLast(); // because this value will not sync.
                }
                notifyListeners();
              }
            }
          }

          //updated will be visible here if it within the limit. i mean if it exist within the batch, if limit ==10 the doc have to be with the 10 doc.
          // at first i set limit and get 10 doc. if i add a new doc last doc will be remove and new doc will be added. but in my array exist the pre value. but we has removed the extra doc menually
          // listen has a internal list not my decleared list.
          else if(change.type == DocumentChangeType.modified){
            debugPrint("update found");
            final data = change.doc.data();
            if (data != null) {

              // note in here data load also.
              final updatedModel = BazerModel.fromMap(data);
              final index = currentDocs.indexWhere((e) => e.tnxId == updatedModel.tnxId); // compare by id

              if (index != -1) {
                currentDocs[index] = updatedModel;
                notifyListeners();
              }
            }
          }

          else if(change.type == DocumentChangeType.removed){
            debugPrint("delete found");
            final data = change.doc.data();
            if (data != null) {

              // note in here data load also.
              final removedModel = BazerModel.fromMap(data);
              final index = currentDocs.indexWhere((e) => e.tnxId == removedModel.tnxId); // compare by id

              if (index != -1) {
                currentDocs.removeAt(index);
                notifyListeners();
              }
            }
          }
          
        }
      });
    } catch (e) {
      
    }
  }



  // get total bazer cost
  Future<double> getTotalBazerCost({
    required String messId,
    required String mealSessionId,
    required Function(String) onFail, 
    Function()? onSuccess,
  })async{

    double cost = 0;
    try {
      final snapshot = await 
      firebaseFirestore
        .collection(Constants.bazer)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .get();
      if(snapshot.exists && snapshot.data()!=null){
        cost = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.totalBazerCost]).toString());
      }
      onSuccess!=null?onSuccess():(){};
    } catch (e) {
      onFail(e.toString());
    }
    return cost;
  }





  Future<void> loadInitial({required String messId, required String mealSessionId}) async {
    debugPrint("loadInitial called");
    setIsLoading(value: true);

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection(Constants.bazer) // change this to your collection name
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .collection(Constants.listOfBazerTnx)
        .orderBy(Constants.createdAt, descending: true)
        .limit(limit)
        .get();

    if (snapshot.docs.isNotEmpty) {
      debugPrint(snapshot.docs.length.toString());
        currentDocs = snapshot.docs.map((x)=> BazerModel.fromMap(x.data())).toList();
        _firstDoc = snapshot.docs.first;
        _lastDoc = snapshot.docs.last;
        _hasMoreForward = snapshot.docs.length==limit;
        _hasMoreBackward = false;
    }
    else{
      _hasMoreForward = false;
    }
  } catch (e) {
  }
    await Future.delayed(Duration(seconds: 3));
    print("load initial complete");
    setIsLoading(value: false);
  }


  Future<void> loadNext({required String messId, required String mealSessionId}) async {
    
    print(_lastDoc.toString());
    if (isLoading || !_hasMoreForward || _lastDoc == null) return;
    debugPrint("loadNext called-2${_lastDoc!.id}");

    setIsLoading(value: true);
    // await Future.delayed(Duration(seconds: 10));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(Constants.bazer)
          .doc(messId)
          .collection(Constants.mealSessionList)
          .doc(mealSessionId)
          .collection(Constants.listOfBazerTnx)
          .orderBy(Constants.createdAt, descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(limit)
          .get();

        
      if (snapshot.docs.isNotEmpty) {
        // snapshot.docs.forEach((x){
        //   print(x.id);
        // });
          currentDocs = (snapshot.docs.map((x)=>BazerModel.fromMap(x.data())).toList());
          
          print(currentDocs.length.toString()+"p");
          notifyListeners();
          _firstDoc = snapshot.docs.first;
          _lastDoc = snapshot.docs.last;
          _hasMoreBackward = true;
          _hasMoreForward = snapshot.docs.length == limit;

      } else {
        _hasMoreForward = false;
      }

    } catch (e) {
      debugPrint(e.toString());
    }
    setIsLoading(value: false);
  }

  Future<void> loadPrevious({required String messId, required String mealSessionId}) async {
    print("loadPrevious");
    if (isLoading || !_hasMoreBackward || _firstDoc == null) return;

    setIsLoading(value: true);

    // await Future.delayed(Duration(seconds: 10));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(Constants.bazer)
          .doc(messId)
          .collection(Constants.mealSessionList)
          .doc(mealSessionId)
          .collection(Constants.listOfBazerTnx)
          .orderBy(Constants.createdAt, descending: true)
          .endBeforeDocument(_firstDoc!)
          .limitToLast(limit)
          .get();
      
      print(snapshot.docs.length);

        print(currentDocs.length.toString() + "from prev");
      if (snapshot.docs.isNotEmpty) {
          int i =0;
          snapshot.docs.map((x){
            currentDocs.insert(i, BazerModel.fromMap(x.data()));
            if(currentDocs.length>limit){
              currentDocs.removeLast(); // because this value will not sync.
            }
            i++;
          }).toList();
          notifyListeners();
          
          _firstDoc = snapshot.docs.first;
          _lastDoc = snapshot.docs.last;
          _hasMoreForward = true;
          _hasMoreBackward = snapshot.docs.length == limit;

          
          if(snapshot.docs.length<limit){
            _hasMoreBackward = false;
          }

      } else {
        _hasMoreBackward = false;
      }

    } catch (e) {
      
    }
    setIsLoading(value: false);
  }

  // get all Bazer transaction list 
  Future<List<BazerModel>?> getBazerTransactions({required String messId,required String mealSessionId,required Function(String) onFail, Function()? onSuccess,})async{
    List<BazerModel>? list;
    double cost=0;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await firebaseFirestore
      .collection(Constants.bazer)
      .doc(messId)
      .collection(Constants.mealSessionList)
      .doc(mealSessionId)
      .collection(Constants.listOfBazerTnx)
      // .orderBy(Constants.createdAt, descending: true)// don't need we are using reverse.
      .get();

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

  // get all Bazer transaction list 
  Future<List<BazerModel>?> getBazerTransactionsForASpacificRange({required String messId,required String mealSessionId,required Function(String) onFail,required Timestamp fromDate, required Timestamp toDate, Function()? onSuccess,})async{
    List<BazerModel>? list;
    double cost=0;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await firebaseFirestore
      .collection(Constants.bazer)
      .doc(messId)
      .collection(Constants.mealSessionList)
      .doc(mealSessionId)
      .collection(Constants.listOfBazerTnx)
      .where(FieldPath.documentId ,isGreaterThanOrEqualTo: fromDate.toDate().millisecondsSinceEpoch.toString())
      .where(FieldPath.documentId ,isLessThanOrEqualTo: toDate.toDate().millisecondsSinceEpoch.toString())
      .orderBy(Constants.createdAt, descending: true) 
      .get();

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

  // add a bazer transaction to database 
  Future<void> addABazerTransaction({required BazerModel bazerModel,required String messId,required String mealSessionId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    // fatch cost,
    setIsLoading(value: true);
        try {
            batch.set(
            firebaseFirestore
            .collection(Constants.bazer)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId)
            .collection(Constants.listOfBazerTnx)
            .doc(bazerModel.tnxId),
            bazerModel.toMap()
          );
          
         
          batch.set(
            firebaseFirestore
            .collection(Constants.bazer)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId),
            {Constants.totalBazerCost:FieldValue.increment(bazerModel.amount)},
            SetOptions(
              merge: true
            )
          );

          await batch.commit();
          setCost(amount: getCost+bazerModel.amount);
          onSuccess!=null? onSuccess() : (){};
        } catch (e) {
          onFail(e.toString());
        }  
    setIsLoading(value: false);
  }

  

  // update a bazer transaction to database 
  Future<void> updateABazerTransaction({required BazerModel bazerModel,required String messId,required String mealSessionId,required double extraAdd,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    // fatch cost,
    setIsLoading(value: true);
        try{
          batch.set(
            firebaseFirestore
            .collection(Constants.bazer)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId)
            .collection(Constants.listOfBazerTnx)
            .doc(bazerModel.tnxId),
            bazerModel.toMap(),
            SetOptions(
              mergeFields: [
                Constants.amount,
                Constants.bazerList ,
                Constants.byWho,
                Constants.bazerTime,
                Constants.bazerDate,
              ],
            ),
          );
         
          batch.set(
            firebaseFirestore
            .collection(Constants.bazer)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId),
            {Constants.totalBazerCost: FieldValue.increment(extraAdd)},
            SetOptions(
              merge: true
            )
          );

          await batch.commit();
          setCost(amount: (getCost+ extraAdd));
          onSuccess!=null? onSuccess() : (){};
        } catch (e) {
          onFail(e.toString());
          print(e.toString());
        }  
    setIsLoading(value: false);
  }

  

  // update a bazer transaction to database 
  Future<void> deleteABazerTransaction({required String tnxId,required String messId,required String mealSessionId,required double extraAdd,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    // fatch cost,

        try {
          batch.delete(
            firebaseFirestore
            .collection(Constants.bazer)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId)
            .collection(Constants.listOfBazerTnx)
            .doc(tnxId),
          );
         
          batch.set(
            firebaseFirestore
            .collection(Constants.bazer)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(mealSessionId),
            {Constants.totalBazerCost : FieldValue.increment(extraAdd)},
            SetOptions(
              merge:true
            )
          );

          await batch.commit();
          setCost(amount: (getCost + extraAdd));
          onSuccess!=null? onSuccess() : (){};
        } catch (e) {
          onFail(e.toString());
        }  
      }

}