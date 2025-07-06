// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/widgets.dart';
// import 'package:mess_management/constants.dart';

// class ColseMessHisabProvider extends ChangeNotifier{

//   final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

//   bool _isLoading = false;


//   //set -------------


//   // get ------------

//   bool get isLoading => _isLoading;



//   void reset(){
//     // null;
//   }


//   // function -----------

//   // add a bazer transaction to database 
//   Future<void> closeMessHisab({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
//     final batch = firebaseFirestore.batch();
//     try {
//       final snapshot= await firebaseFirestore
//         .collection(Constants.mess)
//         .doc(messId)
//         .get(GetOptions(source: Source.server));

//       if(snapshot.exists && snapshot.data()!=null){
//         List<Map<String,dynamic>> memberList = ((snapshot.data() as Map<String,dynamic>)[Constants.messMemberList] as List<dynamic>).map((x)=>x as Map<String,dynamic>).toList();
//         String newmealSessionId= DateTime.now().millisecondsSinceEpoch.toString();
//         for(var x in memberList){
//           // change current meal hisab id
//           batch.update(
//             firebaseFirestore
//             .collection(Constants.users)
//             .doc(x[Constants.uId]),
//             {
//               Constants.mealSessionId:newmealSessionId,
//             },
//           );
//           // add new meal hisab id in mealSessionList
//           batch.set(
//             firebaseFirestore
//             .collection(Constants.users)
//             .doc(x[Constants.uId])
//             .collection(Constants.messList)
//             .doc(messId)
//             .collection(Constants.mealSessionList)
//             .doc(newmealSessionId),
//             {
//               Constants.mealSessionId:newmealSessionId,
//               Constants.messId : messId,
//               Constants.messName : (snapshot.data() as Map<String,dynamic>)[Constants.messName],
//               Constants.joindAt: FieldValue.serverTimestamp()
//             },
//           );
//         }
//       }

//       await batch.commit();
//       onSuccess!=null? onSuccess() : (){};
//     } catch (e) {
//       onFail(e.toString());     
//       debugPrint(e.toString()); 
//     }  
//   }


// }