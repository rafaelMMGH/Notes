import 'dart:async';
import 'package:notes/Model/Note.dart';
import 'package:notes/Database/DBHelper.dart';
import 'package:notes/Screens/card_details.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/CardItemModel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new  MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{

  DBHelper dbHelper = DBHelper();
  List<Note> noteList;
  int count = 0;

  String account,description,getCount;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  var appColors = [ Color.fromRGBO(153,184,152, 1.0),
                    Color.fromRGBO(255,132,124, 1.0),
                    Color.fromRGBO(170, 68, 101, 1.0),
                    Color.fromRGBO(187, 68, 48, 1.0),
                    Color.fromRGBO(232,74,95, 1.0),
                    Color.fromRGBO(58, 79, 65, 1.0),
                    Color.fromRGBO(42,54,59, 1.0),
                    Color.fromRGBO(254,206,171, 1.0),
                    Color.fromRGBO(255,132,124, 1.0),
                    Color.fromRGBO(170, 68, 101, 1.0),
                    Color.fromRGBO(187, 68, 48, 1.0),
                    Color.fromRGBO(232,74,95, 1.0),
                    Color.fromRGBO(58, 79, 65, 1.0),
                    Color.fromRGBO(42,54,59, 1.0)
                  ];
  var cardIndex = 0;
  ScrollController scrollController;
  var currentColor = Color.fromRGBO(153,184,152, 1.0);

  AnimationController animationController;
  ColorTween colorTween;
  CurvedAnimation curvedAnimation;

  var currentTime = new DateFormat('MMMM dd, yyyy').format(new DateTime.now()).toString().toUpperCase();


  @override
  void initState() {
    super.initState();
    scrollController = new ScrollController();
  }

  @override
  Widget build(BuildContext context) {

    if(noteList == null) {
      noteList = List<Note>();
      updateListView();
    }
    return new Scaffold(
      key: scaffoldKey,
      backgroundColor: currentColor,
      appBar: new AppBar(
        title: new Text("Notes",style: TextStyle(fontSize: 20.0),),
        automaticallyImplyLeading: false,
        leading: null,
        backgroundColor: appColors[cardIndex],
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: (){
              openCard(Note('','',''),"Add card",Colors.blueAccent);
            },
            tooltip: 'Add card',
            disabledColor: Colors.grey,),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: (){
            //  searchCard();
            },
            tooltip: 'Search card',
            disabledColor: Colors.grey,),
        ],
        elevation: 0.0,

      ),
      body: new Center(
        child:   new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 14.0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7.0),
                      child: Icon(Icons.account_circle,size:45.0, color: Colors.white,),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 14.0),
                      child: new Text("Hello, Username", style: TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.w400),),
                    ),
                    Text("You have $count ${count > 1 ? 'cards' : 'card' }", style: TextStyle(color: Colors.white),),
                    Text("Looks like feel good", style: TextStyle(color: Colors.white),)
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0,vertical: 10.0),
                  child: new Text("TODAY: $currentTime",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontStyle: FontStyle.italic),),
                ),
                Container(
                  height: 350.0,
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: count,
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context,int position){
                        return GestureDetector(
                          child: Padding(padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: Container(
                                width: 250.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            Icons.payment,
                                            color: appColors[position],
                                          ),
                                          new Container(
                                            width: 111.0,
                                          ),
                                          IconButton(
                                              icon: Icon(Icons.visibility),
                                              color: Colors.black54,
                                              onPressed: (){
                                            openCard(this.noteList[position],"Edit card",appColors[cardIndex]);
                                          }),
                                          IconButton(
                                            icon: Icon(Icons.delete_outline),
                                            color: Colors.black54,
                                            onPressed: (){
                                              _delete(context, noteList[position]);
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical:4.0),
                                            child: new Row(
                                              mainAxisAlignment:  MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(this.noteList[position].account, style: TextStyle(fontSize: 28.0),),
                                              ],
                                            )
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical:2.0),
                                            child: new Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(this.noteList[position].description, style: TextStyle(fontSize: 18.0),),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 4.0),
                                            child: Text(this.noteList[position].date,style: TextStyle(fontSize: 14.0,fontStyle: FontStyle.italic,color: Colors.grey),),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: LinearProgressIndicator(value: (1.0*count)/(position+1),),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)
                              ),
                            ),
                          ),
                          onTapUp: (details){},
                          onHorizontalDragEnd: (details){

                            animationController = AnimationController(vsync: this,duration: Duration(milliseconds: 500));
                            curvedAnimation = CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn);
                            animationController.addListener((){
                              setState(() {
                                currentColor = colorTween.evaluate(curvedAnimation);
                              });
                            });

                            if(details.velocity.pixelsPerSecond.dx > 0){
                              if(cardIndex > 0){
                                cardIndex--;
                                colorTween = ColorTween(begin: currentColor,end: appColors[cardIndex]);
                              }
                            }else{
                              if(cardIndex < count){
                                cardIndex++;
                                colorTween = ColorTween(begin: currentColor,end: appColors[cardIndex]);
                              }
                            }

                            setState(() {
                              scrollController.animateTo((cardIndex)*256.0 + cardIndex*14 , duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
                            });

                            colorTween.animate(curvedAnimation);
                            animationController.forward();

                          },
                        );
                      }),
                )
              ],
            )
          ],
        ),
      ),
        drawer: Drawer(),

    );
  }

  void _delete(BuildContext context, Note note) async{
    int result = await dbHelper.removeNote(note.id);

    if(result != 0) {
      _showAlert('Deleted', 'Card Deleted Successfully');
      updateListView();
    }
  }

  void _showAlert(String title, String message){
    showDialog(
        context: context,
        builder: (BuildContext context ){
          return AlertDialog(
            title: new Text(title),
            content: new Text(message),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void openCard(Note note ,String title, Color color) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context){
      return CardDetail(note,title, color);
    }));

    if(result)
      updateListView();
  }

  void updateListView(){

    final Future<Database> dbFuture = dbHelper.initDB();
    dbFuture.then((database) {

      Future< List<Note>> noteListFuture = dbHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

}
