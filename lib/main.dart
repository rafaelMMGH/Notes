import 'dart:async';
import 'package:flutter/services.dart';
import 'package:notes/Model/Note.dart';
import 'package:notes/Database/DBHelper.dart';
import 'package:notes/Screens/card_details.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  _MyHomePageState();

  DBHelper dbHelper = DBHelper();
  List<Note> noteList;
  int count = 0;

  String account, description, getCount;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  ScrollController scrollController;

  static var appColors = [
    Color.fromRGBO(255,255,255, 1.0), // New
    Color.fromRGBO(41,194,103,1.0), // Edit
    Color.fromRGBO(2,227,160,1.0), // Title
    Color.fromRGBO(106,131,184,1.0), // Icons Card
    Color.fromRGBO(249,249,249,1.0), // New Background Color App
    Color.fromRGBO(240, 247, 255, 1.0) // Old Background Color

  ];

  @override
  void initState() {
    super.initState();
    scrollController = new ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    assert(debugCheckHasMediaQuery(context));

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double aspectRatio = MediaQuery.of(context).devicePixelRatio;

    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: appColors[4],
        body: new RefreshIndicator(onRefresh:_handleRefresh, child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: new GestureDetector(
                child: Text(
                  " ${count > 0 ? count == 1 ? '$count note' :'$count notes' : 'No notes'}",
                ),
                onDoubleTap: (){
                  _showAbout();
                },
              ),
              floating: false,
              pinned: true,
              expandedHeight: 2 * (height / 7),
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  'https://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-655987.png',
                  fit: BoxFit.cover,
                ),
                collapseMode: CollapseMode.parallax,
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: () {
                    openCard(Note('', '', ''), "Add card", appColors[0]);
                  },
                  tooltip: 'Add card',
                  disabledColor: Colors.grey,
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    //  searchCard();
                  },
                  tooltip: 'Search card',
                  disabledColor: Colors.grey,
                ),
              ],
            ),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.0,
                  mainAxisSpacing: 3.0,
                  childAspectRatio: (aspectRatio/2.4)
              ),
              delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
                return new Container(
                  padding: const EdgeInsets.all(0.0),
                  child: new SizedBox(
                    child: new InkWell(
                      onTap: (){
                        openCard(this.noteList[index], "Edit card", appColors[1]);
                      },
                      onLongPress: (){
                        _delete(context, noteList[index]);
                      },
                      child: new Card(
                        color:  Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9.0)
                        ),
                        child: new Column(
                          children: <Widget>[
                            new Center(
                                child: new Column(
                                  children: <Widget>[
                                    new Container(
                                      child: new IconButton(
                                        icon: Icon(Icons.account_balance_wallet),
                                        onPressed: null,
                                        disabledColor: appColors[2],
                                        iconSize: width/8,
                                      ),
                                    ),
                                    new Divider( color: appColors[2], indent: 3,),
                                    new Column(
                                      children: <Widget>[
                                        new Padding(padding: new EdgeInsets.symmetric(vertical: 7)),

                                        new Hero(
                                          tag: 'title-${this.noteList[index].id}',
                                          child: new Column(
                                            children: <Widget>[

                                              TextField(
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                    enabled: false,
                                                    border: InputBorder.none,
                                                    hintText: this.noteList[index].account,
                                                    contentPadding: new EdgeInsets.all(0.0),
                                                    hintStyle: TextStyle(
                                                      color: Colors.black,
                                                    )
                                                ),
                                              ),

                                              new Padding(padding: new EdgeInsets.symmetric(vertical: 9)),

                                              TextField(
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                decoration: InputDecoration(
                                                    enabled: false,
                                                    border: InputBorder.none,
                                                    hintText: this.noteList[index].description,
                                                    contentPadding: new EdgeInsets.all(0.0),
                                                    hintStyle: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                    )
                                                ),
                                              ),


                                            ],
                                          ),
                                        ),

                                      ],
                                    ),
                                  ],
                                )
                            ),
                            new Padding(padding: new EdgeInsets.symmetric(vertical: 11)),
                            new Row(
                              children: <Widget>[
                                new Container(width: width/5,),
                                new Text(this.noteList[index].date, style: TextStyle(fontStyle: FontStyle.italic,color: appColors[3]),maxLines: 1,textAlign: TextAlign.end,),
                              ],
                              mainAxisAlignment: MainAxisAlignment.start,
                              verticalDirection: VerticalDirection.down,

                            )

                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }, childCount: count),
            ),
          ],
        ),),
      ),
    );
  }

  void _delete(BuildContext context, Note note) async {
    int result = await dbHelper.removeNote(note.id);

    if (result != 0) {
      _showAlert('Deleted', 'Card Deleted Successfully');
      updateListView();
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
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

  void _showAbout(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.0)
            ),
            title: new Text('About',textAlign: TextAlign.center,),
            content: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Text(' App created with ❤ and flutter.', textAlign: TextAlign.justify,),
                new Divider(),
                new ListTile(
                  contentPadding: new EdgeInsets.all(0.0),
                  leading: new Icon(Icons.account_circle,),
                  title: new Text('Rafael Alberto Martínez Méndez'),
                ),
                new ListTile(
                  contentPadding: new EdgeInsets.all(0.0),
                  leading: new Icon(Icons.mail_outline,color: Colors.blueAccent,),
                  title: new Text('send me a mail'),
                  onTap: (){
                    debugPrint('send to me');
                  },
                ),
                new ListTile(
                  contentPadding: new EdgeInsets.all(0.0),
                  leading: new Icon(Icons.group_work,color: Colors.blueAccent,),
                  title: new Text("Github"),
                  onTap: (){
                    debugPrint('send to me');
                  },
                ),
              ],
            )
          );
        });
  }

  void openCard(Note note, String title, Color color) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CardDetail(note, title, color);
    }));

    if (result) updateListView();
  }

  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDB();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = dbHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  Future<Null> _handleRefresh() async{
    setState(() {
      updateListView();
    });
  }
}

