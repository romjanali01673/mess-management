import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/model/fand_model.dart';
import 'package:provider/provider.dart';

class FandProvider extends ChangeNotifier{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  StreamSubscription? fandListener;
  StreamSubscription? fandListener2;
  bool _isLoading = false;
  FandModel? _fandModel;
  double _blance = 0;

  int limit = 10;
  List<FandModel> currentDocs = [];
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
  FandModel? get getFandModel => _fandModel;
  double get getBlance => _blance;
  List<FandModel> get getFandModelList => currentDocs;

  bool get getHasMoreForword => _hasMoreForward;
  bool get getHasMoreBackword => _hasMoreBackward;

  void reset(){
    _fandModel = null;
  }

  @override
  void dispose() {
    fandListener?.cancel();
    fandListener2?.cancel();
    // TODO: implement dispose
    super.dispose();
  }
  

  // function -----------

  void listenFand({required String messId}){
    fandListener?.cancel();
    try {
      debugPrint("listenFand called"+messId);
      fandListener = firebaseFirestore
      .collection(Constants.fand)
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

  void listenFandDocChanges({required String messId}){
    fandListener2?.cancel();

    try {
      fandListener2 = firebaseFirestore
      .collection(Constants.fand)
      .doc(messId)
      .collection(Constants.listOfFandTransaction)
      .orderBy(Constants.createdAt, descending: true)
      .limit(limit)
      .snapshots()
      .listen((snapshot){
        for(var change in snapshot.docChanges){
          if(change.type == DocumentChangeType.added){
            final data = change.doc.data();
            if (data != null) {
              final fandModel = FandModel.fromMap(data);
              //Note: fandModel.createdAt == null because firebase firestore send to listener new model before inserting. that's why we can see createdAt == null
              // "listen" at first take few doc. for this moment we are already added by "initialload" function so we did not need to add the that's why we are ignoring the value.

              if(!currentDocs.any((doc) => doc.transactionId == fandModel.transactionId)){ 
                currentDocs.insert(0, fandModel);// নতুন  উপরে বসাও
                currentDocs.removeLast(); // because this value will not sync.
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
              final updatedModel = FandModel.fromMap(data);
              final index = currentDocs.indexWhere((e) => e.transactionId == updatedModel.transactionId); // compare by id

              if (index != -1) {
                currentDocs[index] = updatedModel;
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
    debugPrint("loadInitial called");
    setIsLoading(value: true);

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection(Constants.fand) // change this to your collection name
        .doc(messId)
        .collection(Constants.listOfFandTransaction)
        .orderBy(Constants.createdAt, descending: true)
        .limit(limit)
        .get();

    if (snapshot.docs.isNotEmpty) {
      debugPrint(snapshot.docs.length.toString());
        currentDocs = snapshot.docs.map((x)=> FandModel.fromMap(x.data())).toList();
        _firstDoc = snapshot.docs.first;
        _lastDoc = snapshot.docs.last;
        _hasMoreForward = true;
        _hasMoreBackward = false;
    }
  } catch (e) {
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
          .collection(Constants.fand)
          .doc(messId)
          .collection(Constants.listOfFandTransaction)
          .orderBy(Constants.createdAt, descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(limit)
          .get();

        print(snapshot.docs.length);
      if (snapshot.docs.isNotEmpty) {
        // snapshot.docs.forEach((x){
        //   print(x.id);
        // });
          currentDocs.addAll(snapshot.docs.map((x)=>FandModel.fromMap(x.data())).toList());
          currentDocs.removeRange(0, snapshot.docs.length);

          notifyListeners();
          _firstDoc = snapshot.docs.first;
          _lastDoc = snapshot.docs.last;
          _hasMoreBackward = true;
          _hasMoreForward = snapshot.docs.length == limit;

          if(snapshot.docs.length<limit){
            _hasMoreForward = false; 
          }

      } else {
        _hasMoreForward = false;
      }

    } catch (e) {
      debugPrint(e.toString());
    }
    setIsLoading(value: false);
  }

  Future<void> loadPrevious({required String messId}) async {
    print("loadPrevious");
    if (isLoading || !_hasMoreBackward || _firstDoc == null) return;

    setIsLoading(value: true);

    // await Future.delayed(Duration(seconds: 10));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(Constants.fand)
          .doc(messId)
          .collection(Constants.listOfFandTransaction)
          .orderBy(Constants.createdAt, descending: true)
          .endBeforeDocument(_firstDoc!)
          .limitToLast(limit)
          .get();

      if (snapshot.docs.isNotEmpty) {
          int i =0;
          snapshot.docs.map((x){
            currentDocs.insert(i, FandModel.fromMap(x.data()));
            currentDocs.removeLast();
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
    debugPrint("add fand called");
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
              
              {Constants.blance: FieldValue.increment(fandModel.amount)},
              SetOptions(
                merge: true,
              )              
            );
          }
          else{
            batch.set(
              firebaseFirestore.collection(Constants.fand)
              .doc(messId),
              {Constants.blance:FieldValue.increment(-fandModel.amount)},
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