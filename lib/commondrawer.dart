import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertvtor/Invite_Tutor.dart';
import 'package:fluttertvtor/Manager_Change_Password.dart';
import 'package:fluttertvtor/SignIn.dart';
import 'package:fluttertvtor/Tutor_Assign.dart';
import 'package:fluttertvtor/Tutor_Manager_Home.dart';
import 'package:fluttertvtor/Tutor_Manager_Profile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertvtor/hexColor.dart';
import 'package:fluttertvtor/models/imagemodal.dart';
import 'package:fluttertvtor/models/requests/notificationmodel.dart';
import 'package:fluttertvtor/models/response/logoutresponse.dart';
import 'package:fluttertvtor/models/response/userresponse.dart';
import 'package:fluttertvtor/rest/network_util.dart';
import 'package:fluttertvtor/utils/CommonUtils.dart';
import 'package:fluttertvtor/utils/SharedPrefHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonDrawer extends StatefulWidget {
  @override
  _CommonDrawerState createState() => _CommonDrawerState();
}

class _CommonDrawerState extends State<CommonDrawer>
    with SingleTickerProviderStateMixin {
  String titleShow = "Home";
  List<DrawerModal> drawerItems = <DrawerModal>[];

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  StreamController _streamController = StreamController<ImageModal>();
  late ImageModal imageModal;
  late CommonUtils commonUtils;

  late StreamController<int> _drawerSelectedTab;
  int tab = 3;
  late TabController tabController;
  List<String> title = [
    "Home",
    "Tutor_History",
    "Invite_Tutor",
    "Profile",
    "Change_Password",
    "Signout"
  ];

  // List<String> title = List();
  List<Widget> icons = [
    Icon(Icons.home, color: Colors.grey),
//    Icon(Icons.group, color: Colors.grey),
    Image.asset(
      "assets/tutor_history_gray.png",
      height: 25,
      width: 25,
    ),
    Image.asset(
      "assets/invite_menu_gray.png",
      height: 25,
      width: 25,
    ),
    Icon(Icons.person, color: Colors.grey),
    Icon(Icons.lock, color: Colors.grey),
    Image.asset(
      "assets/logout_gray.png",
      height: 25,
      width: 25,
    )
  ];

  late String image, name;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    // You need to dispose each StreamController when screen destroyed
    _drawerSelectedTab.close();
    _streamController.close();
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    _drawerSelectedTab = StreamController.broadcast();

    for (int i = 0; i < 6; i++)
      drawerItems.add(DrawerModal(
          id: i, title: tr(title[i]), isSelected: false, icon: icons[i]));
    getProfle();
    //getNoti();
  }

  bool change = true;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    title.add(context.toString());
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        bottomOpacity: 0.0,
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: new Image.asset('assets/menu_draw.png',
                color: Colors.indigo[900]),
            onPressed: () {
              setState(() {});
              _scaffoldKey.currentState!.openDrawer();
            }),
        title: Text(titleShow,
            style: TextStyle(
                color: HexColor("122345"),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: Container(
        child: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: tabController,
          children: <Widget>[
            TutorManagerHome(),
            Tutor_Assign(),
            InviteTutor(),
            TutorManagerProfile(),
            ManagerChangePassword(),
          ],
        ),
      ),
      drawer: leftDrawer(),
    );
  }

  leftDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          change
              ? DrawerHeader(
                  child: ListView(
                  children: <Widget>[],
                ))
              : DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFF122345),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(top: 3),
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
                                height: 100,
                                width: 100,
