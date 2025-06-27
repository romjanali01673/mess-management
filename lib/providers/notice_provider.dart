import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/first_screen.dart';
import 'package:meal_hisab/helper/ui_helper.dart';
import 'package:meal_hisab/model/fund_model.dart';
import 'package:meal_hisab/model/notice_model.dart';
import 'package:meal_hisab/providers/firstScreen_provider.dart';

class NoticeProvider extends ChangeNotifier{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  StreamSubscription? _noticeSubscription;
  bool _isLoading = false;
  bool _hasUnseen = false;
  NoticeModel? _noticeModel;

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


  void reset(){
    _noticeModel = null;
  }


  @override
  void dispose() {
    _noticeSubscription?.cancel();
    super.dispose();
  }

  // function -----------

  void listenToNotice({required String messId}){
      _noticeSubscription?.cancel();// cancle pre if have

      _noticeSubscription = firebaseFirestore
        .collection(Constants.mess)
        .doc(messId)
        .collection(Constants.rules)
        .orderBy(Constants.createdAt, descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            final notice = NoticeModel.fromMap(data);
            
            notifyListeners();
          }
        }
      }
    });
  }

  Future<void> checkHasNoticeUnseen({required String uid, required String messId, required String mealHisabId})async{
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
        { Constants.homePindedNotice : noticeModel.toMap()}
      );

      onSuccess!=null? onSuccess():(){};
      first.setPindNoticeForHome(value: noticeModel); 
    } catch (e) {
      onFail(e.toString());
    }
  }

  Future<void> makeAllNoticeSeen({required String uid, required String messId})async{
    try {
      await firebaseFirestore.collection(Constants.notice).doc(messId).update(
        { Constants.messMemberList :FieldValue.arrayRemove([uid])}
      );
      setHasUnseen(value: false);
    } catch (e) {
      
    }
  }

  // get all notice transaction list 
  Future<List<NoticeModel>?> getNoticeList({required String messId,String? uId , required Function(String) onFail, Function()? onSuccess,})async{
      print("getNoticeList called");
    List<NoticeModel>? list;
    _isLoading = true;
    try {
      QuerySnapshot snapshot =  await firebaseFirestore
        .collection(Constants.notice)
        .doc(messId)
        .collection(Constants.listOfNotice)
        .get();

        print(messId);
      print(snapshot.docs.toString()+"doc list");
      list = snapshot.docs.map(
        (doc){
          NoticeModel noticeModel = NoticeModel.fromMap(doc.data() as Map<String, dynamic>);
          return noticeModel;
        }).toList();
      onSuccess!=null? onSuccess() : (){};
      makeAllNoticeSeen(messId:messId , uid: uId??"don't need to make seen");
    } catch (e) {
      onFail(e.toString());
      print(e.toString());
    }  
    _isLoading = false;
    return list;
  }

  // add a notice to database 
  Future<void> addANotice({required NoticeModel noticeModel,required List<String>currentMessMemberUidList, required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();

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
        {Constants.messMemberList : currentMessMemberUidList}
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
  }

  // update a notice to database 
  Future<void> updateANotice({required NoticeModel noticeModel,required List<String> currentMessMemberUidList , required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
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
  }


  //
  
}