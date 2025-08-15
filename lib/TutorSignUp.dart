import 'dart:convert';
import 'dart:async';

import 'package:fluttertvtor/SignIn.dart';
import 'package:fluttertvtor/hexColor.dart';
import 'package:fluttertvtor/models/response/locationresponse.dart';
import 'package:fluttertvtor/rest/network_util.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:dotted_border/dotted_border.dart';
import 'package:fluttertvtor/Tutor_Manager_Profile.dart';
import 'package:fluttertvtor/Tutor_Profile.dart';
import 'package:fluttertvtor/models/requests/RegisterRequest.dart';
import 'package:fluttertvtor/models/response/RegisterResponse.dart' as rr;
import 'package:fluttertvtor/mvp/RegisterContract.dart';
import 'package:fluttertvtor/utils/CommonUtils.dart';
import 'package:fluttertvtor/utils/SharedPrefHelper.dart';
import 'package:fluttertvtor/utils/custom_views/CommonStrings.dart';
import 'package:easy_localization/easy_localization.dart';
class TutorSignUp extends StatefulWidget {
  final bool isTutor;

  TutorSignUp({Key? key, this.title,required this.isTutor}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TutorSignUp> with RegisterContract {
  final _formKey = GlobalKey<FormState>();
  late final bool isTutor;

//  String _locationSelection;
//  List data = List();


  TextEditingController userFirstNameController = new TextEditingController();
  TextEditingController userLastNameController = new TextEditingController();
  TextEditingController userEmailController = new TextEditingController();
  TextEditingController userPasswordController = new TextEditingController();
  TextEditingController userLocationController = new TextEditingController();
  TextEditingController userMobileController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmpasswordController = new TextEditingController();
  TextEditingController codeController = new TextEditingController();
  late RegisterPresenter presenter;
  late RegisterRequest request;



  @override
  void initState() {
    super.initState();
    presenter = RegisterPresenter(this);
    request = RegisterRequest();
    isTutor = widget.isTutor;
//  this.getLocation();
    this.getLocationData();
  }

//  void showToast() {
//    setState(() {
//      _isVisible = !_isVisible;
//    });
//  }
  List dataList = <DataItem>[]; //edited line
  Data value = Data();
  late LocationResponse resBody;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String? location;
  String? id;
  final String url = "https://tvtorbackend.onrender.com/api/v1/location";

//  List<Data> data = <Data>[]; //edited line

  Future<String> getLocationData() async {
    var res = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"});
    debugPrint("Response status: ${res}");
//    var resBody = json.decode(res.body);
    resBody = LocationResponse.fromJson(jsonDecode(res.body));
    debugPrint("resobody: ${resBody.toString()}");
    setState(() {
//      dataList = resBody.data.map((Data value) =>
//          DropdownMenuItem<String>(child: Text(value.location))
//      ).toList();
      dataList = resBody.data?.data  ?? [];
    });

    print(resBody);

//    return "Sucess";
    return tr('Form.Success');
  }

  List<String> locationList = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: true,
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  Container(
                      child: Image.asset(
                        "assets/bg_white.png",
                        fit: BoxFit.fill,
                      ),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage("assets/bg_white.png")))),
                  Stack(
                    children: <Widget>[
                      Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Image.asset(
                                    "assets/header_image.png",
                                    fit: BoxFit.fill,
                                    color: Colors.transparent,
                                  ),
                                ),
                                Visibility(
                                  visible: !isTutor,
                                  child: Container(
//                  color: Colors.pink,
                                    height: 100,
                                    child: ListTile(
                                      title: Padding(
                                        padding: EdgeInsets.fromLTRB(5, 10, 0, 10),
                                        child: Text(
                                          tr('Sign_Up'),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 25,
//                                        color: Colors.indigo[900],
                                            color: HexColor("#122345"),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(10.0),
                                      subtitle: Padding(
                                        padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                                        child: Text(
                                          tr('As_Tutor_Manager'),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
//                                          fontWeight: FontWeight.bold
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                ),
                                Visibility(
                                  visible: isTutor,
                                  child: Container(
//                          color: Colors.pink,
                                    height: 80,
                                    child: ListTile(
                                      title: Padding(
                                        padding: EdgeInsets.fromLTRB(5, 20, 0, 10),
                                        child: Text(
                                          tr('Sign_Up'),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: HexColor("#122345"),
//                                        fontWeight: FontWeight.bold,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(10.0),
                                      subtitle: Padding(
                                        padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                                        child: Text(
                                          tr('As_Tutor'),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
//                                          fontWeight: FontWeight.bold
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 0,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Form(
                                      key: _formKey,
                                      child: Column(children: <Widget>[
                                        Container(
                                          padding:
                                          EdgeInsets.fromLTRB(20, 20, 20, 0),
                                          child: TextFormField(
                                            controller: userFirstNameController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: tr('Form.First_Name'),
                                            ),
                                            validator: (val) {
//                                        if (val.length < 3)
//                                          return 'Name must be more than 2 character';
//                                        else
                                              if (val == null || val.isEmpty) {
                                                return tr("Form.Please_Enter_First_Name");
                                              } else {
                                                return null;
                                              }
                                            },
                                            onSaved: (val) {
                                              final value = val ??"";
                                              print("on saved name " +
                                                  value +
                                                  " >> " +
                                                  userFirstNameController.text);
                                            },
                                          ),
                                        ),
//                          Padding( padding: EdgeInsets.only(top: 10,),),

                                        Container(
                                          padding:
                                          EdgeInsets.fromLTRB(20, 10, 20, 0),
                                          child: TextFormField(
                                            controller: userLastNameController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: tr('Form.Last_Name'),
                                            ),
                                            validator: (val) {
//                                        if (val.length < 3)
//                                          return 'Name must be more than 2 character';
//                                        else
                                              if (val == null ||val.isEmpty) {
                                                return tr('Form.Please_enter_Last_name');
                                              } else {
                                                return null;
                                              }
                                            },
                                            onSaved: (val) {
                                              final value = val ??"";
                                              print("on saved name " +
                                                  value +
                                                  " >> " +
                                                  userFirstNameController.text);
                                            },
                                          ),
                                        ),
                                        Container(
                                          padding:
                                          EdgeInsets.fromLTRB(20, 10, 20, 0),
                                          child: TextFormField(
//                          obscureText: true,
                                            controller: userEmailController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: tr('Form.Email_id'),
                                            ),
                                            validator: (val) {
                                              if (!validateEmail(
                                                  userEmailController.text)) {
                                                return CommonStrings.validEmail;
                                              } else if (val == null || val.isEmpty) {
                                                return tr("Form.Please_Enter_Email_Id");
                                              }
                                              {
                                                return null;
                                              }
                                            },
                                            onSaved: (val) {
                                              final value = val ??"";
                                              print(
                                                  "on saved email " +
                                                      value +
                                                      " >> " +
                                                      userEmailController.text);
                                            },
                                          ),
                                        ),

                                        Visibility(
                                            visible: !isTutor,
                                            child: Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  20, 10, 20, 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    padding: EdgeInsets.fromLTRB(
                                                        10, 0, 20, 0),
                                                    width: 500,
                                                    child: DropdownButton<String>(
                                                      isExpanded: true,
                                                      underline: Container(
                                                        height: 1.0,
                                                      ),
//                                ),

                                                      hint: Text(tr("Choose_Location")),
                                                      items: dataList
                                                          .map((value) =>
                                                          DropdownMenuItem<
                                                              String>(
                                                            child: Text(
                                                              value.location,
                                                              style: TextStyle(
                                                                  fontSize: 15),
                                                            ),
                                                            value: value.sId,
                                                          ))
                                                          .toList(),
                                                      onChanged: (newVal) {
                                                        // setState(() {
                                                        locationList.clear();
                                                        location = newVal;
                                                        print(location.toString());
                                                        if (location != null) {
                                                          locationList.add(location!);
                                                        }
                                                        setState(() {});
//                                                        });
                                                      },
                                                      value: location,
                                                    ),
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            width: 1.0,
                                                            style:
                                                            BorderStyle.solid),
                                                        borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5.0)),
                                                      ),
                                                    ),
                                                  )

//                            Icon(Icons.keyboard_arrow_down,
//                                    color: Colors.black),
                                                ],
                                              ),
                                            )),

                                        Visibility(
                                            visible: isTutor,
                                            child: Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  20, 10, 20, 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: <Widget>[
                                                  TextFormField(
                                                    controller:
                                                    userMobileController,
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
//                                labelText: 'Choose Location',
                                                      labelText: tr('Form.Mobile_Number'),
                                                    ),
                                                    validator: (String? val) {
                                                      if (val == null || val.isEmpty) {
                                                        return tr('Form.Please_enter_mobile_number');  // Or any message you want for empty input
                                                      }
                                                      if (val.length < 10) {
                                                        return tr('Form.Wrong_Number');
                                                      }
                                                      if (!validateMobile(userMobileController.text)) {
                                                        return CommonStrings.validMobile;
                                                      }
                                                      return null;
                                                    },
                                                    onSaved: (val) {
                                                      final value = val ??"";
                                                      print(
                                                          "on saved mobileNumber " +
                                                              value +
                                                              " >> " +
                                                              userMobileController
                                                                  .text);
                                                    },
                                                  ),
//                            Icon(Icons.keyboard_arrow_down,
//                                    color: Colors.black),
                                                ],
                                              ),
                                            )),
                                        Container(
                                          padding:
                                          EdgeInsets.fromLTRB(20, 10, 20, 0),
                                          child: TextFormField(
                                              obscureText: true,
                                              controller: passwordController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: tr('Form.Password'),
                                              ),
                                              validator: (val) {
                                                if (val == null ||val.isEmpty) return tr('Form.Empty');
                                                return null;
                                              }),
                                        ),
                                        Container(
                                          padding:
                                          EdgeInsets.fromLTRB(20, 10, 20, 0),
                                          child: TextFormField(
                                              obscureText: true,
                                              controller: confirmpasswordController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: tr('Form.Confirm_Password'),
                                              ),
                                              validator: (val) {
                                                if (val == null || val.isEmpty) return tr('Form.Empty');
                                                if (val != passwordController.text)
                                                  return tr('Form.Not_Match');
                                                return null;
                                              }),
                                        ),

