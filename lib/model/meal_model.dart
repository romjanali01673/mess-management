import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_management/constants.dart';

class MealModel{
  String date;
  List<Map<String,dynamic>> listOfMeal;//{uId,name,meal},
  double totalMeal;
  Timestamp? CreatedAt;

  MealModel(
    { 
      required this.date,
      required this.listOfMeal,
      required this.totalMeal,
      this.CreatedAt
    }
  );

  factory MealModel.fromMap(Map<String , dynamic>data){
    return MealModel(
      totalMeal: data[Constants.totalMeal]??0,
      date: data[Constants.date]?? "", 
      listOfMeal: (data[Constants.listOfMeal] as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList() ?? [], 
      CreatedAt: data[Constants.createdAt]??Timestamp.fromDate(DateTime.now()), 
    );
  }

  Map<String,dynamic> toMap(){
    return{
      Constants.date: date,
      Constants.totalMeal:totalMeal,
      Constants.listOfMeal: listOfMeal,
      Constants.createdAt: FieldValue.serverTimestamp(),
    };
  }


}