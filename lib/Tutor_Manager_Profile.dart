import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertvtor/Invite_Tutor.dart';
import 'package:fluttertvtor/Manager_Change_Password.dart';
import 'package:fluttertvtor/SignIn.dart';
import 'package:fluttertvtor/Tutor_Assign.dart';
import 'package:fluttertvtor/Tutor_Manager_Home.dart';
import 'package:fluttertvtor/customdrawer.dart';
import 'package:fluttertvtor/models/imagemodal.dart';
import 'package:fluttertvtor/models/requests/userrequest.dart';
import 'package:fluttertvtor/models/response/locationresponse.dart';
import 'package:fluttertvtor/models/response/logoutresponse.dart';
import 'package:fluttertvtor/models/response/update_profile_response.dart';
import 'package:fluttertvtor/models/response/userresponse.dart';
import 'package:fluttertvtor/rest/network_util.dart';
import 'package:fluttertvtor/utils/CommonUtils.dart';
import 'package:fluttertvtor/utils/SharedPrefHelper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import 'utils/custom_views/CommonStrings.dart';
import 'package:easy_localization/easy_localization.dart';

class TutorManagerProfile extends StatefulWidget {
  TutorManagerProfile({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _TutorManagerProfileState createState() => _TutorManagerProfileState();
}

class _TutorManagerProfileState extends State<TutorManagerProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late XFile? image = null;
  XFile? _image;
  late UserResponse userResponse;
  TextEditingController userFirstNameController = new TextEditingController();
  TextEditingController userLastNameController = new TextEditingController();
  TextEditingController userEmailController = new TextEditingController();
  TextEditingController userPasswordController = new TextEditingController();
  TextEditingController userLocationController = new TextEditingController();
  StreamController _controller = StreamController.broadcast();
  StreamController<List<DataItem>> _bbolController =
      StreamController.broadcast();
  StreamController _Image = StreamController();
  final dropDownMenuItems = ['3hr', '6hr', '12hr', '24hr'];
  late String dropdownValue;
  bool edit = true;

  late List<DataItem> locationList;
  late DataItem selectedLocation;
  late String requestlocation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      dropdownValue = dropDownMenuItems[0];
    locationList = [];
    getProfle();
  }

