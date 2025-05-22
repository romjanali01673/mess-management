class Constants {
  // pages
  static const String LandingScreen = "/landingScreen";
  static const String HomeScreen = "/homeScreen";
  // static const String HomeScreen = "/homeScreen";
  // static const String HomeScreen = "/homeScreen";

  // bazer
  static const String bazerList = "Bazer List";
  static const String bazerEntry = "Bazer Entry";
  // meal 
  static const String mealEntry = "Meal Entry";
  static const String mealList = "Meal List";
  //authantication
  static const String logInScreen = "login sereen";
  static const String SignUpScreen = "signup sereen";
  

  // userModel
  static const String uId= "uId";
  static const String fname = "fname";
  static const String email = "email";
  static const String image = "image";
  static const String number = "number";
  static const String createdAt = "createdAt";
  static const String sessionKey = "sessionKey";

  //
  static const String userImages = "userImages";
  static const String users = "users";
  static const String userModel ="userModel";

  // 
  static const String isSignedIn = "isSignedIn";

  // mess model
  static const String mess = "mess";
  static const String messId="messId";
  static const String messName="messName";
  static const String messAddress="messAddress";
  static const String messAuthorityId="messAuthorityId";
  static const String messAuthorityId2nd="messAuthorityId2nd";
  static const String messAuthorityName="messAuthorityName";
  static const String messAuthorityName2nd="messAuthorityName2nd";
  static const String messAuthorityNumber="messAuthorityNumber";
  static const String messAuthorityEmail="messAuthorityEmail";

  //

}

enum BazerScreenMenu{
  bazerList,
  bazerEntry,
}

enum BazerEntry{
  description,
  price,
  member,
  slNo,
  date,
  time,
}
enum NoticeAndAnnouncement{
  Notices,
  addNotice,
}
enum Fand{
  fand,
  addDiposite,
  addCost,
}
enum DrawerItem{
  Home,
  Meal,
  Members,
  Fand,
  Notice_And_Announcements,
  Bazer,
  Mess,
  Settings,
  Diposite,
}

enum Meal{
  mealList,
  mealEntry,
  groupMealList,
  
}

enum Diposite{
  myDiposite,
  addDiposite,
  refund,
  historyOfDiposite
}
enum HistoryOfDiposite{
  memberWise,
  allHostory,
}
enum Member{
  members,
  AddMember,
}
enum Mess{
  mess,
  messCreate,
  messDelete,
  messUpdate,
  messInvitations,

}


void main() {
  print(BazerScreenMenu.bazerList.name);
}