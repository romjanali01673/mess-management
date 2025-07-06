// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:mess_management/constants.dart';
// import 'package:mess_management/model/mess_model.dart';
// import 'package:mess_management/model/pre_data_mess.dart';
// import 'package:mess_management/model/pre_data_user.dart';

// class PreDataProvider  extends ChangeNotifier{
//   FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

//   bool _isLoading = false;


//   // set -----------------------------------
//   void setIsLoading({required bool val}){
//     _isLoading = val;
//     notifyListeners();
//   }


//   // get 
//   bool get getIsLoading => _isLoading;


//   // function ------------------------


//   Future<void> loadNext({required String messId}) async {
    
//     print(_lastDoc.toString());
//     if (isLoading || !_hasMoreForward || _lastDoc == null) return;
//     debugPrint("loadNext called-2${_lastDoc!.id}");

//     setIsLoading(value: true);
//     // await Future.delayed(Duration(seconds: 10));
//     DocumentSnapshot? _firstDoc;
//     DocumentSnapshot? _lastDoc;
//     bool _hasMoreForward = true;

//     while(true){
//       if(!_hasMoreForward) break;
//       final batch = firebaseFirestore.batch();
//       try {
//         final snapshot = await firebaseFirestore
//             .collection(Constants.bazer)
//             .doc(messId)
//             .collection(Constants.listOfFundTnx)
//             // .orderBy(Constants.createdAt, descending: true)
//             .startAfterDocument(_lastDoc!)
//             .limit(500)
//             .get();

//         if (snapshot.docs.isNotEmpty) {
//           for(var doc in snapshot.docs){
//             batch.set(firebaseFirestore.collection(Constants.bazer)
//             .doc(messId)
//             .collection(Constants.listOfBazerTnx).doc(doc.id), doc.data());
//           }

//           _firstDoc = snapshot.docs.first;
//           _lastDoc = snapshot.docs.last;
//           _hasMoreForward = snapshot.docs.length == 500;

//           await batch.commit();
//         } else {
//           _hasMoreForward = false;
//         }
//       } catch (e) {
//         debugPrint(e.toString()+"bazer set");
//         break;
//       }
//     }
//     setIsLoading(value: false);
//   }





//   Future<bool> closeMessHisab({required String messId,  required Function(String)onFail, Function()? onSuccess})async{
//     WriteBatch? batch;
//     bool flag = true;
    
//     double? totalMealOfMess;
//     double? totalBazerCost;
//     double? currentFundBlance;
//     double? totalDepositOfMess;
//     PreDataMessModel? preDataMessModel;
//     List<PreDataMemberModel>? ListOfPreDataMemberModel;

//     DocumentSnapshot? _lastDoc;
//     bool _hasMoreForward = true;


//     try {
//       DocumentSnapshot snapshot = await firebaseFirestore.collection(Constants.mess).doc(messId).get();
//       if(snapshot.exists){
//         MessModel messModel =  MessModel.fromMap(snapshot.data() as Map<String,dynamic>);
//         preDataMessModel =PreDataMessModel(
//           tnxId: DateTime.now().millisecondsSinceEpoch.toString(), 
//           messId: messModel.messId, 
//           messName: messModel.messName, 
//           totalDeposit: 0.0, 
//           currentFundBlance: 0.0, 
//           totalMeal: 0.0, 
//           totalBazerCost: 0.0, 
//           messMemberList: messModel.messMemberList, 
//           mealRate: 0.0, 
//           email: messModel.messAuthorityEmail, 
//           phone: messModel.messAuthorityNumber, 
//           fullAddress: messModel.messAddress,
//         );
//         ListOfPreDataMemberModel = List.generate(preDataMessModel.messMemberList.length, (index){
//           return PreDataMemberModel(
//             tnxId: preDataMessModel!.tnxId,
//             uid: preDataMessModel.messMemberList[index][Constants.uId], 
//             fname: preDataMessModel.messMemberList[index][Constants.fname],
//             messId: preDataMessModel!.messId, 
//             totalDeposit: 0.0, 
//             totalMeal: 0.0, 
//             email: "", 
//             phone: "", 
//             fullAddress: "",
//           );
//         });
//       }
//       else{
//         flag = false;
//       }
//     } catch (e) {
//       onFail(e.toString());
//     }

