import 'package:creta01/common/util/logger.dart';
import 'package:firebase_database/firebase_database.dart';

// class NRConfig {
//   static const String apiKey = "AIzaSyAy4Bvw7VBBklphDa9H1sbLZLLB9WE5Qk0";
//   static const String authDomain = "creta00-4c349.firebaseapp.com";
//   static const String projectId = "creta00-4c349";
//   static const String storageBucket = "creta00-4c349.appspot.com";
//   static const String messagingSenderId = "1022332856313";
//   static const String appId = "1:1022332856313:web:872be7560e0a039fb0bf28";
// }

// class FirebaseConfig {
//   static const String apiKey = "AIzaSyAy4Bvw7VBBklphDa9H1sbLZLLB9WE5Qk0";
//   static const String authDomain = "creta00-4c349.firebaseapp.com";
//   static const String projectId = "creta00-4c349";
//   static const String storageBucket = "creta00-4c349.appspot.com";
//   static const String messagingSenderId = "1022332856313";
//   static const String appId = "1:1022332856313:web:872be7560e0a039fb0bf28";
// }

// 리얼타임 DB config 정보
// // Import the functions you need from the SDKs you need
// import { initializeApp } from "firebase/app";
// // : Add SDKs for Firebase products that you want to use
// // https://firebase.google.com/docs/web/setup#available-libraries

// // Your web app's Firebase configuration
// const firebaseConfig = {
//   apiKey: "AIzaSyCq3Ap2QXjMfPptFyHLHNCyVTeQl9G2PoY",
//   authDomain: "creta02-1a520.firebaseapp.com",
//   databaseURL: "https://creta02-1a520-default-rtdb.firebaseio.com",
//   projectId: "creta02-1a520",
//   storageBucket: "creta02-1a520.appspot.com",
//   messagingSenderId: "352118964959",
//   appId: "1:352118964959:web:6b9d9378aad1b7c9261f6a"
// };

// // Initialize Firebase
// const app = initializeApp(firebaseConfig);

class NRConfig {
  static const String apiKey = "AIzaSyBe_K6-NX9-lzYNjQCPOFWbaOUubXqWVHg";
  static const String authDomain = "creta01-ef955.firebaseapp.com";
  static const String projectId = "creta01-ef955";
  static const String storageBucket = "creta01-ef955.appspot.com";
  static const String messagingSenderId = "878607742856";
  static const String appId = "1:878607742856:web:87e91c3185d1a79980ec3d";
}

// class FirebaseConfig {
//   static const String apiKey = "AIzaSyBe_K6-NX9-lzYNjQCPOFWbaOUubXqWVHg";
//   static const String authDomain = "creta01-ef955.firebaseapp.com";
//   static const String databaseURL = ''; // 일반 Database 에는 이상하게 이 값이 없다.
//   static const String projectId = "creta01-ef955";
//   static const String storageBucket = "creta01-ef955.appspot.com";
//   static const String messagingSenderId = "878607742856";
//   static const String appId = "1:878607742856:web:87e91c3185d1a79980ec3d";
// }

class FirebaseConfig {
  static const String apiKey = "AIzaSyCq3Ap2QXjMfPptFyHLHNCyVTeQl9G2PoY";
  static const String authDomain = "creta02-1a520.firebaseapp.com";
  static const String databaseURL = "https://creta02-1a520-default-rtdb.firebaseio.com";
  static const String projectId = "creta02-1a520";
  static const String storageBucket = "creta02-1a520.appspot.com";
  static const String messagingSenderId = "352118964959";
  static const String appId = "1:352118964959:web:6b9d9378aad1b7c9261f6a";
}

// class CretaDB {
//   final List resultList = [];
//   late CollectionReference collectionRef;

//   CretaDB(String collectionId) {
//     collectionRef = FirebaseFirestore.instance.collection(collectionId);
//   }

//   Future<List> getData(String? key) async {
//     try {
//       if (key != null) {
//         DocumentSnapshot<Object?> result = await collectionRef.doc(key).get();
//         if (result.data() != null) {
//           resultList.add(result);
//         }
//       } else {
//         //await collectionRef.get().then((snapshot) {
//         await collectionRef.orderBy('updateTime').get().then((snapshot) {
//           for (var result in snapshot.docs) {
//             resultList.add(result);
//           }
//         });
//       }
//       return resultList;
//     } catch (e) {
//       logHolder.log("GET DB ERROR : $e", level: 6);
//       return resultList;
//     }
//   }

//   Future<List> simpleQueryData(
//       {required String orderBy, required String name, required String value}) async {
//     try {
//       //await collectionRef.get().then((snapshot) {
//       await collectionRef
//           .orderBy(orderBy, descending: true)
//           .where(name, isEqualTo: value)
//           .get()
//           .then((snapshot) {
//         for (var result in snapshot.docs) {
//           resultList.add(result);
//         }
//       });
//       return resultList;
//     } catch (e) {
//       logHolder.log("GET DB ERROR : $e", level: 6);
//       return resultList;
//     }
//   }

//   Future<bool> setData(
//     String? key,
//     Object data,
//   ) async {
//     try {
//       if (key != null) {
//         await collectionRef.doc(key).set(data, SetOptions(merge: false));
//         logHolder.log('$key saved');
//       } else {
//         await collectionRef.add(data);
//         logHolder.log('$key created');
//       }
//       return true;
//     } catch (e) {
//       logHolder.log("SET DB ERROR : $e", level: 6);
//       return false;
//     }
//   }
// }

class CretaRTDB {
  final List resultList = [];
  final String collectionId;
  late DatabaseReference database;

  CretaRTDB(this.collectionId) {
    database = FirebaseDatabase.instance.ref();
  }

  Future<bool> setData(
    String? key,
    Object data,
  ) async {
    try {
      await database
          .child(collectionId)
          .child(key!)
          //.push()
          .set(data);
      logHolder.log('$collectionId created', level: 5);
      return true;
    } catch (e) {
      logHolder.log("$collectionId SET DB ERROR : $e", level: 6);
      return false;
    }
  }
}
