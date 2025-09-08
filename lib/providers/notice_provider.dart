import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/model/notice_model.dart';
import 'package:mess_management/model/user_model.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/firstScreen_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';
import 'package:mess_management/services/notification_services.dart';

class NoticeProvider extends ChangeNotifier{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  StreamSubscription? _noticeSubscription;
  bool _isLoading = false;
  bool _hasUnseen = false;
  NoticeModel? _noticeModel;

  int limit = 20;
  List<NoticeModel> _noticeList=[];
  DocumentSnapshot? _firstDoc;
  DocumentSnapshot? _lastDoc;

  bool _hasMoreForward = true;
  bool _hasMoreBackward = false;

  //set -------------

  setIsLoading({required bool value}){
    _isLoading = value;
    notifyListeners();
  }
  setHasUnseen({required bool value}){
    _hasUnseen = value;
    notifyListeners();
  }



  // get ------------

  bool get isLoading => _isLoading;
  NoticeModel? get getNoticeModel => _noticeModel;
  bool get getHasUnseen => _hasUnseen;
  List<NoticeModel> get getNoticeList=>_noticeList;

  bool get getHasMoreForword => _hasMoreForward;
  bool get getHasMoreBackword => _hasMoreBackward;

  void reset(){
    _noticeSubscription = null;
    _isLoading = false;
    _hasUnseen = false;
    _noticeModel = null;

    limit = 20;
    _noticeList=[];
    _firstDoc = null;
    _lastDoc = null;

    _hasMoreForward = true;
    _hasMoreBackward = false;  
  }

  void setNoticeList(List<NoticeModel> list){
    _noticeList = list;
    notifyListeners();
  }

  @override
  void dispose() {
    _noticeSubscription?.cancel();
    super.dispose();
  }

  // function -----------

