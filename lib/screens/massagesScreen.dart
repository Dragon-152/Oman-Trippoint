import 'package:flutter/material.dart';
import 'package:oman_trippoint/constants/constants.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/chatProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/chatSchema.dart';
import 'package:oman_trippoint/schemas/massageSchema.dart';
import 'package:oman_trippoint/schemas/userSchema.dart';
import 'package:oman_trippoint/screens/activityDetailsScreen.dart';
import 'package:oman_trippoint/widgets/LinkWidget.dart';
import 'package:oman_trippoint/widgets/activitySelectedMessageBox.dart';
import 'package:oman_trippoint/widgets/massageBoxWidget.dart';
import 'package:oman_trippoint/widgets/profileAvatarWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart' ;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:easy_localization/easy_localization.dart' as localized;

class MassagesScreen extends StatefulWidget {
  static String router = "/massages_screen";
  const MassagesScreen({Key? key}) : super(key: key);

  @override
  State<MassagesScreen> createState() => _MassagesScreenState();
}

class _MassagesScreenState extends State<MassagesScreen> {
  final store = FirebaseFirestore.instance;
  String? massage;
  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();
  ItemScrollController _scrollController = ItemScrollController();
  final ImagePicker _picker = ImagePicker();
  List<int> massegesDateIndex = [];

  List<String> _uploadedImagesPath = [];

  Future sendMassage(BuildContext context) async {
    ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);

