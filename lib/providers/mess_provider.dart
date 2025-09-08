import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/model/joining_model.dart';
import 'package:mess_management/model/member_summary_model.dart';
import 'package:mess_management/model/mess_model.dart';
import 'package:mess_management/model/mess_summary_model.dart';
import 'package:mess_management/model/notice_model.dart';
import 'package:mess_management/model/rule_model.dart';
import 'package:mess_management/model/user_model.dart';
import 'package:mess_management/providers/deposit_provider.dart';
import 'package:mess_management/providers/firstScreen_provider.dart';
import 'package:mess_management/providers/meal_provider.dart';


class MessProvider extends ChangeNotifier {
    List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  bool _isOnline = true;
  bool _isLoading = false;
  MessModel? _messModel;

  int limit = 50;

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
    String? mealSessionId,
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
    if(mealSessionId!= null)_messModel!.mealSessionId= mealSessionId;
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
 try {
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
    } catch (e) {
      
    }
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
  Future<void> createMess({required Function(String) onFail, Function()? onSuccess, required MessModel messModel,required Map<String,dynamic> member})async{
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
        .doc(member[Constants.uId]),
        {
          Constants.currentMessId : messModel.messId ,
          Constants.mealSessionId: messModel.mealSessionId,
        },
        SetOptions(
          merge: true
        )
      );
      
      // add this mess joinded mess list 
      batch.set(
        firebaseFirestore
        .collection(Constants.users)
        .doc(member[Constants.uId])
        .collection(Constants.messList)
        .doc(messModel.messId),
        {
          Constants.messId : messModel.messId,
          Constants.messName : messModel.messName,
          Constants.joindAt: FieldValue.serverTimestamp(),
        },        
      );
      
      // add meal hisab id to my profile 
      MemberSummaryModel memberSummaryModel= MemberSummaryModel(
        fname: member[Constants.fname],
        uId: member[Constants.uId],
        mealSessionId: messModel.mealSessionId, 
        messId: messModel.messId, 
        messName: messModel.messName, 
        totalMeal: 0, 
        totalDeposit: 0, 
        remaining: 0, 
        totalMealOfMess: 0, 
        mealRate: 0, 
        totalBazerCost: 0, 
        currentFundBlance: 0,
      );
      batch.set(
        firebaseFirestore
        .collection(Constants.users)
        .doc(member[Constants.uId])
        .collection(Constants.messList)
        .doc(messModel.messId)
        .collection(Constants.mealSessionList)
        .doc(messModel.mealSessionId),

        memberSummaryModel.toMap()      
      );

      // create a mess summary model.
      MessSummaryModel messSummaryModel = MessSummaryModel(
        mealSessionId: messModel.mealSessionId, 
        messId: messModel.messId, 
        messName: messModel.messName, 
        messMemberList: messModel.messMemberList, 
        totalDeposit: 0, 
        remaining: 0, 
        totalMealOfMess: 0, 
        mealRate: 0, 
        totalBazerCost: 0, 
        currentFundBlance: 0,
      );
    
      batch.set(
        firebaseFirestore
        .collection(Constants.mess)
        .doc(messModel.messId)
        .collection(Constants.mealSessionList)
        .doc(messModel.mealSessionId),
          
        messSummaryModel.toMap()
        
      );

      await batch.commit();
      // all done.
      _messModel = messModel;
      setMessModel(createdAt:Timestamp.fromDate(DateTime.now()));

      onSuccess?.call();
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
      onSuccess?.call();
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
  //     onSuccess?.call();
  //   } catch(e){
  //     onFail(e.toString());
  //   }
  // }


