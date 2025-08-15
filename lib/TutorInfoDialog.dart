import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertvtor/hexColor.dart';
import 'package:fluttertvtor/models/response/BaseResponse.dart';
import 'package:fluttertvtor/models/response/TutorsResponse.dart';
import 'package:fluttertvtor/rest/apiConfig.dart';
import 'package:fluttertvtor/utils/CommonUtils.dart';
import 'package:fluttertvtor/utils/SharedPrefHelper.dart';

import 'models/requests/AddCommentRequest.dart';
import 'mvp/AddCommentMvp.dart';

class TutorInfoDialog extends StatefulWidget {
  final TutorsItem data;
  final String comment;

  const TutorInfoDialog({Key? key, required this.data, required this.comment})
      : super(key: key);

  @override
  _TutorInfoDialogState createState() => _TutorInfoDialogState();
}

class _TutorInfoDialogState extends State<TutorInfoDialog>
    with AddCommentContract {
  late AddCommentPresenter presenter;

  @override
  initState() {
    super.initState();
    presenter = AddCommentPresenter(this);
    textController.text = widget.comment;
  }

  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          top: -30,
          right: -30,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: FloatingActionButton(
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                tooltip: "Close",
                mini: true,
                backgroundColor: Colors.red,
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 60,
              backgroundImage: (widget.data.imageUrl != null && widget.data.imageUrl!.isNotEmpty)
                  ? NetworkImage(widget.data.imageUrl!)
                  : const AssetImage("assets/profile_gray.png") as ImageProvider,
            ),
            Text(
              widget.data.name ?? "",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            Wrap(
              children: (widget.data.subjectData ?? []).map((e) {
                return Card(
                  color: HexColor((e.colorcode != null && e.colorcode!.trim().isNotEmpty)
                      ? e.colorcode!
                      : '#000000'),
                  margin: EdgeInsets.all(2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 12.0, left: 12.0, top: 1, bottom: 1),
                    child: Text(
                      e.subject ?? "",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                  ),
                );
              }).toList(),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                      height: 50,
                      padding: EdgeInsets.only(top: 10),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        controller: textController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintStyle: TextStyle(fontSize: 12),
                            hintText: 'Add Comments'),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 10),
                  child: ButtonTheme(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (textController.text.isEmpty) {
                          CommonUtils.showToast(msg: "Please add Some comment");
                        } else {
                          String managerId = await SharedPrefHelper()
                              .getWithDefault(
                                  SharedPrefHelper.managerId, "null");

                          AddCommentRequest request = AddCommentRequest();
                          request.comment = textController.text;
                          request.tutorId = widget.data.sId;
                          request.managerId = managerId;

                          CommonUtils.fullScreenProgress(context: context);
                          presenter.doAddComment(jsonEncode(request));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // background color
                        textStyle: TextStyle(color: Colors.white), // text color
                      ),
                      child: const Text(
                        "Add",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  void onAddCommentError(String error) {
    Navigator.of(context).pop();
    CommonUtils.showToast(msg: ApiConstants.serverErrorMsg);
  }

  @override
  void onAddCommentSuccess(BaseResponse response) {
    CommonUtils.dismissProgressDialog(context);
    CommonUtils.showToast(msg: response.message ?? "");
    if (response.statusCode == 200) {
      Navigator.of(context).pop(textController.text);
    } else {}
  }
}
