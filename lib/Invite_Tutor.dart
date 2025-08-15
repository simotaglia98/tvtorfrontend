import 'dart:async';
import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertvtor/Manager_Change_Password.dart';
import 'package:fluttertvtor/SignIn.dart';
import 'package:fluttertvtor/Tutor_Assign.dart';
import 'package:fluttertvtor/Tutor_Manager_Home.dart';
import 'package:fluttertvtor/Tutor_Manager_Profile.dart';
import 'package:fluttertvtor/customdrawer.dart';
import 'package:fluttertvtor/models/imagemodal.dart';
import 'package:fluttertvtor/models/requests/randomnumberrequest.dart';
import 'package:fluttertvtor/models/response/logoutresponse.dart';
import 'package:fluttertvtor/models/response/randomnumberresponse.dart';
import 'package:fluttertvtor/rest/network_util.dart';
import 'package:fluttertvtor/utils/CommonUtils.dart';
import 'package:fluttertvtor/utils/SharedPrefHelper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';

//class InviteTutor extends StatelessWidget {
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//
//      home: InviteTutorPage(),
//    );
//  }
//
//}
class InviteTutor extends StatefulWidget {
  InviteTutor({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<InviteTutor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StreamController<String> _controller = StreamController<String>.broadcast();
  late String value;
  late ImageModal imageModal;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNumber();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
            key: _scaffoldKey,
            drawer: CustomDrawer(),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                child: Center(
              child: Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
//      Container(
//          height: 50,
//          child: Row(
//
//            mainAxisAlignment: MainAxisAlignment.start,
//            crossAxisAlignment: CrossAxisAlignment.center,
//            children: <Widget>[
//
//              IconButton(
////                icon: new Image.asset('assets/menu_draw.png', color: Colors.indigo[900] ),
////                                        color: Colors.indigo,
////                icon:  Icon(Icons.menu,color: Colors.indigo[900]),
//                icon: new Image.asset('assets/menu_draw.png', color: Colors.indigo[900] ),
//                iconSize: 30,
//                onPressed: () => _scaffoldKey.currentState.openDrawer(),
//
//              ),
//              Padding( padding: EdgeInsets.only(left: 90,),
//                  child:  InkWell(
//                    onTap: (){
//
//                    },
//                    child: Text("Invite Tutor",
//                      style: TextStyle(color:Colors.indigo[900], fontSize: 18,fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
//                  )
//              )
//            ],
//          ),
//      ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                        ),
                        Container(
                          child: new Image.asset(
                            'assets/invite_tutor.png',
                          ),
                          height: 250,
//        width: 200,
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(90, 10, 90, 0),
                          height: 50,
                          // width: MediaQuery.of(context).size.width, // uncomment if needed
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              // text color
                              backgroundColor: Colors.lightBlue,
                              // button background color
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            onPressed: getNumber,
                            child: Text(tr('Create_New_Code')),
                          ),
                        ),
                        StreamBuilder<String>(
                            stream: _controller.stream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return Container();
                              return Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: Container(
                                    child: Text(
                                  snapshot.data ?? "",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                )),
                              );
                            }),

                        Padding(
                          padding: EdgeInsets.only(top: 30),
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            width: 250,
                            height: 50,

//        child: container1,
                            child: TextButton(
                              onPressed: (value == "") ? null : share,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets
                                    .zero, // removes default padding if you want tight fit
                              ),
                              child: Image.asset(
                                'assets/invite_btn.png',
                              ),
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: 30),
                        ),
                      ])),
            ))));
  }

  getNumber() async {
    value = "";
    _controller.sink.add("Please wait");
    String token =
        await SharedPrefHelper().getWithDefault(SharedPrefHelper.token, "null");
//    imageModal =
//    await SharedPrefHelper().getWithDefault("image", "null");
    String id = await SharedPrefHelper().getWithDefault("id", "null");
    print(token);
    var res = await NetworkUtil().post(
        url: NetworkUtil.BASE_URL + "randomnumber",
        body: jsonEncode(RandomNumberRequest(managerId: id)),
        token: token);
    RandomNumberResponse response = RandomNumberResponse.fromJson(res);
    if (response.success == true) {
      value = response.data?.code.toString() ?? "";
      _controller.add(value);
      setState(() {

      });
    }
  }

  //182668
  Future<void> share() async {
    debugPrint("share button is pressed!");
    await SharePlus.instance.share(
      ShareParams(
        text: "Code is $value",
        subject: tr('Example_share'),
      ),
    );
  }

//  Widget get container1 {
//
//    return DottedBorder(
//      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
//      dashPattern: [9, 5],
//      child: Row(
////        crossAxisAlignment: CrossAxisAlignment.center,
//mainAxisAlignment: MainAxisAlignment.center,
////        height: 50,
////        Icon(Icons.person,
////            color: Colors.black),
////        TextField(
////          obscureText: true,
//////            controller: passwordController,
////          decoration: InputDecoration(
////            labelText: 'Invite',
////          ),
////        ),
//          children: <Widget>[
//                    Icon(Icons.share,
//            color: Colors.black),
//                    Text(" Invite", style: TextStyle(color: Colors.black, fontSize: 20),
//
////            controller: passwordController,
//
//        ),
//          ]
////        width: double.maxFinite,
////        decoration: BoxDecoration(
////
////        ),
//
//      ),
//    );
//  }
}
