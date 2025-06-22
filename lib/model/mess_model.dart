import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_hisab/constants.dart';

class MessModel {
  String messId;
  String messName;
  String messAddress;
  String messAuthorityId;
  String messAuthorityId2nd;
  String messAuthorityName;
  String messAuthorityName2nd;
  String messAuthorityNumber;
  String messAuthorityEmail;
  List<Map<String,dynamic>> messMemberList;
  Timestamp? createdAt;

  MessModel({
    required this.messId,
    required this.messName,
    required this.messAddress,
    required this.messAuthorityId,
    required this.messAuthorityId2nd,
    required this.messAuthorityName,
    required this.messAuthorityName2nd,
    required this.messAuthorityNumber,
    required this.messAuthorityEmail,
    // {
    //   Constants.uId: authProvider.getUserModel!.uId.toString(),
    //   Constants.fname: authProvider.getUserModel!.fname.toString(),
    //   Constants.status: Constants.enable,
    // }
    required this.messMemberList, 
    this.createdAt,
  });

  Map<String, dynamic> toMap(){
    return{
      Constants.messId: messId,
      Constants.messName: messName,
      Constants.messAddress: messAddress,
      Constants.messAuthorityId: messAuthorityId,
      Constants.messAuthorityId2nd: messAuthorityId2nd,
      Constants.messAuthorityName: messAuthorityName,
      Constants.messAuthorityName2nd: messAuthorityName2nd,
      Constants.messAuthorityNumber: messAuthorityNumber,
      Constants.messAuthorityEmail: messAuthorityEmail,
      Constants.messMemberList: messMemberList,
      Constants.createdAt : FieldValue.serverTimestamp(),
    };
  }

  factory MessModel.fromMap(Map<String,dynamic>data){
    return MessModel(
      messId: data[Constants.messId]?? "", 
      messName: data[Constants.messName]?? "", 
      messAddress: data[Constants.messAddress]?? "", 
      messAuthorityId: data[Constants.messAuthorityId]?? "",
      messAuthorityId2nd: data[Constants.messAuthorityId2nd]?? "", 
      messAuthorityName: data[Constants.messAuthorityName]?? "", 
      messAuthorityName2nd: data[Constants.messAuthorityName2nd]?? "", 
      messAuthorityNumber: data[Constants.messAuthorityNumber]?? "", 
      messAuthorityEmail: data[Constants.messAuthorityEmail]?? "",
      messMemberList: (data[Constants.messMemberList] as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList() ?? [],
      createdAt: data[Constants.createdAt]
    );
  }
}
