import 'package:flutter/material.dart';
import 'package:fluttertvtor/Invite_Tutor.dart';
import 'package:fluttertvtor/Manager_Change_Password.dart';
import 'package:fluttertvtor/SignIn.dart';
import 'package:fluttertvtor/Tutor_Manager_Profile.dart';
import 'package:fluttertvtor/models/response/logoutresponse.dart';
import 'package:fluttertvtor/rest/network_util.dart';
import 'package:fluttertvtor/utils/CommonUtils.dart';
import 'package:fluttertvtor/utils/SharedPrefHelper.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,

        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF122345),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 5),
//               padding: EdgeInsets.only(bottom: 20.0, left: 50),
//                              width: 100.0,
//                              height: 100.0,
//
////                                          Padding(
//                              padding: EdgeInsets.only(left: 40),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomRight,
                      children: <Widget>[
                        Container(
                          height: 100  ,
                          width: 100,
//                                          decoration: BoxDecoration(
//                                              color: Colors.blue,
//                                              borderRadius: BorderRadius.all(Radius.circular(20)))
                          decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(1.0),
                            shape: BoxShape.rectangle,
                            color: Colors.indigo,
                            border: Border.all(width: 2, color: Colors.white),
                          ),
                        ),
                        Positioned(
                            bottom: -20,
                            right: -20,
                            child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.cyanAccent[700],
                                child: IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {})))
                      ],
                    ),
                  ),
//                     ),
                  Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "John",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      )),
                ]
//                     Padding(
//                         padding: EdgeInsets.only(top:70.0, right: 10.0),
//                         child: new Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//
//
//                             new Icon(
//                               Icons.camera_alt,
//                               color: Colors.black,
//
//                             )
//                           ],
//                         )),
                ),
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 20.0, right: 100),
            leading: Icon(Icons.home, color: Colors.grey),
            title: Text("Home",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey,
                )),
            onTap: () {
              //  _controller.sink.add(0);
//                      Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                            builder: (context) => TutorManagerHome()),
//                      );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 20.0, right: 100),
            leading: Icon(Icons.group, color: Colors.grey),
            title: Text("Tutor History",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey,
                )),
            onTap: () {
              //  _controller.sink.add(1);
//                Navigator.pop(context);
//                Navigator.push(
//                    context,
//                    MaterialPageRoute(
//                        builder: (context) => Tutor_Assign()));
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 20.0, right: 100),
            leading: Image.asset(
              "assets/invite_menu_gray.png",
              height: 24,
              width: 24,
            ),
            title: Text("Invite Tutor",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey,
                )),
            onTap: () {
              //   _controller.sink.add(2);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InviteTutor()),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 20.0, right: 100),
            leading: Icon(Icons.person, color: Colors.grey),
            title: Text("Profile",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey,
                )),
            onTap: () {
              //  _controller.sink.add(3);
//                Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TutorManagerProfile()),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 20.0, right: 50),
            leading: Icon(Icons.lock, color: Colors.grey),
            title: Text("Change Password",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey,
                )),
            onTap: () {
              //  _controller.sink.add(4);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ManagerChangePassword()),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 20.0, right: 100),
            leading: Image.asset(
              "assets/logout_gray.png",
              height: 24,
              width: 24,
            ),
            title: Text("Signout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey,
                )),
            onTap: () async {
              CommonUtils.fullScreenProgress(context: context);
              String token = await SharedPrefHelper()
                  .getWithDefault(SharedPrefHelper.token, "null");
              String id = await SharedPrefHelper().getWithDefault("id", "null");
              var res = await NetworkUtil()
                  .deleteApi("user/logout/$id", token: token);
              LogoutResponse response = LogoutResponse.fromJson(res);
              if (response.success == true) {
                CommonUtils.dismissProgressDialog(context);
                bool first = await SharedPrefHelper().save("first", false);
                await SharedPrefHelper().save("tutor", false);

                bool token =
                    await SharedPrefHelper().save(SharedPrefHelper.token, "");
                bool id = await SharedPrefHelper().save("id", "");
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              }
            },
          ),
        ],
      ),
    );
  }
}