  void listenToNotice({required String messId}){
  _noticeSubscription?.cancel();// cancle pre if have
  try {
      _noticeSubscription = firebaseFirestore
        .collection(Constants.notice)
        .doc(messId)
        .collection(Constants.listOfNotice)
        .orderBy(Constants.createdAt, descending: true)
        .snapshots()
        .listen((snapshot) {
        for(var change in snapshot.docChanges){

          if(change.type == DocumentChangeType.added){
            final data = change.doc.data();
            if (data != null) {
              debugPrint('add found notice');
              final noticeModel = NoticeModel.fromMap(data);
              //Note: noticeModel.createdAt == null because firebase firestore send to listener new model before inserting. that's why we can see createdAt == null
              // "listen" at first take few doc. for this moment we are already added by "initialload" function so we did not need to add the that's why we are ignoring the value.

              if(!_noticeList.any((doc) => doc.noticeId == noticeModel.noticeId)){ 
                _noticeList.insert(0, noticeModel);// নতুন  উপরে বসাও
                if(_noticeList.length>limit){
                  _noticeList.removeLast(); // because this value will not sync.
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
              final updatedModel = NoticeModel.fromMap(data);
              final index = _noticeList.indexWhere((e) => e.noticeId == updatedModel.noticeId); // compare by id

              if (index != -1) {
                _noticeList[index] = updatedModel;
                notifyListeners();
              }
            }
          }
          else if(change.type == DocumentChangeType.removed){
            debugPrint("delete found");
            final data = change.doc.data();
            if (data != null) {

              // note in here data load also.
              final removedModel = NoticeModel.fromMap(data);
              final index = _noticeList.indexWhere((e) => e.noticeId == removedModel.noticeId); // compare by id

              if (index != -1) {
                _noticeList.removeAt(index);
                notifyListeners();
              }
            }
          }
        }  
      }
    );    
    } catch (e) {
      
    }
  }



  Future<void> loadInitial({required String messId, String? uId}) async {
    // currentDocs = [];
    debugPrint("loadInitial called");
    setIsLoading(value: true);

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection(Constants.notice) // change this to your collection name
        .doc(messId)
        .collection(Constants.listOfNotice)
        .orderBy(Constants.createdAt, descending: true)
        .limit(limit)
        .get();

    if (snapshot.docs.isNotEmpty) {
      debugPrint(snapshot.docs.length.toString());
        setNoticeList(snapshot.docs.map((x)=> NoticeModel.fromMap(x.data())).toList());
        _firstDoc = snapshot.docs.first;
        _lastDoc = snapshot.docs.last;
        _hasMoreForward = snapshot.docs.length==limit;
        _hasMoreBackward = false;
    }
    else{
      _hasMoreForward = false;
    }
    makeAllNoticeSeen(uid: uId??"not-given", messId:messId);
  } catch (e) {
  }
    setIsLoading(value: false);
  }

  Future<void> sendNotification(
    MessProvider messProvider,
    {required String title, required String body ,Map<String, dynamic>? data})async{
    NotificationServices notificationServices = NotificationServices.getInstance;
    // List<String> memberDeviceIdList = [];

    for(var x in messProvider.getMessModel!.messMemberList){
      DocumentSnapshot snapshot = await firebaseFirestore.collection(Constants.users).doc(x[Constants.uId]).get();
      if(snapshot.exists && snapshot.data() != null){
        UserModel userModel = UserModel.fromMap(snapshot.data() as Map<String,dynamic>);
        if((userModel.deviceId) != null){
          debugPrint(userModel.deviceId!);
          await notificationServices.sendMessage(
            deviceToken: userModel.deviceId!, 
            title:  title, 
            body: body, 
            data: data,
          );
        }
      }
    }
  }

  Future<void> loadNext({required String messId}) async {
    
    print(_lastDoc.toString());
    if (isLoading || !_hasMoreForward || _lastDoc == null) return;
    debugPrint("loadNext called-2${_lastDoc!.id}");

    setIsLoading(value: true);
    // await Future.delayed(Duration(seconds: 10));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(Constants.notice)
          .doc(messId)
          .collection(Constants.listOfNotice)
          .orderBy(Constants.createdAt, descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(limit)
          .get();

        print(snapshot.docs.length);
      if (snapshot.docs.isNotEmpty) {
        // snapshot.docs.forEach((x){
        //   print(x.id);
        // });
          _noticeList = (snapshot.docs.map((x)=>NoticeModel.fromMap(x.data())).toList());
          // _noticeList.removeRange(0, snapshot.docs.length);

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

  Future<void> loadPrevious({required String messId}) async {
    print("loadPrevious");
    if (isLoading || !_hasMoreBackward || _firstDoc == null) return;

    setIsLoading(value: true);

    // await Future.delayed(Duration(seconds: 10));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(Constants.notice)
          .doc(messId)
          .collection(Constants.listOfNotice)
          .orderBy(Constants.createdAt, descending: true)
          .endBeforeDocument(_firstDoc!)
          .limitToLast(limit)
          .get();

      if (snapshot.docs.isNotEmpty) {
          int i =0;
          snapshot.docs.map((x){
            _noticeList.insert(i, NoticeModel.fromMap(x.data()));
            if(_noticeList.length>limit){
              _noticeList.removeLast(); // because this value will not sync.
            }
            i++;
          }).toList();

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



  Future<void> checkHasNoticeUnseen({required String uid, required String messId, required String mealSessionId})async{
    print("has notice called");
    try {
      // DocumentSnapshot snapshot = await 
      firebaseFirestore
        .collection(Constants.notice)
        .doc(messId)
        .snapshots()
        .listen((sanpshot){
          if (sanpshot.data() != null){
            var data = (sanpshot.data() as Map<String,dynamic>);
            
            if((data[Constants.messMemberList]??[]).contains(uid)){
              setHasUnseen(value: true);
              notifyListeners();
              print("has notice t");
            }
            else{
              setHasUnseen(value: false);
              print("has notice f");
            }
          }
        }  
      );
    }catch(e){
      debugPrint(e.toString()+"check notifications");
    }
  }

  Future<void> pinToHome({required NoticeModel noticeModel, required String messId, required Function(String) onFail, Function()? onSuccess})async{
    FirstScreenProvider  first = FirstScreenProvider();
    try {
      await firebaseFirestore.collection(Constants.notice).doc(messId).set(
        { Constants.homePindedNotice : noticeModel.toMap()},
        SetOptions(merge: true),
      );

      onSuccess?.call();
      first.setPindNoticeForHome(value: noticeModel); 
    } catch (e) {
      onFail(e.toString());
    }
  }

  Future<void> makeAllNoticeSeen({required String uid, required String messId})async{
    try {
      if(!getHasUnseen) return;// if already seen break;
      await firebaseFirestore.collection(Constants.notice).doc(messId).update(
        {Constants.messMemberList :FieldValue.arrayRemove([uid])}
      );
      setHasUnseen(value: false);
    } catch (e) {
      
    }
  }

  // get all notice transaction list 
  Future<List<NoticeModel>?> getAllNoticeList({required String messId,String? uId , required Function(String) onFail, Function()? onSuccess,})async{
    print("getNoticeList called");


    List<NoticeModel>? list;
    _isLoading = true;

    AggregateQuerySnapshot dc =await 
      firebaseFirestore
      .collection(Constants.notice)
      .doc(messId)
      .collection(Constants.listOfNotice)
      .count()
      .get();

    int i = dc.count??0;
    while(i>0){
      try {
        QuerySnapshot snapshot =  await firebaseFirestore
          .collection(Constants.notice)
          .doc(messId)
          .collection(Constants.listOfNotice)
          .limit(10)
          .get();

          print(messId);
        print(snapshot.docs.toString()+"doc list");
        list??=[];
        list.addAll(snapshot.docs.map(
          (doc){
            NoticeModel noticeModel = NoticeModel.fromMap(doc.data() as Map<String, dynamic>);
            return noticeModel;
          }).toList());
        onSuccess!=null? onSuccess() : (){};
        makeAllNoticeSeen(messId:messId , uid: uId??"don't need to make seen");
        i-=snapshot.docs.length;
        if(snapshot.docs.isEmpty) break;
      } catch (e) {
        onFail(e.toString());
        print(e.toString());
        break;
      }  
    }
    _isLoading = false;
    return list;
  }

  // add a notice to database 
  Future<void> addANotice({required NoticeModel noticeModel,required List<String>currentMessMemberUidList, required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    setIsLoading(value: true);
    try {
      batch.set(
        firebaseFirestore.collection(Constants.notice)
        .doc(messId)
        .collection(Constants.listOfNotice)
        .doc(noticeModel.noticeId),
        noticeModel.toMap()
      );

      batch.set(
        firebaseFirestore.collection(Constants.notice)
        .doc(messId),
        {Constants.messMemberList : currentMessMemberUidList},
        SetOptions(merge: true),
      );

     
      await batch.commit();

      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
      debugPrint(e.toString());
    } 
    setIsLoading(value: false);
  }
  // delete a notice from database 
  Future<void> deleteANotice({required String messId, required String noticeId,Function()? onSuccess, required Function(String) onFail})async{
    final batch = firebaseFirestore.batch();
    setIsLoading(value: true);
    try {
      batch.delete(
        firebaseFirestore.collection(Constants.notice)
        .doc(messId)
        .collection(Constants.listOfNotice)
        .doc(noticeId),
      );
     
      await batch.commit();
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    } 
    setIsLoading(value: false);
  }

  // update a notice to database 
  Future<void> updateANotice({required NoticeModel noticeModel,required List<String> currentMessMemberUidList , required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    setIsLoading(value: true);
    try {
      batch.set(
        firebaseFirestore.collection(Constants.notice)
        .doc(messId)
        .collection(Constants.listOfNotice)
        .doc(noticeModel.noticeId),
        noticeModel.toMap(),
        SetOptions(mergeFields: [Constants.title, Constants.description,])
      );

      batch.update(
        firebaseFirestore.collection(Constants.notice)
        .doc(messId),
        {
          Constants.messMemberList: currentMessMemberUidList
        }
      );

     
      await batch.commit();
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    } 
    setIsLoading(value: false);
  }


  //
  
}