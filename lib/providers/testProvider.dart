import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/model/fund_model.dart';

class Testprovider extends ChangeNotifier{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  StreamSubscription? fundListener;
  StreamSubscription? fundListener2;
  bool _isLoading = false;
  FundModel? _fundModel;
  double _blance = 0;

  int limit = 30;
  List<FundModel> currentDocs = [];
  DocumentSnapshot? _firstDoc;
  DocumentSnapshot? _lastDoc;

  bool _hasMoreForward = true;
  bool _hasMoreBackward = false;

  //set -------------

  setIsLoading({required bool value}){
    _isLoading = value;
    notifyListeners();
  }

  setBlance({required dynamic amount}){
    _blance = double.parse(amount.toString());
    notifyListeners();
  }


  // get ------------

  bool get isLoading => _isLoading;
  FundModel? get getFundModel => _fundModel;
  double get getBlance => _blance;
  List<FundModel> get getFundModelList => currentDocs;

  bool get getHasMoreForword => _hasMoreForward;
  bool get getHasMoreBackword => _hasMoreBackward;

  void reset(){
    fundListener = null;
    fundListener2 = null;
    _isLoading = false;
    _fundModel = null;
    _blance = 0;

    limit = 100;
    currentDocs = [];
    _firstDoc = null;
    _lastDoc = null;

    _hasMoreForward = true;
    _hasMoreBackward = false;  
  }

  @override
  void dispose() {
    fundListener?.cancel();
    fundListener2?.cancel();
    // TODO: implement dispose
    super.dispose();
  }
  

  // function -----------

