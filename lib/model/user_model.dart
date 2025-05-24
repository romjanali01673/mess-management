import 'package:meal_hisab/constants.dart';

class UserModel {
  String uId;
  String fname;
  String email;
  String image;
  String number;
  String sessionKey;
  String currentMessId;
  String fullAddress;

  UserModel({
    required this.uId,
    required this.fname,
    required this.email,
    required this.image,
    required this.number,
    required this.sessionKey,
    required this.currentMessId,
    required this.fullAddress,

  });

  Map<String, dynamic>toMap(){
    return{
      Constants.uId : uId,
      Constants.fname  : fname,
      Constants.email  : email,
      Constants.image  : image,
      Constants.number  : number,
      Constants.sessionKey  : sessionKey,
      Constants.currentMessId  : currentMessId,
      Constants.fullAddress  : fullAddress,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic>data){
    return UserModel(
      uId: data[Constants.uId]??"", 
      fname: data[Constants.fname]??"", 
      email: data[Constants.email]??"", 
      image: data[Constants.image]??"", 
      number: data[Constants.number]??"",
      sessionKey: data[Constants.sessionKey]??"",
      currentMessId: data[Constants.currentMessId]??"",
      fullAddress: data[Constants.fullAddress]??"",
    );
  }
}
