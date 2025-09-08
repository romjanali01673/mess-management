import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management/constants.dart';

class BazerModel{
  String tnxId;
  double amount;
  dynamic bazerList; //List<Map<String,dynamic>>
  Map<String,dynamic> byWho; //{Constants.uId : "", Constants.fname:""}
  Timestamp? CreatedAt;
  String bazerTime;
  String bazerDate;

  BazerModel(
    { 
      required this.tnxId,
      required this.amount,
      required this.bazerList,
      required this.byWho,
      required this.bazerTime,
      required this.bazerDate,
      this.CreatedAt
    }
  );

  factory BazerModel.fromMap(Map<String , dynamic>data){
    return BazerModel(
      tnxId: data[Constants.tnxId]?? "", 
      amount: data[Constants.amount]?? 0, 
      bazerList: data[Constants.bazerList] ??[],
      CreatedAt: data[Constants.createdAt]??Timestamp.fromDate(DateTime.now()), 
      byWho : data[Constants.byWho]??{Constants.uId : "", Constants.fname:""},
      bazerTime: data[Constants.bazerTime],
      bazerDate: data[Constants.bazerDate],
    );
  }

  Map<String,dynamic> toMap(){
    return{
      Constants.tnxId: tnxId,
      Constants.amount: amount,
      Constants.bazerList : bazerList,
      Constants.createdAt: FieldValue.serverTimestamp(),
      Constants.byWho: byWho,
      Constants.bazerTime: bazerTime ,
      Constants.bazerDate:bazerDate ,
    };
  }
}