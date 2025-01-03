import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/view/chatScreens/FullVideoView.dart';
import 'package:record/record.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../main.dart';
import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../../utils/CommonTextField.dart';
import '../../utils/PermissionHandler.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import 'SqliteDataBase.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class ConversationScreen extends StatefulWidget {
  String receiverId;
  String roomId;
  String receiverImage;
  String receiverName;

  ConversationScreen({
    super.key,
    required this.receiverId,
    required this.roomId,
    required this.receiverName,
    required this.receiverImage,
  });

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver
    implements NetworkResponse {
  late Size size;

  final swipeLeftKey = GlobalKey<ScaffoldState>();
  TextEditingController messageController = TextEditingController();
  TextEditingController messageReplyController = TextEditingController();
  ScrollController chatScrollController = ScrollController();
  PlayerController controller = PlayerController();

  SqliteDataBase sqliteDatabase = SqliteDataBase();
  Timer? timer;

  String lastSeen = "";
  AudioPlayer audio = AudioPlayer();
  ///Predictive Message List
  bool showPredictiveMsg = false;

  /// Sender Information
  final String _senderId = sharedPreferences!.getString(hopperIdKey) ?? "";
  final String _senderProfilePic =
      avatarImageUrl + (sharedPreferences!.getString(avatarKey) ?? "");
  final String _senderName =
      ((sharedPreferences!.getString(firstNameKey) ?? "") +
          (sharedPreferences!.getString(lastNameKey) ?? ""));
  String audioPath = "", audioDuration = "";

  /// Receiver Information
  String _receiverId = "";
  String _receiverProfilePic = "";
  String _receiverName = "";
  String roomId = "";

  bool isLoading = false;
  bool isOnline = false;
  bool isRecordingLongPress = false;
  bool isPlayOrPause = false;
  bool isShowSendButton = false;
  bool? keyboardIsOpened;
  bool audioPlaying = false, draftSelected = false;
  FocusNode inputNode = FocusNode();



  Stream? chatStream;

  bool isChatEmpty = false;

  bool _showData = false;

  List<AttachIconModel> attachIconList = [
    AttachIconModel(icon: "$chatIconsPath/cameraIcon.png", iconName: 'Photo'),
    AttachIconModel(
        icon: "$chatIconsPath/galleryIcon.png", iconName: 'Gallery'),
    AttachIconModel(icon: "$chatIconsPath/videoIcon.png", iconName: 'Video'),
  ];

  ///audio

  String recordText = "";
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  final _audioRecorder = Record();
  String _pickedRecordingFilePath = "";
  AudioCache? audioCache;
  bool isPlaying = false;
  String collectionId = "";

  @override
  void initState() {
    debugPrint('Class Name: $runtimeType');
    debugPrint('adminName====>: ${widget.receiverImage}');
    debugPrint('roomID====>: $roomId');
    debugPrint('hopperName====>: ${sharedPreferences!.getString(avatarKey)}');
    debugPrint(
        'hopperProfile====>: ${sharedPreferences!.getString(avatarKey)}');
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    addOnlineOffline(true, roomId);
    _initializeData();
  }

  @override
  void dispose() {
    addOnlineOffline(false, widget.roomId);
    controller.dispose();
    audio.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("AppLifecycleState ::: $state");
    switch (state) {
      case AppLifecycleState.paused:
        addOnlineOffline(true, roomId);
        break;

      case AppLifecycleState.resumed:
        addOnlineOffline(true, roomId);
        break;

      case AppLifecycleState.inactive:
        addOnlineOffline(false, roomId);
        break;

      case AppLifecycleState.detached:
        addOnlineOffline(false, roomId);
        break;
    }
  }

  ///Typing-->
  void _onTypingFocusChange() {
    addTyping(messageController.text.length);
  }

  addFirebaseMessageToLocal(QueryDocumentSnapshot<Object?> element) async {
    debugPrint("addedMessage===> ${element.get('message')}");

    sendLocalChat({
      'message': element.get('message'),
      'senderId': _senderId,
      'senderName': _senderName,
      'senderImage': _senderProfilePic,
      'receiverName': _receiverName,
      'receiverImage': _receiverProfilePic,
      'receiverId': element.get("receiverId"),


      'messageType': element.get('message'),
      'videoThumbnail': element.get('videoThumbnail'),
      'replyType': "",
      'roomId': roomId,
      'uploadPercent': 100.0,
      'date': element.get('date'),
      'readStatus': "unread",
      'replyMessage': "",
      'isReply': 0,
      'latitude': 0.0,
      'longitude': 0.0,
      'isLocal': 0,
      'messageId': element.get('messageId')
    });

    /*var db = await sqliteDatabase.getDataBase();

    var result = await db.query(
        'CHAT',
        where: 'messageId = ?',
        whereArgs: [element.get('messageId')]
    );



    if(result.isNotEmpty) {

      result.forEach((element1) {

        debugPrint("element1=====>  ${element1}");

        if(element1['messageId'] != element.get('messageId')) {
          debugPrint("enterInsideResult=====>  ${element.get('messageId')}");


        }
      });




    }
    else {
      debugPrint("messagees====> $result");
    }*/
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    dynamic messages;
    if (_showData && roomId.isNotEmpty) {
      messages = FirebaseFirestore.instance
          .collection('Chat')
          .doc(roomId)
          .collection('Messages');
    }
    return _showData && roomId.isNotEmpty
        ? WillPopScope(
            onWillPop: () async {
               Navigator.pop(context, true);

              return false;
            },
            child: Scaffold(
                appBar: CommonAppBar(
                    elevation: 0,
                    hideLeading: false,
                    title: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                            size.width * numD01,
                          ),
                          height: size.width * numD14,
                          width: size.width * numD14,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle),
                          child: ClipOval(
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              adminProfileUrl + widget.receiverImage,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return Image.asset(
                                  "${commonImagePath}rabbitLogo.png",
                                );
                              },
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * numD02,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.receiverName.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD045),
                            ),
                            SizedBox(
                              height: size.width * numD01,
                            ),
                          /*  checkOnlineOffline(
                                context, size, widget.receiverId),*/
                          ],
                        ),
                      ],
                    ),
                    centerTitle: false,
                    titleSpacing: 0,
                    size: size,
                    showActions: true,
                    leadingFxn: () {
                      Navigator.pop(context);
                    },
                    actionWidget: null),
                body: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: messages
                            .orderBy('date', descending: true)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapShot) {
                          if (snapShot.hasError) {
                            return const Center(
                              child: Text('Something went wrong'),
                            );
                          } else if (snapShot.hasData) {
                            return ListView.separated(
                              padding: const EdgeInsets.all(15),
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  height: 10,
                                );
                              },
                              itemBuilder: (context, index) {
                                var document = snapShot.data!.docs[index];

                                return Column(
                                  children: [
                                    document.get('senderId') == _senderId ||
                                            document.get('receiverId') ==
                                                _senderId
                                        ? Container(
                                            color: Colors.transparent,
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.only(
                                                right: size.width * numD03,
                                                left: size.width * numD03,
                                                top: size.width * numD03),
                                            child: messageWidget(
                                                document, "sender", size),
                                          )
                                        : Container(
                                            color: Colors.transparent,
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(
                                                right: size.width * numD03,
                                                left: size.width * numD03,
                                                top: size.width * numD03),
                                            child: messageWidget(
                                                document, "receiver", size),
                                          ),
                                  ],
                                );
                              },
                              reverse: true,
                              shrinkWrap: true,
                              itemCount: snapShot.data != null
                                  ? snapShot.data!.docs.length
                                  : 0,
                            );
                          } else {
                            return showLoader();
                          }
                        },
                      ),
                    ),

                    bottomButton("sender", size),

                    /// Emoji Key Board
                    // buildStickerKeyboard()
                  ],
                )),
          )
        : Scaffold(
            body: showLoader(),
          );
  }

  Future<void> sendLocalChat(var data) async {
    debugPrint("ChatDataSHUBHAM: $data");
    // Get a reference to the database.
    final db = await sqliteDatabase.getDataBase();

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db
        .insert(
      'CHAT',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    )
        .then((value) async {
      debugPrint("Inserted");

      if (mounted) {
        setState(() {});
      }
    });
  }

