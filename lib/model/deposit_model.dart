import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management/constants.dart';

class DepositModel{
  String tnxId;
  double amount;
  String description;
  String type;
  Timestamp? CreatedAt;

  DepositModel(
    { 
      required this.tnxId,
      required this.amount,
      required this.description,
      required this.type,
      this.CreatedAt
    }
  );

  factory DepositModel.fromMap(Map<String , dynamic>data){
    return DepositModel(
      tnxId: data[Constants.tnxId]?? "", 
      amount: data[Constants.amount]?? 0, 
      description: data[Constants.description]?? "",
      CreatedAt: data[Constants.createdAt]??Timestamp.fromDate(DateTime.now()), 
      type: data[Constants.type]?? Constants.add,
    );
  }

  Map<String,dynamic> toMap(){
    return{
      Constants.tnxId: tnxId,
      Constants.amount: amount,
      Constants.description: description,
      Constants.createdAt: FieldValue.serverTimestamp(),
      Constants.type: type,
    };
  }


}