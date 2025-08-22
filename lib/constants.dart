class Constants {
  // pages
  static const String LandingScreen = "/landingScreen";
  static const String HomeScreen = "/homeScreen";
  static const String noticeScreen = "/noticeScreen";
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
  static const String phone = "phone";
  static const String createdAt = "createdAt";
  static const String sessionKey = "sessionKey";
  static const String currentMessId = "currentMessId";
  static const String fullAddress = "fullAddress";

  static const String member = "Member";
  static const String menager = "Menager";
  static const String actMenager = "Act Menager";
  static const String memberType = Constants.member;

  //
  static const String userImages = "userImages";
  static const String users = "users";

  // 
  static const String isSignedIn = "isSignedIn";

  // mess model
  static const String disable = "disable";
  static const String enable = "enable";
  static const String mess = "mess";
  static const String messId="messId";
  static const String messName="messName";
  static const String messAddress="messAddress";
  static const String menagerId="menagerId";
  static const String menagerPhone="menagerPhone";
  static const String menagerName="menagerName";
  static const String menagerEmail="menagerEmail";
  static const String actMenagerId="actMenagerId";
  static const String actMenagerName="actMenagerName";
  static const String messMemberList="messMemberList";
  static const String disabledMemberList="disabledMemberList";
  static const String leavedMemberIds="leavedMemberIds";
  
  static const String inSide = "inSide";
  static const String rules = "rules";
  
  static const String messList = "messList";


  static const String preData = "preData";
  static const String preDataList = "preDataList";


  // fund
  static const String listOfFundTnx = "listOfFundTnx";
  static const String fund = "fund";
  static const String tnxId = "tnxId";
  static const String amount = "amount";
  static const String title = "title";
  static const String type = "type";
  static const String add = "add";
  static const String sub = "sub";
  static const String blance = "blance";

  static const String currentFundBlance = "currentFundBlance";

  //deposit
  static const String listOfDepositTnx = "listOfDepositTnx";
  static const String deposit = "deposit";
  static const String refund = "refund";
  static const String totalDeposit = "totalDeposit";
  


  //
  static const String invaitations = "invaitations";
  static const String invaitationId = "invaitationId";
  static const String status="status";
  static const String description="description";
  static const String invaitedTime="invaitedTime";
  static const String myInvaitationList="myInvaitationList";

  // bazer
  static const String bazer="bazer";
  static const String listOfBazerTnx="listOfBazerTnx";
  static const String price="price";
  static const String product="product";
  static const String byWho="byWho";
  static const String bazerTime="bazerTime";
  static const String bazerDate="bazerDate";  
  static const String totalBazerCost="totalBazerCost";


  // meal 
  static const String date = "date";
  static const String totalMeal = "totalMeal";
  static const String meal = "meal";
  static const String listOfMealTnx = "listOfMealTnx";
  static const String listOfMeal = "listOfMeal";
  static const String mealRate="mealRate";

  // notice
  static const String notice = "notice";
  static const String noticeId = "noticeId";
  static const String listOfNotice = "listOfNotice";
  static const String homePindedNotice = "homePindedNotice";

  
  static const String entryTime = "entryTime";
  static const String userData = "userData";

  //xyz
  static const String members = "members";
  static const String mealSessionList = "mealSessionList";
  static const String deviceId = "deviceId";
  static const String mealSessionId = "mealSessionId";
  static const String joindAt = "joindAt";
  static const String remaining = "remaining";
  static const String mealSessionModel = "mealSessionModel";
  static const String totalMealOfMess = "totalMealOfMess";
  static const String Temporary = "Temporary";
  static const String Fianl = "Final";
  static const String closedAt = "closedAt";
  static const String selectedMember = "Selected Member";

  // models
  static const String userModel ="userModel";
  static const String depositModel = "depositModel";
  static const String fundModel= "fundModel";
  static const String messModel = "messModel";
  static const String bazerModel = "bazerModel";
  static const String mealModel = "mealModel";



}

enum BazerScreenMenu{
  bazerList,
  bazerEntry,
  bazerUpdate,
}

enum NoticeAndAnnouncement{
  Notices,
  addNotice,
}

enum DrawerItem{
  Home,
  Meal,
  Members,
  Fund,
  Notice_And_Announcements,
  Bazer,
  Mess,
  PreData,
  Settings,
  Deposit,
}

enum Meal{
  mealList,
  mealEntry,
  groupMealList,
  memberMealList,
}

enum Deposit{
  myDeposit,
  addDeposit,
  refund,
  historyOfDeposit
}
enum HistoryOfDeposit{
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
  static const String pending = "pending"; 
  static const String expaired = "expaired"; 
}


void main() {
  print(BazerScreenMenu.bazerList.name);
}