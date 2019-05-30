import 'dart:async';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:notes/Model/Note.dart';
import 'package:notes/Database/DBHelper.dart';
import 'package:notes/Screens/card_details.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_walkthrough/flutter_walkthrough.dart';
import 'package:flutter_walkthrough/walkthrough.dart';
import 'package:url_launcher/url_launcher.dart';


import 'package:local_auth/error_codes.dart' as auth_error;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lato',
          primaryColor: Colors.white,
          hintColor: Colors.transparent,
          canvasColor: Colors.transparent,
      ),
      home: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();

}

class SplashState extends State<Splash> {

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new MyHomePage()));
    } else {
      prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new IntroPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    new Timer(new Duration(milliseconds: 200), () {
      checkFirstSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Text('Loading...'),
      ),
    );
  }

}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  _MyHomePageState();

  final LocalAuthentication auth = new LocalAuthentication();
  String _authorized = 'Not Authorized';
  List<BiometricType> list = [];

  DBHelper dbHelper = DBHelper();
  List<Note> noteList;
  int count = 0;

  Color _color1 = Colors.deepOrange[100];
  Color _color2 = Colors.deepOrange[100];
  Color _color3 = Colors.deepOrange[100];
  Color _color4 = Colors.deepOrange[100];

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

  var aux = [];
  var password = [2,1,4,2];

  @override
  void initState() {
    super.initState();

    scrollController = new ScrollController();

    _iconAnimationController = new AnimationController(vsync: this,duration: new Duration(milliseconds: 380));
    _iconAnimation = new  CurvedAnimation(parent: _iconAnimationController,curve: Curves.fastOutSlowIn);

    _iconAnimation.addListener(()=> this.setState((){}));
    _iconAnimationController.forward();
  }

  Future<Null> _authenticate() async {
    bool authenticated = false;

    try {
      await auth.getAvailableBiometrics();

        authenticated = await auth.authenticateWithBiometrics(
            localizedReason: 'Scan your fingerprint to authenticate',
            useErrorDialogs: true,
            stickyAuth: true);
      }on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
       print(e.code);
      }
    }
    if (!mounted) return;

    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';

    });
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
                    leading: new Icon(Icons.account_circle,color: Colors.blueAccent,),
                    title: new Text('Rafael Alberto Martínez Méndez'),
                    onTap: (){
                      _launchURL();
                    },
                  ),
                ],
              )
          );
        });
  }

  _launchURL() async {
    const url = 'https://github.com/rafaelMMGH';

    if (await canLaunch(url))
      await launch(url);
    else
      throw 'Could not launch $url';

  }

  void openCard(Note note, String title, Color color) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CardDetail(note, title, color);
    }));

    if (result) updateListView();
  }

  Widget _passwordButtons(String number){
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double aspectRatio = MediaQuery.of(context).devicePixelRatio;

    setState(() {

        aux.add(number);


      if(_color1 == Colors.deepOrange[100])
        _color1 = Colors.deepOrange;
      else if(_color2 == Colors.deepOrange[100])
        _color2 = Colors.deepOrange;
      else if(_color3 == Colors.deepOrange[100])
        _color3 = Colors.deepOrange;
      else if(_color4 == Colors.deepOrange[100])
        _color4 = Colors.deepOrange;


      if(aux.toString() == password.toString())
        _authorized = 'Authorized';

    });

    return build(context);
  }

  void _clearPasswordButtons(){
    setState(() {

      aux.removeLast();

      if(_color4 == Colors.deepOrange)
        _color4 = Colors.deepOrange[100];
      else if(_color3 == Colors.deepOrange)
        _color3 = Colors.deepOrange[100];
      else if(_color2 == Colors.deepOrange)
        _color2 = Colors.deepOrange[100];
      else if(_color1 == Colors.deepOrange)
        _color1 = Colors.deepOrange[100];
    });
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
      Container(
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: appColors[4],
          body: new RefreshIndicator(onRefresh:_handleRefresh, child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                leading: null,
                automaticallyImplyLeading: false,
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
                  background: Image.asset(
                    'assets/SliverAppBar.jpeg',
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
                        showSearch(context: context, delegate: DataSearch());
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
                    childAspectRatio:(aspectRatio/2.5)
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
                                          icon: Icon(Icons.beenhere),
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

  Widget _biometrics(double height,double width, double aspectRatio){

    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Container(
            child: Scaffold(
              body: ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Padding(padding: new EdgeInsets.only(top: 15.00)),
                        new Image.asset("assets/icon.png",alignment: Alignment.topCenter,repeat: ImageRepeat.noRepeat,width: width,height: height/3,),

                        new Container(
                          padding: new EdgeInsets.only(top: 15,right: width/8,left: width/8),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              new Row(
                                children: <Widget>[
                                  
                                  new Padding(padding: EdgeInsets.only(left: width/5),
                                    child: Container(
                                      width: 15,
                                      height: 15,
                                      decoration: new BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _color1,
                                      ),
                                    ) ,
                                  ),
                                  new Padding(padding: EdgeInsets.only(left: width/16),
                                    child: Container(
                                      width: 15,
                                      height: 15,
                                      decoration: new BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _color2,
                                      ),
                                    ) ,
                                  ),
                                  new Padding(padding: EdgeInsets.only(left: width/16),
                                      child: Container(
                                        width: 15,
                                        height: 15,
                                        decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _color3,
                                        ),
                                      ) ,
                                    ),
                                  new Padding(padding: EdgeInsets.only(left: width/16),
                                      child: Container(
                                        width: 15,
                                        height: 15,
                                        decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _color4,
                                        ),
                                      ) ,
                                    ),

                                ],
                            ),
                              new Padding(padding: EdgeInsets.only(bottom: 30)),

                              new Row(
                                children: <Widget>[
                                  new ButtonTheme(
                                    minWidth: width/4,
                                    height: height/8,
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15.0)),
                                    child: new FlatButton(onPressed: (){ _passwordButtons("1"); },child: new Center(child: Text("1",style: TextStyle(fontSize: 30),),)),

                                  ),
                                  new ButtonTheme(
                                    minWidth: width/4,
                                    height: height/8,
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(17.0)),
                                    child: new FlatButton(onPressed: (){ _passwordButtons("2"); },child: new Center(child: Text("2",style: TextStyle(fontSize: 30),),)),

                                  ),
                                  new ButtonTheme(
                                    minWidth: width/4,
                                    height: height/8,
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(17.0)),
                                    child: new FlatButton(onPressed: (){ _passwordButtons("3"); },child: new Center(child: Text("3",style: TextStyle(fontSize: 30),),)),

                                  ),
                                ],
                              ),
                              new Row(
                                children: <Widget>[
                                  new ButtonTheme(
                                    minWidth: width/4,
                                    height: height/8,
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(17.0)),
                                    child: new FlatButton(onPressed: (){ _passwordButtons("4"); },child: new Center(child: Text("4",style: TextStyle(fontSize: 30),),)),

                                  ),
                                  new ButtonTheme(
                                    minWidth: width/4,
                                    height: height/8,
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(17.0)),
                                    child: new FlatButton(onPressed: (){ _passwordButtons("5"); },child: new Center(child: Text("5",style: TextStyle(fontSize: 30),),)),

                                  ),
                                  new ButtonTheme(
                                    minWidth: width/4,
                                    height: height/8,
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(17.0)),
                                    child: new FlatButton(onPressed: (){ _passwordButtons("6"); },child: new Center(child: Text("6",style: TextStyle(fontSize: 30),),)),

                                  ),
                                ],
                              ),
                              new Row(
                                children: <Widget>[
                                  new ButtonTheme(
                                    minWidth: width/4,
                                    height: height/8,
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(17.0)),
                                    child: new FlatButton(onPressed: (){ _passwordButtons("7"); },child: new Center(child: Text("7",style: TextStyle(fontSize: 30),),)),

                                  ),
                                  new ButtonTheme(
                                    minWidth: width/4,
                                    height: height/8,
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(17.0)),
                                    child: new FlatButton(onPressed: (){ _passwordButtons("8"); },child: new Center(child: Text("8",style: TextStyle(fontSize: 30),),)),

                                  ),
                                  new ButtonTheme(
                                    minWidth: width/4,
                                    height: height/8,
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(17.0)),
                                    child: new FlatButton(onPressed: (){ _passwordButtons("9"); },child: new Center(child: Text("9",style: TextStyle(fontSize: 30),),)),

                                  ),
                                ],
                              ),

                              new Row(
                                children: <Widget>[
                                  new ButtonTheme(
                                    minWidth: width/4,
                                    height: height/8,
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(17.0)),
                                    child: new FlatButton(onPressed: (){ _clearPasswordButtons(); },child: new Center(child: Icon(Icons.backspace,),)),

                                  ),

                                  new ButtonTheme(
                                    minWidth: width/4,
                                    height: height/8,
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(17.0)),
                                    child: new FlatButton(onPressed: (){ _passwordButtons("0"); },child: new Center(child: Text("0",style: TextStyle(fontSize: 30),),)),

                                  ),

                                  new ButtonTheme(
                                    minWidth: width/4,
                                    height: height/8,
                                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(17.0)),
                                    child:
                                        FlatButton(
                                          padding: EdgeInsets.all(0.0),
                                          onPressed: _authenticate,
                                          child: new Center(child: Icon(Icons.fingerprint,size: width/7,color: Colors.red,),),
                                        ),
                                      
                                    

                                  ),



                                ],
                              )

                            ],
                          ),
                        ),
                      ]
                  )
              ),
            ),)
    );

  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double aspectRatio = MediaQuery.of(context).devicePixelRatio;

    assert(debugCheckHasMediaQuery(context));

    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return _authorized == 'Authorized' ? _mainBody(height,width,aspectRatio) : _biometrics(height,width,aspectRatio);
  }

}

