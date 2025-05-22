import 'package:meal_hisab/constants.dart';

class ItemProvider {

  BazerScreenMenu _bazerScreenMenu = BazerScreenMenu.bazerList;

  // set function------------------------------------------------------------------------
  
  void setBazerItem({required BazerScreenMenu menu}){
    _bazerScreenMenu = menu;
  }

  // get ------------------------------------------------------------------------------

  BazerScreenMenu get bazerItem => _bazerScreenMenu;


}
