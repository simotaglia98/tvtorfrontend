import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertvtor/ChangeTutorPassword.dart';
import 'package:fluttertvtor/CreateProfile.dart';
import 'package:fluttertvtor/SignIn.dart';
import 'package:fluttertvtor/models/requests/userrequest.dart';
import 'package:fluttertvtor/models/response/logoutresponse.dart';
import 'package:fluttertvtor/models/response/userresponse.dart';
import 'package:fluttertvtor/rest/network_util.dart';
import 'package:fluttertvtor/utils/CommonUtils.dart';
import 'package:fluttertvtor/utils/SharedPrefHelper.dart';
import 'package:fluttertvtor/utils/custom_views/CommonStrings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:easy_localization/easy_localization.dart';
import 'hexColor.dart';
//import 'package:fluttertvtor/tabs/Tutor_Assign.dart';

//class Tutor_Profile extends StatelessWidget {
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//
//      home: Tutor_Profile_Page(),
//    );
//  }
//
//}
class Tutor_Profile extends StatefulWidget {
  Tutor_Profile({Key? key, this.title, this.isTutor}) : super(key: key);
  final bool? isTutor;
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Tutor_Profile> {
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController mobileController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  XFile? image;
  XFile? _image;
  late UserResponse userResponse;
  StreamController _controller = StreamController.broadcast();
  StreamController<List<String>> _subjectListController =
      StreamController.broadcast();
  bool edit = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Color color = Colors.grey;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    getProfle();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _subjectListController?.close();
    _controller?.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: onRefresh,
          child: StreamBuilder(
              stream: _controller.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                      height: MediaQuery.of(context).size.height,
                      width: double.infinity,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ));
                } else {
                  UserResponse userResponse = snapshot.data as UserResponse;
                  return Container(
                      child: SingleChildScrollView(
                          child: Center(
                              child: new Column(children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              left: 150,
                            ),
                            child: Text(
                              tr("Profile"),
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 50,
                            ),
                            child: GestureDetector(
                              child: new Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: (IconButton(
                                      onPressed: () {},
                                      icon: new Image.asset(
                                        'assets/signout.png',
                                      ),
                                      iconSize: 10,
                                    )),
                                  ),
                                  Text(
                                    tr("Signout"),
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ).tr(),
                                ],
                              ),
                              onTap: () async {
                                CommonUtils.fullScreenProgress(
                                    context: context);
                                String token = await SharedPrefHelper()
                                    .getWithDefault(
                                        SharedPrefHelper.token, "null");
                                String id = await SharedPrefHelper()
                                    .getWithDefault("id", "null");
                                var res = await NetworkUtil()
                                    .deleteApi("user/logout/$id", token: token);
                                LogoutResponse response =
                                    LogoutResponse.fromJson(res);
                                if (response.success == true) {
                                  CommonUtils.dismissProgressDialog(context);
                                  await SharedPrefHelper().clearAllSharedPref();
                                  bool first = await SharedPrefHelper()
                                      .save("first", false);
                                  await SharedPrefHelper().save("tutor", false);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignIn()));
                                }
                              },
                            ),
                          )
                        ]),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.bottomRight,
                            children: <Widget>[
                              Container(
                                height: 120,
                                width: 120,
                                decoration: new BoxDecoration(
                                  borderRadius: BorderRadius.circular(1.0),
                                  shape: BoxShape.rectangle,
                                  color: Colors.tealAccent,
                                  border: Border.all(
                                      width: 2.0,
                                      color: const Color(0xFF00B8D4)),
                                ),
                                child: Center(
                                  child: userResponse.data?.imageUrl == null
                                      ? _image != null
                                          ? Image.file(
                                              File(_image?.path ?? ""),
                                              height: 150,
                                              width: 150,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              "assets/add_photo.png",
                                              height: 150,
                                              width: 150,
                                              fit: BoxFit.fitHeight,
                                            )
                                      : Image.network(
                                          userResponse.data?.imageUrl ?? "",
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.fill,
                                        ),
                                ),
                              ),
                              Positioned(
                                  bottom: -20,
                                  right: -20,
                                  child: InkWell(
                                    onTap: edit
                                        ? null
                                        : () async {
                                            print("click");
                                            image = await ImagePicker()
                                                .pickImage(
                                                    source: ImageSource.gallery,
                                                    imageQuality: 50);
                                            if (image != null) {
                                              setState(() {
                                                _image = image;
                                                userResponse.data?.imageUrl =
                                                    null;
                                              });
                                            }
                                          },
                                    child: IconButton(
                                        icon: Image.asset(
                                            "assets/edit_pencil.png"),
                                        onPressed: edit
                                            ? null
                                            : () async {
                                                print("click");
                                                image = await ImagePicker()
                                                    .pickImage(
                                                        source:
                                                            ImageSource.gallery,
                                                        imageQuality: 50);
                                                if (image != null) {
                                                  setState(() {
                                                    _image = image;
                                                    userResponse
                                                        .data?.imageUrl = null;
                                                  });
                                                }
                                              }),
                                  ))
                            ],
                          ),
