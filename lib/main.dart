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
        hintColor: Colors.transparent
      ),
      home: MyHomePage(),
    );
  }

}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  _MyHomePageState();

  DBHelper dbHelper = DBHelper();
  List<Note> noteList;
  int count = 0;

  String account, description, getCount;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
 // final formKey = new GlobalKey<FormState>();

  ScrollController scrollController;
  AnimationController _iconAnimationController;
  Animation<double> _iconAnimation;

  static var appColors = [
    Colors.grey[100], // New Card
    Colors.grey[200], // Edit Card
    Color.fromRGBO(62,152,52,1.0), // Icon
    Color.fromRGBO(106,131,184,1.0), // Date
    Color.fromRGBO(249,249,249,1.0), // New Background Color App
    Color.fromRGBO(240, 247, 255, 1.0), // Old Background Color
    Color.fromRGBO(28,139,253,1.0)
  ];

  @override
  void initState() {
    super.initState();

    scrollController = new ScrollController();

    _iconAnimationController = new AnimationController(vsync: this,duration: new Duration(milliseconds: 380));
    _iconAnimation = new  CurvedAnimation(parent: _iconAnimationController,curve: Curves.fastOutSlowIn);

    _iconAnimation.addListener(()=> this.setState((){}));
    _iconAnimationController.forward();
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

    return _mainBody(height,width,aspectRatio);
  }

  void _delete(BuildContext context, Note note) async {

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Warning !"),
            content: new Text("Are you sure to delete this card? "),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new OutlineButton(
                onPressed: () async {
                  int r=await dbHelper.removeNote(note.id);
                  updateListView();
                  if(r == 1) Navigator.of(context).pop();
                },
                child: new Text("Delete",style: TextStyle(color: Colors.red),),borderSide: new BorderSide(color: Colors.red),),
            ],
          );
        });
  }

  void mainBottomSheet(BuildContext context, Note note) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context){
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: new Text('Warning'),
                  subtitle: new Text('Are you sure to delete this card ?'),
                  onTap: (){
                    _delete(context, note);
                  },
                )
              ],
            );
          }
      );
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

  Widget _mainBody(double height,double width, double aspectRatio){
    return
    SafeArea(
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
              expandedHeight: _iconAnimation.value * 2 * (height / 7),
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?ixlib=rb-1.2.1&auto=format&fit=crop&w=1932&q=80',
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
                  childAspectRatio:(aspectRatio/2.4)
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
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.5)
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
                                        iconSize: _iconAnimation.value * width/8,
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

}

