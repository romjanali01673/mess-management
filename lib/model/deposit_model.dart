import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_hisab/constants.dart';

class DepositModel{
  String transactionId;
  double amount;
  String description;
  String type;
  Timestamp? CreatedAt;

  DepositModel(
    { 
      required this.transactionId,
      required this.amount,
      required this.description,
      required this.type,
      this.CreatedAt
    }
  );

  factory DepositModel.fromMap(Map<String , dynamic>data){
    return DepositModel(
      transactionId: data[Constants.transactionId]?? "", 
      amount: data[Constants.amount]?? 0, 
      description: data[Constants.description]?? "",
      CreatedAt: data[Constants.createdAt]??Timestamp.fromDate(DateTime.now()), 
      type: data[Constants.type]?? Constants.add,
    );
  }

  Map<String,dynamic> toMap(){
    return{
      Constants.transactionId: transactionId,
      Constants.amount: amount,
      Constants.description: description,
      Constants.createdAt: FieldValue.serverTimestamp(),
      Constants.type: type,
    };
  }


}