import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mess_management/helper/ui_helper.dart';
import 'package:mess_management/providers/authantication_provider.dart';
import 'package:mess_management/providers/mess_provider.dart';

// pick an image 
Future<File?> pickedImage({ required bool fromCamera, required BuildContext context, required Function(String) onFail })async{
  File ? fileImage;
  if(fromCamera){
    try{
      final takenPhoto = await ImagePicker().pickImage(source: ImageSource.camera);
      if(takenPhoto!=null){
        fileImage = File(takenPhoto.path);
      }
    }catch (e){
      onFail(e.toString());
    }
  }
  else{
    try{
      final choosenImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(choosenImage!=null){
        fileImage = File(choosenImage.path);
      }
    }catch(e){
      onFail(e.toString());
    }
  }
  if(fileImage==null){
    onFail("Image Selection Failed!\n Try Again.");
  }
  return fileImage;
}


class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}

Future<File?> cropImage(BuildContext context, String path)async{
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: path,
    compressFormat: ImageCompressFormat.jpg,
    maxHeight: 500,
    maxWidth: 500,
    compressQuality: 100,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: false,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPresetCustom(),
        ],
      ),
      IOSUiSettings(
        title: 'Cropper',
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPresetCustom(),
        ],
      ),

      WebUiSettings(
        context: context,
        presentStyle: WebPresentStyle.dialog,
        size: const CropperSize(
          width: 520,
          height: 520,
        ),
      ),
    ],
  );
  if(croppedFile!= null) return File(croppedFile.path);
  return null;
}

// TimeOfDay to String time
String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

void add_in_bazer_List(List<Map<String, dynamic>> list, Map<String,dynamic> map){
  list.add(map);
}

// email validator
String? emailValidator(String email){
  email = email.trim();
  if(email.isEmpty) return "Email Required";
  final pattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return pattern.hasMatch(email)?null : "Invalid Email";
}

// phone number validator
// ^(?:\+88|88)? → allows optional country code +88 or 88.
// 01[2-9] → valid operator codes (e.g., 013 to 019).
// \d{8}$ → exactly 8 digits after the operator code (total 11 digits).
String? numberVAladator(String phone){
  phone = phone.trim();
  if(phone.contains(" ")){
    return "Number Can't Contain \"Space\"";
  }
  if(phone.isEmpty) return "Number Required";
  final pattern = RegExp(r'^(?:\+88|88)?01[2-9]\d{8}$');
  return pattern.hasMatch(phone)?null:"Invalid Phone";
}


String? nameValidator(String value) {
  value = value.trim();
  if (value.trim().isEmpty) {
    return 'Name are required';
  }
  if(value.length<4){
    return "Name shouldcontain  at least 4 character!";
  }
  final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');

  if (!nameRegExp.hasMatch(value.trim())) {
    return 'Name must contain only letters and spaces';
  }

  return null; // valid
}

String? titleValidator(String value) {
  value = value.trim();
  if (value.trim().isEmpty) {
    return 'Title are required';
  }
  return null; // valid
}
String? descValidator(String value) {
  value = value.trim();
  if (value.trim().isEmpty) {
    return 'Description are required';
  }
  if(value.length<14){
    return "Description shouldcontain  at least 14 character!";
  }

  return null; // valid
}

String? passValidator(String value) {
  if (value.trim().isEmpty) {
    return 'Password are required';
  }
  if(value.contains(" ")){
    return "pass can't contain \"Space\"";
  }
  if(value.length<6){
    return "Password should contain  at least 6 character!";
  }

  return null; // valid
}

String? addressValidator(String value) {
  if (value.trim().isEmpty) {
    return 'Address are required';
  }
  if(value.length<10){
    return "Address should contain at least 10 character!";
  }

  return null; // valid
}

String? validateUid(String value){
  value = value.trim();
  final regex = RegExp(r'[^0-9]');
  if(value.length<5){
    return  "invalid uid";
  }
  return !regex.hasMatch(value)? null : "invalid uid";
}

String? validatePrice(String value){
  if(value.toString().trim()==""){
    return "Enter price";
  }
  double pr=0;
  try{
    pr = double.parse(value.toString().trim());
  }catch (e){
    return "Invalid Price";
  }
  if(pr<0){
    return "Argument Can't be Negetive";
  }
  return null;
}

bool amIAdmin({required MessProvider messProvider,required AuthenticationProvider authProvider}){
  if(messProvider.getMessModel!=null){
    if(messProvider.getMessModel!.menagerId == authProvider.getUserModel!.uId){
      return true;
    }
    else{
      return false;
    }
  }
  else{
    return false;
  }
} 

bool amIactmenager({required MessProvider messProvider,required AuthenticationProvider authProvider}){
  if(messProvider.getMessModel!=null){
    if(messProvider.getMessModel!.actMenagerId == authProvider.getUserModel!.uId){
      return true;
    }
    else{
      return false;
    }
  }
  else{
    return false;
  }
} 

String capitalizeEachWord(String text) {
  if (text.isEmpty) return "";

  return text
      .toLowerCase()
      .split(' ')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
      .join(" ");
}


int getDaysInMonth(int year, int month) {
  // If month is December, move to January of next year
  if (month == 12) {
    return DateTime(year + 1, 1, 0).day;
  }
  // Return the last day of the given month
  return DateTime(year, month + 1, 0).day;
}


