
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management/constants.dart';

class JoiningModel{

  String invaitationId;
  String messName;
  String messId;
  String status;
  String description;
  String messAddress;
  Timestamp? invaitedTime;

  JoiningModel({
    required this.invaitationId,
    required this.messName,
    required this.messId,
    required this.status,
    required this.description,
    required this.messAddress,
    this.invaitedTime,
  });

  factory JoiningModel.fromMap(Map<String,dynamic> data){
    return JoiningModel(
      invaitationId: data[Constants.invaitationId]??"",
      messName: data[Constants.messName] ?? "", 
      messId: data[Constants.messId] ?? "", 
      status: data[Constants.status] ?? JoiningStatus.pending, 
      description: data[Constants.description] ?? "", 
      messAddress: data[Constants.messAddress] ?? "", 
      invaitedTime: data[Constants.invaitedTime],
    );
  }
  
  Map<String, dynamic> toMap(){
    return {
      Constants.invaitationId : invaitationId,
      Constants.messName : messName ,
      Constants.messId : messId,
      Constants.status : status,
      Constants.description : description,
      Constants.messAddress : messAddress,
      Constants.invaitedTime : FieldValue.serverTimestamp(),
    };
  }

}