  Future<void> fun()async{
    final x =await firebaseFirestore.
      collection(Constants.mess)
      .doc("1751809113692")
      // .doc(getMessModel!.messId)
      .collection(Constants.mealSessionList)
      .doc(getMessModel!.mealSessionId)
      .get();
    var messModel  =  MessModel(messId: "1751809113692",messName: "Higher Society", messAddress: "messAddress", menagerId: "1751626583875", menagerName: "md romjan ali", menagerPhone: "menagerPhone", menagerEmail: "menagerEmail", actMenagerId: "actMenagerId", actMenagerName: "actMenagerName", mealSessionId: "mealSessionId", messMemberList: []);
    await firebaseFirestore.
      collection(Constants.mess)
      // .doc(getMessModel!.messId)
      .doc("1751809113692")
      .set(
        // messModel.toMap()
        {

        Constants.messMemberList: ((x.data() as Map<String,dynamic>)[Constants.messMemberList]),
        },
        SetOptions(merge: true),
      );
  }

  // remove from Mess- Id To Member Profile / leave
  Future<void> leaveFromMess({required Function(String) onFail, Function()? onSuccess,required String memberUid, required String messId})async{
     final batch = firebaseFirestore.batch();
    try{

      // clear current mess id
      // clear current session id
      batch.update( 
        firebaseFirestore
        .collection(Constants.users)
        .doc(memberUid),
      
        {
          Constants.currentMessId : "",
          Constants.mealSessionId: "",
        },
      );

      // add as leaved member id, because when menager create a new session create excipt you.
      batch.update( 
        firebaseFirestore
        .collection(Constants.mess)
        .doc(messId),
      
        {
          Constants.leavedMemberIds: FieldValue.arrayUnion([memberUid]),
        },
      );


      await batch.commit();
      await Future.delayed(Duration(seconds: 1));
      _messModel= null;
      onSuccess?.call();
    } catch(e){
      onFail(e.toString());
    }
    setIsloading(false);
  }

  // delete  Mess doc from mess collection
  Future<void> deleteMess({required Function(String) onFail, Function()? onSuccess,required String messId,required String uId})async{
    final batch = firebaseFirestore.batch();
    setIsloading(false);
    try{


      // clear fund 
      AggregateQuerySnapshot aQuerySnapshot = await firebaseFirestore
        .collection(Constants.fund)
        .doc(messId)
        .collection(Constants.listOfFundTnx)
        .count()
        .get();
          
      int i = aQuerySnapshot.count??0;

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
          setIsloading(false);
          return;// to off loop and declain next process
        }
      }
      await firebaseFirestore.collection(Constants.fund).doc(messId).delete();


      // clear meal session 
      AggregateQuerySnapshot aQuerySnapshonMealSession = await firebaseFirestore
        .collection(Constants.mess)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .count()
        .get();
          
      i = aQuerySnapshonMealSession.count??0;

      while(i>0){
        try {
          QuerySnapshot aQuerySnapshonMealSession = await firebaseFirestore
            .collection(Constants.mess)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .limit(limit)
            .get();

          await Future.wait(aQuerySnapshonMealSession.docs.map((x) => x.reference.delete()));
          await Future.delayed(Duration(milliseconds: 1100));// to ignore firebase time limit.
          i-=aQuerySnapshonMealSession.docs.length;
          if(aQuerySnapshonMealSession.docs.isEmpty) break;
        } catch (e) {
          onFail(e.toString());
          setIsloading(false);
          return;// to off loop and declain next process
        }
      }
      // await firebaseFirestore.collection(Constants.fund).doc(messId).delete();


      //clear notices
      AggregateQuerySnapshot aQuerySnapshot2 = await firebaseFirestore
        .collection(Constants.notice)
        .doc(messId)
        .collection(Constants.listOfNotice)
        .count()
        .get();

        i = aQuerySnapshot2.count??0;

      while(i>0){
        try {
          QuerySnapshot qSnapshot = await firebaseFirestore
            .collection(Constants.notice)
            .doc(messId)
            .collection(Constants.listOfNotice)
            .limit(limit)
            .get();

          await Future.wait(qSnapshot.docs.map((x) => x.reference.delete()));
          await Future.delayed(Duration(milliseconds: 1050));
          i-=qSnapshot.docs.length;
          if(qSnapshot.docs.isEmpty) break;
        } catch (e) {
          onFail(e.toString());
          setIsloading(false);
          return;// to off loop and declain next process
        }
      }
      await firebaseFirestore.collection(Constants.notice).doc(messId).delete();