//                                          decoration: BoxDecoration(
//                                              color: Colors.blue,
//                                              borderRadius: BorderRadius.all(Radius.circular(20)))
                                decoration: new BoxDecoration(
                                  borderRadius: BorderRadius.circular(1.0),
                                  shape: BoxShape.rectangle,
                                  color: Colors.indigo,
                                  border:
                                      Border.all(width: 2, color: Colors.white),
                                ),
                                child: CommonUtils.imageModal?.imageUrl == null
                                    ? Image.asset("assets/add_photo.png")
                                    : Image.network(
                                        CommonUtils.imageModal!.imageUrl,
                                        fit: BoxFit.fill,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              CommonUtils.imageModal?.imageUrl == null
                                  ? ""
                                  : CommonUtils.imageModal!.name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )),
                      ]),
                ),
          StreamBuilder<int>(
              stream: _drawerSelectedTab.stream,
              initialData: tab,
              builder: (context, snapshot) {
                drawerItems.forEach((element) {
                  if (element.id == tab) {
                    titleShow = element.title;
                    print("title show $titleShow");
                    element.isSelected = true;
//                    setState(() {
//
//                    });
                  } else {
                    element.isSelected = false;
                  }
                });
                return ListView.builder(
                  shrinkWrap: true,
                  // ShrinkWrap must be true when you use ListView.builder in Column Widget
                  itemBuilder: (buildContext, index) {
                    return drawerItem(
                      modal: drawerItems[index],
//                      color: _currentSelected == index ? Colors.red : Colors.white,
                    );
                  },
                  itemCount: drawerItems.length,
                );
              })
        ],
      ),
    );
  }

  drawerItem({required DrawerModal modal, Color? color}) {
    return Column(
      children: <Widget>[
        Container(
          // color: modal.isSelected ? Colors.blue : Colors.white,

          child: ListTile(
            //  contentPadding: EdgeInsets.zero,
            onTap: () async {
              if (modal.id == 5) {
                CommonUtils.fullScreenProgress(context: context);
                String token = await SharedPrefHelper()
                    .getWithDefault(SharedPrefHelper.token, "null");
                String id =
                    await SharedPrefHelper().getWithDefault("id", "null");
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

                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  await pref.clear();

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignIn()));
                }
              } else {
                _drawerSelectedTab.sink.add(modal.id);
                tabController.index = modal.id;
                titleShow = modal.title;
                tab = modal.id; // Saved last selected tab
                closeDrawer();
              }
            },

            leading: modal.icon,
            title: Text(
              modal.title,
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
        ),
//        Container(
//          height: 1,
//          color: Colors.grey[400],
//        )
      ],
    );
  }

  closeDrawer() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      setState(() {});
      Navigator.pop(context);
    }
  }

  getProfle() async {
    String token =
        await SharedPrefHelper().getWithDefault(SharedPrefHelper.token, "null");
    String id = await SharedPrefHelper().getWithDefault("id", "null");
    var res = await NetworkUtil()
        .get(NetworkUtil.BASE_URL + "user/$id", token: token);
    UserResponse response = UserResponse.fromJson(res);
    if (response.success == true) {
      //  CommonUtils.dismissProgressDialog(context);
//      userResponse = response;
//      userEmailController.text = userResponse.data.email;
//      userFirstNameController.text = userResponse.data.name;
//      userLastNameController.text = userResponse.data.surname;
//      userLocationController.text = userResponse.data.locationData[0];

      await SharedPrefHelper().save("image", response.data?.imageUrl);
      await SharedPrefHelper().save("name", response.data?.name);
      imageModal = ImageModal(
          imageUrl: response.data?.imageUrl ?? '',
          name: response.data?.name ?? "");
      image = response.data?.imageUrl ?? '';
      name = response.data?.name ?? '';
      _streamController.sink.add(imageModal);
      CommonUtils.imageModal = imageModal;
      change = !change;
      setState(() {});
//      print("image is ${imageModal.imageUrl}");
//      print("name is ${imageModal.name}");
//      // ImageModal newWord = await SharedPrefHelper().getWithDefault("image", null);
////      print(await "image is ${newWord.imageUrl}");
////      print(await "name is ${newWord.name}");
//      print(response.data.imageUrl);
//      _controller.sink.add(userResponse);
//      _Image.sink.add(imageModal);
    }
  }

  getNoti() async {
    String token =
        await SharedPrefHelper().getWithDefault("firebasetoken", "null");
    String deviceName;
    String deviceVersion;
    late String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        deviceVersion = build.version.toString();
        identifier = build.id; //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor ?? ""; //UUID for iOS
      }
    } catch (e) {
      print('Failed to get platform version  $e');
    }
    String tokennn =
        await SharedPrefHelper().getWithDefault(SharedPrefHelper.token, "null");
    String managerId =
        await SharedPrefHelper().getWithDefault(SharedPrefHelper.managerId, "");
    // print("FirebaseMessaging token: $token");

    var res = await NetworkUtil().post(
        url: "fcmdevices",
        body: NotificationRequest(
          tmId: managerId,
          deviceId: identifier,
          deviceToken: token,
          deviceType: Platform.isAndroid ? "Android" : "Ios",
        ),
        token: tokennn);
    if (res != null) {
      print("res is $res");
    }
  }
}

class DrawerModal {
  int id;
  String title;
  bool isSelected;
  Widget icon;

  DrawerModal(
      {required this.id,
      required this.title,
      required this.isSelected,
      required this.icon});
}
