import 'package:creta01/common/util/logger.dart';
import 'package:flutter/cupertino.dart';

import '../../acc/acc_manager.dart';

class MyDummy2 extends StatelessWidget {
  const MyDummy2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: accManagerHolder!.isACCInit(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData == false) {
            //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
            return Container();
          }
          if (snapshot.hasError) {
            //error가 발생하게 될 경우 반환하게 되는 부분
            return Container();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            logHolder.log('build Dummy.....2', level: 5);

            return Container();
          }

          logHolder.log('build Dummy.....1', level: 5);

          return Container();
        });
  }
}

class MyDummy extends StatefulWidget {
  const MyDummy({Key? key}) : super(key: key);

  @override
  State<MyDummy> createState() => _MyDummyState();
}

class _MyDummyState extends State<MyDummy> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      logHolder.log('after build _MyDummyState........', level: 5);
      await accManagerHolder!.isACCInit();
      // ignore: use_build_context_synchronously
      accManagerHolder!.registerOverlayAll(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //     future: accManagerHolder!.isACCInit(),
    //     builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
    //       if (snapshot.hasData == false) {
    //         //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
    //         return Container();
    //       }
    //       if (snapshot.hasError) {
    //         //error가 발생하게 될 경우 반환하게 되는 부분
    //         return Container();
    //       }
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         logHolder.log('build Dummy.....2', level: 5);
    //         return Container();
    //       }

    //       logHolder.log('build Dummy.....1', level: 5);
    //       return Container();
    //     });
    return Container();
  }
}
