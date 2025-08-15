import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertvtor/Invite_Tutor.dart';
import 'package:fluttertvtor/Manager_Change_Password.dart';
import 'package:fluttertvtor/SignIn.dart';
import 'package:fluttertvtor/TutorInfoDialog.dart';
import 'package:fluttertvtor/Tutor_Assign.dart';
import 'package:fluttertvtor/Tutor_Manager_Profile.dart';
import 'package:fluttertvtor/customdrawer.dart';
import 'package:fluttertvtor/hexColor.dart';
import 'package:fluttertvtor/models/imagemodal.dart';
import 'package:fluttertvtor/models/response/BaseResponse.dart';
import 'package:fluttertvtor/models/response/TutorsResponse.dart';
import 'package:fluttertvtor/mvp/TutorsContract.dart';
import 'package:fluttertvtor/rest/RestApiClient.dart';
import 'package:fluttertvtor/utils/CommonUtils.dart';
import 'package:fluttertvtor/utils/custom_views/CommonStrings.dart';
import 'package:fluttertvtor/utils/pushnotification.dart';
import 'package:easy_localization/easy_localization.dart';

class TutorManagerHome extends StatefulWidget {
  TutorManagerHome({Key? key, this.title, this.name}) : super(key: key);

  final String? title;
  String? name;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TutorManagerHome> with TutorsContract {
  TextEditingController commentController = TextEditingController();

  File? image;
  late TutorsPresenter tPresenter;
  StreamController<List<TutorsItem>> _controller = StreamController.broadcast();

  final GlobalKey<RefreshIndicatorState> refreshIndicator = GlobalKey();
  late PushNotificationsManager pushNotificationsManager;

  List<TutorsItem> tutorList = <TutorsItem>[];

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    tPresenter = TutorsPresenter(this);
    pushNotificationsManager = PushNotificationsManager(context);
    pushNotificationsManager.init();
    getTutors();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        drawer: CustomDrawer(),
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          key: refreshIndicator,
          onRefresh: onRefresh,
          child: StreamBuilder<List<TutorsItem>>(
            stream: _controller.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tutors = snapshot.data ?? [];
              if (tutors.isEmpty) {
                return Center(
                  child: Text(
                    tr("No_Tutor_associated_yet"),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              }

              // Grid with exactly 3 per row
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 per row
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.49, // adjust height/width
                ),
                itemCount: tutors.length,
                itemBuilder: (context, index) {
                  return childList(tutors[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void onTutorsError(String error) {
    CommonUtils.showToast(msg: error);
  }

  @override
  void onTutorsSuccess(TutorsResponse mData) {
    if (mData.status == true) {
      tutorList = mData.data?.data ?? [];
      _controller.sink.add(tutorList);
    } else {
      if (mData.message == "Unauthenticated.") {
        print("Session has expired! Please login again.");
      } else {
        CommonUtils.showAlertDialog(
          context,
          CommonStrings.alert,
          mData.message ?? "",
        );
      }
    }
  }

  Future<void> getTutors() async {
    if (await CommonUtils.isNetworkAvailable()) {
      tPresenter.getTutors();
    }
  }

  Future<bool> deleteTutor(String id) async {
    RestApiCalls api = RestApiCalls();
    BaseResponse res = await api.deleteUsers(id).catchError((e) {
      return false;
    });
    if (res.statusCode == 200) {
      CommonUtils.showToast(msg: res.message ?? "");
      return true;
    }
    return false;
  }

  Widget childList(TutorsItem value) {
      return GestureDetector(
        onLongPress: () {
          setState(() {
            tutorList.forEach((element) {
              element.isShowDelete = (element.sId == value.sId);
            });
            _controller.sink.add(tutorList);
          });
        },
        onTap: () async {
          String? comment = await showDialog<String>(
            context: context,
            builder: (buildContext) {
              return AlertDialog(
                contentPadding: const EdgeInsets.all(10),
                content: TutorInfoDialog(
                  data: value,
                  comment: value.comment ?? "",
                ),
              );
            },
          );
          if (comment != null && comment.isNotEmpty) {
            setState(() {
              tutorList.forEach((element) {
                if (element.sId == value.sId) {
                  element.comment = comment;
                }
              });
              _controller.sink.add(tutorList);
            });
          }
        },
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none, // Allow delete button to overflow
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: value.isShowDelete == true ? Colors.red : Colors.black),
                borderRadius: BorderRadius.circular(10),
                color: value.isShowDelete == true
                    ? Colors.black26
                    : Colors.transparent,
              ),
              child: Column(
                children: [
                  // Image
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        image: (value.imageUrl != null &&
                            value.imageUrl!.isNotEmpty)
                            ? NetworkImage(value.imageUrl!)
                            : const AssetImage("assets/add_photo.png")
                        as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(width: 1.0, color: const Color(0xFF00B8D4)),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Name
                  Text(
                    value.name ?? "",
                    style: const TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Subjects
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: (value.subjectData ?? []).map((e) {
                      final colorCode = (e.colorcode != null && e.colorcode!.trim().isNotEmpty)
                          ? e.colorcode!
                          : '#000000';
                      return Card(
                        color: HexColor(colorCode),
                        margin: const EdgeInsets.all(2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4),
                          child: Text(
                            e.subject ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 5),

                  // Comment box full width
                  Container(
                    height: 30,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Text(
                      (value.comment == null || value.comment!.isEmpty)
                          ? tr("Add_Comment")
                          : value.comment!,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Delete button at top center
            if (value.isShowDelete == true)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (buildContext) {
                      return AlertDialog(
                        title: Text(tr("Alert")),
                        content: Text(tr("Are_you_sure_want_to_delete")),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              CommonUtils.fullScreenProgress(context: context);
                              final bool success =
                              await deleteTutor(value.sId ?? "");
                              CommonUtils.dismissProgressDialog(context);
                              if (success) {
                                tutorList.remove(value);
                                _controller.sink.add(tutorList);
                              }
                            },
                            child: Text(
                              tr("Yes"),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              tutorList.forEach((element) {
                                if (element.sId == value.sId) {
                                  element.isShowDelete = false;
                                }
                              });
                              _controller.sink.add(tutorList);
                            },
                            child: Text(
                              tr("No"),
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 14,
                  child: Icon(Icons.delete, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      );

  }

  Future<void> onRefresh() async {
    await tPresenter.getTutors();
  }
}
