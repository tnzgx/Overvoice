import 'package:flutter/material.dart';
import 'package:overvoice_project/controller/recordButton_controller.dart';
import 'package:overvoice_project/controller/recordButton_controller_duo.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class Record extends StatefulWidget {
  Map<String, dynamic> detailList;
  String character;
  String docID;
  String characterimgURL;

  Record(this.detailList, this.character, this.characterimgURL, this.docID,
      {super.key});

  static int converIndex = 0;

  @override
  State<Record> createState() =>
      _RecordState(detailList, character, characterimgURL, docID);
}

class _RecordState extends State<Record> {
  Map<String, dynamic> detailList;
  String character;
  String characterimgURL;
  String docID;

  _RecordState(
    this.detailList,
    this.character,
    this.characterimgURL,
    this.docID,
  );

  late List conversationList = detailList["conversation"].split(",");
  bool isPlaying = false;
  bool checkButton =
      false; // for check status of button (ว่าปุ่มนี้กำลังกดอยู่หรือไม่ กันกดปุ่มทับกัน)
  List currentConverDuration = []; // list of conversation duration
  int timeTotal = 0;
  int checkTime = 0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  AudioPlayer audioPlayer = AudioPlayer();
  AudioPlayer audioPlayerBGM = AudioPlayer();

  PlayerState playerState = PlayerState.stopped;
  bool isStarted = false;

  late String currentText = conversationList[0];
  late List displayConversationText = [];

