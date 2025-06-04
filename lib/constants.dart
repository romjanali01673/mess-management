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
  static const String currentMessId = "currentMessId";
  static const String fullAddress = "fullAddress";

  static const String memberType = Constants.member;
  static const String member = "member";
  static const String menager = "menager";
  static const String actMenager = "Act Menager";

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
  static const String messMemberList="messMemberList";
  static const String disabledMemberList="disabledMemberList";


  // fand
  static const String listOfFandTransaction = "listOfFandTransaction";
  static const String fand = "fand";
  static const String transactionId = "transactionId";
  static const String amount = "amount";
  static const String title = "title";
  static const String type = "type";
  static const String add = "add";
  static const String sub = "sub";
  static const String blance = "blance";


  //
  static const String invaitations = "invaitations";
  static const String invaitationId = "invaitationId";
  static const String status="status";
  static const String description="description";
  static const String invaitedTime="invaitedTime";
  static const String myInvaitationList="myInvaitationList";

  // bazer
  static const String bazer="bazer";
  static const String cost="cost";
  static const String listOfBazerTransaction="listOfBazerTransaction";
  static const String price="price";
  static const String product="product";
  static const String byWho="byWho";
  static const String bazerTime="bazerTime";
  static const String bazerDate="bazerDate";


  




}

enum BazerScreenMenu{
  bazerList,
  bazerEntry,
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
  joinOrleave,

}

class JoiningStatus{
  static const String joined = "joined"; 
  static const String declain = "declain"; 
  static const String panding = "panding"; 
  static const String expaired = "expaired"; 
}


void main() {
  print(BazerScreenMenu.bazerList.name);
}