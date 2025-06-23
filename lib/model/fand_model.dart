import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_hisab/constants.dart';

class FandModel{
  String transactionId;
  double amount;
  String title;
  String description;
  String type;
  Timestamp? CreatedAt;

  FandModel(
    { 
      required this.transactionId,
      required this.amount,
      required this.title,
      required this.description,
      required this.type,
      this.CreatedAt
    }
  );

  factory FandModel.fromMap(Map<String , dynamic>data){
    return FandModel(
      transactionId: data[Constants.transactionId]?? "", 
      amount: data[Constants.amount]?? 0, 
      title: data[Constants.title]?? "", 
      description: data[Constants.description]?? "",
      CreatedAt: data[Constants.createdAt]??Timestamp.fromDate(DateTime.now()), 
      type: data[Constants.type]?? Constants.add,
    );
  }

  Map<String,dynamic> toMap(){
    return{
      Constants.transactionId: transactionId,
      Constants.amount: amount,
      Constants.title: title,
      Constants.description: description,
      Constants.createdAt: FieldValue.serverTimestamp(),
      Constants.type: type,
    };
  }


}