                                        Padding(
                                          padding: EdgeInsets.only(top: 10),
                                        ),
//                      Padding( padding: EdgeInsets.only(top: 20),),

                                        Visibility(
                                            visible: isTutor,
                                            child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    20, 0, 20, 0),
                                                child: Center(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(
                                                            tr('Form.Enter_your_given_code'),
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 15),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(
                                                              top: 10,
                                                            ),
                                                          ),
                                                          Container(
//                margin: EdgeInsets.only(left: 20,),
                                                            width: 320,

                                                            child: container1,
                                                          )
                                                        ])))),
                                        Container(
                                            padding:
                                            EdgeInsets.fromLTRB(20, 10, 20, 10),
                                            height: 70,
                                            width: 500,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                submit();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: HexColor("#10acff"),
                                                textStyle: TextStyle(color: Colors.white),// background color
                                              ),
                                              child: Text(
                                                'SIGN_UP',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ).tr(),
                                            )),
                                      ])),
                                )
                              ])),
                      IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop()),
                    ],
                  ),
                ],
              ),
            )));
  }

  Widget get container1 {
    return DottedBorder(
      options: RectDottedBorderOptions(
        color: HexColor("#10acff"),
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        dashPattern: [9, 5],
      ),
      child: Container(
//        height: 50,
        child: TextFormField(
//      obscureText: true,
          controller: codeController,
          decoration: InputDecoration(
            hintText: tr('Form.Code'),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          validator: (String? val) {
            if (val == null || val.isEmpty) {
              return tr('Form.Code_is_required');
            } else if (val.length < 3) {
              return tr('Form.Please_enter_valid_code');
            } else {
              return null;
            }
          },
        ),
        width: double.maxFinite,
        decoration: BoxDecoration(),
      ),
    );
  }

  @override
  void onRegisterError(String error) {
    CommonUtils.dismissProgressDialog(context);
    CommonUtils.showToast(msg: error);
    // TODO: implement onRegisterError
  }

  @override
  void onRegisterSuccess(rr.RegisterResponse response) async {
    CommonUtils.dismissProgressDialog(context);
    print("success");
    if (response.success == true) {
//      await SharedPrefHelper()
//          .save(SharedPrefHelper.token, response.data.apiToken);
      await SharedPrefHelper()
          .save(SharedPrefHelper.userData, jsonEncode(response.data));
      await SharedPrefHelper().save("first", true);

//      Navigator.pushReplacement(
//        context,
//        MaterialPageRoute(builder: (context) => Tutor_Profile()),
//      );
      print(isTutor);
      if (isTutor == true) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Tutor_Profile()));
      } else if (isTutor == false) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => TutorManagerProfile()));
      }
    } else {
      CommonUtils.showAlertDialog(
          context, CommonStrings.alert, response.message ??"");
    }
  }

  // TODO: implement onRegisterSuccess

  // void submit(){
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => SignIn(
  //             isTutor: isTutor,
  //           )));
  // }
  void submit() {
    final form = _formKey.currentState;
    form!.save();
    if (form!.validate()) {
      request = RegisterRequest(
          name: userFirstNameController.text.toString(),
          location: locationList.length == 0 ? null : locationList,
          surname: userLastNameController.text.toString(),
          email: userEmailController.text.toString(),
          password: passwordController.text.toString(),
          mobileNumber: userMobileController.text.isEmpty
              ? " "
              : userMobileController.text.toString(),
          userType: isTutor ? "tutor" : "tutormanager",
          code: codeController.text.isEmpty
              ? ""
              : codeController.text.toString());
      print(
          "name :${request.name},\n surname :${request.surname},\n password :${request.password},"
              "\nemail :${request.email},\n usertype: ${request.userType},"
              "\n location : ${request.location},\nmob no :${request.mobileNumber},\n code :${request.code}");

      CommonUtils.isNetworkAvailable().then((bool connected) async {
        debugPrint("Network connection");
        if (connected) {
          debugPrint("Network connected: $connected");
          CommonUtils.fullScreenProgress(context: context);
          // presenter.doRegister(jsonEncode(request));
          var res = await NetworkUtil().post(
              url: NetworkUtil.BASE_URL + "register", body: request);
          rr.RegisterResponse response = rr.RegisterResponse.fromJson(res);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SignIn(
                    isTutor: isTutor,
                  )));
          if (response.success == true) {
            CommonUtils.dismissProgressDialog(context);
        isTutor?  CommonUtils.showToast(msg: response.message ?? "") : CommonUtils.showToast(msg: tr("Tutor_Manager_Created_Successfully"));
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SignIn(
                      isTutor: isTutor,
                    )));
          } else {
            CommonUtils.dismissProgressDialog(context);

            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(response.message ??""),
                  );
                });
          }
        } else {
          debugPrint(" no internet");
//          CommonUtils.showToast(msg: CommonStrings.noInternet);
        }
      });
    }
  }

  void getLocation() {}

  bool validateMobile(String phone) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);
    if (phone.length == 0 || phone.length < 10) {
      return false;
    } else if (!regExp.hasMatch(phone)) {
      return false;
    }
    return true;
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
}