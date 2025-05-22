import 'package:meal_hisab/constants.dart';

class UserModel {
  String uId;
  String fname;
  String email;
  String image;
  String number;
  String createdAt;
  String sessionKey;

  UserModel({
    required this.uId,
    required this.fname,
    required this.email,
    required this.image,
    required this.number,
    required this.createdAt,
    required this.sessionKey,

  });

  Map<String, dynamic>toMap(){
    return{
      Constants.uId : uId,
      Constants.fname  : fname,
      Constants.email  : email,
      Constants.image  : image,
      Constants.number  : number,
      Constants.createdAt  : createdAt,
      Constants.sessionKey  : sessionKey,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic>data){
    return UserModel(
      uId: data[Constants.uId]??"", 
      fname: data[Constants.fname]??"", 
      email: data[Constants.email]??"", 
      image: data[Constants.image]??"", 
      number: data[Constants.number]??"",
      createdAt: data[Constants.createdAt]??"",
      sessionKey: data[Constants.sessionKey]??"",
    );
  }
}
