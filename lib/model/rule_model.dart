import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management/constants.dart';

class RuleModel{
  String tnxId;
  String title;
  String description;
  Timestamp? createdAt;


  RuleModel(
    { 
      required this.tnxId,
      required this.title,
      required this.description,
      this.createdAt
    }
  );

  factory RuleModel.fromMap(Map<String , dynamic>data){
    return RuleModel(
      tnxId: data[Constants.tnxId]?? "", 
      title: data[Constants.title]?? "", 
      description: data[Constants.description] ??"",
      createdAt: data[Constants.createdAt]??Timestamp.fromDate(DateTime.now()), 
    );
  }

  Map<String,dynamic> toMap(){
    return{
      Constants.tnxId: tnxId,
      Constants.title: title,
      Constants.description : description,
      Constants.createdAt: createdAt?? FieldValue.serverTimestamp(),
    };
  }
}