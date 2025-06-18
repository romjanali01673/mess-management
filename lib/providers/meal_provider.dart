import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/model/bazer_model.dart';
import 'package:meal_hisab/model/meal_model.dart';
import 'package:meal_hisab/model/user_model.dart';

class MealProvider extends ChangeNotifier{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  MealModel? _mealModel;
  double _totalMeal = 0;
  double _totalMealOfMess = 0;
  List<Map<String,dynamic>> ? _listOfmember;
  //set -------------

  setIsLoading({required bool value}){
    _isLoading = value;
    notifyListeners();
  }

  setMeal({required double meal}){
    _totalMeal = meal;
    notifyListeners();
  }


  // get ------------

  bool get isLoading => _isLoading;
  MealModel? get getMealModel => _mealModel;
  double get getTotalMeal => _totalMeal;
  double get getTotalMealOfMess => _totalMealOfMess;
  List get getListOfMember => _listOfmember!;

  void reset(){
    _mealModel = null;
  }




  // function -----------

  // get member data
  Future<void> getMemberData({required String messId, Function()? onSuccess, required Function(String) onFail})async{
    try {
      DocumentSnapshot snapshot =  await firebaseFirestore.collection(Constants.mess).doc(messId).get();
      if(snapshot.exists){
        _listOfmember =  (snapshot.data() as Map<String,dynamic>)[Constants.messMemberList];
        onSuccess!=null? onSuccess():(){};
      }
      else{
        onFail("No Data Found!");
      }
    } catch (e) {
      onFail(e.toString());
    }
  }
  
  // get all meal transaction list 
  Future<List<MealModel>?> getMealList({required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    List<MealModel>? list;
    double meal=0;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await firebaseFirestore.collection(Constants.meal).doc(messId).collection(Constants.listOfMeal).get();
      list = snapshot.docs.map(
        (doc){
          MealModel mealModel = MealModel.fromMap(doc.data() as Map<String, dynamic>);
          print(mealModel.totalMeal);
          meal += mealModel.totalMeal;
          
          return mealModel;
        }).toList();
      
      _totalMealOfMess = meal;
      debugPrint(_totalMeal.toString());
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      debugPrint('FAILED');
      onFail(e.toString());
    }  
    _isLoading  = false;
    return list?.reversed.toList();
  }

  // get all meal transaction of a member
  Future<List<Map<String,dynamic>>?> getAllMealListOfAMember({required String messId,required String uId, required Function(String) onFail, Function()? onSuccess,})async{
    List<Map<String,dynamic>>? list;
    double meal=0;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await firebaseFirestore.collection(Constants.meal).doc(messId).collection(Constants.listOfMeal).get();
      snapshot.docs.map(
        (doc){
          MealModel mealModel = MealModel.fromMap(doc.data() as Map<String, dynamic>);
          mealModel.listOfMeal.map((e) {

            if(e[Constants.uId] == uId){
              meal +=e[Constants.meal];
              list ??= [];
              list!.add({
                Constants.fname: e[Constants.fname],
                Constants.date: mealModel.date,
                Constants.createdAt: mealModel.CreatedAt,
                Constants.meal: e[Constants.meal],
              });
            }
          },).toList();
        }).toList();
      
      _totalMeal = meal;
      debugPrint(_totalMeal.toString());
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      debugPrint('FAILED');
      onFail(e.toString());
    }  
    _isLoading  = false;
    return list?.reversed.toList();
  }
  
  // check already exist 
  Future<MealModel?> checkMealModelExist({required String messId,required String date,required Function(String) onFail, Function()? onSuccess,})async{
    try {
      DocumentSnapshot snapshot =  await firebaseFirestore.collection(Constants.meal).doc(messId).collection(Constants.listOfMeal).doc(date).get();

      onSuccess!=null? onSuccess() : (){};
      if(!snapshot.exists){
        return null;
      }
      return MealModel.fromMap(snapshot.data() as Map<String,dynamic>);
    } catch (e) {
      debugPrint('FAILED');
      onFail(e.toString());
    }  
    _isLoading  = false;
    return null;
  }

  // add a fand transaction to database 
  Future<void> addAMeal({required MealModel mealModel,required String messId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    // fatch cost,
    await getMealList(
      messId: messId, 
      onFail: (message) {  
        onFail(message);
      }, 
      onSuccess: () async{
        try {
          batch.set(
            firebaseFirestore.collection(Constants.meal)
            .doc(messId)
            .collection(Constants.listOfMeal)
            .doc(mealModel.date),
            mealModel.toMap()
          );
         
          batch.set(
            firebaseFirestore.collection(Constants.meal)
            .doc(messId),
            {Constants.totalMeal:getTotalMeal+mealModel.totalMeal}
          );

          await batch.commit();
          setMeal(meal: getTotalMealOfMess+mealModel.totalMeal);
          onSuccess!=null? onSuccess() : (){};
        } catch (e) {
          onFail(e.toString());
        }  
      }
    );
  }
}