class IntroPage extends StatelessWidget {

  /*here we have a list of walkthroughs which we want to have,
  each walkthrough have a title,content and an icon.
  */
  final List<Walkthrough> list = [
    Walkthrough(
      title: "Create",
      content: "Create notes to save password ",
      imageIcon: Icons.add_box,
    ),
    Walkthrough(
      title: "Keep safe",
      content: "All your information safe with a password or biometric reader",
      imageIcon: Icons.security,
    ),
    Walkthrough(
      title: "Search",
      content: "Search your notes easily",
      imageIcon: Icons.search,
    ),
    Walkthrough(
      title: "Take control with gestures",
      content: "Tap: Open a note \n\r Pressed: Delete a note",
      imageIcon: Icons.gesture,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    //here we need to pass the list and the route for the next page to be opened after this.
    return new IntroScreen(
      list,
      new MaterialPageRoute(builder: (context) => new MyHomePage()),
    );
  }

}

class DataSearch extends SearchDelegate<String>{

  DBHelper dbHelper = DBHelper();
  List<Note> noteList;
  int count = 0;

  static var appColors = [
    Colors.grey[100], // New Card
    Colors.grey[200], // Edit Card
    Color.fromRGBO(62,152,52,1.0), // Icon
    Color.fromRGBO(106,131,184,1.0), // Date
    Color.fromRGBO(249,249,249,1.0), // New Background Color App
    Color.fromRGBO(240, 247, 255, 1.0), // Old Background Color
    Color.fromRGBO(28,139,253,1.0)
  ];

  void openCard(Note note, String title, Color color, BuildContext context) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CardDetail(note, title, color);
    }));

    if (result) updateListView();
  }

  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDB();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = dbHelper.getNoteList();
      noteListFuture.then((noteList) {
          this.noteList = noteList;
          this.count = noteList.length;
      });
    });
  }


  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [IconButton(
        icon:
          Icon(Icons.clear),
          onPressed: (){
            query= "";
          })];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
        icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: (){
          close(context,null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;//CardDetail(context, 'Edit card', appColors[1]);
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    final suggestionsList = query.isEmpty ?  noteList : noteList.where((p) => p.account.toString().startsWith(query)).toList();

    // TODO: implement buildSuggestions
    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
          leading: Icon(Icons.note,color: Colors.indigoAccent,),
          title: Text(suggestionsList[index].account),
          onTap: (){
            openCard(suggestionsList[index], "Edit card", appColors[1],context);
          },
        ),
    itemCount: suggestionsList.length,);
  }

}
