import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/model/mess_model.dart';
import 'package:meal_hisab/model/user_model.dart';


class MessProvaider extends ChangeNotifier {
    List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  bool _isOnline = true;
  bool _isLoading = false;
  MessModel? _messModel;

  MessProvaider(){
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  
  }
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;


  // set ------------------------------


  void setIsOnline(bool val){
    _isOnline = val;
    notifyListeners();
  }
  void setIsloading(bool val){
    _isLoading = val;
    notifyListeners();
  }

  void setMessModel({
    String? messId,
    String? messName,
    String? messAddress,
    String? messAuthorityId,
    String? messAuthorityId2nd,
    String? messAuthorityName,
    String? messAuthorityName2nd,
    String? messAuthorityNumber,
    String? messAuthorityEmail,
    List? messMemberList,
    List?disabledMemberList,
  }){
    if(messId != null) _messModel!.messId = messId;
    if(messName != null) _messModel!.messName = messName;
    if(messAddress != null) _messModel!.messAddress = messAddress;
    if(messAuthorityId != null)_messModel!.messAuthorityId = messAuthorityId;
    if(messAuthorityId2nd != null)_messModel!.messAuthorityId2nd = messAuthorityId2nd;
    if(messAuthorityName != null)_messModel!.messAuthorityName = messAuthorityName;
    if(messAuthorityName2nd != null)_messModel!.messAuthorityName2nd = messAuthorityName2nd;
    if(messAuthorityNumber != null)_messModel!.messAuthorityNumber = messAuthorityNumber;
    if(messAuthorityEmail != null)_messModel!.messAuthorityEmail = messAuthorityEmail;
    if(messMemberList != null)_messModel!.messMemberList = messMemberList;
    if(disabledMemberList != null)_messModel!.disabledMemberList = disabledMemberList;
    notifyListeners();
  }
  

  // get -----------------------------
  MessModel? get getMessModel =>_messModel;
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;

