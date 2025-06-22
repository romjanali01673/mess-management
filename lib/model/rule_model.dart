import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_hisab/constants.dart';

class RuleModel{
  String transactionId;
  String title;
  String description;
  Timestamp? CreatedAt;


  RuleModel(
    { 
      required this.transactionId,
      required this.title,
      required this.description,
      this.CreatedAt
    }
  );

  factory RuleModel.fromMap(Map<String , dynamic>data){
    return RuleModel(
      transactionId: data[Constants.transactionId]?? "", 
      title: data[Constants.title]?? "", 
      description: data[Constants.description] ??"",
      CreatedAt: data[Constants.createdAt], 
    );
  }

  Map<String,dynamic> toMap(){
    return{
      Constants.transactionId: transactionId,
      Constants.title: title,
      Constants.description : description,
      Constants.createdAt: FieldValue.serverTimestamp(),
    };
  }
}