  void listenFundBlance({required String messId}){
    fundListener?.cancel();
    try {
      debugPrint("listenfund called"+messId);
      fundListener = firebaseFirestore
      .collection(Constants.fund)
      .doc(messId)
      .snapshots()
      .listen((snapshot){
        debugPrint("blance");
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          setBlance(amount: data[Constants.blance]);
        }
      });
    } catch (e) {
      
    }
  }

  Future<void> set100record(String messId)async{
    for(int i =0; i<500; i++){
      FundModel fundModel =  FundModel(tnxId:i.toString() , amount: i.toDouble(), title: i.toString(), description: i.toString(), type: Constants.add);
      await firebaseFirestore.collection(Constants.fund).doc(messId).collection(Constants.listOfFundTnx).doc(i.toString()).set(
        fundModel.toMap()
      );
    }
  }

  void listenFundDocChanges({required String messId}){
    fundListener2?.cancel();

    try {
      fundListener2 = firebaseFirestore
      .collection(Constants.fund)
      .doc(messId)
      .collection(Constants.listOfFundTnx)
      .orderBy(Constants.createdAt, descending: true)
      .limit(limit)
      .snapshots()
      .listen((snapshot){
        for(var change in snapshot.docChanges){

          if(change.type == DocumentChangeType.added){
            final data = change.doc.data();
            if (data != null) {
              debugPrint('add found');
              final fundModel = FundModel.fromMap(data);
              //Note: fundModel.createdAt == null because firebase firestore send to listener new model before inserting. that's why we can see createdAt == null
              // "listen" at first take few doc. for this moment we are already added by "initialload" function so we did not need to add the that's why we are ignoring the value.

              if(!currentDocs.any((doc) => doc.tnxId == fundModel.tnxId)){ 
                currentDocs.insert(0, fundModel);// নতুন  উপরে বসাও
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
              final updatedModel = FundModel.fromMap(data);
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
              final removedModel = FundModel.fromMap(data);
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



  Future<void> loadInitial({required String messId}) async {
    currentDocs = [];
    debugPrint("loadInitial called");
    setIsLoading(value: true);

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection(Constants.fund) // change this to your collection name
        .doc(messId)
        .collection(Constants.listOfFundTnx)
        .orderBy(Constants.createdAt, descending: true)
        .limit(limit)
        .get();

    if (snapshot.docs.isNotEmpty) {
      debugPrint(snapshot.docs.length.toString());
        currentDocs = snapshot.docs.map((x)=> FundModel.fromMap(x.data())).toList();
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
    setIsLoading(value: false);
  }

  Future<void> loadForASpacificRange({required String messId, required Timestamp fromDate, required Timestamp toDate}) async {
    debugPrint("loadForASpacificRange");
    // print(toDate.toString() +"\n" + fromDate.toString());
    currentDocs = [];
    setIsLoading(value: true);

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection(Constants.fund) // change this to your collection name
        .doc(messId)
        .collection(Constants.listOfFundTnx)
        .where(FieldPath.documentId ,isGreaterThanOrEqualTo: fromDate.toDate().millisecondsSinceEpoch.toString())
        .where(FieldPath.documentId ,isLessThanOrEqualTo: toDate.toDate().millisecondsSinceEpoch.toString())
        .orderBy(Constants.createdAt, descending: true)
        // .limit(limit)
        .get();

    if (snapshot.docs.isNotEmpty) {
      currentDocs = snapshot.docs.map((x)=> FundModel.fromMap(x.data())).toList();
      _hasMoreForward = false;
      _hasMoreBackward = false;
    }
  } catch (e) {
    debugPrint(e.toString());
  }
    setIsLoading(value: false);
  }



  Future<void> loadNext({required String messId}) async {
    
    print(_lastDoc.toString());
    if (isLoading || !_hasMoreForward || _lastDoc == null) return;
    debugPrint("loadNext called-2${_lastDoc!.id}");

    setIsLoading(value: true);
    // await Future.delayed(Duration(seconds: 10));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(Constants.fund)
          .doc(messId)
          .collection(Constants.listOfFundTnx)
          .orderBy(Constants.createdAt, descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(limit)
          .get();

        print(snapshot.docs.length);
      if (snapshot.docs.isNotEmpty) {
        // snapshot.docs.forEach((x){
        //   print(x.id);
        // });
          currentDocs.addAll(snapshot.docs.map((x)=>FundModel.fromMap(x.data())).toList());

          notifyListeners();
          _firstDoc = snapshot.docs.first;
          _lastDoc = snapshot.docs.last;
          _hasMoreBackward = true;
          _hasMoreForward = snapshot.docs.length == limit;

      } else {
        _hasMoreForward = false;
      }

    } catch (e) {
      debugPrint(e.toString()+"error");
    }
    setIsLoading(value: false);
  }

  Future<void> loadPrevious({required String messId}) async {
    if (isLoading || !_hasMoreBackward || _firstDoc == null) return;
    print("loadPrevious");

    setIsLoading(value: true);

    // await Future.delayed(Duration(seconds: 10));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(Constants.fund)
          .doc(messId)
          .collection(Constants.listOfFundTnx)
          .orderBy(Constants.createdAt, descending: true)
          .endBeforeDocument(_firstDoc!)
          .limitToLast(limit)
          .get();

      if (snapshot.docs.isNotEmpty) {
          int i =0;
          snapshot.docs.map((x){
            currentDocs.insert(i, FundModel.fromMap(x.data()));
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

  Future<double> getFundBlance({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    print("called total fund");
    double blance = 0.0;
    try {
      DocumentSnapshot snapshot =  await firebaseFirestore
      .collection(Constants.fund)
      .doc(messId)
      .get();
      if(snapshot.exists && snapshot.data() != null){
        blance = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.blance]).toString());
        setBlance(amount: blance);
        onSuccess!=null? onSuccess() : (){};
        print(blance);
      }
      onFail("Somthing Wrong.\nData Not Found");
    } catch (e) {
      onFail(e.toString());
    }  
    return blance;
  }


  // get all fund transaction list 
  Future<List<FundModel>?> getFundTransactions({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    List<FundModel>? list;
    double blance=0;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await firebaseFirestore.collection(Constants.fund).doc(messId).collection(Constants.listOfFundTnx).get();
      list = snapshot.docs.map(
        (doc){
          FundModel fundModel = FundModel.fromMap(doc.data() as Map<String, dynamic>);
          
          if(fundModel.type==Constants.add) blance += fundModel.amount;
          else blance -= fundModel.amount;
          
          return fundModel;
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

  // add a fund transaction to database 
  Future<void> addAFundTransaction({required FundModel fundModel,required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    debugPrint("add fund called");
    setIsLoading(value: true);
    final batch = firebaseFirestore.batch();

        try {
          batch.set(
            firebaseFirestore.collection(Constants.fund)
            .doc(messId)
            .collection(Constants.listOfFundTnx)
            .doc(fundModel.tnxId),
            fundModel.toMap()
          );

          if(fundModel.type ==Constants.add){
            batch.set(
              firebaseFirestore.collection(Constants.fund)
              .doc(messId),
              
              {Constants.blance: FieldValue.increment(fundModel.amount)},
              SetOptions(
                merge: true,
              )              
            );
          }
          else{
            batch.set(
              firebaseFirestore.collection(Constants.fund)
              .doc(messId),
              {Constants.blance:FieldValue.increment(-fundModel.amount)},
              SetOptions(
                merge: true,
              )  
            );
          }

          await batch.commit();

          onSuccess!=null? onSuccess() : (){};
        } catch (e) {
          onFail(e.toString());
        } 
        setIsLoading(value: false);
  }

  // update a fund transaction to database 
  Future<void> updateAFundTransaction({required FundModel fundModel,required String messId,required double extraAmount, required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    setIsLoading(value: true);
    try {

      batch.set(
        firebaseFirestore.collection(Constants.fund)
        .doc(messId)
        .collection(Constants.listOfFundTnx)
        .doc(fundModel.tnxId),
        fundModel.toMap(),
        SetOptions(
          mergeFields: [
            Constants.amount, 
            Constants.title,  
            Constants.description,
          ]
        )
      );

      fundModel.type==Constants.add?
      batch.update(
        firebaseFirestore.collection(Constants.fund)
        .doc(messId),
        {Constants.blance: FieldValue.increment(extraAmount)}
      )
      :
      batch.update(
        firebaseFirestore.collection(Constants.fund)
        .doc(messId),
        {Constants.blance: FieldValue.increment(-extraAmount)}
      );
        
      await batch.commit();
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    } 
    setIsLoading(value: false);
  }
    
  



  // delete a fund transaction
  Future<void> deleteAFundTransaction({required String messId, required String tnxId,required double extraAmount, required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    setIsLoading(value: true);
    try {
      batch.delete(
        firebaseFirestore.collection(Constants.fund).doc(messId).collection(Constants.listOfFundTnx).doc(tnxId),
      );

      batch.update(firebaseFirestore.
        collection(Constants.fund)
        .doc(messId),
        {Constants.blance : FieldValue.increment(extraAmount)}
      );
      await batch.commit();
      onSuccess!=null? onSuccess(): (){};
    } catch (e) {
      onFail(e.toString());
    }
    setIsLoading(value: false);
  }

  // delete a fund transaction
  Future<void> clearAllFundTnx({required String messId, required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    try {
      setIsLoading(value: true);

      final fundModel = FundModel(
        tnxId: DateTime.now().millisecondsSinceEpoch.toString(), 
        amount: getBlance, 
        title: "Previous Transaction Has Cleared!", 
        description: "All previous N (number of transactions) transactions have been cleared. You will no longer be able to view them. From now on, only new transactions will be available.\n\nNote: The deposited amount reflects the Current remaining balance of the fund.", 
        type: Constants.add,
      );
          
      // delete all pre fund history or transactions. 
      AggregateQuerySnapshot aQuerySnapshot = await firebaseFirestore
        .collection(Constants.fund)
        .doc(messId)
        .collection(Constants.listOfFundTnx)
        .count()
        .get();
          
      int i = aQuerySnapshot.count??00;

      while(i>0){
        try {
          QuerySnapshot qSnapshot = await firebaseFirestore
            .collection(Constants.fund)
            .doc(messId)
            .collection(Constants.listOfFundTnx)
            .limit(limit)
            .get();

          await Future.wait(qSnapshot.docs.map((x) => x.reference.delete()));
          await Future.delayed(Duration(milliseconds: 1100));
          i-=qSnapshot.docs.length;
          if(qSnapshot.docs.isEmpty) break;
        } catch (e) {
          onFail(e.toString());
          return;// to off loop and declain next process
        }
      }

      batch.set(
        firebaseFirestore.
        collection(Constants.fund)
        .doc(messId)
        .collection(Constants.listOfFundTnx)
        .doc(fundModel.tnxId),
        fundModel.toMap()
      );
      await batch.commit();
      onSuccess!=null? onSuccess(): (){};
    } catch (e) {
      onFail(e.toString());
    }
    setIsLoading(value: false);
  }
}