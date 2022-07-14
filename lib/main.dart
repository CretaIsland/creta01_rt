import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

import 'common/util/config.dart';
import 'creta_main.dart';
//import 'studio/studio_main_screen.dart';
import 'model/users.dart';
//import 'constants/styles.dart';
import 'db/creta_db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (FirebaseConfig.databaseURL.isEmpty) {
    // 일반 DB 사용의 경우.
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: FirebaseConfig.apiKey,
            appId: FirebaseConfig.appId,
            storageBucket: FirebaseConfig.storageBucket,
            messagingSenderId: FirebaseConfig.messagingSenderId,
            projectId: FirebaseConfig.projectId)); // for firebase
  } else {
    // 일반 reealTime DB 사용의 경우.
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            databaseURL: FirebaseConfig.databaseURL,
            apiKey: FirebaseConfig.apiKey,
            appId: FirebaseConfig.appId,
            storageBucket: FirebaseConfig.storageBucket,
            messagingSenderId: FirebaseConfig.messagingSenderId,
            projectId: FirebaseConfig.projectId)); // for firebas
  }
  //runApp(const ProviderScope(child: MyApp()));
  runApp(const MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    CretaConfig.loadAsset(context); //for server

    cretaMainHolder = CretaMainScreen(
        mainScreenKey: GlobalKey<CretaMainScreenState>(), user: UserModel(id: 'b49@sqisoft.com'));

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        // theme: ThemeData.light().copyWith(
        //   appBarTheme: AppBarTheme(
        //     color: MyColors.primaryColor,
        //     centerTitle: true,
        //     titleTextStyle: MyTextStyles.subtitle1,
        //     actionsIconTheme: const IconThemeData(color: MyColors.primaryColor),
        //   ),
        //   primaryColor: MyColors.primaryColor,
        //   scaffoldBackgroundColor: MyColors.bgColor,
        //   textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
        //       .apply(bodyColor: MyColors.primaryText),
        //   canvasColor: MyColors.secondaryColor,
        //   inputDecorationTheme: const InputDecorationTheme(
        //     labelStyle: TextStyle(color: MyColors.mainColor),
        //   ),
        //   outlinedButtonTheme: OutlinedButtonThemeData(
        //     style: MyButtonStyle.b1,
        //   ),
        //   tabBarTheme: TabBarTheme(
        //     labelStyle: MyTextStyles.body2, // color for text
        //   ),
        //   hoverColor: MyColors.hover,
        //   colorScheme: ThemeData()
        //       .colorScheme
        //       .copyWith(primary: MyColors.primaryColor)
        //       .copyWith(secondary: MyColors.secondaryColor),
        // ),
        //home: studioMainHolder!);
        home: cretaMainHolder!);
  }
}