      // clear rulse
      AggregateQuerySnapshot aQuerySnapshot3 = await firebaseFirestore
        .collection(Constants.mess)
        .doc(messId)
        .collection(Constants.rules)
        .count()
        .get();

        i = aQuerySnapshot3.count??0;

      while(i>0){
        try {
          QuerySnapshot qSnapshot = await firebaseFirestore
            .collection(Constants.mess)
            .doc(messId)
            .collection(Constants.rules)
            .limit(limit)
            .get();

          await Future.wait(qSnapshot.docs.map((x) => x.reference.delete()));
          await Future.delayed(Duration(milliseconds: 1100));
          i-=qSnapshot.docs.length;
          if(qSnapshot.docs.isEmpty) break;
        } catch (e) {
          onFail(e.toString());
          setIsloading(false);
          return;// to off loop and declain next process
        }
      }


      // delete mess
      batch.delete(
        firebaseFirestore
        .collection(Constants.mess)
        .doc(messId)
      );



      // remove current mess id and meal hisab id 

      final snapshot= await firebaseFirestore
        .collection(Constants.mess)
        .doc(messId)
        .get(GetOptions(source: Source.server));

      if(snapshot.exists && snapshot.data()!=null){
        
        List<String> leavedMemberIds = (((snapshot.data() as Map<String,dynamic>)[Constants.leavedMemberIds]?? []) as List<dynamic>).map((x)=>x as String).toList();
        List<Map<String,dynamic>> memberList = ((snapshot.data() as Map<String,dynamic>)[Constants.messMemberList] as List<dynamic>).map((x)=>x as Map<String,dynamic>).toList();
        memberList.removeWhere((x)=>leavedMemberIds.contains(x[Constants.uId]));// remove leaved member data from the list
        
        for(var x in memberList){
          // change current meal hisab id
          batch.update(
            firebaseFirestore
            .collection(Constants.users)
            .doc(x[Constants.uId]),
            {
              Constants.currentMessId :"",
              Constants.mealSessionId:"",
            },
          );
        }
      }


