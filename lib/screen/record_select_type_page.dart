import 'package:flutter/material.dart';
import 'package:overvoice_project/screen/record_duo_page.dart';
import 'package:overvoice_project/screen/record_select_character_page.dart';

import '../controller/recordButton_controller_duo_coop.dart';

class Start extends StatefulWidget {
  Map<String, dynamic> detaillMap;
  String docID;
  Start(this.detaillMap, this.docID, {super.key});

  @override
  State<Start> createState() => _StartState(detaillMap, docID);
}

class _StartState extends State<Start> {
  Map<String, dynamic> detaillMap;
  String docID;
  _StartState(this.detaillMap, this.docID);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          detaillMap["name"],
          style: TextStyle(fontWeight: FontWeight.bold),
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
        padding: EdgeInsets.only(top: 40, left: 40, right: 40),
        height: screenHeight / 1.6,
        width: double.infinity,
        child: Container(
            child: Column(children: <Widget>[
          SizedBox(
            height: screenHeight / 8.9,
          ),
          Container(
            child: Text(
              "เลือกรูปแบบการพากย์ของคุณ",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ),
          SizedBox(
            height: screenHeight / 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Column(children: [
                  RawMaterialButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => (Solo(detaillMap, docID))));
                    },
                    elevation: 2.0,
                    fillColor: Color(0xFFFF7200),
                    child: Icon(Icons.person, size: 74.0, color: Colors.white),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
                  SizedBox(
                    height: screenHeight / 48,
                  ),
                  SizedBox(
                    width: screenWidth / 3.4,
                    height: screenHeight / 20.5,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: Color(0xFFFF7200),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    (Solo(detaillMap, docID))));
                      },
                      child: const Text('พากย์เดี่ยว'),
                    ),
                  )
                ]),
              ),
              SizedBox(
                width: screenWidth / 10,
              ),
              Container(
                child: Column(children: [
                  RawMaterialButton(
                    onPressed: () {},
                    elevation: 2.0,
                    fillColor: Color(0xFFFF7200),
                    child: Icon(Icons.people, size: 74.0, color: Colors.white),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
                  SizedBox(
                    height: screenHeight / 48,
                  ),
                  SizedBox(
                    width: screenWidth / 3.4,
                    height: screenHeight / 20.5,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: Color(0xFFFF7200),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => (RecordDuo())));
                      },
                      child: const Text('พากย์คู่'),
                    ),
                  )
                ]),
              )
            ],
          )
        ])),
      ),
    );
  }
}
