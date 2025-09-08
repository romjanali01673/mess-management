import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management/constants.dart';

class MessModel {
  String messId;
  String messName;
  String messAddress;
  String menagerId;
  String menagerName;
  String menagerPhone;
  String menagerEmail;
  String actMenagerId;
  String actMenagerName;
  List<Map<String,dynamic>> messMemberList;
  String mealSessionId;
  Timestamp? createdAt;

  MessModel({
    required this.messId,
    required this.messName,
    required this.messAddress,
    required this.menagerId,
    required this.menagerName,
    required this.menagerPhone,
    required this.menagerEmail,
    required this.actMenagerId,
    required this.actMenagerName,
    // {
    //   Constants.uId: authProvider.getUserModel!.uId.toString(),
    //   Constants.fname: authProvider.getUserModel!.fname.toString(),
    //   Constants.status: Constants.enable,
    // }
    required this.mealSessionId,
    required this.messMemberList, 
    this.createdAt,
  });

  Map<String, dynamic> toMap(){
    return{
      Constants.messId: messId,
      Constants.messName: messName,
      Constants.messAddress: messAddress,
      Constants.menagerId: menagerId,
      Constants.actMenagerId: actMenagerId,
      Constants.menagerName: menagerName,
      Constants.actMenagerName: actMenagerName,
      Constants.menagerPhone: menagerPhone,
      Constants.menagerEmail: menagerEmail,
      Constants.messMemberList: messMemberList,
      Constants.mealSessionId: mealSessionId,
      Constants.createdAt : FieldValue.serverTimestamp(),
    };
  }

  factory MessModel.fromMap(Map<String,dynamic>data){
    return MessModel(
      messId: data[Constants.messId]?? "", 
      messName: data[Constants.messName]?? "", 
      messAddress: data[Constants.messAddress]?? "", 
      actMenagerId: data[Constants.actMenagerId]?? "",
      actMenagerName: data[Constants.actMenagerName]?? "", 
      menagerEmail: data[Constants.menagerEmail]?? "", 
      menagerId: data[Constants.menagerId]?? "", 
      menagerName: data[Constants.menagerName]?? "", 
      menagerPhone: data[Constants.menagerPhone]?? "",
      messMemberList: (data[Constants.messMemberList] as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList() ?? [],
            
      mealSessionId: data[Constants.mealSessionId]??"",
      createdAt: data[Constants.createdAt]??Timestamp.fromDate(DateTime.now())
    );
  }
}

