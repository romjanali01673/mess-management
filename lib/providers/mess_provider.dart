import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/model/joining_model.dart';
import 'package:meal_hisab/model/mess_model.dart';
import 'package:meal_hisab/model/notice_model.dart';
import 'package:meal_hisab/model/rule_model.dart';
import 'package:meal_hisab/model/user_model.dart';


class MessProvider extends ChangeNotifier {
    List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  bool _isOnline = true;
  bool _isLoading = false;
  MessModel? _messModel;

  MessProvider(){
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  
  }
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  StreamSubscription? _messSubscription;


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
    String? menagerId,
    String? menagerName,
    String? menagerPhone,
    String? menagerEmail,
    String? actMenagerId,
    String? actMenagerName,
    List<Map<String,dynamic>>? messMemberList,
    List?disabledMemberList,
    String? mealHisabId,
    Timestamp? createdAt,
  }){
    if(messId != null) _messModel!.messId = messId;
    if(messName != null) _messModel!.messName = messName;
    if(messAddress != null) _messModel!.messAddress = messAddress;
    if(menagerId != null)_messModel!.menagerId = menagerId;
    if(menagerName != null)_messModel!.menagerName = menagerName;
    if(menagerPhone != null)_messModel!.menagerPhone = menagerPhone;
    if(menagerEmail != null)_messModel!.menagerEmail = menagerEmail;
    if(actMenagerId != null)_messModel!.actMenagerId = actMenagerId;
    if(actMenagerName != null)_messModel!.actMenagerName = actMenagerName;
    if(messMemberList != null)_messModel!.messMemberList = messMemberList;
    if(mealHisabId != null)_messModel!.mealHisabId = mealHisabId;
    if(createdAt != null)_messModel!.createdAt = createdAt;
    notifyListeners();
  }
  
  void reset(){
    _messModel = null;
  }


  // get -----------------------------
  MessModel? get getMessModel =>_messModel;
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;

  
  
  @override
  void dispose() {
    _messSubscription?.cancel();
    super.dispose();
  }


  // function --------------
  
  
  
  
  
  

  void listenToMess({required String messId}) {
    _messSubscription?.cancel(); // পুরানো subscription থাকলে বন্ধ করো

    _messSubscription = firebaseFirestore
        .collection(Constants.mess)
        .doc(messId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        _messModel = MessModel.fromMap(data);
        notifyListeners();
        debugPrint("listenToMess-1" +"notifyListener called");
      }
    });
  }

 

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
  Future<void> createMess({required Function(String) onFail, Function()? onSuccess, required MessModel messModel,required String uId})async{
    final batch = firebaseFirestore.batch();
    setIsloading(true);
    try{
      // create  mess
      batch.set(      
        firebaseFirestore
        .collection(Constants.mess)
        .doc(messModel.messId),
        (messModel.toMap())
      );
      
      // sync the mess with my profile
      batch.set(      
        firebaseFirestore
        .collection(Constants.users)
        .doc(uId),
        {
          Constants.currentMessId : messModel.messId ,
          Constants.mealHisabId : messModel.mealHisabId,
        },
        SetOptions(
          merge: true
        )
      );
      
      // add this mess joinded mess list 
      batch.set(
        firebaseFirestore
        .collection(Constants.users)
        .doc(uId)
        .collection(Constants.messList)
        .doc(messModel.messId),
        {
          Constants.messId : messModel.messId,
          Constants.messName : messModel.messName,
          Constants.joindAt: FieldValue.serverTimestamp(),
        },        
      );
      
      // add meal hisab id to my profile 
      batch.set(
        firebaseFirestore
        .collection(Constants.users)
        .doc(uId)
        .collection(Constants.messList)
        .doc(messModel.messId)
        .collection(Constants.mealHisaList)
        .doc(messModel.mealHisabId),
        {
          Constants.messId : messModel.messId,
          Constants.mealHisabId : messModel.mealHisabId,
          Constants.messName : messModel.messName,
          Constants.joindAt: FieldValue.serverTimestamp(),
        },        
      );

      await batch.commit();
      // all done.
      _messModel = messModel;
      setMessModel(createdAt:Timestamp.fromDate(DateTime.now()));

      onSuccess!=null? onSuccess():(){};
    } catch(e){
      onFail(e.toString());
      setIsloading(false);
    }
    setIsloading(false);
  }



  // Update mess data to firestore
  Future<void> updateMessData({required Function(String) onFail, Function()? onSuccess, required MessModel messModel, })async{
    try{
      setMessModel(
        messName: messModel.messName,
        messAddress: messModel.messAddress,
        menagerPhone: messModel.menagerPhone,
        menagerEmail: messModel.menagerEmail,
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
            Constants.menagerEmail,
            Constants.menagerPhone,
          ],
        ),
      );
      onSuccess!=null? onSuccess():(){};
    } catch(e){
      onFail(e.toString());
    }
  }

  // // assign Mess- Id To Member Profile
  // Future<void> assignMessIdToMemberProfile({required Function(String) onFail, Function()? onSuccess,required String memberUid, required String messId})async{
  //   try{
  //     await firebaseFirestore
  //     .collection(Constants.users)
  //     .doc(memberUid)
  //     .set(
  //       {
  //         Constants.currentMessId : messId
  //       },
  //       SetOptions(merge: true),
        
  //     );
  //     onSuccess!=null? onSuccess():(){};
  //   } catch(e){
  //     onFail(e.toString());
  //   }
  // }

  // remove from Mess- Id To Member Profile / leave
  Future<void> leaveFromMess({required Function(String) onFail, Function()? onSuccess,required String memberUid})async{
     final batch = firebaseFirestore.batch();
    try{

      // clear current mess id
      // clear current access id
      batch.update( 
        firebaseFirestore
        .collection(Constants.users)
        .doc(memberUid),
      
        {
          Constants.currentMessId : "",
          Constants.mealHisabId : "",
        },
      );

      await batch.commit();
      _messModel= null;
      notifyListeners();
      onSuccess!=null? onSuccess():(){};

    } catch(e){
      onFail(e.toString());
    }
  }

    // delete  Mess doc from mess collection
  Future<void> deleteMess({required Function(String) onFail, Function()? onSuccess,required String messId,required String uId})async{
    final batch = firebaseFirestore.batch();
    try{

      // delete mess
      batch.delete(
        firebaseFirestore
        .collection(Constants.mess)
        .doc(messId)
      );

      // clear fand 
      batch.delete(
        firebaseFirestore
        .collection(Constants.fand)
        .doc(messId)
      );

      // remove current mess id and meal hisab id 
      batch.update(
        firebaseFirestore
        .collection(Constants.users)
        .doc(uId),
        {
          Constants.currentMessId :"",
          Constants.mealHisabId :"",
        }
      );

      batch.commit();
      _messModel = null;
      notifyListeners();
      onSuccess!=null? onSuccess():(){};

    } catch(e){
      onFail(e.toString());
    }
  }

  // get mess data 
  Future<void> getMessData({required Function(String) onFail, Function()? onSuccess, required String messId,bool Function()? isDisposed})async{
    debugPrint("called get mess data");
    DocumentSnapshot? documentSnapshot ;
    try{
      documentSnapshot = await 
        firebaseFirestore
          .collection(Constants.mess)
          .doc(messId)
          .get();
      
    if(!(isDisposed==null || !isDisposed())) return;
      

    }catch (e){
      if(!(isDisposed==null || !isDisposed())) return;
        onFail("No Data Found.\n${e.toString()}");
    }
    if(!(isDisposed==null || !isDisposed())) return;
    // for any kind of error we gat null.
    // if everything is okk check has found or not 
    if(documentSnapshot!=null && documentSnapshot.exists){
      _messModel = MessModel.fromMap(documentSnapshot!.data() as Map<String,dynamic>);
      notifyListeners();
      onSuccess!=null?onSuccess():(){};
    }
  }

  // change mess ownership 
  Future<void> transferMessOwnership({required String adimnName,required String adminId,required  Function(String) onFail, required Function()? onSuccess})async{
    try {
      await firebaseFirestore
      .collection(Constants.mess)
      .doc(getMessModel!.messId)
      .update(
        {
          Constants.menagerId : adminId,
          Constants.menagerName : adimnName,
        }
      );

      onSuccess!=null?onSuccess():(){};
      setMessModel(
        menagerName: adimnName,
        menagerId: adminId,
      );
    } catch (e) {
      onFail(e.toString());
      debugPrint("failed ownership");
   }
  }

  // change 2nd mess ownership 
  Future<void> change2ndMessOwnership({required String secondAdimnName,required String secondAdminId,required  Function(String) onFail, required Function()? onSuccess})async{
    try {
      await firebaseFirestore
      .collection(Constants.mess)
      .doc(getMessModel!.messId)
      .set(
        {
        Constants.actMenagerId: secondAdminId,
        Constants.actMenagerName: secondAdimnName,
        },
        SetOptions(mergeFields: [Constants.actMenagerId, Constants.actMenagerName]),
      );
      onSuccess!=null?onSuccess():(){};
      setMessModel(
        actMenagerName: secondAdimnName,
        actMenagerId: secondAdminId,
      );
    } catch (e) {
      onFail(e.toString());
   }
  }

  // join mess 
  Future<void> joiningToInvaitatedMess({required Function(String) onFail, Function()? onSuccess, required String messId, required Map<String,dynamic> member, required String invaitationsId,required String status})async{
    final batch = firebaseFirestore.batch();
    try{
      DocumentSnapshot snapshot = await firebaseFirestore.collection(Constants.mess).doc(messId).get();
      if(snapshot.exists){
        
        // add member to mess
        batch.update(
          firebaseFirestore
          .collection(Constants.mess)
          .doc(messId),
          {
            Constants.messMemberList : FieldValue.arrayUnion([member])
          }
        );
        
        
        // change invaitation ststus
        batch.update(
          firebaseFirestore
          .collection(Constants.invaitations)
          .doc(member[Constants.uId])
          .collection(Constants.myInvaitationList)
          .doc(invaitationsId),

          ({Constants.status:status})
        );


                                                
        // update current mess id
        batch.update(
          firebaseFirestore
          .collection(Constants.users)
          .doc(member[Constants.uId]),

          {
            Constants.currentMessId : messId,
            Constants.mealHisabId : (snapshot.data() as Map<String,dynamic>)[Constants.mealHisabId],
          },        
        );
                                                
        // assign this mess-id to my joinded mess list 
        batch.set(
          firebaseFirestore
          .collection(Constants.users)
          .doc(member[Constants.uId])
          .collection(Constants.messList)
          .doc(messId),
          {
            Constants.messId : messId,
            Constants.messName : (snapshot.data() as Map<String,dynamic>)[Constants.messName],
            Constants.joindAt: FieldValue.serverTimestamp(),
          },     
        );

        // start meal 
        batch.set(
          firebaseFirestore
          .collection(Constants.users)
          .doc(member[Constants.uId])
          .collection(Constants.messList)
          .doc(messId)
          .collection(Constants.mealHisaList)
          .doc((snapshot.data() as Map<String,dynamic>)[Constants.mealHisabId]),
          {
            Constants.mealHisabId : (snapshot.data() as Map<String,dynamic>)[Constants.mealHisabId],
            Constants.messId : messId,
            Constants.messName : (snapshot.data() as Map<String,dynamic>)[Constants.messName],
            Constants.joindAt: FieldValue.serverTimestamp()
          },            
        );

        await batch.commit();                                 
        onSuccess!=null? onSuccess():(){};
      
      }
    }catch (e){
      onFail(e.toString());
    }
  }


  // get list of mess member data.
  Future<List<UserModel>?> getListOfMessMemberData({required List<String> listOfMember, })async{
    List<UserModel> ?list=[];

    try{
      for(String uid in listOfMember){
        DocumentSnapshot documentSnapshot =  await firebaseFirestore.collection(Constants.users).doc(uid).get();
     
        if(documentSnapshot.exists){
          list.add(UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>));
        }
      }
    }catch(e){
        debugPrint(e.toString());
    }

    return list.isEmpty?null:list;
  }



  // change joining invaitation status 
  Future<void> changeJoiningInvaitationStatus({required Function(String) onFail,required String uId, required String invaitationsId, Function()? onSuccess,required String status})async{
    try{
      await firebaseFirestore.collection(Constants.invaitations).doc(uId).collection(Constants.myInvaitationList).doc(invaitationsId).update({Constants.status:status});
      onSuccess!=null? onSuccess():(){};
    }catch (e){
      onFail(e.toString());
    }
  }

  // get mess invaitations list
  Future<List<JoiningModel?>?> getInvaitationsList({required String uId,required Function(String) onFail})async{
    List<JoiningModel?>? list;
    try {
      QuerySnapshot snapshot = await firebaseFirestore.collection(Constants.invaitations).doc(uId).collection(Constants.myInvaitationList).get();
      
      list = snapshot.docs.map((doc){
        if(doc.exists){
          return JoiningModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      }).toList();

      // if(snapshot.exist){
      //   // final map = snapshot.data() as Map<String,dynamic>;
      //   // final objlist = map[Constants.myInvaitationList] as List<dynamic>;
      //   // list = objlist.map((x)=>JoiningModel.fromMap(x as Map<String,dynamic>)).toList();
      //   list = (((snapshot.data() as Map<String,dynamic>)[Constants.myInvaitationList]) as List<dynamic>).map((x)=> JoiningModel.fromMap(x as Map<String, dynamic>)).toList();
      // }
    } catch (e) {
      onFail(e.toString());
    }
    return list;
  }

  Future<bool> checkAlreadyInvaited({required String uId, required String messId})async{
    try {
      QuerySnapshot snapshot = await firebaseFirestore.collection(Constants.invaitations).doc(uId).collection(Constants.myInvaitationList).get();
      
      snapshot.docs.map((doc){
        if(doc.exists && doc.data()!=null){
          JoiningModel joiningModel = JoiningModel.fromMap(doc.data() as Map<String, dynamic>);
          if(joiningModel.messId == messId && joiningModel.status == JoiningStatus.panding){
            return true;
          }
        }
      }).toList();

      // if(snapshot.exist){
      //   // final map = snapshot.data() as Map<String,dynamic>;
      //   // final objlist = map[Constants.myInvaitationList] as List<dynamic>;
      //   // list = objlist.map((x)=>JoiningModel.fromMap(x as Map<String,dynamic>)).toList();
      //   list = (((snapshot.data() as Map<String,dynamic>)[Constants.myInvaitationList]) as List<dynamic>).map((x)=> JoiningModel.fromMap(x as Map<String, dynamic>)).toList();
      // }
    }catch(e){
      print("failed check already invited");
    }
    return false;
  }

  // send mess invaitation card
  Future<void> sendMessInvaitaionCard({required String memberUid, required JoiningModel joiningModel,Function()? onSuccess, required Function(String) onFail})async{
    try {
      // check already invited ?

      bool flag =  await checkAlreadyInvaited(messId: joiningModel.messId, uId:memberUid );
      if(!flag){
        await firebaseFirestore 
        .collection(Constants.invaitations)
        .doc(memberUid)
        .collection(Constants.myInvaitationList)
        .doc(joiningModel.invaitationId)
        .set(joiningModel.toMap());
        onSuccess!=null?onSuccess():(){};
      }
      else{
        onFail("Already Invited");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }


  // change status member
  Future<void> changeMemberStatus()async{
    if(_isOnline == false){
      debugPrint("cancel for offline ");
      return;
    } 
    try {
      // update changed/new member list. where already changed the member status
      await firebaseFirestore.collection(Constants.mess).doc(getMessModel!.messId).update({Constants.messMemberList: getMessModel!.messMemberList});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // cick member
  Future<void> kickMemberFromMess({required Map<String,dynamic> member})async{
    final batch = firebaseFirestore.batch();
    try {

      // remove member from mess
      batch.update(
        firebaseFirestore
        .collection(Constants.mess)
        .doc(getMessModel!.messId),
        {Constants.messMemberList:FieldValue.arrayRemove([member])}
      );

      // remove current mess-id, meal-hisab-id from member profile
      batch.update(
        firebaseFirestore
        .collection(Constants.users)
        .doc(member[Constants.uId]),
        {
          Constants.currentMessId : "",
          Constants.mealHisabId : "",
        },        
      );

      await batch.commit();
      final list = getMessModel!.messMemberList;
      list.remove(member);
      setMessModel(messMemberList: list);
      
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // set Mess Rules
  Future<void> addAMessRule({required String messId,required RuleModel ruleModel, required Function(String) onFail, Function()? onSuccess})async{
    debugPrint("set a Mess Rule called");
    try {
      await firebaseFirestore
        .collection(Constants.mess)
        .doc(getMessModel!.messId)
        .collection(Constants.rules)
        .doc(ruleModel.tnxId)
        .set(
          ruleModel.toMap(),
        );

      onSuccess!=null? onSuccess():(){};
    } catch (e) {
      onFail(e.toString());
      debugPrint(e.toString());
    }
  }

  // set Mess Rules
  Future<void> updateAMessRule({required String messId,required RuleModel ruleModel, required Function(String) onFail, Function()? onSuccess})async{
    debugPrint("set a Mess Rule called");
    try {
      await firebaseFirestore
        .collection(Constants.mess)
        .doc(getMessModel!.messId)
        .collection(Constants.rules)
        .doc(ruleModel.tnxId)
        .set(
          ruleModel.toMap(),
          SetOptions(
            mergeFields: [
              Constants.title, 
              Constants.description
            ]
          )
        );

      onSuccess!=null? onSuccess():(){};
    } catch (e) {
      onFail(e.toString());
      debugPrint(e.toString());
    }
  }

  // delete Mess Rules
  Future<void> deleteAMessRule({required String messId, required String tnxId, required Function(String) onFail, Function()? onSuccess})async{
    debugPrint("delete A Mess Rule called");
    try {
      await firebaseFirestore
        .collection(Constants.mess)
        .doc(getMessModel!.messId)
        .collection(Constants.rules)
        .doc(tnxId)
        .delete();

      onSuccess!=null? onSuccess():(){};
    } catch (e) {
      onFail(e.toString());
      debugPrint(e.toString());
    }
  }

  // get getMessRules
  Future<List<RuleModel>?> getMessRules({required String messId,required Function(String) onFail, Function()? onSuccess})async{
    debugPrint("get getMessRules called");
    List<RuleModel>? list ;
    try {
      QuerySnapshot qSnapshot  = await firebaseFirestore
        .collection(Constants.mess)
        .doc(getMessModel!.messId)
        .collection(Constants.rules)
        .get();

      list =  qSnapshot.docs.map((snapshot){
        return  RuleModel.fromMap(snapshot.data() as Map<String,dynamic>);
      }).toList();
      onSuccess!=null? onSuccess():(){};
    } catch (e) {
      onFail(e.toString());
      debugPrint(e.toString());
    }
    return list;
  }
}

