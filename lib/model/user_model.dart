import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management/constants.dart';

class UserModel {
  String uId;
  String fname;
  String email;
  String image;
  String number;
  String sessionKey;
  String currentMessId;
  String fullAddress;
  String mealSessionId;
  String? deviceId;
  Timestamp? createdAt;

  UserModel({
    required this.uId,
    required this.fname,
    required this.email,
    required this.image,
    required this.number,
    required this.sessionKey,
    required this.currentMessId,
    required this.fullAddress,
    this.deviceId,
    required this.mealSessionId,
    this.createdAt,
  });

  Map<String, dynamic>toMap(){
    return{
      Constants.uId : uId,
      Constants.fname  : fname,
      Constants.email  : email,
      Constants.image  : image,
      Constants.phone  : number,
      Constants.sessionKey  : sessionKey,
      Constants.currentMessId  : currentMessId,
      Constants.fullAddress  : fullAddress,
      Constants.deviceId: deviceId,
      Constants.mealSessionId: mealSessionId,
      Constants.createdAt: createdAt?? FieldValue.serverTimestamp()
    };
  }

  factory UserModel.fromMap(Map<String, dynamic>data){
    return UserModel(
      uId: data[Constants.uId]??"", 
      fname: data[Constants.fname]??"", 
      email: data[Constants.email]??"", 
      image: data[Constants.image]??"", 
      number: data[Constants.phone]??"",
      sessionKey: data[Constants.sessionKey]??"",
      currentMessId: data[Constants.currentMessId]??"",
      fullAddress: data[Constants.fullAddress]??"",
      deviceId: data[Constants.deviceId],
      mealSessionId: data[Constants.mealSessionId]??"",
      createdAt: data[Constants.createdAt]?? Timestamp.now(), //Timestamp.fromDate(DateTime.now())==Timestamp.now(),
    );
  }
}
