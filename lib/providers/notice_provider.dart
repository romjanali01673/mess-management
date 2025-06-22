import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/model/fand_model.dart';
import 'package:meal_hisab/model/notice_model.dart';

class NoticeProvider extends ChangeNotifier{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

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


  // function -----------

  Future<void> checkHasNoticeUnseen({required String uid, required String messId})async{
    print("has notice called");
    try {
      DocumentSnapshot snapshot = await firebaseFirestore.collection(Constants.notice).doc(messId).get();
      if(snapshot.exists && snapshot.data() != null){
        List<String> memberList = ((snapshot.data() as Map<String,dynamic>)[Constants.messMemberList] as List<dynamic>).map((x){ return x.toString();}).toList();
        if(memberList.contains(uid)){
          setHasUnseen(value: true);
          print("has notice t");
        }
        else{
          setHasUnseen(value: false);
          print("has notice f$memberList");
        }
      }
    } catch (e) {
      print(e.toString()+"check has notice");
    }
  }
  Future<void> pinToHome({required NoticeModel noticeModel, required String messId, required Function(String) onFail, Function()? onSuccess})async{
    try {
      await firebaseFirestore.collection(Constants.notice).doc(messId).set(
        { Constants.homePindedNotice : noticeModel.toMap()}
      );
      onSuccess!=null? onSuccess():(){};
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

      batch.update(
        firebaseFirestore.collection(Constants.notice)
        .doc(messId),
        {Constants.messMemberList : currentMessMemberUidList}
      );

     
      await batch.commit();

      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    } 
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