//     // failed to read mess data. so stop executations
//     if(!flag) {
//       return flag;
//     }

//     try {


//       // get current fund blance 
//       try {
//         final snapshot =  await firebaseFirestore.collection(Constants.fund).doc(messId).get(GetOptions(source: Source.server));
//         if(snapshot.exists || snapshot.data()!=null){
//           currentFundBlance = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.blance]).toString());
//         }
//       } catch (e) {
//         return false;
//       }

//       // get and set pre bazer data--------------------------------------
//       try {
//         DocumentSnapshot snapshot =  await firebaseFirestore.collection(Constants.bazer).doc(messId).get(GetOptions(source: Source.server));
//         if(snapshot.exists || snapshot.data()!=null){
//           totalBazerCost = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.totalBazerCost]).toString());
//         }
//       } catch (e) {
//         return false;
//       }

//       while(true){
//         if(!_hasMoreForward) break;
//         batch = firebaseFirestore.batch();
//         try {
//           Query query = firebaseFirestore
//             .collection(Constants.bazer)
//             .doc(messId)
//             .collection(Constants.listOfBazerTnx);
//             if(_lastDoc!=null){
//               query = query.startAfterDocument(_lastDoc!);
//             } 
//             query =  query.limit(500);

//           final qSnapshot = await query
//               .get(GetOptions(source: Source.server));

//               debugPrint("get bazer successfully");

//           if (qSnapshot.docs.isNotEmpty) {
//             for(var doc in qSnapshot.docs){
//               batch.set(firebaseFirestore.collection(Constants.bazer)
//               .doc(messId)
//               .collection(Constants.listOfBazerTnx).doc(doc.id), (doc.data() as Map<String,dynamic>));
//             }

//             _lastDoc = qSnapshot.docs.last;
//             _hasMoreForward = qSnapshot.docs.length == 500;

//             await batch.commit();
//               debugPrint("set bazer successfully");
//           } else {
//             _hasMoreForward = false;
//           }
//         } catch (e) {
//           debugPrint(e.toString()+"bazer set");
//           flag = false;
//           break;
//         }
//       }

//       if(!flag){
//         // bazer update failed, delete if updoaded something
//         await firebaseFirestore.collection(Constants.preData).doc(messId).delete();
//         return flag;
//       } 
      


//       // get pre meal data ---------------------------------------------------
//       // bazer updated successfully
//       // now clear 
//       _hasMoreForward = true;
//       _lastDoc = null;
//       try {
//         DocumentSnapshot snapshot =  await firebaseFirestore.collection(Constants.meal).doc(messId).get(GetOptions(source: Source.server));
//         if(snapshot.exists || snapshot.data()!=null){
//           totalMealOfMess = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.totalMeal]).toString());
//         }
//       } catch (e) {
//           await firebaseFirestore.collection(Constants.preData).doc(messId).delete();
//           flag = false;
//           return flag;
//       }

//       while(true){
//         if(!_hasMoreForward) break;
//         batch = firebaseFirestore.batch();
//         try {
//           Query query = firebaseFirestore
//             .collection(Constants.meal)
//             .doc(messId)
//             .collection(Constants.listOfMealTnx);
//             if(_lastDoc!=null){
//               query = query.startAfterDocument(_lastDoc!);
//             } 
//             query =  query.limit(500);

//           final qSnapshot = await query.get(GetOptions(source: Source.server));

//               debugPrint("get meal successfully");

//           if (qSnapshot.docs.isNotEmpty) {
//             for(var doc in qSnapshot.docs){
//               batch.set(firebaseFirestore.collection(Constants.meal)
//               .doc(messId)
//               .collection(Constants.listOfMealTnx).doc(doc.id), (doc.data() as Map<String,dynamic>));
//             }

//             _lastDoc = qSnapshot.docs.last;
//             _hasMoreForward = qSnapshot.docs.length == 500;