//                     ),
                          Padding(
                              padding: EdgeInsets.only(
                                top: 20,
                              ),
                              child: TextButton(
                                  child: Text(
                                    tr("Change_Password1"),
                                    style: TextStyle(
                                        color: Color(0xFF00B8D4),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    String res = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ChangePasswordPage()));

                                    if (res == "Update") {
                                      _refreshIndicatorKey.currentState!.show();
                                    }
                                  })),
                        ]),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: TextFormField(
                              readOnly: edit,
                              obscureText: false,
                              controller: firstNameController,
                              style: TextStyle(color: color),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: tr('Form.Firstname'),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return CommonStrings.validName;
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (val) {
                                final String value = val ?? '';
                                print("on saved name " +
                                    value +
                                    " >> " +
                                    firstNameController.text);
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: TextFormField(
                              readOnly: edit,
                              obscureText: false,
                              controller: lastNameController,
                              style: TextStyle(color: color),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: tr('Form.Lastname'),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return CommonStrings.validLastName;
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (val) {
                                final String value = val ?? '';

                                print("on saved name " +
                                    value +
                                    " >> " +
                                    lastNameController.text);
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: TextFormField(
                              readOnly: true,
                              obscureText: false,
                              controller: emailController,
                              style: TextStyle(color: color),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: tr('Form.Email'),
                              ),
                              validator: (val) {
//                                          Navigator.pushAndRemoveUntil(context, newRoute, predicate);

                                if (!validateEmail(emailController.text)) {
                                  return CommonStrings.validEmail;
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (val) {
                                final String value = val ?? '';
                                print("on saved email " +
                                    value +
                                    " >> " +
                                    emailController.text);
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: TextFormField(
                              readOnly: edit,
                              obscureText: false,
                              controller: mobileController,
                              style: TextStyle(color: color),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: tr('Form.Mob_No'),
                              ),
                              validator: (String? val) {
                                if (val == null || val.isEmpty) {
                                  return tr("Form.Please_enter_mobile_number");
                                } else if (val.length != 10) {
                                  return tr('Form.Wrong_Number');
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (val) {
                                final String value = val ?? '';
                                print("on saved name " +
                                    value +
                                    " >> " +
                                    mobileController.text);
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: TextFormField(
                                maxLines: 3,
                                readOnly: edit,
                                controller: descriptionController,
                                obscureText: false,
                                style: TextStyle(color: color),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: tr('Form.Description'),
                                    alignLabelWithHint: true),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return tr("Form.Required");
                                  } else {
                                    return null;
                                  }
                                }),
                          ),
                          Container(
                              child: new Row(children: <Widget>[
                            Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                                child: Text(tr("Subjects"),
                                    style: TextStyle(
                                        color: Color(0xFF122345),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)))
                          ])),
                          subjectGridView(userResponse.data?.subjectData  ?? []),
                          Padding(
                              padding: EdgeInsets.only(top: 10, left: 150),
                              child: GestureDetector(
                                  child: Text(tr("Choose_More_Subjects"),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Color(0xFF122345),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                  onTap: () async {
                                    UserRequest request = UserRequest(
                                        name: firstNameController.text,
                                        email: emailController.text,
                                        surname: lastNameController.text,
                                        description: descriptionController.text,
                                        mobileNumber: mobileController.text);

                                    UserResponse user = snapshot.data as UserResponse;

                                    String res = await Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (buildContext) {
                                      return CreateTutorProfile(
                                          title: request,
                                          selectedList:
                                              user.data?.subjects ?? []);
                                    }));

                                    if (res == "Update") {
                                      _refreshIndicatorKey.currentState!.show();
                                    }
                                  })),
                          Padding(
                            padding: EdgeInsets.only(top: 30),
                          ),
                          Container(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              height: 60,
                              width: 500,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                    )),
                                child: Text(
                                  edit ? tr('Edit') : tr('Save'),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 20),
                                ),
                                onPressed: edit
                                    ? () {
                                        print(edit);
                                        setState(() {
                                          edit = !edit;
                                          color = Colors.black;
                                        });
                                        print(edit);
                                      }
                                    : () async {
                                        CommonUtils.fullScreenProgress(
                                            context: context);
                                        UserRequest request = UserRequest(
                                            name: firstNameController.text,
                                            email: emailController.text,
                                            surname: lastNameController.text,
                                            description:
                                                descriptionController.text,
                                            mobileNumber:
                                                mobileController.text);
                                        FormData formData = new FormData
                                            .fromMap(
                                            jsonDecode(jsonEncode(request)));
                                        if (image != null) {
                                          formData.files.add(MapEntry(
                                            "image",
                                            await MultipartFile.fromFile(
                                                image?.path ?? "",
                                                filename: basename(
                                                    image?.path ?? "")),
                                          ));
                                        }
                                        //  CommonUtils.fullScreenProgress(context: context);
                                        String token = await SharedPrefHelper()
                                            .getWithDefault(
                                                SharedPrefHelper.token, "null");
                                        String id = await SharedPrefHelper()
                                            .getWithDefault("id", "null");
                                        var res = await NetworkUtil().putApi(
                                            NetworkUtil.BASE_URL + "user/$id",
                                            token: token,
                                            isFormData: true,
                                            body: formData);
                                        UserResponse response =
                                            UserResponse.fromJson(res);
                                        if (response.success == true) {
                                          ScaffoldMessenger.of(
                                                  _scaffoldKey.currentContext!)
                                              .showSnackBar(SnackBar(
                                            content: Text(tr(
                                                "Profile_Update_Successfully")),
                                            duration:
                                                Duration(milliseconds: 500),
                                          ));

                                          print("success");
                                          CommonUtils.dismissProgressDialog(
                                              context);
                                          userResponse = response;
                                          setState(() {
                                            edit = true;
                                            color = Colors.grey;
                                          });
                                          // return userResponse;
                                        } else {
                                          CommonUtils.dismissProgressDialog(
                                              context);
                                        }
                                      },
                              )),
                          SizedBox(
                            height: 30.0,
                          )
                        ])
                  ]))));
                }
              }),
        ));
  }

  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
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
      userResponse = response;
      emailController.text = userResponse.data?.email ?? "";
      firstNameController.text = userResponse.data?.name ?? "";
      lastNameController.text = userResponse.data?.surname ?? "";
      mobileController.text = userResponse.data?.mobileNumber.toString() ?? "";
      descriptionController.text = userResponse.data?.description ?? "";
      _controller.sink.add(userResponse);
      _subjectListController.sink.add(userResponse.data?.subjectData as List<String>? ?? []);

    }
    return response;
  }

  subjectGridView(List<String> subjectData) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: StreamBuilder<List<String>>(
          stream: _subjectListController.stream,
          initialData: subjectData,
          builder: (buildContext, snapShot) {
            return snapShot.hasData
                ? gridView(snapShot.data ?? [])
                : Container();
          }),
    );
  }

  gridView(List<String> data) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 3.0,
      crossAxisSpacing: 20.0,
      mainAxisSpacing: 10,
      controller: new ScrollController(keepScrollOffset: false),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: data.map((value) {
        return Card(
            elevation: 4,
            color: HexColor(CustomColor.lightThemeBlueColor),
            child: DottedBorder(
                options: RectDottedBorderOptions(
                  color: Colors.blue,
                  strokeWidth: 1,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                )));
      }).toList(),
    );
  }

  Future<void> onRefresh() async {
    await getProfle();
    return;
  }
}