  @override
  void initState() {
    super.initState();

    // Listen to states: playing, paused, stopped
    audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      //print('Current player state: $s');
      if (!mounted) return;
      setState(() => playerState = s);
    });

    // Listen to audio duration
    audioPlayer.onDurationChanged.listen((Duration d) {
      //print('Max duration: $d');
      if (!mounted) return;
      setState(() => duration = d);
    });

    // Listen to audio position
    audioPlayer.onPositionChanged.listen((Duration p) {
      if (!mounted) return;
      setState(() => position = p);
      if (p.inSeconds >= this.timeTotal) {
        pause();
        audioPlayer.seek(Duration(
            seconds:
                timeTotal - int.parse(this.currentConverDuration[checkTime])));
      }
    });

    audioPlayer.onPlayerComplete.listen((event) {
      isPlaying = false;
      if (!mounted) return;
      setState(() {
        position = duration;
      });
    });
  }

  @override
  void dispose() {
    Record.converIndex = 0;
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          detailList["name"],
          style: GoogleFonts.prompt(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFF7200),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: screenHeight / 30, left: 20, right: 20),
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFFF7200),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 52,
              backgroundColor: Colors.white,
              child: Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(characterimgURL),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight / 80,
            ),
            Text(
              character,
              textAlign: TextAlign.center,
              style: GoogleFonts.prompt(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            SizedBox(
              height: screenHeight / 40,
            ),
            Stack(
              children: <Widget>[
                Container(
                  height: screenHeight / 2.1, // กรอบบท
                  width: double.infinity,
                  padding: EdgeInsets.only(
                      top: screenHeight / 44.5, left: 26, right: 26),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "บทที่ต้องทำการพากย์",
                          style: GoogleFonts.prompt(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight / 49,
                      ),
                    ],
                  ),
                ),
                Positioned(
                    top: screenHeight / 15,
                    left: screenWidth / 43,
                    height: screenHeight / 2.52,
                    width: screenWidth / 1.17, // บท
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xFFFFD4B2),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10))),
                      child: displayConversation(detailList),
                      //ConversationController(conversationList),
                    ))
              ],
            ),
            SizedBox(
              height: screenHeight / 30,
            ),
            // record button all-function here

            checkAudioType(),

            SizedBox(
              height: screenHeight / 50,
            ),
            SizedBox(
              width: screenWidth / 1.4,
              height: screenHeight / 20,
              child: TextButton(
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    backgroundColor: Color(0xFFFF9900),
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.prompt(
                        fontSize: 19, fontWeight: FontWeight.w600)),
                onPressed: () async {
                  // condition for check button (ถ้าปุ่มถูกกดอยู่จะ return)
                  if (checkButton == true) {
                    return;
                  }
                  if (isPlaying == false) {
                    play();
                  } else {
                    isPlaying = false;
                    pause();
                  }
                },
                child: const Text('ตัวช่วยสำหรับการพากย์'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future play() async {
    audioPlayer.resume();
    audioPlayerBGM.resume();
  }

  Future pause() async {
    await audioPlayer.pause();
    await audioPlayerBGM.pause();
    isPlaying = false;
  }

  Widget checkAudioType() {
    if (detailList["voiceoverAmount"] == "1") {
      return RecordButton(conversationList, docID, (a) => {setup(a)},
          (status) => {checkStatus(status)},
          converIndexSetter: _converIndexSetter);
    } else {
      return RecordButtonDuo(conversationList, docID, character,
          (a) => {setup(a)}, (status) => {checkStatus(status)},
          converIndexSetter: _converIndexSetter);
    }
  }

  Future checkStatus(bool status) async {
    if (status == true) {
      checkButton = true;
    } else {
      print("Status is checked");
      await audioPlayer.seek(Duration(seconds: timeTotal));
      position = Duration(seconds: timeTotal);

      if (checkTime < this.currentConverDuration.length - 1) {
        checkTime++;
      }

      if (checkTime < this.currentConverDuration.length) {
        timeTotal += int.parse(this.currentConverDuration[checkTime]);
        print(
            "checktime: ${this.checkTime}, timetotal: ${this.timeTotal}, timelength: ${this.currentConverDuration.length}, position: ${this.position}");
      }

      checkButton = false;
    }
  }

  Future setup(List times) async {
    this.currentConverDuration = times;
    if (timeTotal == 0) {
      timeTotal = int.parse(this.currentConverDuration[0]);
      final storageRef = await FirebaseStorage.instance.ref();
      final soundRefAssist = await storageRef
          .child(detailList["assistanceVoiceName"]); // <-- your file name
      final soundRefBGM =
          await storageRef.child(detailList["bgmName"]); // <-- your file name
      final metaDataAssist = await soundRefAssist.getDownloadURL();
      final metaDataBGM = await soundRefBGM.getDownloadURL();
      log('data: ${metaDataAssist.toString()}');
      log('data: ${metaDataBGM.toString()}');
      String urlAssist = metaDataAssist.toString();
      String urlBGM = metaDataBGM.toString();
      // await audioPlayerA.setSourceUrl(urlA);
      await audioPlayerBGM.setSourceUrl(urlBGM);
      await audioPlayer.setSourceUrl(urlAssist);
      print("Already Set!");
    }
  }

  Widget displayConversation(Map<String, dynamic> detailList) {
    if (isStarted == false) {
      int i;
      String fullConversation = "";
      for (i = 0; i < conversationList.length; i++) {
        final conversationWithDetail;
        if (detailList["voiceoverAmount"] == "1") {
          conversationWithDetail =
              conversationList[i].replaceAllMapped(RegExp(r'\((.*?)\)'), (m) {
            return '(มีเวลาพากย์ ${m[1]} วินาที)';
          });
        } else {
          conversationWithDetail =
              conversationList[i].replaceAllMapped(RegExp(r'\((.*?)\:'), (m) {
            return '(มีเวลาพากย์ ${m[1]} วินาที:';
          });
        }
        displayConversationText.add(conversationWithDetail);
        fullConversation +=
            "ประโยคที่ ${i + 1} " + conversationWithDetail + "\n\n";
      }
      currentText = fullConversation;
    }
    return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) => ListTile(
              title: Text(
                currentText,
                style: GoogleFonts.prompt(
                    fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ));
  }

  // use for change conversation text
  void _converIndexSetter(int converIndex) {
    isStarted = true;
    currentText = displayConversationText[converIndex];
    setState(() {});
  }
}
