import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:mess_management/constants.dart';
import 'package:mess_management/model/bazer_model.dart';
import 'package:mess_management/model/meal_model.dart';
import 'package:mess_management/model/user_model.dart';

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

  setMeal({required double meal,}){
    _totalMeal = meal;
    notifyListeners();
  }
  setTotalMealOfMess({required double meal,}){
    _totalMealOfMess = meal;
    notifyListeners();
  }


  // get ------------

  bool get isLoading => _isLoading;
  MealModel? get getMealModel => _mealModel;
  double get getTotalMeal => _totalMeal;
  double get getTotalMealOfMess => _totalMealOfMess;
  List get getListOfMember => _listOfmember!;

  void reset(){
    _isLoading = false;
    _mealModel  = null;
    _totalMeal = 0;
    _totalMealOfMess = 0;
    _listOfmember  = null;
  }




  // function -----------

  // get member data
  Future<void> getMemberData({required String messId, required String mealSessionId, Function()? onSuccess, required Function(String) onFail})async{
    try {
      DocumentSnapshot snapshot =  await 
      firebaseFirestore
      .collection(Constants.mess)
      .doc(messId)
      .collection(Constants.mealSessionList)
      .doc(mealSessionId)
      .get();

      if(snapshot.exists){
        _listOfmember =  (snapshot.data() as Map<String,dynamic>)[Constants.messMemberList];
        onSuccess?.call();
      }
      else{
        onFail("No Data Found!");
      }
    } catch (e) {
      onFail(e.toString());
    }
  }
  

  // get Total Meal Of Mess From Database
  Future<void> getTotalMealOfMessFromDatabase({required String messId, required String mealSessionId, Function()? onSuccess, required Function(String) onFail})async{
    try {
      DocumentSnapshot snapshot =  await 
      firebaseFirestore
      .collection(Constants.meal)
      .doc(messId)
      .collection(Constants.mealSessionList)
      .doc(mealSessionId)
      .get();

      if(snapshot.exists){
        double d = double.parse(((snapshot.data() as Map<String,dynamic>)[Constants.totalMeal]).toString());
        onSuccess?.call();
        setTotalMealOfMess(meal: d);
      }
      else{
        onFail("No Data Found!");
        setTotalMealOfMess(meal: 0);

      }
    } catch (e) {
      onFail(e.toString());
      setTotalMealOfMess(meal: 0);
    }
  }
  

  // get all meal transaction list 
  Future<List<MealModel>?> getMealList({required String messId,required String mealSessionId, required Function(String) onFail, Function()? onSuccess,})async{
    List<MealModel>? list;
    double meal=0;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await 
      firebaseFirestore
      .collection(Constants.meal)
      .doc(messId)
      .collection(Constants.mealSessionList)
      .doc(mealSessionId)
      .collection(Constants.listOfMealTnx)
      .get();
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



  Future<double> getTotalMealOfMember({required String messId, required String mealSessionId, required String uId,required Function(String) onFail, Function()? onSuccess,})async{
    print("get my total meal called");
    double meal = 0.0;
    // setIsLoading(value: true);
    try {
      QuerySnapshot querySnapshot =  await 
        firebaseFirestore
        .collection(Constants.meal)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .collection(Constants.listOfMealTnx)
        .get();
      
      querySnapshot.docs.map((snapshot){
        print(snapshot.id);
        if(snapshot.exists && snapshot.data() != null){
          (((snapshot.data() as Map<String,dynamic>)[Constants.listOfMeal]) as List<dynamic>).map((x){
            Map<String,dynamic> mp = x as Map<String,dynamic>;
            if(mp[Constants.uId]==uId){
              meal += double.parse(mp[Constants.meal].toString());
            }
          }).toList();
        }
      }).toList();
            
      print("my total meal $meal");
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
      print(e.toString()+"getTotalMealOfMember");
    }  
    // setIsLoading(value: false);
    _totalMeal = meal;
    return meal;
  }


  // get all meal transaction of a member
  Future<List<Map<String,dynamic>>?> getAllMealListOfAMember({required String messId,required String mealSessionId, required String uId, required Function(String) onFail, Function()? onSuccess,})async{
    List<Map<String,dynamic>>? list;
    double meal=0;
    _isLoading =  true;
    try {
      QuerySnapshot snapshot =  await firebaseFirestore.
      collection(Constants.meal)
      .doc(messId)
      .collection(Constants.mealSessionList)
      .doc(mealSessionId)
      .collection(Constants.listOfMealTnx)
      .get();

      snapshot.docs.map(
        (doc){
          MealModel mealModel = MealModel.fromMap(doc.data() as Map<String, dynamic>);
          mealModel.listOfMeal.map((e) {

            if(e[Constants.uId] == uId){
              meal += double.parse(e[Constants.meal].toString());

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
    print(list);
    return list?.reversed.toList();
  }
  
  // check already exist 
  Future<MealModel?> checkMealModelAlreadyExist({required String messId, required String mealSessionId, required String date,required Function(String) onFail, Function()? onSuccess,})async{
    try {
      DocumentSnapshot snapshot =  await 
      firebaseFirestore
      .collection(Constants.meal)
      .doc(messId)
      .collection(Constants.mealSessionList)
      .doc(mealSessionId)
      .collection(Constants.listOfMealTnx)
      .doc(date)
      .get();

      print(date.toString());
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

  // add a meal transaction to database 
  Future<void> addAMeal({required MealModel mealModel,required String messId, required String mealSessionId,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    setIsLoading(value: true);
    MealModel? flg = await checkMealModelAlreadyExist(messId: messId, mealSessionId: mealSessionId, date: mealModel.date, onFail: (_) {});
    if(flg==null){
      try {
        batch.set(
          firebaseFirestore
          .collection(Constants.meal)
          .doc(messId)
          .collection(Constants.mealSessionList)
          .doc(mealSessionId)
          .collection(Constants.listOfMealTnx)
          .doc(mealModel.date),
          mealModel.toMap()
        );
  
        batch.set(
          firebaseFirestore
          .collection(Constants.meal)
          .doc(messId)
          .collection(Constants.mealSessionList)
          .doc(mealSessionId),
          // increment work with only update. but work with setoption "merge"
          {Constants.totalMeal: FieldValue.increment(mealModel.totalMeal)},
          SetOptions(merge: true)
        );

        await batch.commit();
        setTotalMealOfMess(meal: getTotalMealOfMess+mealModel.totalMeal);
        onSuccess!=null? onSuccess() : (){};

      } catch (e) {
        onFail(e.toString());
      }  
    }
    else{
      onFail("Already Added at this date");
    }
    setIsLoading(value: false);
  }

  // update a meal from database 
  Future<void> updateAMeal({required MealModel mealModel,required String messId,required String mealSessionId,required double extraMeal,required Function(String) onFail, Function()? onSuccess,})async{
    final batch = firebaseFirestore.batch();
    setIsLoading(value: true);
    // fatch cost,
    try {
      batch.set(
        firebaseFirestore
        .collection(Constants.meal)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId)
        .collection(Constants.listOfMealTnx)
        .doc(mealModel.date),
        mealModel.toMap(),
        SetOptions(
          mergeFields: [
            Constants.listOfMeal, Constants.totalMeal,
          ]
        )
      );
     
      batch.update(
        firebaseFirestore
        .collection(Constants.meal)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId),
        
        // increment work with only update. but work with setoption "merge"
        {Constants.totalMeal:FieldValue.increment(extraMeal)}
      );
      await batch.commit();
      setTotalMealOfMess(meal: getTotalMealOfMess+extraMeal);
      onSuccess!=null? onSuccess() : (){};
    } catch (e) {
      onFail(e.toString());
    }  
    setIsLoading(value: false);
  }

  // delete a meal
  Future<void> deleteAMeal({required String messId, required String mealSessionId, required String date, Function()? onSuccess, required Function(String) onFail, required double extraMeal})async{
    final batch =  firebaseFirestore.batch();
    try {
      batch.delete(
        firebaseFirestore
          .collection(Constants.meal)
          .doc(messId)
          .collection(Constants.mealSessionList)
          .doc(mealSessionId)
          .collection(Constants.listOfMealTnx)
          .doc(date),
      );

      batch.update(
        firebaseFirestore
        .collection(Constants.meal)
        .doc(messId)
        .collection(Constants.mealSessionList)
        .doc(mealSessionId),
        
        // increment work with only update. but work with setoption "merge"
        {Constants.totalMeal:FieldValue.increment(extraMeal)}
      );

      await batch.commit();
      setTotalMealOfMess(meal: getTotalMealOfMess -extraMeal);
      onSuccess?.call();
    } catch (e) {
      onFail(e.toString());
    }
  }
  
  // delete a meal
  Future<void> deleteAllTransaction({required String messId,required String mealSessionId,  Function()? onSuccess, required Function(String) onFail,})async{
    final batch =  firebaseFirestore.batch();
    try {
      batch.delete(
        firebaseFirestore
          .collection(Constants.meal)
          .doc(messId)
          .collection(Constants.mealSessionList)
          .doc(mealSessionId)
      );

      await batch.commit();

      onSuccess?.call();
    } catch (e) {
      onFail(e.toString());
    }
  }

  // 
  
}