  late ImageModal imageModal;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.close();
    _Image.close();
    _bbolController.close();
  }

  List<bool> change = <bool>[];
  List<String> words = <String>[];
  List<String> requestList = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: true,
        child: Scaffold(
            key: _scaffoldKey,
            drawer: CustomDrawer(),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                child: StreamBuilder(
                    stream: _controller.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Container(
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            child: Center(child: CircularProgressIndicator()));
                      return Container(
                          padding: EdgeInsets.only(top: 20),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(top: 20)),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.bottomRight,
                                          children: <Widget>[
                                            Container(
                                              height: 150,
                                              width: 150,
                                              decoration: new BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(1.0),
                                                shape: BoxShape.rectangle,
                                                //color: Colors.tealAccent,
                                                border: Border.all(
                                                    width: 2.0,
                                                    color: const Color(
                                                        0xFF00B8D4)),
                                              ),
                                              child: Center(
                                                child: userResponse
                                                            .data?.imageUrl ==
                                                        null
                                                    ? _image != null
                                                        ? Image.file(
                                                            File(_image!.path),
                                                            height: 150,
                                                            width: 150,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.asset(
                                                            "assets/add_photo.png",
                                                            height: 150,
                                                            width: 150,
                                                            fit: BoxFit
                                                                .fitHeight,
                                                          )
                                                    : Image.network(
                                                        imageModal.imageUrl,
                                                        height: 150,
                                                        width: 150,
                                                        fit: BoxFit.cover,
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
                                                          print("clicked");
                                                          image = await ImagePicker()
                                                              .pickImage(
                                                                  source:
                                                                      ImageSource
                                                                          .gallery,
                                                                  imageQuality:
                                                                      50);
                                                          if (image != null) {
                                                            setState(() {
                                                              _image = image;
                                                            });
                                                          }
                                                        },
                                                  child: CircleAvatar(
                                                      radius: 20,
                                                      backgroundColor: Colors
                                                          .cyanAccent[700],
                                                      child: IconButton(
                                                          icon: Icon(
                                                            Icons.edit,
                                                            color: Colors.white,
                                                          ),
                                                          onPressed: edit
                                                              ? null
                                                              : () async {
                                                                  image = await ImagePicker()
                                                                      .pickImage(
                                                                          source:
                                                                              ImageSource.gallery);
                                                                  if (image !=
                                                                      null) {
                                                                    setState(
                                                                        () {
                                                                      _image =
                                                                          image;
                                                                      userResponse
                                                                          .data
                                                                          ?.imageUrl = null;
                                                                    });
                                                                  }
                                                                })),
                                                ))
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: 30, left: 20),
                                              child: Text(
                                                tr("Availability_For_The_Next"),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Color(0xFF122345),
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          Container(
                                            padding: EdgeInsets.only(left: 10),
                                            margin: EdgeInsets.fromLTRB(
                                                20, 0, 20, 0),
                                            height: 50,
                                            width: 450,
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              value: dropDownMenuItems.contains(dropdownValue) ? dropdownValue : null,  // initialized with '3hr', which is valid
                                              underline: Container(height: 1.0),
                                              onChanged: edit ? null : (String? newValue) {
                                                if (newValue == null) return;
                                                setState(() {
                                                  dropdownValue = newValue;
                                                });
                                              },
                                              items: dropDownMenuItems
                                                  .map<DropdownMenuItem<String>>((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value, style: TextStyle(color: Colors.grey)),
                                                );
                                              }).toList(),
                                              hint: Text(
                                                dropdownValue.isNotEmpty ? dropdownValue : tr("Select_Availability_hours"),
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            ),
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 1.0,
                                                    style: BorderStyle.solid),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 20, 20, 0),
                                        child: TextFormField(
                                          readOnly: edit,
                                          obscureText: false,
                                          style: TextStyle(color: Colors.grey),
                                          controller: userFirstNameController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: tr('Form.Name'),
                                          ),
                                          validator: (val) {
//                                            if (val.length < 3)
//                                              return 'Name must be more than 2 character';
                                            if (val == null || val.isEmpty) {
                                              return CommonStrings.validName;
                                            } else {
                                              return null;
                                            }
                                          },
                                          onSaved: (val) {
                                            final value = val ?? '';
                                            print(
                                                "on saved name $value >> ${userFirstNameController.text}");
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 20, 20, 0),
                                        child: TextFormField(
                                          readOnly: edit,
                                          obscureText: false,
                                          style: TextStyle(color: Colors.grey),
                                          controller: userLastNameController,
//            controller: passwordController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: tr('Form.Surname'),
                                          ),
                                          validator: (val) {
//                                            if (val.length < 3)
//                                              return 'Name must be more than 2 character';
                                            if (val == null || val.isEmpty) {
                                              return CommonStrings.validName;
                                            } else {
                                              return null;
                                            }
                                          },
                                          onSaved: (val) {
                                            final value = val ?? '';
                                            print("on saved name " +
                                                value +
                                                " >> " +
                                                userFirstNameController.text);
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 20, 20, 0),
                                        child: TextFormField(
                                          readOnly: true,
                                          style: TextStyle(color: Colors.grey),
                                          obscureText: false,
                                          controller: userEmailController,
//            controller: passwordController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: tr('Form.Email'),
                                          ),
                                          validator: (val) {
                                            if (!validateEmail(
                                                userEmailController.text)) {
                                              return CommonStrings.validEmail;
                                            } else {
                                              return null;
                                            }
                                          },
                                          onSaved: (val) {
                                            final value = val ?? '';
                                            print("on saved email " +
                                                value +
                                                " >> " +
                                                userEmailController.text);
                                          },
                                        ),
                                      ),