  // function --------------


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status',);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    return _updateConnectionStatus(result);
  }

    Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    _connectionStatus = result;
    // ignore: avoid_print
    print('Connectivity changed: $_connectionStatus');
    if(_connectionStatus.contains(ConnectivityResult.none)){
      setIsOnline(false);
    }
    else{
      setIsOnline(true);
    }
  }

  // insert mess data to firestore
  Future<void> storeMessDataToFirestore({required Function(String) onFail, Function()? onSuccess, required MessModel messModel})async{
    try{
      String cratedMessId = DateTime.now().millisecondsSinceEpoch.toString();
      messModel.messId = cratedMessId;
      _messModel = messModel;


      firebaseFirestore
      .collection(Constants.mess)
      .doc(cratedMessId)
      .set(messModel.toMap());
      onSuccess!=null? onSuccess():(){};
    } catch(e){
      onFail(e.toString());
    }
  }

  // Update mess data to firestore
  Future<void> updateMessDataToFirestore({required Function(String) onFail, Function()? onSuccess, required MessModel messModel, })async{
    try{
      setMessModel(
        messName: messModel.messName,
        messAddress: messModel.messAddress,
        messAuthorityNumber: messModel.messAuthorityNumber,
        messAuthorityEmail: messModel.messAuthorityEmail,
      );
      print(getMessModel!.messId);
      firebaseFirestore
      .collection(Constants.mess)
      .doc(getMessModel!.messId)
      .set(
        getMessModel!.toMap(),
        SetOptions(
          // if we  provaide murge field we don't need to provaide murge field vice visa.
          // merge: true, // 
          mergeFields: 
          [
            Constants.messName,
            Constants.messAddress,
            Constants.messAuthorityEmail,
            Constants.messAuthorityNumber,
          ],
        ),
      );
      onSuccess!=null? onSuccess():(){};
    } catch(e){
      onFail(e.toString());
    }
  }

  // assign Mess- Id To Member Profile
  Future<void> assignMessIdToMemberProfile({required Function(String) onFail, Function()? onSuccess,required String memberUid, required String messId})async{
    try{

      firebaseFirestore
      .collection(Constants.users)
      .doc(memberUid)
      .set(
        {
          Constants.currentMessId : messId
        },
        SetOptions(merge: true),
        
      );
      onSuccess!=null? onSuccess():(){};
    } catch(e){
      onFail(e.toString());
    }
  }

  // remove from Mess- Id To Member Profile
  Future<void> removeMessIdFromMemberProfile({required Function(String) onFail, Function()? onSuccess,required String memberUid})async{
    try{
      firebaseFirestore
      .collection(Constants.users)
      .doc(memberUid)
      .set(
        {
          Constants.currentMessId : "",
        },
        SetOptions(merge: true),
        
      );
      _messModel= null;
      notifyListeners();
      onSuccess!=null? onSuccess():(){};

    } catch(e){
      onFail(e.toString());
    }
  }

    // delete  Mess doc from mess collection
  Future<void> deleteMess({required Function(String) onFail, Function()? onSuccess,required String MessId})async{
    try{
      firebaseFirestore
      .collection(Constants.mess)
      .doc(MessId)
      .delete();
      // mess has deleted so clear mess model
      _messModel = null;
      notifyListeners();
      onSuccess!=null? onSuccess():(){};
    } catch(e){
      onFail(e.toString());
    }
  }

  // get mess data 
  Future<void> getMessData({required Function(String) onFail, Function()? onSuccess, required String messId})async{
    DocumentSnapshot? documentSnapshot ;
    try{
      documentSnapshot = await 
        firebaseFirestore
          .collection(Constants.mess)
          .doc(messId)
          .get();
    }catch (e){
      onFail(e.toString());
    }
    // for any kind of error we gat null.
    // if everything is okk check has found or not 
    if(documentSnapshot!=null && documentSnapshot.exists){
      _messModel = MessModel.fromMap(documentSnapshot!.data() as Map<String,dynamic>);
      notifyListeners();
      onSuccess!=null?onSuccess():(){};
    }
    else{
      // we fatch data successfully but there has no data
      onFail("No Data found");
    }
    
  }

  // change mess ownership 
  Future<void> transferMessOwnership({required String adimnName,required String adminId,required  Function(String) onFail, required Function()? onSuccess})async{
    try {
      setMessModel(
        messAuthorityName: adimnName,
        messAuthorityId: adminId,
      );
      await firebaseFirestore
      .collection(Constants.mess)
      .doc(getMessModel!.messId)
      .update(
        {
          Constants.messAuthorityId : getMessModel!.messAuthorityId,
          Constants.messAuthorityName : getMessModel!.messAuthorityName,
        }
      );

      onSuccess!=null?onSuccess():(){};
    } catch (e) {
      onFail(e.toString());
   }
  }

  // change 2nd mess ownership 
  Future<void> change2ndMessOwnership({required String secondAdimnName,required String secondAdminId,required  Function(String) onFail, required Function()? onSuccess})async{
    try {
      setMessModel(
        messAuthorityName: secondAdimnName,
        messAuthorityId: secondAdminId,
      );
      await firebaseFirestore
      .collection(Constants.mess)
      .doc(getMessModel!.messId)
      .set(
        getMessModel!.toMap(),
        SetOptions(mergeFields: [Constants.messAuthorityId2nd, Constants.messAuthorityName2nd]),
      );

      onSuccess!=null?onSuccess():(){};
    } catch (e) {
      onFail(e.toString());
   }
  }

  // join mess 
  Future<void> joiningToInvaitatedMess({required Function(String) onFail, Function()? onSuccess, required String messId, required String uId})async{
    try{
      await firebaseFirestore.collection(Constants.mess).doc(messId).set({Constants.messMemberList : FieldValue.arrayUnion([uId])});
      onSuccess!=null? onSuccess():(){};
    }catch (e){
      onFail(e.toString());
    }
  }


  // change joining invaitation status 
  Future<void> changeJoiningInvaitationStatus({required Function(String) onFail, required String invaitationsId, Function()? onSuccess,required String status})async{
    try{
      await firebaseFirestore.collection(Constants.invaitationId).doc(invaitationsId).update({Constants.status : status});
      onSuccess!=null? onSuccess():(){};
    }catch (e){
      onFail(e.toString());
    }
  }

  // get list of mess member data.
  Future<List<UserModel>> getListOfMessMemberData({required List<String> listOfMember, })async{
    List<UserModel> list=[];

    for(String uid in listOfMember){
      DocumentSnapshot documentSnapshot =  await firebaseFirestore.collection(Constants.users).doc(uid).get();
      if(documentSnapshot.exists){
        list.add(UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>));
      }
    }
    return list;
  }

  Future<UserModel?> getMemberData({required String uId})async{
    DocumentSnapshot snapshot = await firebaseFirestore.collection(Constants.users).doc(uId).get();
    if(snapshot.exists){
      return UserModel.fromMap(snapshot.data() as Map<String,dynamic>);
    }
    return null;
  }


}

