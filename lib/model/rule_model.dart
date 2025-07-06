import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management/constants.dart';

class RuleModel{
  String tnxId;
  String title;
  String description;
  Timestamp? CreatedAt;


  RuleModel(
    { 
      required this.tnxId,
      required this.title,
      required this.description,
      this.CreatedAt
    }
  );

  factory RuleModel.fromMap(Map<String , dynamic>data){
    return RuleModel(
      tnxId: data[Constants.tnxId]?? "", 
      title: data[Constants.title]?? "", 
      description: data[Constants.description] ??"",
      CreatedAt: data[Constants.createdAt]??Timestamp.fromDate(DateTime.now()), 
    );
  }

  Map<String,dynamic> toMap(){
    return{
      Constants.tnxId: tnxId,
      Constants.title: title,
      Constants.description : description,
      Constants.createdAt: FieldValue.serverTimestamp(),
    };
  }
}