/*  /// For checking person is Online Or OffLine
  Widget checkOnline(BuildContext context, size) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('OnlineOffline')
            .doc(_receiverId)
            .snapshots(),
        builder: (context, snapshot) {
          debugPrint("snapshot :$snapshot");
          if (!snapshot.hasData) {
            return Text(
              "Loading..",
              style: TextStyle(fontSize: size.width * numD03),
            );
          }
          var value = snapshot.data!.data();

          debugPrint("value :$value");
          if (value != null) {
            debugPrint("OnlineStatus :${value['isOnline']}");
            return Text(
              value['isOnline'] == false ? 'Offline'.toString() : 'Online',
              style: TextStyle(fontSize: size.width * numD03),
            );
          } else {
            return Text(
              "Offline",
              style: TextStyle(fontSize: size.width * numD03),
            );
          }
        });
  }*/

  Future<void> imagePickerOptions(BuildContext context, size) {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: size.width * numD02),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size.width * numD04),
                      color: Colors.white),
                  child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, index) {
                        return ListTile(
                          minLeadingWidth: 10,
                          minVerticalPadding: 5,
                          leading: Image.asset(
                            attachIconList[index].icon,
                            height: size.width * numD06,
                            width: size.width * numD06,
                            color: Colors.black,
                          ),
                          title: Text(
                            attachIconList[index].iconName,
                          ),
                          onTap: () {
                            if (attachIconList[index].iconName == "Photo") {
                              getImage(ImageSource.camera);
                            } else if (attachIconList[index].iconName ==
                                "Gallery") {
                              getImage(ImageSource.gallery);
                            } else {
                              getVideo();
                            }
                            setState(() {});
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, index) {
                        return Divider(
                          thickness: 1,
                          color: Colors.grey.shade200,
                        );
                      },
                      itemCount: attachIconList.length),
                ),
                SizedBox(
                  height: size.width * numD02,
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: size.width * numD13,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04)),
                              backgroundColor: Colors.white),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.width * numD03,
                ),
              ],
            ),
          );
        });
  }

  void settingsDialog() {
    showDialog(
        context: navigatorKey.currentState!.context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Dialog(
                    backgroundColor: Colors.transparent,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: const Text(
                                  "More Options",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  //callReportListApi();
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: const Text(
                                    "Report Profile",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  //callBlockProfileApi(senderId, widget.otherUserId);
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: const Text(
                                    "Block Profile",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  // callUnMatchApi(senderId,widget.otherUserId);
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: const Text(
                                    "Unmatch the profile",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ),
                              ),
                              /* privateImageAccess == "yes"
                                  ? InkWell(
                                      onTap: () {
                                        stateSetter(() {
                                          isGrantPics = !isGrantPics;
                                        });

                                        if (isGrantPics) {
                                          // callGrantAccessApi(senderId, widget.otherUserId,'images');
                                        } else {
                                          // callRevokeAccessApi(senderId, widget.otherUserId,'images');
                                        }
                                      },
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        width: double.infinity,
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              "Grant Access to Pics",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16),
                                            ),
                                            Image.asset(
                                              isGrantPics
                                                  ? "assets/toggle_active.png"
                                                  : "assets/toggle_inactive.png",
                                              height: 20,
                                              width: 30,
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              InkWell(
                                onTap: () {
                                  stateSetter(() {
                                    isGrantInsta = !isGrantInsta;
                                  });

                                  if (isGrantInsta) {
                                    //callGrantAccessApi(senderId, widget.otherUserId,'instagram');
                                  } else {
                                    //callRevokeAccessApi(senderId, widget.otherUserId,'instagram');
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Grant Access to Instagram",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                      Image.asset(
                                        isGrantInsta
                                            ? "assets/toggle_active.png"
                                            : "assets/toggle_inactive.png",
                                        height: 20,
                                        width: 30,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  stateSetter(() {
                                    isGrantLinkedIn = !isGrantLinkedIn;
                                  });

                                  if (isGrantLinkedIn) {
                                    //  callGrantAccessApi(senderId, widget.otherUserId,'linkedin');
                                  } else {
                                    // callRevokeAccessApi(senderId, widget.otherUserId,'linkedin');
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Grant Access to LinkedIn",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                      Image.asset(
                                        isGrantLinkedIn
                                            ? "assets/toggle_active.png"
                                            : "assets/toggle_inactive.png",
                                        height: 20,
                                        width: 30,
                                      )
                                    ],
                                  ),
                                ),
                              ),*/
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  color: Colors.grey.shade200, fontSize: 18),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  Future<bool> onBackPress() {
    Navigator.pop(navigatorKey.currentState!.context);
    return Future.value(false);
  }

  //Emoji---keyboard--->
  Widget buildStickerKeyboard() {
    return Offstage(
      offstage: false,
      child: SizedBox(
        height: 250,
        child: EmojiPicker(
            onEmojiSelected: (Category? category, Emoji? emoji) {
              _onEmojiSelected(emoji!);
            },
            onBackspacePressed: onBackPress,
            config: Config(
                columns: 7,
                // Issue: https://github.com/flutter/flutter/issues/28894
                emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                verticalSpacing: 0,
                horizontalSpacing: 0,
                initCategory: Category.RECENT,
                bgColor: const Color(0xFFF2F2F2),
                indicatorColor: Colors.blue,
                iconColor: Colors.grey,
                iconColorSelected: Colors.blue,
                //progressIndicatorColor: Colors.white,
                backspaceColor: Colors.blue,
                //showRecentsTab: false,
                recentsLimit: 28,
                //noRecentsText: 'No Recents',
                // noRecentsStyle: const TextStyle(fontSize: 20, color: Colors.black26),
                //tabIndicatorAnimDuration: kTabScrollDuration,
                categoryIcons: const CategoryIcons(),
                buttonMode: ButtonMode.MATERIAL)),
      ),
    );
  }

  _onEmojiSelected(Emoji emoji) {
    if (mounted) {
      setState(() {
        // messageController.text = messageController.text + emoji.emoji;
        messageController
          ..text += emoji.emoji
          ..selection = TextSelection.fromPosition(
              TextPosition(offset: messageController.text.length));
      });
    }

    /*..selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length));*/
  }

  Widget bottomButton(String type, size) {
    return Container(
      alignment: Alignment.bottomCenter,
      color: Colors.transparent,
      child: Container(
          margin: EdgeInsets.only(top: size.width * numD03),
          padding: EdgeInsets.only(right: size.width * numD035),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * numD01,
                        ),
                        GestureDetector(
                            onTap: () {
                              FocusScope.of(navigatorKey.currentState!.context)
                                  .requestFocus(FocusNode());
                              if (mounted) {
                                imagePickerOptions(
                                    navigatorKey.currentState!.context, size);
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: size.width * numD06,
                              child: Image.asset(
                                "${iconsPath}ic_attachment.png",
                                height: size.width * numD048,
                                width: size.width * numD048,
                              ),
                            )),
                        SizedBox(
                          width: size.width * numD02,
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              CommonTextField(
                                size: size,
                                controller: messageController,
                                hintText: "Type here ...",
                                prefixIcon: null,
                                borderColor: Colors.grey.shade300,
                                prefixIconHeight: size.width * numD06,
                                suffixIconIconHeight: size.width * numD06,
                                textInputFormatters: null,
                                suffixIcon: InkWell(
                                  onTap: () async {
                                    /// To Reply

                                    if(messageController.text.trim().isNotEmpty){
                                      debugPrint(
                                          "::::: Inside Send Text Message With Not Reply :::::");

                                      commonValues(
                                          messageType: "text",
                                          messageInput: messageController.text.trim(),
                                          duration: '',
                                          isAudioSelected: false);

                                      messageController.clear();

                                      if (mounted) {
                                        setState(() {});
                                      }
                                    }

                                    /*if (await isInternetConnected()) {
                                      callCustomNotificationApi('text');
                                    }*/
                                  },
                                  child: Image.asset(
                                    "${iconsPath}ic_arrow_right.png",
                                    color: Colors.black,
                                    width: size.width * numD07,
                                  ),
                                ),
                                hidePassword: false,
                                keyboardType: TextInputType.text,
                                validator: null,
                                enableValidations: true,
                                filled: false,
                                filledColor: Colors.transparent,
                                maxLines: 1,
                              ),
                              isRecordingLongPress
                                  ? Positioned.fill(
                                      child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * numD04),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD03),
                                        color: colorLightGrey,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.mic_none_outlined,
                                              color: colorThemePink),
                                          SizedBox(width: size.width * numD02),
                                          Text(
                                            Duration(seconds: _recordDuration)
                                                .toString()
                                                .split('.')
                                                .first,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD05,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          ),

                                        ],
                                      ),
                                    ))
                                  : Container(),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: size.width * numD02,
                        ),
                        isRecordingLongPress?InkWell(
                          onTap: (){
                            debugPrint("tazb::::::::");
                            isRecordingLongPress = false;
                            _stop();
                            setState(() {});
                          },
                          child: CircleAvatar(
                            backgroundColor: isRecordingLongPress
                                ? colorThemePink
                                : Colors.transparent,
                            radius: size.width * numD06,
                            child: Icon(
                              Icons.send,
                              color: isRecordingLongPress
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ):GestureDetector(
                            onTap: () {
                              recordText = "Recording...";
                              debugPrint('onLongPress-Start');
                              isRecordingLongPress = true;
                              _start();
                              setState(() {});
                            },
                            onLongPressEnd: (value) {
                              debugPrint('onLongPress-End');
                              isRecordingLongPress = false;
                              _stop();
                              setState(() {});
                            },
                            child: CircleAvatar(
                              backgroundColor: isRecordingLongPress
                                  ? colorThemePink
                                  : Colors.transparent,
                              radius: size.width * numD06,
                              child: Icon(
                                Icons.mic_none_sharp,
                                color: isRecordingLongPress
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: size.width * numD03,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget leftChatWidget(QueryDocumentSnapshot<Object?> document) {
    return Padding(
      padding: EdgeInsets.only(right: size.width * numD20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(
              size.width * numD01,
            ),
            height: size.width * numD12,
            width: size.width * numD12,
            decoration: const BoxDecoration(
                color: colorSwitchBack, shape: BoxShape.circle),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                height: size.width * numD09,
                width: size.width * numD09,
              ),
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(top: size.width * numD02),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(size.width * numD04),
                        bottomLeft: Radius.circular(size.width * numD04),
                        bottomRight: Radius.circular(size.width * numD04),
                      ),
                      border: Border.all(width: 1.5, color: colorSwitchBack)),
                  /* padding: EdgeInsets.all(size.width * numD05),*/
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * numD05,
                      vertical: size.width * numD025),
                  child: Text(
                    document.get("message").toString(),
                    style: TextStyle(
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: "AirbnbCereal_W_Bk"),
                  ),
                ),
                Container(
                  // width: size.width / 1.5,
                  padding: EdgeInsets.only(
                    right: size.width * numD02,
                    top: size.width * numD01,
                  ),
                  child: Text(
                    timeParse(document.get('date')),
                    style: TextStyle(
                        fontSize: size.width * numD03,
                        color: colorGoogleButtonBorder,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget rightChatWidget(QueryDocumentSnapshot<Object?> document) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorGreyChat,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(size.width * numD04),
                    bottomLeft: Radius.circular(size.width * numD04),
                    topLeft: Radius.circular(size.width * numD04),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * numD05,
                    vertical: size.width * numD025),
                child: Text(
                  document.get("message").toString(),
                  style: TextStyle(
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontFamily: "AirbnbCereal_W_Bk"),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  right: size.width * numD02,
                  top: size.width * numD01,
                ),
                child: Text(
                  timeParse(document.get('date')),
                  style: TextStyle(
                      fontSize: size.width * numD028,
                      color: colorGoogleButtonBorder,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: size.width * numD02,
        ),
        _senderProfilePic.isNotEmpty
            ? Container(
                padding: EdgeInsets.all(
                  size.width * numD01,
                ),
                height: size.width * numD12,
                width: size.width * numD12,
                decoration: const BoxDecoration(
                    color: colorLightGrey, shape: BoxShape.circle),
                child: ClipOval(
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      _senderProfilePic,
                      fit: BoxFit.cover,
                    )),
              )
            : Container(
                padding: EdgeInsets.all(
                  size.width * numD01,
                ),
                height: size.width * numD12,
                width: size.width * numD12,
                decoration: const BoxDecoration(
                    color: colorSwitchBack, shape: BoxShape.circle),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    "${commonImagePath}rabbitLogo.png",
                    height: size.width * numD09,
                    width: size.width * numD09,
                  ),
                ),
              ),
      ],
    );
  }

  ///Message widgets-->
  Widget messageWidget(QueryDocumentSnapshot<Object?> document, String type, size) {
    //callCustomNotificationApi(document.get('messageType') == 'text' ?document.get("message").toString():document.get('messageType'));
    return Slidable(
      key: ValueKey(
        document.get("messageId").toString(),
      ),
      startActionPane: ActionPane(
        extentRatio: 0.2,
        key: ValueKey(
          document.get("messageId").toString(),
        ),
        motion: const BehindMotion(),
        children: [
          type == 'sender'
              ? Container(): SlidableAction(
                  onPressed: (_) {
                    _deleteChat(document);
                    debugPrint(
                        "deleteMessage====>  ${document.get("message")}");
                  },
                  icon: Icons.delete,
                  spacing: 4,
                )

        ],
      ),
      endActionPane: ActionPane(
        extentRatio: 0.2,
        key: ValueKey(
          document.get("messageId").toString(),
        ),
        motion: const BehindMotion(),
        children: [
          type == 'sender'
              ? SlidableAction(
                  onPressed: (_) {
                    _deleteChat(document);
                    debugPrint(
                        "deleteMessage====>  ${document.get("message")}");
                  },
                  icon: Icons.delete,
                  spacing: 4,
                )
              : Container(),
        ],
      ),
      child: Column(
        crossAxisAlignment: type == 'sender'
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          document.get('messageType') == 'text'
              ? type == 'sender'
                  ? rightChatWidget(document)
                  : leftChatWidget(document)
              : Container(),

          /// To Send Image
          document.get('messageType') == 'image' ||
                  document.get('messageType') == 'imageFile'
              ? type == 'sender'
                  ? rightImageChatWidget(document)
                  : leftImageChatWidget(document)
              : Container(),

          /// To Send Document
          document.get('messageType') == 'doc' ||
                  document.get('messageType') == 'docFile'
              ? Container(
                  decoration: type == 'sender'
                      ? BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(size.width * numD03),
                            topLeft: Radius.circular(size.width * numD03),
                            bottomLeft: Radius.circular(size.width * numD03),
                            bottomRight: Radius.circular(size.width * numD1),
                          ),
                          color: Colors.white,
                        )
                      : BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(size.width * numD1),
                            topRight: Radius.circular(size.width * numD03),
                            bottomRight: Radius.circular(size.width * numD03),
                            bottomLeft: Radius.circular(size.width * numD03),
                          ),
                          color: Colors.pink,
                        ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            minWidth: MediaQuery.of(
                                        navigatorKey.currentState!.context)
                                    .size
                                    .width /
                                2.5,
                            maxWidth: MediaQuery.of(
                                        navigatorKey.currentState!.context)
                                    .size
                                    .width /
                                2),
                        margin: const EdgeInsets.all(8.0),
                        child: document.get('uploadPercent') < 100
                            ? Container(
                                margin: const EdgeInsets.all(20),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: double.parse(document
                                          .get('uploadPercent')
                                          .toString()),
                                      strokeWidth: 4,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                      backgroundColor: Colors.white,
                                    ),
                                    document.get('uploadPercent') == 100
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          )
                                        : Container()
                                  ],
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  FocusScope.of(
                                          navigatorKey.currentState!.context)
                                      .requestFocus(FocusNode());
                                  /*Navigator.push(
                          navigatorKey.currentState!.context,
                          MaterialPageRoute(
                              builder: (context) => PdfViewScreen(
                                pdfPath: mapData['message'],
                                isFile:
                                mapData["messageType"] ==
                                    "docFile"
                                    ? true
                                    : false,
                              )));*/
                                  //  launch(document.get('message'));
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  color: type == 'sender'
                                      ? Colors.white
                                      : Colors.pink,
                                  alignment: Alignment.center,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.file_copy_outlined,
                                            size: size.width * numD1,
                                            color: Colors.white,
                                          )),
                                      Container(
                                        height: 60,
                                        alignment: Alignment.center,
                                        child: Text("Document".toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      type == 'sender'
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      timeParse(
                                                          document.get('date')),
                                                      //timeParse(document.get('date')).toString().split('.').first.toString(),
                                                      textAlign: TextAlign.end,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10.0,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  document.get('isLocal') == 1
                                                      ? const Icon(
                                                          Icons.history,
                                                          color: Colors.white,
                                                          size: 15)
                                                      : Container(
                                                          height: 15.0,
                                                          width: 15.0,
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5),
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Image.asset(
                                                            "$chatIconsPath/double_tick_active.png",
                                                            color: document.get(
                                                                        'readStatus') ==
                                                                    "unread"
                                                                ? Colors.white
                                                                : Colors.blue,
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.only(
                                                right: 10,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      timeParse(
                                                          document.get('date')),
                                                      textAlign: TextAlign.end,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10.0,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ],
                                              ),
                                            )
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                )
              : Container(),

          /// To Send Music
          document.get('messageType') == 'music' ||
                  document.get('messageType') == 'musicFile'
              ? Container(
                  decoration: type == 'sender'
                      ? BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(size.width * numD03),
                            topLeft: Radius.circular(size.width * numD03),
                            bottomLeft: Radius.circular(size.width * numD03),
                            bottomRight: Radius.circular(size.width * numD1),
                          ),
                          color: Colors.white,
                        )
                      : BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(size.width * numD1),
                            topRight: Radius.circular(size.width * numD03),
                            bottomRight: Radius.circular(size.width * numD03),
                            bottomLeft: Radius.circular(size.width * numD03),
                          ),
                          color: Colors.pink,
                        ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            minWidth: MediaQuery.of(
                                        navigatorKey.currentState!.context)
                                    .size
                                    .width /
                                2.5,
                            maxWidth: MediaQuery.of(
                                        navigatorKey.currentState!.context)
                                    .size
                                    .width /
                                2),
                        margin: const EdgeInsets.all(8.0),
                        child: document.get('uploadPercent') < 100
                            ? Container(
                                margin: const EdgeInsets.all(20),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: double.parse(document
                                          .get('uploadPercent')
                                          .toString()),
                                      strokeWidth: 4,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                      backgroundColor: Colors.white,
                                    ),
                                    document.get('uploadPercent') == 100
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          )
                                        : Container()
                                  ],
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  /* FocusScope.of(
                          navigatorKey.currentState!.context)
                          .requestFocus(FocusNode());
                      Navigator.push(
                          navigatorKey.currentState!.context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PlayAudio(mapData['message'])));*/
                                },
                                child: Container(
                                  color: type == 'sender'
                                      ? Colors.white
                                      : Colors.pink,
                                  alignment: Alignment.center,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(
                                        Icons.library_music,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        height: 60,
                                        child: Text("Music".toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      type == 'sender'
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                  top: 15, right: 10),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      timeParse(
                                                          document.get('date')),
                                                      //timeParse(mapData['date')).toString().split('.').first.toString(),
                                                      textAlign: TextAlign.end,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10.0,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  document.get('isLocal') == 1
                                                      ? const Icon(
                                                          Icons.history,
                                                          color: Colors.white,
                                                          size: 15)
                                                      : Container(
                                                          height: 15.0,
                                                          width: 15.0,
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5),
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Image.asset(
                                                            "$chatIconsPath/double_tick_active.png",
                                                            color: document.get(
                                                                            'messageType')[
                                                                        'readStatus'] ==
                                                                    "unread"
                                                                ? Colors.white
                                                                : Colors.blue,
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.only(
                                                  top: 15, right: 10),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      timeParse(
                                                          document.get('date')),
                                                      textAlign: TextAlign.end,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10.0,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ],
                                              ),
                                            )
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                )
              : Container(),

          /// To Send Video
          document.get('messageType') == 'video' ||
                  document.get('messageType') == 'videoFile'
              ? type == 'sender'
                  ? rightVideoChatWidget(document)
                  : leftVideoChatWidget(document)
              : Container(),

          /// CSV
          document.get('messageType') == 'csv'
              ? Container(
                  margin: EdgeInsets.only(right: size.width * numD20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          size.width * numD01,
                        ),
                        height: size.width * numD12,
                        width: size.width * numD12,
                        decoration: const BoxDecoration(
                            color: colorSwitchBack, shape: BoxShape.circle),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            "${commonImagePath}rabbitLogo.png",
                            height: size.width * numD09,
                            width: size.width * numD09,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * numD02,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                openUrl(document.get('message'));
                              },
                              child: Container(
                                margin:
                                    EdgeInsets.only(top: size.width * numD02),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight:
                                          Radius.circular(size.width * numD04),
                                      bottomLeft:
                                          Radius.circular(size.width * numD04),
                                      bottomRight:
                                          Radius.circular(size.width * numD04),
                                    ),
                                    border: Border.all(
                                        width: 1.5, color: colorSwitchBack)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD01),
                                    child: Image.asset(
                                      "assets/chatIcons/csv_image.png",
                                      fit: BoxFit.contain,
                                      height: size.width * numD30,
                                      errorBuilder: (context, strace, object) {
                                        return errorImage();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              width: size.width / 1.5,
                              padding: EdgeInsets.only(
                                right: size.width * numD02,
                                top: size.width * numD01,
                              ),
                              child: Text(
                                timeParse(document.get('date')),
                                style: TextStyle(
                                    fontSize: size.width * numD03,
                                    color: const Color(0xFF979797),
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),

          document.get('messageType') == 'recording'
              ? type == 'sender'
                  ?   Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: document.get('uploadPercent') < 100
                                  ? size.width * numD15
                                  : size.width * numD40,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.width * numD03,
                                    horizontal: size.width * numD03),
                                decoration: BoxDecoration(
                                    color: colorLightGrey,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD06)),
                                child: document.get('uploadPercent') < 100
                                    ? commonUploadLoader(document
                                        .get('uploadPercent')
                                        .toString())
                                    : Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              FirebaseFirestore.instance
                                                  .collection('Chat')
                                                  .doc(roomId)
                                                  .collection('Messages')
                                                  .get()
                                                  .then((value) {
                                                var pos = value.docs.indexWhere(
                                                    (element) => element.get(
                                                        'isAudioSelected'));
                                                if (pos != -1) {
                                                  collectionId =
                                                      value.docs[pos].id;
                                                  setState(() {});
                                                  updateAudio(
                                                      value.docs[pos].id,
                                                      false);
                                                }
                                              }).whenComplete(() {
                                                debugPrint(
                                                    "whenComplete:::: Loop");
                                                if (document
                                                    .get('isAudioSelected')) {
                                                  updateAudio(
                                                          document.id, false)
                                                      .whenComplete(() {
                                                    controller.pausePlayer();
                                                    debugPrint("Pause");
                                                    setState(() {});
                                                  });
                                                } else {
                                                  updateAudio(document.id, true)
                                                      .whenComplete(() {
                                                    updateAudio(
                                                            document.id, true)
                                                        .whenComplete(() {
                                                      debugPrint("senderRecordingUrl=======>${document.get('message')} ");
                                                      downloadAudioFromUrl(

                                                              document.get(
                                                                  'message'))
                                                          .then((value) =>
                                                              initWave(
                                                                  value, true));
                                                    });
                                                  });
                                                }
                                              });

                                              setState(() {});
                                            },
                                            child: SizedBox(
                                              height: size.width * numD06,
                                              child: Icon(
                                                document.get('isAudioSelected')
                                                    ? Icons.pause_circle
                                                    : Icons.play_circle,
                                                color: Colors.black,
                                                size: size.width * numD06,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: size.width * numD02),
                                          document.get('isAudioSelected')
                                              ? Expanded(
                                                  child: AudioFileWaveforms(
                                                    size: Size(size.width,
                                                        size.width * numD04),
                                                    playerController:
                                                        controller,
                                                    enableSeekGesture: false,
                                                    animationCurve:
                                                        Curves.bounceIn,
                                                    waveformType:
                                                        WaveformType.long,
                                                    continuousWaveform: true,
                                                    playerWaveStyle:
                                                        PlayerWaveStyle(
                                                      fixedWaveColor:
                                                          Colors.black,
                                                      liveWaveColor:
                                                          colorThemePink,
                                                      spacing: 6,
                                                      liveWaveGradient:
                                                          ui.Gradient.linear(
                                                        const Offset(70, 50),
                                                        Offset(
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2,
                                                            0),
                                                        [
                                                          Colors.green,
                                                          Colors.white70
                                                        ],
                                                      ),
                                                      fixedWaveGradient:
                                                          ui.Gradient.linear(
                                                        const Offset(70, 50),
                                                        Offset(
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2,
                                                            0),
                                                        [
                                                          Colors.green,
                                                          Colors.white70
                                                        ],
                                                      ),
                                                      seekLineColor:
                                                          colorThemePink,
                                                      seekLineThickness: 2,
                                                      showSeekLine: true,
                                                      showBottom: true,
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              width: size.width / 1.5,
                              padding: EdgeInsets.only(
                                right: size.width * numD02,
                                top: size.width * numD01,
                              ),
                              child: Text(
                                timeParse(document.get('date')),
                                style: TextStyle(
                                    fontSize: size.width * numD03,
                                    color: const Color(0xFF979797),
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: size.width * numD02,
                        ),
                        _senderProfilePic.isNotEmpty
                            ? Container(
                                padding: EdgeInsets.all(
                                  size.width * numD01,
                                ),
                                height: size.width * numD12,
                                width: size.width * numD12,
                                decoration: const BoxDecoration(
                                    color: colorLightGrey,
                                    shape: BoxShape.circle),
                                child: ClipOval(
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.network(
                                      _senderProfilePic,
                                      fit: BoxFit.cover,
                                    )),
                              )
                            : Container(
                                padding: EdgeInsets.all(
                                  size.width * numD01,
                                ),
                                height: size.width * numD12,
                                width: size.width * numD12,
                                decoration: const BoxDecoration(
                                    color: colorSwitchBack,
                                    shape: BoxShape.circle),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Image.asset(
                                    "${commonImagePath}rabbitLogo.png",
                                    height: size.width * numD09,
                                    width: size.width * numD09,
                                  ),
                                ),
                              ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                            size.width * numD01,
                          ),
                          height: size.width * numD12,
                          width: size.width * numD12,
                          decoration: const BoxDecoration(
                              color: colorSwitchBack, shape: BoxShape.circle),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Image.asset(
                              "${commonImagePath}rabbitLogo.png",
                              height: size.width * numD09,
                              width: size.width * numD09,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * numD02,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: size.width * numD40,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.width * numD03,
                                    horizontal: size.width * numD03),
                                decoration: BoxDecoration(
                                    color: colorLightGrey,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD06)),
                                child: Row(
                                  children: [
                                    /* InkWell(
                                      onTap: () {
                                        FirebaseFirestore.instance
                                            .collection('Chat')
                                            .doc(roomId)
                                            .collection('Messages')
                                            .get()
                                            .then((value) {
                                          var pos = value.docs.indexWhere(
                                              (element) => element
                                                  .get('isAudioSelected'));
                                          if (pos != -1) {
                                            updateAudio(
                                                value.docs[pos].id, false);
                                          }
                                        }).whenComplete(() {
                                          debugPrint("whenComplete:::: Loop");
                                          if (document.get('isAudioSelected')) {
                                            updateAudio(document.id, false)
                                                .whenComplete(() {
                                              controller.pausePlayer();
                                              debugPrint("Pause");
                                              setState(() {});
                                            });
                                          } else {
                                            updateAudio(document.id, true)
                                                .whenComplete(() {
                                              updateAudio(document.id, true)
                                                  .whenComplete(() {
                                                */
                                    /*initWaveData(audioPath, true);*/ /*
                                              });
                                            });
                                          }
                                        });

                                        audioPath =
                                            document.get('message').toString();
                                        audioDuration =
                                            document.get('duration').toString();
                                        debugPrint(
                                            "AudioPath======>1:$audioPath");
                                        debugPrint(
                                            "audioDuration========>1:$audioDuration");

                                        setState(() {});
                                      },
                                      child: SizedBox(
                                        height: size.width * numD06,
                                        child: Icon(
                                          document.get('isAudioSelected')
                                              ? Icons.pause_circle
                                              : Icons.play_circle,
                                          color: Colors.black,
                                          size: size.width * numD06,
                                        ),
                                      ),
                                    ),*/
                                    InkWell(
                                      onTap: () {
                                        FirebaseFirestore.instance
                                            .collection('Chat')
                                            .doc(roomId)
                                            .collection('Messages')
                                            .get()
                                            .then((value) {
                                          var pos = value.docs.indexWhere(
                                              (element) => element
                                                  .get('isAudioSelected'));
                                          if (pos != -1) {
                                            collectionId = value.docs[pos].id;
                                            setState(() {});
                                            updateAudio(
                                                value.docs[pos].id, false);
                                          }
                                        }).whenComplete(() {
                                          debugPrint("whenComplete:::: Loop");
                                          if (document.get('isAudioSelected')) {
                                            updateAudio(document.id, false)
                                                .whenComplete(() {
                                              controller.pausePlayer();
                                              debugPrint("Pause");
                                              setState(() {});
                                            });
                                          } else {
                                            updateAudio(document.id, true)
                                                .whenComplete(() {
                                              updateAudio(document.id, true)
                                                  .whenComplete(() {
                                                    debugPrint("receiverRecordingUrl=======>${document.get('message')} ");
                                                    downloadAudioFromUrl( document.get(
                                                        'message'))
                                                    .then((value) =>
                                                        initWave(value, true));

                                              });
                                            });
                                          }
                                        });

                                        setState(() {});
                                      },
                                      child: SizedBox(
                                        height: size.width * numD06,
                                        child: Icon(
                                          document.get('isAudioSelected')
                                              ? Icons.pause_circle
                                              : Icons.play_circle,
                                          color: Colors.black,
                                          size: size.width * numD06,
                                        ),
                                      ),
                                    ),
                                    document.get('isAudioSelected')
                                        ? Expanded(
                                            child: AudioFileWaveforms(
                                              size: Size(size.width,
                                                  size.width * numD04),
                                              playerController: controller,
                                              enableSeekGesture: false,
                                              animationCurve: Curves.bounceIn,
                                              waveformType: WaveformType.long,
                                              continuousWaveform: true,
                                              playerWaveStyle: PlayerWaveStyle(
                                                fixedWaveColor: Colors.black,
                                                liveWaveColor: colorThemePink,
                                                spacing: 6,
                                                liveWaveGradient:
                                                    ui.Gradient.linear(
                                                  const Offset(70, 50),
                                                  Offset(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2,
                                                      0),
                                                  [
                                                    Colors.green,
                                                    Colors.white70
                                                  ],
                                                ),
                                                fixedWaveGradient:
                                                    ui.Gradient.linear(
                                                  const Offset(70, 50),
                                                  Offset(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2,
                                                      0),
                                                  [
                                                    Colors.green,
                                                    Colors.white70
                                                  ],
                                                ),
                                                seekLineColor: colorThemePink,
                                                seekLineThickness: 2,
                                                showSeekLine: true,
                                                showBottom: true,
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              width: size.width / 1.5,
                              padding: EdgeInsets.only(
                                right: size.width * numD02,
                                top: size.width * numD01,
                              ),
                              child: Text(
                                timeParse(document.get('date')),
                                style: TextStyle(
                                    fontSize: size.width * numD03,
                                    color: const Color(0xFF979797),
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
              : Container(),
        ],
      ),
    );
  }

  Future<String> downloadAudioFromUrl(String url) async {
    var dir = await getApplicationDocumentsDirectory();
    var path = dir.path;
   var file = File('$path/file.m4a');
    var response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    debugPrint("file path=====> ${file.path}");
    debugPrint("file exist=====> ${ await file.exists()}");
    return file.path;
  }

  /*Future<String> downloadAndSaveMP3(String url) async {
    var dir = await getApplicationDocumentsDirectory();
    var path = dir.path;
    file = File('$path/file.mp3');
    var response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    debugPrint("file path=====> ${file.path}");
    debugPrint("file exist=====> ${ await file.exists()}");

    return file.path;
  }*/

  Future<void> initWave(String path, bool audioPlaying) async {
    debugPrint("path=========> $path");
    await controller.preparePlayer(
      path: path,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );
    if (audioPlaying) {
      controller.startPlayer(finishMode: FinishMode.pause);
      debugPrint("Play=======>");
    } else {
      FirebaseFirestore.instance
          .collection('Chat')
          .doc(roomId)
          .collection('Messages')
          .get()
          .then((value) {
        var pos =
            value.docs.indexWhere((element) => element.get('isAudioSelected'));
        if (pos != -1) {
          updateAudio(value.docs[pos].id, false);
        }
      });
      controller.pausePlayer();
    }
    controller.onPlayerStateChanged.listen((event) {
      if (event.isPaused) {
        FirebaseFirestore.instance
            .collection('Chat')
            .doc(roomId)
            .collection('Messages')
            .get()
            .then((value) {
          var pos = value.docs
              .indexWhere((element) => element.get('isAudioSelected'));
          if (pos != -1) {
            updateAudio(value.docs[pos].id, false);
          }
        });
        setState(() {});
      }
    });
    /* controller.onCompletion.listen((event) {
      FirebaseFirestore.instance
          .collection('Chat')
          .doc(roomId)
          .collection('Messages')
          .get()
          .then((value) {
        var pos =
            value.docs.indexWhere((element) => element.get('isAudioSelected'));
        if (pos != -1) {
          updateAudio(value.docs[pos].id, false);
        }
      });
    });*/
  }

 /*  Future initWaveData(String aPath, bool audioPlaying) async {
    debugPrint("audioPlaying ::: $audioPlaying");
    if (audioPlaying) {
      audio.play(
        UrlSource(aPath),
        volume: 1.0,
      );
      debugPrint("Play");
    } else {
      audioPlaying = false;
      setState(() {});
      audio.pause();
      debugPrint("Pause");
    }
    audio.onPlayerComplete.listen((event) {
      audioPlaying = false;
      FirebaseFirestore.instance
          .collection('Chat')
          .doc(roomId)
          .collection('Messages')
          .get()
          .then((value) {
        var pos =
            value.docs.indexWhere((element) => element.get('isAudioSelected'));
        if (pos != -1) {
          updateAudio(value.docs[pos].id, false);
        }
      });
      setState(() {});
      print("Audio playback complete");
      audio.dispose(); // Release resources
    });

    setState(() {});
  }
*/
  ///Record--audio-->
  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _recordDuration = 0;
        });
        _startTimer();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    final path = await _audioRecorder.stop();
    debugPrint("stop========>");
      var file = File(path!);
      debugPrint("recordingPath====>Exist ${await file.exists()}");
      Uri uri = Uri.parse(file.path);
      String filePath = uri.path;

      debugPrint("recordingPath====> ${filePath}");
      commonValues(
          messageType: 'recording',
          messageInput: filePath,
          duration: '',
          isAudioSelected: false);

    //widget.onStop(path!);
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
    //debugPrint("timerrrrrrrr========> $_timer");
    _ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      setState(() {});
    });
  }

  Widget rightVideoChatWidget(QueryDocumentSnapshot<Object?> document) {
    return Container(
      margin: EdgeInsets.only(left: size.width * numD20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorGreyChat,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      topLeft: Radius.circular(size.width * numD04),
                    ),
                  ),
                  padding: EdgeInsets.all(size.width * numD03),
                  child: document.get('uploadPercent') < 100
                      ? commonUploadLoader(
                          document.get('uploadPercent').toString())
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(navigatorKey.currentState!.context)
                                    .push(MaterialPageRoute(
                                        builder: (context) => MediaViewScreen(
                                            mediaFile:
                                                document.get('message'), type: MediaTypeEnum.video,)));
                              },
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD01),
                                child: Image.network(
                                  document.get('videoThumbnail'),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, strace, object) {
                                    return errorImage();
                                  },
                                ),
                              ),
                            ),
                            Icon(
                              Icons.play_circle,
                              color: Colors.white,
                              size: size.width * numD07,
                            )
                          ],
                        ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    right: size.width * numD02,
                    top: size.width * numD01,
                  ),
                  child: Text(
                    timeParse(document.get('date')),
                    style: TextStyle(
                        fontSize: size.width * numD03,
                        color: colorGoogleButtonBorder,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
          _senderProfilePic.isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(
                    size.width * numD01,
                  ),
                  height: size.width * numD12,
                  width: size.width * numD12,
                  decoration: const BoxDecoration(
                      color: colorLightGrey, shape: BoxShape.circle),
                  child: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        _senderProfilePic,
                        fit: BoxFit.cover,
                      )),
                )
              : Container(
                  padding: EdgeInsets.all(
                    size.width * numD01,
                  ),
                  height: size.width * numD12,
                  width: size.width * numD12,
                  decoration: const BoxDecoration(
                      color: colorSwitchBack, shape: BoxShape.circle),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      "${commonImagePath}rabbitLogo.png",
                      height: size.width * numD09,
                      width: size.width * numD09,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget leftVideoChatWidget(QueryDocumentSnapshot<Object?> document) {
    return Container(
      margin: EdgeInsets.only(right: size.width * numD20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(
              size.width * numD01,
            ),
            height: size.width * numD12,
            width: size.width * numD12,
            decoration: const BoxDecoration(
                color: colorSwitchBack, shape: BoxShape.circle),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                height: size.width * numD09,
                width: size.width * numD09,
              ),
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: size.width * numD02),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(size.width * numD04),
                        bottomLeft: Radius.circular(size.width * numD04),
                        bottomRight: Radius.circular(size.width * numD04),
                      ),
                      border: Border.all(width: 1.5, color: colorSwitchBack)),
                  padding: EdgeInsets.all(size.width * numD03),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(navigatorKey.currentState!.context).push(
                          MaterialPageRoute(
                              builder: (context) => MediaViewScreen(
                                  mediaFile:
                                      document.get('messageType')["message"], type: MediaTypeEnum.video,)));
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(size.width * numD01),
                          child: Image.network(
                           // document.get('messageType')["videoThumbnail"],
                            document.get('videoThumbnail'),
                            fit: BoxFit.contain,
                            errorBuilder: (context, strace, object) {
                              return errorImage();
                            },
                          ),
                        ),
                        Icon(
                          Icons.play_circle,
                          color: Colors.white,
                          size: size.width * numD07,
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  width: size.width / 1.5,
                  padding: EdgeInsets.only(
                    right: size.width * numD02,
                    top: size.width * numD01,
                  ),
                  child: Text(
                    timeParse(document.get('date')),
                    style: TextStyle(
                        fontSize: size.width * numD03,
                        color: const Color(0xFF979797),
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget rightImageChatWidget(QueryDocumentSnapshot<Object?> document) {
    return Container(
      margin: EdgeInsets.only(left: size.width * numD20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorGreyChat,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      topLeft: Radius.circular(size.width * numD04),
                    ),
                  ),
                  padding: EdgeInsets.all(size.width * numD03),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * numD01),
                    child: document.get('uploadPercent') < 100
                        ? commonUploadLoader(
                            document.get('uploadPercent').toString())
                        : document.get('messageType') == "imageFile" &&
                                File(document.get('message')).existsSync()
                            ? Image.file(
                                File(document.get('message')),
                                fit: BoxFit.contain,
                                errorBuilder: (context, strace, object) {
                                  return errorImage();
                                },
                              )
                            : Image.network(
                                document.get('message'),
                                fit: BoxFit.contain,
                                errorBuilder: (context, strace, object) {
                                  return errorImage();
                                },
                              ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    right: size.width * numD02,
                    top: size.width * numD01,
                  ),
                  child: Text(
                    timeParse(document.get('date')),
                    style: TextStyle(
                        fontSize: size.width * numD03,
                        color: colorGoogleButtonBorder,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
          _senderProfilePic.isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(
                    size.width * numD01,
                  ),
                  height: size.width * numD12,
                  width: size.width * numD12,
                  decoration: const BoxDecoration(
                      color: colorLightGrey, shape: BoxShape.circle),
                  child: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        _senderProfilePic,
                        fit: BoxFit.cover,
                      )),
                )
              : Container(
                  padding: EdgeInsets.all(
                    size.width * numD01,
                  ),
                  height: size.width * numD12,
                  width: size.width * numD12,
                  decoration: const BoxDecoration(
                      color: colorSwitchBack, shape: BoxShape.circle),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      "${commonImagePath}rabbitLogo.png",
                      height: size.width * numD09,
                      width: size.width * numD09,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget leftImageChatWidget(QueryDocumentSnapshot<Object?> document) {
    return Container(
      margin: EdgeInsets.only(right: size.width * numD20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(
              size.width * numD01,
            ),
            height: size.width * numD12,
            width: size.width * numD12,
            decoration: const BoxDecoration(
                color: colorSwitchBack, shape: BoxShape.circle),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                height: size.width * numD09,
                width: size.width * numD09,
              ),
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: size.width * numD02),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(size.width * numD04),
                        bottomLeft: Radius.circular(size.width * numD04),
                        bottomRight: Radius.circular(size.width * numD04),
                      ),
                      border: Border.all(width: 1.5, color: colorSwitchBack)),
                  padding: EdgeInsets.all(size.width * numD03),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * numD01),
                    child: Image.network(
                      document.get('message'),
                      fit: BoxFit.contain,
                      errorBuilder: (context, strace, object) {
                        return errorImage();
                      },
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  width: size.width / 1.5,
                  padding: EdgeInsets.only(
                    right: size.width * numD02,
                    top: size.width * numD01,
                  ),
                  child: Text(
                    timeParse(document.get('date')),
                    style: TextStyle(
                        fontSize: size.width * numD03,
                        color: colorGoogleButtonBorder,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget commonUploadLoader(String per) {
    return CircularProgressIndicator(
      value: double.parse(per),
      strokeWidth: 4,
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      backgroundColor: colorThemePink,
    );
  }

/*  Widget checkOnlineOffline1(BuildContext context, var size) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('OnlineOffline')
            .doc(widget.receiverId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text(
              "",
              style: TextStyle(
                  fontSize: size.width * numD03,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
            );
          }

          var userDocument = snapshot.data!.data();
          if (userDocument != null) {
            if (userDocument["isOnline"] == true) {
              isOnline = true;
              seeMsg();
            } else {
              isOnline = false;
            }
          } else {
            isOnline = false;
          }
          debugPrint("userDocument : $userDocument");
          return Container(
            margin: EdgeInsets.only(left: size.width * numD035),
            child: Text(
              isOnline == true ? "Online" : "Offline",
              style: TextStyle(
                  fontSize: size.width * numD03,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
            ),
          );
        });
  }*/

  Widget checkOnlineOffline(BuildContext context, var size, String receiverId) {
    debugPrint("receiverId checkOnlineOffline: $receiverId");
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('OnlineOffline')
            .doc(receiverId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text(
              "",
              style: TextStyle(
                  fontSize: size.width * numD03,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
            );
          }

          var userDocument = snapshot.data!.data();

          if (userDocument != null) {
            if (userDocument["isOnline"] == true) {
              isOnline = true;
            } else {
              isOnline = false;
            }
          } else {
            isOnline = false;
          }
          debugPrint("userDocument : $userDocument");
          debugPrint("isOnline : $isOnline");
          return Text(
            isOnline
                ? "Online"
                : lastSeen.isEmpty
                    ? "Offline"
                    : "Last seen at $lastSeen",
            style: TextStyle(
              fontSize: size.width * numD03,
              color: isOnline ? Colors.green : Colors.grey,
            ),
            textAlign: TextAlign.center,
          );
        });
  }

  openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }
  }

  Widget errorImage() {
    return Container(
      alignment: Alignment.center,
      child: Image.asset(
        '${commonImagePath}rabbitLogo.png',
        height: 150.0,
        width: size.width,
      ),
    );
  }

  /* ///Emoji text layout-->
  Widget _buildMessageContent(String content, String type) {
    var size = MediaQuery.of(navigatorKey.currentState!.context).size;
    // final Iterable<Match> matches = REG_EMOJI.allMatches(content);

    if (matches.isEmpty) {
      debugPrint("messageContentBox====> $matches<=====> $type<==== $content");
      return Text(
        content,
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * numD04,
        ),
      );
    }

    return RichText(
        text: TextSpan(children: [
      for (var t in content.characters)
        TextSpan(
            text: t,
            style: TextStyle(
              fontSize: REG_EMOJI.allMatches(t).isNotEmpty
                  ? (Platform.isIOS ? 28.0 : 25.0)
                  : 16.0,
              color: Colors.white,
            )),
    ]));
  }*/

  ///Message reply widgets-->
  Widget replyMessageWidget(Map<String, dynamic> document, String type, size) {
    debugPrint("enterInsideReplyWidget======>$document  $type");
    return Container();
  }

  Widget dateWidget(DocumentSnapshot document, String type, size) {
    return Container(
        padding: const EdgeInsets.only(bottom: 5.0, right: 5.0),
        child: type == "sender"
            ? Wrap(
                alignment: WrapAlignment.end,
                children: [
                  Text(timeParse(document.get('date')),
                      //timeParse(document.get('date')).toString().split('.').first.toString(),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600)),
                  Container(
                    height: 15.0,
                    width: 15.0,
                    margin: const EdgeInsets.only(left: 5),
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      "$chatIconsPath/double_tick_active.png",
                      color: document.get('readStatus') == "unread"
                          ? Colors.white
                          : Colors.blue,
                    ),
                  ),
                ],
              )
            : Wrap(
                alignment: WrapAlignment.start,
                children: [
                  Text(timeParse(document.get('date')),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600)),
                ],
              ));
  }

  /// Initialize Data
  Future<void> _initializeData() async {
    debugPrint('sender Id :$_senderId');
    debugPrint('sender Name :$_senderName');
    debugPrint('Sender Pic :$_senderProfilePic');

    _receiverId = widget.receiverId;
    _receiverName = widget.receiverName.toCapitalized();
    _receiverProfilePic = widget.receiverImage;
    roomId = widget.roomId;
    debugPrint('receive Id :$_receiverId');
    debugPrint('receive Name :$_receiverName');
    debugPrint('receive Pic :$_receiverProfilePic');

    debugPrint("room id Initialize Func: $roomId");

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (roomId.isEmpty) {
        debugPrint(":::::::::Inside Call Get Room Id Api:::::::::::");
        callGetRoomIdApi();
      } else {
        debugPrint(":::::::::Inside Room Id Exist:::::::::::");
        // checkRoomExists(roomId);
        timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
          //   checkOnlineOffline();
          /*   ///Typing Focus
        messageController.addListener(_onTypingFocusChange);
          timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      checkOnlineOffline();

     // checkTyping();
    });

        messageController.addListener(() {
          if (mounted) {
            setState(() {
              if (messageController.text.isNotEmpty) {
                isShowSendButton = true;
                showPredictiveMsg = true;
              } else {
                isShowSendButton = false;
                showPredictiveMsg = false;
              }
            });
          }
        });
*/
          // mytimer = Timer.periodic(const Duration(seconds: 2), (timer) {
          //   debugPrint("runDelay===>");
          //   if (roomId.isNotEmpty) {
          //     messages = FirebaseFirestore.instance
          //         .collection('Chat')
          //         .doc(roomId)
          //         .collection('Messages');
          //
          //     debugPrint("roomId Is====> $roomId");
          //   }
          //   getChatList();
          //   if (mounted) {
          //     setState(() {});
          //   }
          // });
        });
      }
    });

    _showData = true;
  }

  /// **************************

  void commonValues({
    required String messageType,
    required String messageInput,
    required String duration,
    required bool isAudioSelected,
    String thumbnailPath = "",
    int isReply = 0,
  }) {
    debugPrint("::::: Inside Common Values ::::::::::");

    String messageId = DateTime.now().toUtc().millisecondsSinceEpoch.toString();

    Map<String, dynamic> map = {
      'messageId': messageId,
      'senderId': _senderId,
      'senderName': _senderName,
      'senderImage': _senderProfilePic,
      'receiverId': _receiverId,
      'receiverName': _receiverName,
      'receiverImage': _receiverProfilePic,
      'roomId': roomId,
      'replyMessage': "Empty Comming Soon",
      'messageType': messageType,
      'message': messageInput,
      'duration': duration,
      'videoThumbnail': thumbnailPath,
      'date': dateTimeFormatter(
          dateTime: DateTime.now().toString(),
          format: "yyyy-MM-dd HH:mm:ss",
          utc: true),
      'uploadPercent': 0.0,
      'readStatus': "unread",
      'replyType': "text",
      'latitude': 0.0,
      'longitude': 0.0,
      'isReply': isReply,
      'isLocal': 1,
      'isAudioSelected': isAudioSelected
    };

   // sendLocalChat(map);

    map["isLocal"] = 0;

    debugPrint("Map ==== > $map");

    uploadChatNew(map).whenComplete(() {

      callCustomNotificationApi(messageType=="text"?messageInput:messageType);
      debugPrint(":::::: When Complete Upload Chat ::::::: $messageId");
    });
  }

  Future<void> uploadChatNew(Map<String, dynamic> data) async {
    DocumentReference docReference = FirebaseFirestore.instance
        .collection('Chat')
        .doc(roomId)
        .collection('Messages')
        .doc();

    debugPrint("::::: Inside Upload Chat New ::::::::::");

    DocumentReference roomDetails =
        FirebaseFirestore.instance.collection('Chat').doc(roomId);

    debugPrint("::::: Inside Upload Chat1 ::::::::::");
    await docReference.set(data);

    debugPrint("::::: Inside Upload Chat 2 ::::::::::");
    await roomDetails.set(data);
    debugPrint("::::: Inside Upload Chat 3 ::::::::::");
    if (data["messageType"] != "text") {
      debugPrint("::::: Inside Upload Chat 4::::::::::");
      uploadMediaToFirebase(data["message"], data["messageId"], docReference.id,
         data["messageType"], thumbnail: data["videoThumbnail"]);
    }
  }

  /// Upload Media
  Future uploadMediaToFirebase(
      String mediaPath, String messageId, String subCollectionId, String mediaType,
      {String thumbnail = ""}) async {

    debugPrint("::::: Inside Upload Func ::::::::::");
    /// Video thumbnail Upload
    if (thumbnail.isNotEmpty) {
      debugPrint("::::: Inside Upload Thumbnail Func ::::::::::");
      Reference thumbnailStorageReference = FirebaseStorage.instance.ref().child('Media/$thumbnail');
      UploadTask thumbnailUploadTask =
          thumbnailStorageReference.putFile(File(thumbnail));

      thumbnailUploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        debugPrint('Task state---: ${snapshot.state}');
        debugPrint('Progress---: $progress %');
        // updateChatNew("", progress, messageId,subCollectionId);
      }, onError: (e) {
        debugPrint(thumbnailUploadTask.snapshot.toString());
        if (e.code == 'permission-denied') {
          debugPrint(
              'User does not have permission to upload to this reference.');
        }
      });

      await thumbnailUploadTask.then((p0) {
        thumbnailStorageReference.getDownloadURL().then((value) => {
              debugPrint("Uploaded Thumbnail to Firebase value : $value"),
              updateChatNew("", 0.0, messageId, subCollectionId,
                  thumbnail: value),
            });
      });
    }

  /*   if(mediaType == "recording"){
       Reference recordingStorageReference =
       FirebaseStorage.instance.ref().child('recordings/$mediaPath');
       UploadTask recordingUploadTask =
       recordingStorageReference.putFile(File(mediaPath));

       recordingUploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
         var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
         debugPrint('Task state---: ${snapshot.state}');
         debugPrint('Progress---: $progress %');
         // updateChatNew("", progress, messageId,subCollectionId);
       }, onError: (e) {
         debugPrint(recordingUploadTask.snapshot.toString());
         if (e.code == 'permission-denied') {
           debugPrint(
               'User does not have permission to upload to this reference.');
         }
       });

       await recordingUploadTask.then((p0) {
         recordingStorageReference.getDownloadURL().then((value) => {
           debugPrint("Uploaded Recording to Firebase value : $value"),
         updateChatNew("", 0.0, messageId, subCollectionId),
         });
       });
     }*/

    debugPrint("::::: Inside Upload Media Func ::::::::::");
    debugPrint("::::: Inside Upload Media Func ::::::::::");

    Reference storageReference = FirebaseStorage.instance.ref().child('Media/$mediaPath');
    debugPrint('Task file---: $mediaPath');
    debugPrint('Task file---Exist: ${await File(mediaPath).absolute.exists()}');
    UploadTask uploadTask = storageReference.putFile(File(mediaPath));
    debugPrint('uploaded Task---: $mediaPath');
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      debugPrint('Task state---: ${snapshot.state}');
      debugPrint(
          'Progress---: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
      var progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;

      updateChatNew("", 0.0, messageId, subCollectionId);
    }, onError: (e) {
      debugPrint(uploadTask.snapshot.toString());
      if (e.code == 'permission-denied') {
        debugPrint(
            'User does not have permission to upload to this reference.');
      }
    });

    try {
      await uploadTask;
      debugPrint('Upload complete.....');
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    storageReference.getDownloadURL().then((value) => {
          debugPrint("Uploaded Media to Firebase value : $value"),
          updateChatNew(value, 100.0, messageId, subCollectionId),
        });

    debugPrint(":::::: Update Local Chat Database ::::::");
  }

  /// Update AudioValue

  Future<void> updateAudio(String subCollectionId, bool value) async {
    debugPrint("::::: Inside Upload Chat Func ::::::::::");

    CollectionReference? users = FirebaseFirestore.instance.collection('Chat');

    debugPrint("updateAudioValue====> $value");

    users.doc(roomId).collection('Messages').doc(subCollectionId).update({
      'isAudioSelected': value,
    });
  }

  /// UpdateChat
  void updateChatNew(String? message, double? percent, String messageId,
      String subCollectionId,
      {String thumbnail = ""}) {
    debugPrint("::::: Inside Upload Chat Func ::::::::::");

    CollectionReference? users = FirebaseFirestore.instance.collection('Chat');

    debugPrint("uploadPercentage====> $percent");

    if (thumbnail.isNotEmpty) {
      users.doc(roomId).collection('Messages').doc(subCollectionId).update({
        'videoThumbnail': thumbnail,
        'uploadPercent': percent,
      });
    }

    if (percent == 100.0 && message!.isNotEmpty) {
      debugPrint("isPercentage====> $percent");
      users.doc(roomId).collection('Messages').doc(subCollectionId).update({
        'message': message,
        'uploadPercent': percent,
      });
    }

    users.doc(roomId).collection('Messages').doc(subCollectionId).update({
      'uploadPercent': percent,
    });
  }

  ///Typing---->
  void addTyping(int typingValue) {
    if (typingValue > 0) {
      debugPrint("isUserTyping-->");
      DocumentReference docTypingReference = FirebaseFirestore.instance
          .collection('Chat')
          .doc(roomId)
          .collection('Typing')
          .doc(_senderId);

      docTypingReference.set({
        'isTyping': true,
      });
    } else {
      debugPrint("isUser--Not--Typing-->");
      DocumentReference docTypingReference = FirebaseFirestore.instance
          .collection('Chat')
          .doc(roomId)
          .collection('Typing')
          .doc(_senderId);

      docTypingReference.set({
        'isTyping': false,
      });
    }
  }

  /*void checkTyping() {
    if (roomId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('Chat')
          .doc(roomId)
          .collection('Typing')
          .doc(_receiverId)
          .get()
          .then((value) {
        if (mounted) {
          if (value.data() != null) {
            setState(() {
              isTyping = value.get('isTyping');
              debugPrint("isTypingValue-->$isTyping");
            });
          }
        }
      });
    }
  }*/



  ///OnlineOffline-->
  void addOnlineOffline(bool isOnline, String myRoomId) {
    debugPrint("OnLine-->$isOnline");

    FirebaseFirestore.instance.collection('OnlineOffline').get().then((value) {
      debugPrint("OnlineOfflineData-->$value");
      if (value.size == 0 || value.size > 0) {
        debugPrint("InsideAddOnLine--Add-->");

        FirebaseFirestore.instance
            .collection('OnlineOffline')
            .doc(_senderId)
            .set({
          'isOnline': isOnline,
          'last_seen': DateTime.now().toUtc().toLocal(),
          'userName': _senderName,
          'senderImage': _senderProfilePic,
          'roomId': myRoomId,
        });
      } else {
        debugPrint("InsideAddOnLine--Update-->${value.size}");

        FirebaseFirestore.instance
            .collection('OnlineOffline')
            .doc(_senderId)
            .update({
          'isOnline': isOnline,
          'last_seen': DateTime.now().toUtc().toLocal(),
          'userName': _senderName,
          'senderImage': _senderProfilePic,
          'roomId': myRoomId,
        });
      }
    });
  }

  /* void checkOnlineOffline() {
    FirebaseFirestore.instance
        .collection('OnlineOffline')
        .doc(_receiverId)
        .get()
        .then((value) {
      debugPrint("OtherUser--ValueIs-->${value.data()}");
      if (mounted) {
        setState(() {
          if (mounted) {
            if (value.data() != null) {
              isOnline = value.get('isOnline');
              lastSeen = DateFormat('hh:mm a').format(value.get('last_seen').toDate());
              debugPrint("onlineValue-->$isOnline");
              debugPrint("lastSeen---online $lastSeen");
              if (isOnline) {
                seeMsg();
              } else {
                //updateReadStatus('unread');
              }
            }
          }
        });
      }
    });
  }*/

  Future<void> seeMsg() async {
    final query = await FirebaseFirestore.instance
        .collection('Chat')
        .doc(roomId)
        .collection('Messages')
        .where('senderId', isEqualTo: _senderId)
        .where('readStatus', isEqualTo: 'unread')
        .get();

    for (var doc in query.docs) {
      debugPrint("seen--Doc-->$doc");
      doc.reference.update({'readStatus': 'read'});
    }

    seeMyMessageCount(roomId);
  }

  Future<void> seeMyMessageCount(String myRoomId) async {
    debugPrint("roomID--$myRoomId");

    DocumentReference roomDetails =
        FirebaseFirestore.instance.collection('Chat').doc(myRoomId);

    roomDetails.update({
      'readStatus': "read",
      'unReadCount': "0",
    });
  }

  ///  In Use
  _deleteChat(var document) async {
    await FirebaseFirestore.instance
        .collection('Chat')
        .doc(roomId)
        .collection('Messages')
        .doc(document.id)
        .delete()
        .then((value) => debugPrint('Deleted'))
        .catchError((onError) => debugPrint('Error'));
  }

  /// To get Videos From the Gallery
  Future getVideo() async {
    debugPrint("isVideoPicked=====> yes");
    Navigator.pop(navigatorKey.currentState!.context);
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (mounted) {
      var file = File(pickedFile!.path);

      File videoPickedPath = file;
      debugPrint('videoEdited mFile :::::::: ${videoPickedPath.path}');

      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPickedPath.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 300,
        quality: 100,
      );

      commonValues(
        messageType: "video",
        messageInput: videoPickedPath.path,
        thumbnailPath: thumbnail!,
        duration: '',
        isAudioSelected: false,
      );
    }
  }

  /// Get Image
  Future<void> getImage(ImageSource source) async {
    Navigator.pop(context);
    bool cameraValue = await cameraPermission();
    bool storageValue = await storagePermission();

    if (cameraValue && storageValue) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
        debugPrint("image=======> $image");
      if (image != null) {
        commonValues(
          messageType: "image",
          messageInput: image.path,
          duration: '',
          isAudioSelected: false,
        );

       /* if (await isInternetConnected()) {
          callCustomNotificationApi('Image');
        }*/
      }
    } else {
      showSnackBar("Permission Denied", "Permission Denied", Colors.red);
    }
  }

  ///custom
  void callCustomNotificationApi(String type) {
      Map<String, String> map = {
        'sender_id': _senderId,
        'receiver_id': widget.receiverId,
        'title': 'PRESSHOP',
        'body': type == 'text' ? messageController.text : type,
      };
      debugPrint('map: $map');
      NetworkClass.fromNetworkClass(sendPushNotificationAPI, this, reqSendPushNotificationAPI, map)
          .callRequestServiceHeader(false, "post", null);
  }

  /// Get Room Id
  void callGetRoomIdApi() {
    Map<String, String> map = {
      "receiver_id": _receiverId,
      "room_type": "HoppertoAdmin",
    };

    debugPrint("Map : $map");

    NetworkClass.fromNetworkClass(getRoomIdUrl, this, getRoomIdReq, map)
        .callRequestServiceHeader(false, "post", null);
  }

  @override
  void onError({Key? key, required int requestCode, required String response}) {
    switch (requestCode) {
      /// Get Room Id
      case getRoomIdReq:
          var data = jsonDecode(response);
          debugPrint("getRoomIdReq Error : $data");
          break;
      case reqSendPushNotificationAPI:
        var data = jsonDecode(response);
        debugPrint("sendNotification Error : $data");
        break;
    }
  }

  @override
  void onResponse(
      {Key? key, required int requestCode, required String response}) {
    switch (requestCode) {
      /// Get Room Id
      case getRoomIdReq:
          var data = jsonDecode(response);
          debugPrint("getRoomIdReq Success : $data");
          if (data["details"] != null) {
            roomId = data["details"]["room_id"] ?? "";
            debugPrint("Room Id : $roomId");
            _initializeData();
          }
            break;
      case reqSendPushNotificationAPI:
        var data = jsonDecode(response);
        debugPrint("sendNotification success : $data");
        break;
        }
    }
  }


class AttachIconModel {
  String iconName = "";
  String icon = "";

  AttachIconModel({
    required this.icon,
    required this.iconName,
  });
}

Future<bool> isInternetConnected() async {
  bool connected = false;
  if (await InternetConnectionChecker().hasConnection) {
    connected = true;
  }
  debugPrint("isInternetConnectionWorking====> $connected");
  return connected;
}

///time parse with AM-PM -- Utc to Local ---->
String timeParse(String time) {
  debugPrint("Time Before parse Value : $time");

  var utc = DateTime.parse(time).toLocal();

  debugPrint("Time parse Value : ${utc.toUtc().toLocal()}");
  debugPrint("Time parse Value : $utc");

  utc = utc.add(DateTime.parse(time).timeZoneOffset);

  String finalDate = DateFormat('hh:mm a').format(utc).toString();

  return finalDate;
}
