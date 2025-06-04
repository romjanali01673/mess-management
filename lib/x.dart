

import 'package:cloud_firestore/cloud_firestore.dart';

main(){
DateTime local = DateTime.now(); // e.g., 2025-06-03 15:00 in Asia/Dhaka
Timestamp ts = Timestamp.fromDate(local);

// Later when retrieving
DateTime utc = ts.toDate();          // In UTC
DateTime localAgain = utc.toLocal();


}