      await batch.commit();
      _messModel = null;
      notifyListeners();
      onSuccess?.call();
    } catch(e){
      onFail(e.toString());
    }
    setIsloading(false);
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
      onSuccess?.call();
    }
  }
  // get mess data 
  Future<List<Map<String,dynamic>>> getMessMemberList({required Function(String) onFail, Function()? onSuccess, required String messId,bool Function()? isDisposed})async{
    debugPrint("getMessMemberList called");
    
    await getMessData(onFail: onFail, messId: messId);
    onSuccess?.call();
    
    return getMessModel?.messMemberList??[];
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

      onSuccess?.call();
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
      onSuccess?.call();
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
        MessModel messModel = MessModel.fromMap(snapshot.data() as Map<String,dynamic>);
        
        // add member to mess
        batch.update(
          firebaseFirestore
          .collection(Constants.mess)
          .doc(messId),
          {
            Constants.messMemberList : FieldValue.arrayUnion([member]),
            Constants.leavedMemberIds: FieldValue.arrayRemove([member[Constants.uId].toString()]),
          }
        );

        // assign new member data to the mealsession of mess summary
        batch.update(
          firebaseFirestore
          .collection(Constants.mess)
          .doc((snapshot.data() as Map<String,dynamic>)[Constants.messId])
          .collection(Constants.mealSessionList)
          .doc((snapshot.data() as Map<String,dynamic>)[Constants.mealSessionId]),
          {
            //mess member list AND add new meal hisab id in mealSessionList FOR MESS
            Constants.messMemberList: FieldValue.arrayUnion([member]),
          },
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


                                                
        // update current mess id, meal session id
        batch.update(
          firebaseFirestore
          .collection(Constants.users)
          .doc(member[Constants.uId]),

          {
            Constants.currentMessId : messId,
            Constants.mealSessionId: (snapshot.data() as Map<String,dynamic>)[Constants.mealSessionId],
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

        MemberSummaryModel memberSummaryModel= MemberSummaryModel(
          fname:member[Constants.uId] ,
          uId: member[Constants.uId],
          mealSessionId: messModel.mealSessionId, 
          messId: messModel.messId, 
          messName: messModel.messName, 
          totalMeal: 0, 
          totalDeposit: 0, 
          remaining: 0, 
          totalMealOfMess: 0, 
          mealRate: 0, 
          totalBazerCost: 0, 
          currentFundBlance: 0,
        );
        batch.set(
          firebaseFirestore
          .collection(Constants.users)
          .doc(member[Constants.uId])
          .collection(Constants.messList)
          .doc(messId)
          .collection(Constants.mealSessionList)
          .doc((snapshot.data() as Map<String,dynamic>)[Constants.mealSessionId]),
          
          memberSummaryModel.toMap()
                      
        );

        await batch.commit();                                 
        onSuccess?.call();
      
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
      onSuccess?.call();
    }catch (e){
      onFail(e.toString());
    }
  }

  // get mess invaitations list
  Future<List<JoiningModel?>?> getInvaitationsList({required String uId,required Function(String) onFail})async{
    List<JoiningModel>? list;
    try {
      QuerySnapshot snapshot = await 
        firebaseFirestore
        .collection(Constants.invaitations)
        .doc(uId)
        .collection(Constants.myInvaitationList)
        .limit(limit)
        .get();
      
      list = snapshot.docs.map((doc){
        return JoiningModel.fromMap(doc.data() as Map<String, dynamic>);
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
    return list?.reversed.toList();
  }

  // send mess invaitation card
  Future<void> sendMessInvaitaionCard({required String memberUid, required JoiningModel joiningModel,Function()? onSuccess, required Function(String) onFail})async{
    try {
      // check already invited ?

      if(true){
        await firebaseFirestore 
        .collection(Constants.invaitations)
        .doc(memberUid)
        .collection(Constants.myInvaitationList)
        .doc(joiningModel.invaitationId)
        .set(joiningModel.toMap());
        onSuccess?.call();
      }
    } catch (e) {
      onFail(e.toString());
    }
  }


  // change status member
  Future<void> changeMemberStatus({required Map<String,dynamic> preMemberData,required Map<String,dynamic> newMemberData,})async{
    if(_isOnline == false){
      debugPrint("cancel for offline ");
      return;
    } 
    try {
      final batch = firebaseFirestore.batch();
      // update changed/new member list. where already changed the member status
      batch.update(
        firebaseFirestore
        .collection(Constants.mess)
        .doc(getMessModel!.messId),
      
        {Constants.messMemberList: FieldValue.arrayRemove([preMemberData])}
      );
      batch.update(
        firebaseFirestore
        .collection(Constants.mess)
        .doc(getMessModel!.messId),
      
        {Constants.messMemberList: FieldValue.arrayUnion([newMemberData])}
      );
    
      await batch.commit();
      
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
          Constants.mealSessionId: "",
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
    setIsloading(true);
    try {
      await firebaseFirestore
        .collection(Constants.mess)
        .doc(getMessModel!.messId)
        .collection(Constants.rules)
        .doc(ruleModel.tnxId)
        .set(
          ruleModel.toMap(),
        );

      onSuccess?.call();
    } catch (e) {
      onFail(e.toString());
      debugPrint(e.toString());
    }
    setIsloading(false);
  }

  // set Mess Rules
  Future<void> updateAMessRule({required String messId,required RuleModel ruleModel, required Function(String) onFail, Function()? onSuccess})async{
    debugPrint("set a Mess Rule called");
    setIsloading(true);
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

      onSuccess?.call();
    } catch (e) {
      onFail(e.toString());
      debugPrint(e.toString());
    }
    setIsloading(false);
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

      onSuccess?.call();
    } catch (e) {
      onFail(e.toString());
      debugPrint(e.toString());
    }
  }

  // get getMessRules
  Future<List<RuleModel>?>  getMessRules({required String messId,required Function(String) onFail, Function()? onSuccess})async{
    debugPrint("get getMessRules called");
    List<RuleModel>? list ;
    try {
      QuerySnapshot qSnapshot  = await firebaseFirestore
        .collection(Constants.mess)
        .doc(messId)
        .collection(Constants.rules)
        .get();

      list =  qSnapshot.docs.map((snapshot){
        return  RuleModel.fromMap(snapshot.data() as Map<String,dynamic>);
      }).toList();
      onSuccess?.call();
    } catch (e) {
      onFail(e.toString());
      debugPrint(e.toString());
    }
    return list?.reversed.toList();
  }

  Future<void> closeMessHisab({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    setIsloading(true);
    List<String> leavedMemberIds=[];
    List<Map<String,dynamic>> memberList=[];
    MessModel? messModel;

    try {
      String newmealSessionId= DateTime.now().millisecondsSinceEpoch.toString();

      final snapshot= await firebaseFirestore
        .collection(Constants.mess)
        .doc(messId)
        .get(GetOptions(source: Source.server));


      // set new meal hisab id in every member profile
      if(snapshot.exists && snapshot.data()!=null){
        
        messModel = MessModel.fromMap(snapshot.data() as Map<String,dynamic>);
        leavedMemberIds = (((snapshot.data() as Map<String,dynamic>)[Constants.leavedMemberIds]??[]) as List<dynamic>).map((x)=>x as String).toList();
        memberList = ((snapshot.data() as Map<String,dynamic>)[Constants.messMemberList] as List<dynamic>).map((x)=>x as Map<String,dynamic>).toList();
        memberList.removeWhere((x)=>leavedMemberIds.contains(x[Constants.uId]));// remove leaved member data from the list
        
        for(var member in memberList){
          // change current meal hisab id
          batch.update(
            firebaseFirestore
            .collection(Constants.users)
            .doc(member[Constants.uId]),
            {
              Constants.mealSessionId:newmealSessionId,
            },
          );

          // add new meal session id in mealSessionList
          MemberSummaryModel memberSummaryModel= MemberSummaryModel(
            fname: member[Constants.fname],
            uId: member[Constants.uId],
            mealSessionId: newmealSessionId, 
            messId: messModel.messId, 
            messName: messModel.messName, 
            totalMeal: 0, 
            totalDeposit: 0, 
            remaining: 0, 
            totalMealOfMess: 0, 
            mealRate: 0, 
            totalBazerCost: 0, 
            currentFundBlance: 0,
          );
          batch.set(
            firebaseFirestore
            .collection(Constants.users)
            .doc(member[Constants.uId])
            .collection(Constants.messList)
            .doc(messId)
            .collection(Constants.mealSessionList)
            .doc(newmealSessionId),
            
            memberSummaryModel.toMap(),
          );
        }

        // create new mess summary .
        MessSummaryModel messSummaryModel = MessSummaryModel(
          mealSessionId: newmealSessionId, //new
          messId: messModel.messId, 
          messName: messModel.messName, 
          messMemberList: messModel.messMemberList, 
          totalDeposit: 0, 
          remaining: 0, 
          totalMealOfMess: 0, 
          mealRate: 0, 
          totalBazerCost: 0, 
          currentFundBlance: 0,
        );

        batch.set(
          firebaseFirestore
          .collection(Constants.mess)
          .doc(messId)
          .collection(Constants.mealSessionList)
          .doc(newmealSessionId),
          
          messSummaryModel.toMap()
          
        );

        // set session end date to pre meal session model
        batch.update(
          firebaseFirestore
            .collection(Constants.mess)
            .doc(messModel.messId)
            .collection(Constants.mealSessionList)
            .doc(messModel.mealSessionId),// pre meal session id
          
          {
            Constants.closedAt: FieldValue.serverTimestamp(),
          }
        );

        // removed leaved mess member data from the member list.
        // clear leaved member list
        // update new meal hisab id in mess profile
        batch.update(
          firebaseFirestore
          .collection(Constants.mess)
          .doc(messId),
          {
            Constants.messMemberList:memberList, 
            Constants.mealSessionId:newmealSessionId,
            Constants.leavedMemberIds:[],
          },
        );


        await batch.commit();
        onSuccess?.call();
      }
      else{
        // safety if get faild when read.
        onFail("Somthing Wrong");
        return;
      }

    } catch (e) {
      onFail(e.toString());     
      debugPrint(e.toString()); 
    }  
    setIsloading(false);
  }

  Future<List<Map<String,dynamic>>> getAUserMessList({
    required String uId,
    required Function(String) onFail,
    Function()? onSuccess,
  }) async{
    List<Map<String,dynamic>> list = [];

    QuerySnapshot qSnapshot =await firebaseFirestore.collection(Constants.users).doc(uId).collection(Constants.messList).get();
  

    for (DocumentSnapshot x in qSnapshot.docs){
      try {
          list.add(x.data() as Map<String, dynamic>);
      } catch (e) {
        onFail("Failed to get data for ID $x: $e");
      }
    }

    onSuccess?.call();
    return list;
  }

  Future<MemberSummaryModel?> getAMemberMealSummaryForASpacificMess({
    required String uId,
    required String messId,
    required String mealSessionId,
    required Function(String) onFail,
    Function()? onSuccess,
  }) async{
    MemberSummaryModel? memberSummaryModel;

    DocumentSnapshot snapshot =await firebaseFirestore
      .collection(Constants.users)
      .doc(uId)
      .collection(Constants.messList)
      .doc(messId)
      .collection(Constants.mealSessionList)
      .doc(mealSessionId)
      .get();
  
    if (snapshot.exists && snapshot.data() != null){
      memberSummaryModel = MemberSummaryModel.fromMap(snapshot.data() as Map<String,dynamic>);
    }
    else{
      onFail("Data Not Found");
    }
    onSuccess?.call();
    return memberSummaryModel;
  }

  Future<List<Map<String,dynamic>>> getAMemberMealSessionListForASpacificMess({
    required String uId,
    required String messId,
    required Function(String) onFail,
    Function()? onSuccess,
  }) async{
    List<Map<String,dynamic>> list = [];

    QuerySnapshot qSnapshot =await firebaseFirestore
      .collection(Constants.users)
      .doc(uId)
      .collection(Constants.messList)
      .doc(messId)
      .collection(Constants.mealSessionList)
      .get();
  
    for (DocumentSnapshot x in qSnapshot.docs){
      try {
          list.add(x.data() as Map<String, dynamic>);
      } catch (e) {
        onFail(e.toString());
      }
    }
    onSuccess?.call();
    return list;
  }

  Future<List<Map<String,dynamic>>> getAllMessSummaryModelForASpacificMess({
    required String messId,
    required Function(String) onFail,
    Function()? onSuccess,
  }) async{
    List<Map<String,dynamic>> list = [];

    QuerySnapshot qSnapshot =await firebaseFirestore
      .collection(Constants.mess)
      .doc(messId)
      .collection(Constants.mealSessionList)
      .get();
  
    for (DocumentSnapshot x in qSnapshot.docs){
      try {
          list.add(x.data() as Map<String, dynamic>);
      } catch (e) {
        onFail("Failed to get data for ID $x: $e");
      }
    }

    onSuccess?.call();
    return list;
  }

  // genarate member summary
  Future<void> genarateMemberSummary({
    required MessSummaryModel messSummaryModel,
    required Function(String) onFail,
    Function()? onSuccess,
  })async{
    setIsloading(true);
    print("genarateMemberSummary called");
    final firstScreenProvider =  FirstScreenProvider();
    final  mealProvider =  MealProvider();
    final  depositProvider =  DepositProvider();
      
    double getTotalDepositOfMember =0;
    double getTotalMealOfMember = 0;

    double totalDepositOfMess = 0;
    double totalBazerCost =  0; 
    double totalMealOfMess = 0;    
    double currentFundBlance = 0;    
    bool flag = true;

    MessSummaryModel? preMessSummaryModel;

    final batch= firebaseFirestore.batch();

    try {
      if(flag) totalDepositOfMess =      await firstScreenProvider.getTotalDeposit(messId: messSummaryModel.messId, onFail: (message){onFail(message); flag = false;}, mealSessionId: messSummaryModel.mealSessionId);
      if(flag) totalBazerCost =          await firstScreenProvider.getTotalBazer(messId: messSummaryModel.messId, onFail: (message){onFail(message); flag = false;}, mealSessionId: messSummaryModel.mealSessionId);
      if(flag) totalMealOfMess =         await firstScreenProvider.getTotalMeal(messId: messSummaryModel.messId, onFail: (message){onFail(message); flag = false;}, mealSessionId: messSummaryModel.mealSessionId);
      if(flag) currentFundBlance =       await firstScreenProvider.getFundBlance(messId: messSummaryModel.messId, onFail: (message){onFail(message); flag = false;},);
      
      double mealRate = totalBazerCost / (totalMealOfMess==0? 1:totalMealOfMess);

      DocumentSnapshot snapshot = await firebaseFirestore
        .collection(Constants.mess)
        .doc(messSummaryModel.messId)
        .collection(Constants.mealSessionList)
        .doc(messSummaryModel.mealSessionId)
        .get();

      if(snapshot.exists && snapshot.data()!=null){
        preMessSummaryModel = MessSummaryModel.fromMap(snapshot.data() as Map<String,dynamic>);
        


        // set final member summary for every member of this session.
        for(var member in preMessSummaryModel.messMemberList){
          if(flag) getTotalDepositOfMember = await depositProvider.getTotalDepositOfAMember(messId: messSummaryModel.messId, uId: member[Constants.uId], onFail: (message){onFail(message); flag = false;}, mealSessionId: messSummaryModel.mealSessionId);
          if(flag) getTotalMealOfMember =    await mealProvider.getTotalMealOfMember(messId: messSummaryModel.messId, uId: member[Constants.uId], onFail: (message){onFail(message); flag = false;}, mealSessionId: messSummaryModel.mealSessionId);

          // data get failed,
          // stop progress
          if(!flag) return;

          MemberSummaryModel newMemberSummaryModel = MemberSummaryModel(
            fname: member[Constants.fname],
            uId: member[Constants.uId],
            mealSessionId: messSummaryModel.mealSessionId,
            messId: messSummaryModel.messId, 
            messName: messSummaryModel.messName, 
            joindAt: messSummaryModel.joindAt,
            closedAt: preMessSummaryModel.closedAt, //update closedAt 

            totalMeal: getTotalMealOfMember, 
            totalDeposit: getTotalDepositOfMember, 
            remaining: (getTotalDepositOfMember - mealRate*getTotalMealOfMember), 
            totalMealOfMess: totalMealOfMess, 
            mealRate: mealRate, 
            totalBazerCost: totalBazerCost, 
            currentFundBlance: currentFundBlance,
            status: Constants.Fianl, // make it final 
          );

          batch.set(
            firebaseFirestore 
              .collection(Constants.users)
              .doc(member[Constants.uId])
              .collection(Constants.messList)
              .doc(messSummaryModel.messId)
              .collection(Constants.mealSessionList)
              .doc(messSummaryModel.mealSessionId),

            newMemberSummaryModel.toMap()
          );


        }

        // make mess summary final.
        preMessSummaryModel.totalDeposit = totalDepositOfMess;
        preMessSummaryModel.totalMealOfMess = totalMealOfMess;
        preMessSummaryModel.totalBazerCost = totalBazerCost;
        preMessSummaryModel.currentFundBlance = currentFundBlance;
        preMessSummaryModel.mealRate = mealRate;
        preMessSummaryModel.remaining = totalDepositOfMess+currentFundBlance-totalBazerCost;
        preMessSummaryModel.status = Constants.Fianl;// make it final 

        batch.update(
          firebaseFirestore
          .collection(Constants.mess)
          .doc(preMessSummaryModel.messId)
          .collection(Constants.mealSessionList)
          .doc(preMessSummaryModel.mealSessionId),
          
          preMessSummaryModel.toMap()
        );

        await batch.commit();
        onSuccess?.call();
      }
    } catch (e) {
      onFail(e.toString());
      debugPrint("genarateMemberSummary Error: " + e.toString());
    }
    setIsloading(false);
  }

}