//             await batch.commit();
//               debugPrint("set meal successfully");
//           } else {
//             _hasMoreForward = false;
//           }
//         } catch (e) {
//           debugPrint(e.toString()+"meal set");
//           flag = false;
//           break;
//         }
//       }

//       if(!flag){
//         // meal update failed, delete if updoaded something
//         await firebaseFirestore.collection(Constants.preData).doc(messId).delete();
//         return flag;
//       }


//       // get and set pre deposit data---------------------------------------------------
//       // meal updated successfully
//       // now clear 
//       _hasMoreForward = true;
//       _lastDoc = null;

//       try {
//         for(var x in preDataMessModel!.messMemberList){
//           QuerySnapshot qSnapshot = await firebaseFirestore.collection(Constants.deposit).doc(messId).collection(Constants.members).doc(x[Constants.uId]).collection(Constants.listOfDepositTnx).get();

//           if(qSnapshot.docs.)

//         }
//       } catch (e) {
//         onFail(e.toString());
//         flag = false;
//       }

//       try {
//         DocumentSnapshot snapshot =  await firebaseFirestore.collection(Constants.deposit).doc(messId).get(GetOptions(source: Source.server));
//         if(snapshot.exists || snapshot.data()!=null){
//           totalMealOfMess = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.blance]).toString());
//         }
//       } catch (e) {
//           await firebaseFirestore.collection(Constants.preData).doc(messId).delete();
//           flag = false;
//           return flag;
//       }


//       ListOfPreDataMemberModel[].uid = "4";
//       while(true){
//         if(!_hasMoreForward) break;
//         batch = firebaseFirestore.batch();
//         try {
//           Query query = firebaseFirestore
//             .collection(Constants.deposit)
//             .doc(messId)
//             .collection(Constants.members)
//             .;
//             if(_lastDoc!=null){
//               query = query.startAfterDocument(_lastDoc!);
//             } 
//             query =  query.limit(500);

//           final qSnapshot = await query.get(GetOptions(source: Source.server));

//               debugPrint("get deposit successfully");

//           if (qSnapshot.docs.isNotEmpty) {
//             for(var doc in qSnapshot.docs){
//               batch.set(firebaseFirestore.collection(Constants.meal)
//               .doc(messId)
//               .collection(Constants.listOfMealTnx).doc(doc.id), (doc.data() as Map<String,dynamic>));
//             }

//             _lastDoc = qSnapshot.docs.last;
//             _hasMoreForward = qSnapshot.docs.length == 500;

//             await batch.commit();
//               debugPrint("set depsoit successfully");
//           } else {
//             _hasMoreForward = false;
//           }
//         } catch (e) {
//           debugPrint(e.toString()+"deposit set");
//           flag = false;
//           break;
//         }
//       }

//       if(!flag){
//         // meal update failed, delete if updoaded something
//         await firebaseFirestore.collection(Constants.preData).doc(messId).delete();
//         return flag;
//       }






//       // set pre-mess data model
//       batch.set(
//         firebaseFirestore
//           .collection(Constants.preData)
//           .doc(messId)
//           .collection(Constants.preDataList)
//           .doc(preDataMessModel!.tnxId),

//         preDataMessModel!.toMap()  
//       );

//       for(int i =0; i<ListOfPreDataMemberModel.length; i++){
//         batch.set(
//           firebaseFirestore
//             .collection(Constants.preData)
//             .doc(messId)
//             .collection(Constants.members)
//             .doc(ListOfPreDataMemberModel[i].uid),

//           ListOfPreDataMemberModel[i]
//         );
//       }

//       batch = firebaseFirestore.batch();
//       // delete deposit
//       batch.delete(
//         firebaseFirestore
//           .collection(Constants.deposit)
//           .doc(messId)
//       );

//       // delete meal
//       batch.delete(
//         firebaseFirestore
//           .collection(Constants.meal)
//           .doc(messId)
//       );

//       // delete bazer
//       batch.delete(
//         firebaseFirestore
//           .collection(Constants.bazer)
//           .doc(messId)
//       );
      
//     }catch(e){
//       flag = false;
//     }
//     return flag;
//   }
// }