import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management/constants.dart';

class FundModel{
  String tnxId;
  double amount;
  String title;
  String description;
  String type;
  Timestamp? CreatedAt;

  FundModel(
    { 
      required this.tnxId,
      required this.amount,
      required this.title,
      required this.description,
      required this.type,
      this.CreatedAt
    }
  );

  factory FundModel.fromMap(Map<String , dynamic>data){
    return FundModel(
      tnxId: data[Constants.tnxId]?? "", 
      amount: data[Constants.amount]?? 0, 
      title: data[Constants.title]?? "", 
      description: data[Constants.description]?? "",
      CreatedAt: data[Constants.createdAt]??Timestamp.fromDate(DateTime.now()), 
      type: data[Constants.type]?? Constants.add,
    );
  }

  Map<String,dynamic> toMap(){
    return{
      Constants.tnxId: tnxId,
      Constants.amount: amount,
      Constants.title: title,
      Constants.description: description,
      Constants.createdAt: FieldValue.serverTimestamp(),
      Constants.type: type,
    };
  }


}