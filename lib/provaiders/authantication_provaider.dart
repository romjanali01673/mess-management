import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meal_hisab/constants.dart';
import 'package:meal_hisab/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage firebaseStorage= FirebaseStorage.instance;
  final FirebaseFirestore firebaseFirestore= FirebaseFirestore.instance;
  
  bool _isLoading = false;
  bool _isSignedIn = false;

  String? _uId;
  UserModel? _userModel;

  // get ---------------------

  bool get isLoading => _isLoading;
  String? get uid => _uId;
  UserModel? get userModel=> _userModel;

  // set -------------------



  Future<void> setSignedIn ({required bool val, })async{
    SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
    _isSignedIn = val;
    if(val){
      await sharedPreferences.setBool(Constants.isSignedIn, true);
    }
    notifyListeners();
  }

  void setLoading({required bool val}){
    _isLoading = val;
    notifyListeners();
  }



  // function here ---------------------------------------
  

  //
  Future<void> sessionValid({required Function(bool) onSuccess,required Function(String) onFail})async{
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String StringUserModel =  await sharedPreferences.getString(Constants.userModel).toString();
      UserModel userM = UserModel.fromMap(jsonDecode(StringUserModel));

      onSuccess(userM.sessionKey == userModel!.sessionKey);
      print(userModel!.sessionKey);
      print(userM.sessionKey);
    } catch (e) {
      onFail(e.toString()+"0002");
    }
  }

  // set session key to firestore
  Future<void> setSessionKey({required Function(String) onFail,Function()? onSuccess})async{
    try {
      firebaseFirestore 
        .collection(Constants.users)
        .doc(firebaseAuth.currentUser!.uid)
        .set(
          {
            Constants.sessionKey : DateTime.now().millisecondsSinceEpoch.toString()
          },
          SetOptions(
            merge: true
          ),
        );
        onSuccess!=null? onSuccess() :(){} ;
    } catch (e) {
      onFail(e.toString());
    }
  }

  //check is Sign In
  Future<bool> checkIsSignedIn()async{
    final SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
    _isSignedIn =  sharedPreferences.getBool(Constants.isSignedIn) ?? false;
    notifyListeners();
    return _isSignedIn;
  }

  // store userprofile data to shared preference
  Future<bool> saveUserDataToSharedPref()async{
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString(Constants.userModel, jsonEncode(userModel!.toMap()));
    } catch (e) {
      return false;
    }
    return true;
  }


  // check user exist
  Future<bool> getUserProfileData({required Function(String) onFail})async{
    // way 1
    // await firebaseFirestore.collection(Constants.users).doc(uid).get().then((DocumentSnapshot documentSnapshot){
      // _userModel = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    // });
    // way 2
    DocumentSnapshot? documentSnapshot;
    try{
      documentSnapshot = await firebaseFirestore
        .collection(Constants.users)
        .doc(firebaseAuth.currentUser!.uid) //"firebaseAuth.currentUser" it's stored local memory (in rom). so we can access it untill cashed was not cleared or logout.
        .get(const GetOptions( source: Source.serverAndCache)); 
    }catch (e){
      onFail(e.toString()+"getUserProfileData");
    }
    if(documentSnapshot!=null &&  documentSnapshot!.exists){
      // user exist 
      _userModel = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    return true;
      
    }
    else{
      return false;
    }
  }

  // signIn with email and password
  Future<UserCredential?> signInWithEmailAndPassword({required String email, required String password,required Function(String) onFail})async{

    UserCredential? userCredential;
    try {
      userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      //"firebaseAuth.currentUser!.uid" it's stored local memory (in rom). so we can access it untill cashed was not cleared or logout.
      
    }on FirebaseException catch(e){
      if(e.toString()=="user-not-found"){
        onFail("User Not Found");
      }
      else onFail(e.toString());
    }catch (e) {
      onFail(e.toString());
    }
    if(userCredential!=null){
      _uId = userCredential.user!.uid;
    }
    return userCredential;
  }


  // create a user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({required String email, required String password, required Function(String) onFail})async{
    setLoading(val:true);
    UserCredential? userCredential;
    try {
      userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _uId = userCredential.user!.uid;
    } catch (e) {
      setLoading(val: false);
      onFail(e.toString());
      notifyListeners();
    }

    return userCredential;
  }

  // save user data to Firestore database
  Future<void> saveUserDataToFireStore({
    required UserModel currentUser,
    required File? fileImage,
    required Function() onSuccess,
    required Function(String) onFail,
  })async{
    String createdAt = DateTime.now().millisecondsSinceEpoch.toString();
    try{
      if(fileImage!=null){
        // upload image to firestore storage and  assign the given link in currentUser
        String imageUrl = await storeFileImageToStorage(
          ref: "${Constants.userImages}/$_uId",
          file: fileImage,
          onFail: (val){
            // image up failed
          }
        );
        currentUser.image = imageUrl;
      } 

      currentUser.createdAt = createdAt;
      _userModel = currentUser;

      // save data to firestore
      await firebaseFirestore
        .collection(Constants.users)
        .doc(firebaseAuth.currentUser!.uid)
        .set(currentUser.toMap());

      onSuccess();

    }catch(e){
        onFail(e.toString());
        setLoading(val: false);
    }
    setLoading(val: false);
  }

  // store file to firebase storage
  Future<String> storeFileImageToStorage({
    required String ref,
    required File file,
    required Function(String) onFail,
  })async{
    try {
      UploadTask uploadTask = firebaseStorage.ref().child(ref).putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      onFail(e.toString());
    }
    return "";
  }


}