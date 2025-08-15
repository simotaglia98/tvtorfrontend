import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertvtor/hexColor.dart';
import 'package:fluttertvtor/models/requests/userrequest.dart';
import 'package:fluttertvtor/models/response/SubjectResponse.dart';
import 'package:fluttertvtor/rest/network_util.dart';
import 'package:fluttertvtor/utils/CommonUtils.dart';
import 'package:fluttertvtor/utils/SharedPrefHelper.dart';
import 'package:fluttertvtor/Tutor_Profile.dart';

import 'models/response/userresponse.dart';
import 'rest/RestApiClient.dart';

class CreateTutorProfile extends StatefulWidget {
  const CreateTutorProfile({
    Key? key,
    required this.title,
    required this.selectedList,
  }) : super(key: key);

  final UserRequest title;
  final List<String> selectedList;

  @override
  _CreateTutorProfileState createState() => _CreateTutorProfileState();
}

class _CreateTutorProfileState extends State<CreateTutorProfile> {
  late final UserRequest request;
  late final List<String>? selectedList;
  SubjectResponse? subBody;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<SubjectItem> dataList = <SubjectItem>[];
  final StreamController<List<SubjectItem>> streamController =
  StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    request = widget.title;
    selectedList = widget.selectedList;
    getSubjectData();
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  Future<void> getSubjectData() async {
    RestApiCalls rest = RestApiCalls();
    subBody = await rest.getSubjectList();

    dataList = subBody?.data?.data ?? [];

    if (selectedList != null) {
      for (var element in dataList) {
        if (selectedList!.contains(element.sId)) {
          element.isSelected = true;
        }
      }
    }

    streamController.sink.add(dataList);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop("Update");
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop("Update");
            },
          ),
          title: Text(
            tr("Choose_Your_Subjects"),
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  child: StreamBuilder<List<SubjectItem>>(
                    stream: streamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return gridView(snapshot.data ?? []);
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: saveSubjects,
                    child: Text(tr('SAVE')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget gridView(List<SubjectItem> data) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 3.0,
      crossAxisSpacing: 20.0,
      mainAxisSpacing: 30,
      controller: ScrollController(keepScrollOffset: false),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: data.map((value) {
        return GestureDetector(
          onTap: () {
            setState(() {
              final selectedCount = dataList.where((e) => e.isSelected == true).length;

              // Allow toggle ON only if less than 3 are already selected
              if (value.isSelected == true) {
                // If already selected, allow deselect
                value.isSelected = false;
              } else if (selectedCount < 3) {
                // If not selected and limit not reached, allow select
                value.isSelected = true;
              }
            });

            streamController.sink.add(dataList);
          },
          child: Card(
            elevation: 4,
            color: value.isSelected == true
                ? HexColor(CustomColor.lightThemeBlueColor)
                : Colors.white,
            child: DottedBorder(
              options: RectDottedBorderOptions(
                color: Colors.blue,
                strokeWidth: 1,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: Text(
                      value.subject ?? '',
                      style: TextStyle(
                        color: value.isSelected == true
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Image.asset("assets/tick_ion.png"),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> saveSubjects() async {
    List<SubjectItem> selectedItems =
    dataList.where((element) => element.isSelected == true).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr("Please_select_at_least_one_subject")),
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    List<String> list = selectedItems.map((e) => e.sId ?? '').toList();
    request.subjects = list.join(",");

    print(jsonEncode(request));

    CommonUtils.fullScreenProgress(context: context);

    FormData formData =
    FormData.fromMap(jsonDecode(jsonEncode(request)));

    String token = await SharedPrefHelper()
        .getWithDefault(SharedPrefHelper.token, "null");
    String id =
    await SharedPrefHelper().getWithDefault("id", "null");

    var res = await NetworkUtil().putApi(
      NetworkUtil.BASE_URL + "user/$id",
      token: token,
      isFormData: true,
      body: formData,
    );

    UserResponse response = UserResponse.fromJson(res);
    CommonUtils.dismissProgressDialog(context);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr("Profile_Update_Successfully")),
          duration: const Duration(milliseconds: 500),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Tutor_Profile(),
        ),
      );
    } else {
      CommonUtils.showToast(msg: response.message ?? '');
    }
  }
}