//                                Padding( padding: EdgeInsets.only(top: 10),),

                                      Container(
                                          margin: EdgeInsets.fromLTRB(
                                              20, 20, 20, 0),
                                          padding: EdgeInsets.only(left: 5),
                                          child: InkWell(
                                            onTap: () {
                                              if (!edit) {
                                                showSheet(context);
                                              }
                                            },
                                            child: TextField(
                                              onTap: () {
                                                if (!edit) {
                                                  showSheet(context);
                                                }
                                              },
                                              readOnly: true,
                                              controller:
                                                  userLocationController,
                                              decoration: InputDecoration(
                                                  hintText:
                                                      tr('Form.Location')),
                                            ),
                                          ),
//                                          child: DropdownButton<DataItem>(
//                                            isExpanded: true,
//                                            underline: Container(
//                                              height: 1.0,
//                                            ),
////                                ),
//
//                                            hint: Text("Choose Location"),
//                                            items: locationList
//                                                .map((value) =>
//                                                    DropdownMenuItem<DataItem>(
//                                                      child: Text(
//                                                        value.location,
//                                                        style: TextStyle(
//                                                            fontSize: 15),
//                                                      ),
//                                                      value: value,
//                                                    ))
//                                                .toList(),
//                                            onChanged: (newVal) {
//                                              selectedLocation = newVal;
//                                              setState(() {});
//                                            },
//                                            value: selectedLocation,
//                                          ),
                                          decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  width: 1.0,
                                                  style: BorderStyle.solid),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0)),
                                            ),
                                          )),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10),
                                      ),

                                      Container(
                                          padding: EdgeInsets.fromLTRB(
                                              20, 10, 20, 0),
                                          height: 70,
                                          width: 500,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              textStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                              backgroundColor: Colors.lightBlue,
                                            ),
                                            child: Text(
                                              edit ? tr('Edit') : tr('Save'),
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            onPressed: edit
                                                ? () {
                                                    setState(() {
                                                      if (edit)
                                                        edit = false;
                                                      else
                                                        edit = true;
                                                    });
                                                  }
                                                : () async {
                                                    if (locationList
                                                            .where((element) =>
                                                                element
                                                                    .isSelected ==
                                                                true)
                                                            .length ==
                                                        0) {
                                                      CommonUtils.showToast(
                                                          msg: tr(
                                                              "Please_select_atleast_one_location"));
                                                      setState(() {
                                                        if (edit)
                                                          edit = false;
                                                        else
                                                          edit = true;
                                                      });
                                                    } else {
                                                      List<String>
                                                          selectedLocation =
                                                          <String>[];
                                                      locationList
                                                          .forEach((element) {
                                                        if (element
                                                                .isSelected ==
                                                            true) {
                                                          selectedLocation.add(
                                                              element.sId ??
                                                                  "");
                                                        }
                                                      });
                                                      CommonUtils
                                                          .fullScreenProgress(
                                                              context: context);
                                                      UserRequest request = UserRequest(
                                                          name: userFirstNameController
                                                              .text,
                                                          location:
                                                              selectedLocation
                                                                  .join(","),
                                                          email:
                                                              userEmailController
                                                                  .text,
                                                          availability:
                                                              dropdownValue,
                                                          surname:
                                                              userLastNameController
                                                                  .text,
                                                          mobileNumber:
                                                              userPasswordController
                                                                  .text);

                                                      print(
                                                          jsonEncode(request));

                                                      FormData formData =
                                                          new FormData.fromMap(
                                                              jsonDecode(
                                                                  jsonEncode(
                                                                      request)));

                                                      print(formData.fields);
                                                      if (image != null) {
                                                        formData.files
                                                            .add(MapEntry(
                                                          "image",
                                                          await MultipartFile.fromFile(
                                                              image?.path ?? "",
                                                              filename: basename(
                                                                  image?.path ??
                                                                      "")),
                                                        ));
                                                      }

                                                      //  CommonUtils.fullScreenProgress(context: context);
                                                      String token =
                                                          await SharedPrefHelper()
                                                              .getWithDefault(
                                                                  SharedPrefHelper
                                                                      .token,
                                                                  "null");
                                                      String id =
                                                          await SharedPrefHelper()
                                                              .getWithDefault(
                                                                  "id", "null");
                                                      var res = await NetworkUtil()
                                                          .putApi(
                                                              NetworkUtil
                                                                      .BASE_URL +
                                                                  "user/$id",
                                                              token: token,
                                                              isFormData: true,
                                                              body: formData);
                                                      UserResponse response =
                                                          UserResponse.fromJson(
                                                              res);
                                                      if (response.statusCode ==
                                                          200) {
                                                        print("success");

                                                        await SharedPrefHelper()
                                                            .save(
                                                                "name",
                                                                response.data
                                                                        ?.name ??
                                                                    "");
                                                        await SharedPrefHelper()
                                                            .save(
                                                                "image",
                                                                response.data
                                                                    ?.imageUrl);
                                                        imageModal = ImageModal(
                                                            imageUrl: response
                                                                    .data
                                                                    ?.imageUrl ??
                                                                "",
                                                            name: response.data
                                                                    ?.name ??
                                                                "");
                                                        CommonUtils.imageModal =
                                                            imageModal;
                                                        _Image.sink
                                                            .add(imageModal);
                                                        CommonUtils
                                                            .dismissProgressDialog(
                                                                context);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(tr(
                                                              "Profile_Update_Successfully")),
                                                          duration: Duration(
                                                              milliseconds:
                                                                  500),
                                                        ));

                                                        userResponse = response;
                                                        setState(() {
                                                          edit = true;
                                                        });
                                                        // return userResponse;
                                                      } else {
                                                        CommonUtils
                                                            .dismissProgressDialog(
                                                                context);
                                                      }
                                                    }
                                                  },
                                          )),
                                      SizedBox(
                                        height: 30.0,
                                      )
                                    ]),
                              ]));
                    }))));
  }

  late String showWords;

  getProfle() async {
    // BuildContext context;
    // CommonUtils.fullScreenProgress(context: context);
    String token =
        await SharedPrefHelper().getWithDefault(SharedPrefHelper.token, "null");
    String id = await SharedPrefHelper().getWithDefault("id", "null");
    var res = await NetworkUtil()
        .get(NetworkUtil.BASE_URL + "user/$id", token: token);
    UserResponse response = UserResponse.fromJson(res);
    if (response.success == true) {
      //  CommonUtils.dismissProgressDialog(context);
      userResponse = response;
      userEmailController.text = userResponse.data?.email ?? "";
      userFirstNameController.text = userResponse.data?.name ?? "";
      userLastNameController.text = userResponse.data?.surname ?? "";
//      userLocationController.text = userResponse.data.locationData.length > 0
//          ? userResponse.data.locationData[0]
//          : "";
      List<String> loc = <String>[];

      locationList.addAll(userResponse.data?.locationList ?? []);

      final selectedLocations = userResponse.data?.location ?? [];

      for (final element in locationList) {
        element.isSelected = selectedLocations.contains(element.sId);
      }
      for (var i in locationList) {
        loc.add(i.location ?? "");
      }

      // userLocationController.text = loc.join(",");

      await SharedPrefHelper().save("image", userResponse.data?.imageUrl);
      await SharedPrefHelper().save("name", userResponse.data?.name);
      imageModal = ImageModal(
          imageUrl: userResponse.data?.imageUrl ?? "",
          name: userResponse.data?.name ?? "");
      print("image is ${imageModal.imageUrl}");
      print("name is ${imageModal.name}");
      CommonUtils.imageModal = imageModal;
      _controller.sink.add(userResponse);
      _Image.sink.add(imageModal);
      dropdownValue = response.data?.availability ?? "";
      _bbolController.sink.add(locationList);

      // setState(() {});
    }
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

  showSheet(BuildContext context) {
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        builder: (context) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(tr("Select_Location")),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: IconButton(
                          icon: Icon(Icons.done),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                    )
                  ],
                ),
                Expanded(
                  child: StreamBuilder<List<DataItem>>(
                    stream: _bbolController.stream,
                    initialData: locationList ?? [],
                    builder: (context, snapshot) {
                      final dataList = snapshot.data ?? [];

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: dataList.length,
                        itemBuilder: (_, index) {
                          final item = dataList[index];

                          return ListTile(
                            onTap: () {
                              item.isSelected = !(item.isSelected ?? false);
                              _bbolController.sink.add(dataList);
                            },
                            title: Text(item.location ?? ''),
                            trailing: (item.isSelected ?? false)
                                ? const Icon(Icons.check)
                                : const Icon(Icons.check_box_outline_blank),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}