    bool validate = formKey.currentState!.validate();
    if (validate) {
      formKey.currentState!.save();
      if (massage != "") {
        await chatProvider.sendMassage(context: context, text: massage!);
      }
    }
  }

  List scrollTo(int index) {
    Future.delayed(Duration.zero, () {
      _scrollController.scrollTo(
          index: index, duration: const Duration(milliseconds: 100));
    });
    // }
    //   if (_scrollController.isAttached) {
    // Future.delayed(Duration(seconds: 4), () {
    //   scrollTo(index);
    // });
    //   }

    return [];
  }

  Future fetchUserAndActivityData({
    required String userId,
    required String activityId,
  }) async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    ActivityProvider activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);
    await userProvider.fetchUserData(userId: userId);
    await activityProvider.fetchActivityWStore(activityId);
  }

  Future _uploadImages() async {
    ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      _uploadedImagesPath.addAll(images.map((e) => e.path));

      _uploadedImagesPath.forEach((e) async {
        await chatProvider.sendImageMessage(context: context, imagePath: e);
      });
    }
  }

  void _sortMessages(BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    ChatProvider chatProvider = Provider.of(context, listen: false);

    chatProvider.readMessages(context: context);
    String previousVarCreatedAtDay = "";

    docs.asMap().forEach((i, m) {
      String createdAtDay = intl.DateFormat('dd/MM/yyyy')
          .format(DateTime.fromMillisecondsSinceEpoch(m.data()["createdAt"]));

      // print(createdAt);
      if (createdAtDay != previousVarCreatedAtDay) {
        previousVarCreatedAtDay = createdAtDay;
        massegesDateIndex.add(i);
      }
    });
  }

  Future<bool> deleteChat(String chatId, String chatStoreId) async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    bool done = await chatProvider.deleteChatOneSide(
        context: context, chatId: chatId, chatStoreId: chatStoreId);

    return done;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as ChatSchema;
    UserProvider userProvider = Provider.of<UserProvider>(context);
    ChatProvider chatProvider = Provider.of<ChatProvider>(context);
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);

    args.users.remove(userProvider.credentialUser?.uid);
    String userId = args.users[0];
    String activityId = args.activityId;
    UserSchema user = userProvider.users[userId]!;

    return FutureBuilder(
        future:
            fetchUserAndActivityData(userId: userId, activityId: activityId),
        builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              activityProvider.activities[activityId] == null ||
              userProvider.users[userId] == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (userProvider.users[userId] == null) {
            Navigator.pop(context);
          }

          return StreamBuilder(
              stream: store
                  .collection(ChatProvider.collection)
                  .doc(args.storeId)
                  .collection(CollectionsConstants.massages)
                  .orderBy("createdAt")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.hasData == false ||
                    snapshot.data == null) {
                  return const SizedBox();
                }

                _sortMessages(context, snapshot.data!.docs);
                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ProfileAvatarWidget(
                            profileColor: user.profileColor,
                            profileImagePath: user.profileImagePath,
                            size: 18,
                          ),
                        ),
                        Text(
                          user.name.toString().length > 19
                              ? user.name.toString().substring(0, 18) + "..."
                              : user.name.toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    leading: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              chatProvider.sortChats();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back_rounded)),
                      ],
                    ),
                    actions: [
                      DropdownButton(
                        // Initial Value
                        //   value: dropdownvalue,

                        // Down Arrow Icon
                        icon: const Icon(Icons.keyboard_arrow_down),

                        // Array list of items
                        //   items: items.map((String items) {
                        //     return DropdownMenuItem(
                        //       value: items,
                        //       child: Text(items),
                        //     );
                        //   }).toList(),
                        items: [
                          DropdownMenuItem(
                              value: 1,
                              onTap: () {},
                              child: InkWell(
                                onTap: () {
                                  print("open");
                                  showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SimpleDialog(
                                        title: const Text(''),
                                        children: <Widget>[
                                          SimpleDialogOption(
                                            onPressed: () async {
                                              EasyLoading.show();
                                              try {
                                                bool done = await deleteChat(
                                                    args.Id, args.storeId!);
                                                chatProvider.sortChats();
                                                if (done == false) {
                                                  throw 99;
                                                }
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              } catch (err) {
                                                EasyLoading.showError(
                                                    AppHelper.returnText(
                                                        context,
                                                        "Something wrong",
                                                        "حدث خطأ ما"));
                                              }
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500),
                                                  () {});
                                              EasyLoading.dismiss();
                                            },
                                            child: Text(AppHelper.returnText(
                                                context,
                                                "Delete Chat",
                                                "حذف المحادثة")),
                                          ),
                                          SimpleDialogOption(
                                            onPressed: () {},
                                            //   child: const Text('Option 2'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Text(AppHelper.returnText(
                                          context, "Delete", "حذف ")),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      const Icon(Icons.delete_rounded)
                                    ],
                                  ),
                                ),
                              ))
                        ],
                        // After selecting the desired option,it will
                        // change button value to selected value
                        onChanged: (newValue) {
                          print("0");
                          // setState(() {
                          //   dropdownvalue = newValue!;
                          // });
                        },
                      ),
                    ],
                  ),
                  body: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                            decoration: const BoxDecoration(
                                // border:
                                // Border.all(color: Colors.black45, width: 1),
                                // borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 6,
                                    color: Color(0x33000000),
                                    offset: Offset(1, 2),
                                  )
                                ]
                                // color: Colors.white,
                                ),
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                onTap: () {
                                  if (activityProvider.activities[activityId] !=
                                      null) {
                                    Navigator.pushNamed(
                                        context, ActivityDetailsScreen.router,
                                        arguments: activityProvider
                                            .activities[activityId]);
                                  }
                                },
                                leading: Container(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: 100,
                                  height: 100,
                                  child: activityProvider
                                              .activities[activityId] !=
                                          null
                                      ? Image.network(
                                          activityProvider.mainDisplayImage(
                                              activityProvider
                                                      .activities[activityId]
                                                      ?.images ??
                                                  []),
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.delete_forever_sharp,
                                          size: 50,
                                          color: Colors.grey[800],
                                        ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activityProvider
                                              .activities[activityId]?.title ??
                                          "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      activityProvider.activities[activityId]
                                              ?.category ??
                                          "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(color: Colors.grey[600]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        Expanded(
                            child: ScrollablePositionedList.builder(
                          // !!!!!!!!!!!! PROBLEM !!!!!!!!!!!!!!!!

                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          itemScrollController: _scrollController,
                          itemCount: snapshot.data!.docs.length,
                          initialScrollIndex: snapshot.data!.docs.length - 1 < 0
                              ? snapshot.data!.docs.length - 1
                              : 0,
                          itemBuilder: (context, index) {
                            QueryDocumentSnapshot<Map<String, dynamic>>
                                massageData = snapshot.data!.docs[index];
                            MassageSchema massage = MassageSchema(
                              type: massageData.data()["type"],
                              Id: massageData.data()["Id"],
                              url: massageData.data()["url"],
                              audioPath: massageData.data()["audioPath"],
                              imagePath: massageData.data()["imagePath"],
                              from: massageData.data()["from"],
                              massage: massageData.data()["massage"],
                              createdAt: massageData.data()["createdAt"],
                              readedAt: massageData.data()["readedAt"],
                              chatId: massageData.data()["chatId"],
                            );

                            if (massegesDateIndex.contains(index)) {
                              if (massage.type == "activity") {
                                return Column(
                                  children: [
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: ColorsHelper.yellow
                                                  .withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          padding: EdgeInsets.all(9),
                                          child: Text(
                                            intl.DateFormat('dd/MM/yyyy').format(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        massage.createdAt)),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(fontSize: 11),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ActivitySelectedMessageBox(
                                      date: massage.createdAt,
                                      text: massage.massage!,
                                      url: massage.url,
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                // !!!!!!!!!!!! PROBLEM !!!!!!!!!!!!!!!!
                                key: Key(massageData.id),
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: ColorsHelper.yellow
                                                .withOpacity(0.4),
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        padding: EdgeInsets.all(9),
                                        child: Text(
                                          intl.DateFormat('dd/MM/yyyy').format(
                                              DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      massage.createdAt)),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(fontSize: 11),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  MassageBoxWidget(massage: massage)
                                ],
                              );
                            }

                            if (massage.type == "activity") {
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  ActivitySelectedMessageBox(
                                    date: massage.createdAt,
                                    text: massage.massage!,
                                    url: massage.url,
                                  ),
                                ],
                              );
                            }

                            return MassageBoxWidget(
                                key: Key(massageData.id), massage: massage);
                          },
                        )),
                        ...scrollTo(snapshot.data!.docs.length - 1),
                        Form(
                            key: formKey,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 80,
                                    child: SizedBox.expand(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextFormField(
                                            // maxLength: 2000,
                                                  textDirection: context.locale.languageCode == "ar" ? TextDirection.rtl :  TextDirection.ltr,

                                            textInputAction:
                                                TextInputAction.newline,
                                            scrollPadding:
                                                const EdgeInsets.all(10),
                                            controller: textController,
                                            maxLines: 2,
                                            minLines: 1,
                                            validator: (v) {
                                              if (v != null) {
                                                if (v.trim().length > 2000) {
                                                  return "";
                                                }
                                              }
                                            },
                                            onSaved: (t) {
                                              // setState(() {
                                              if (t?.trim() != "") {
                                                massage = t?.trim();
                                              }
                                              textController.text = "";
                                              // });
                                            },
                                            keyboardType:
                                                TextInputType.multiline,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  top: 10,
                                                  bottom: 10,
                                                  right: context.locale
                                                              .languageCode ==
                                                          "en"
                                                      ? 100
                                                      : 8,
                                                  left: context.locale
                                                              .languageCode ==
                                                          "en"
                                                      ? 8
                                                      : 100),

                                              hintText: AppHelper.returnText(
                                                  context,
                                                  " Message ...",
                                                  " رسالة ..."),
                                              filled: true,
                                              fillColor: ColorsHelper.whiteBlue,
                                              //   prefixIcon: Icon(
                                              //     Icons.person,
                                              //   ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(16)),
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(16)),
                                              ),
                                              border: const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(16)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: context.locale.languageCode == "ar"
                                        ? null
                                        : 0.5,
                                    left: context.locale.languageCode == "ar"
                                        ? 0.5
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 45,

                                            // margin: const EdgeInsets.symmetric(
                                            //     horizontal: 5),
                                            decoration: BoxDecoration(
                                              color: ColorsHelper.grey,
                                              borderRadius: BorderRadius.only(
                                                topLeft: context.locale
                                                            .languageCode ==
                                                        "ar"
                                                    ? Radius.circular(0)
                                                    : Radius.circular(16),
                                                topRight: context.locale
                                                            .languageCode ==
                                                        "ar"
                                                    ? Radius.circular(16)
                                                    : Radius.circular(0),
                                                bottomLeft: context.locale
                                                            .languageCode ==
                                                        "ar"
                                                    ? Radius.circular(0)
                                                    : Radius.circular(16),
                                                bottomRight: context.locale
                                                            .languageCode ==
                                                        "ar"
                                                    ? Radius.circular(16)
                                                    : Radius.circular(0),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                // IconButton(
                                                //     onPressed: () async {
                                                //       // _scrollController.scrollTo(index: snapshot.data!.docs.length-1, duration: Duration(seconds: 1));
                                                //     },
                                                //     icon: const Icon(
                                                //       Icons
                                                //           .keyboard_voice_rounded,
                                                //       size: 18,
                                                //     )),
                                                IconButton(
                                                    onPressed: () async {
                                                      await _uploadImages();
                                                      //   _scrollController.scrollTo(index: snapshot.data!.docs.length-1, duration: Duration(seconds: 1));
                                                    },
                                                    icon: const Icon(
                                                      Icons.camera_alt_rounded,
                                                      size: 18,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 45,

                                            // margin:
                                            //     const EdgeInsets.only(right: 5),
                                            decoration: BoxDecoration(
                                                color: ColorsHelper.yellow,
                                                borderRadius: BorderRadius.only(
                                                  topRight: context.locale
                                                              .languageCode ==
                                                          "ar"
                                                      ? Radius.circular(0)
                                                      : Radius.circular(16),
                                                  topLeft: context.locale
                                                              .languageCode ==
                                                          "ar"
                                                      ? Radius.circular(16)
                                                      : Radius.circular(0),
                                                  bottomRight: context.locale
                                                              .languageCode ==
                                                          "ar"
                                                      ? Radius.circular(0)
                                                      : Radius.circular(16),
                                                  bottomLeft: context.locale
                                                              .languageCode ==
                                                          "ar"
                                                      ? Radius.circular(16)
                                                      : Radius.circular(0),
                                                )),
                                            child: IconButton(
                                                onPressed: () async {
                                                  await sendMassage(context);
                                                  //   await _scrollController.scrollTo(index: snapshot.data!.docs.length-1, duration: Duration(seconds: 1));
                                                },
                                                icon: const Icon(
                                                  Icons.send,
                                                  size: 18,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ))
                      ],
                    ),
                  ),
                );
              });
        });
  }
}
