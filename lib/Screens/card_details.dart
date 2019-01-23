import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes/Model/Note.dart';
import 'package:notes/Database/DBHelper.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';


class CardDetail extends StatefulWidget{

  final String appBarTitle;
  final Color color;
  final Note note;

  CardDetail(this.note,this.appBarTitle, this.color);

  @override
  State<StatefulWidget> createState() {
    return CardDetailState(this.note,this.appBarTitle, this.color);
  }
}

class CardDetailState extends State<CardDetail> {

  String appBarTitle;
  Color color;
  int length = 4;
  int letters = 1;
  bool checkBoxNumbers = true;
  bool checkBoxSpecial = true;

  Note note;

  DBHelper helper = DBHelper();

  TextEditingController accountController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool _accountValidate = false;
  bool _passwordValidate = false;

  bool _obscureText = true;
  IconData _iconPassword = Icons.lock_outline ;

  CardDetailState(this.note,this.appBarTitle,this.color);


  @override
  void initState() {
    super.initState();
  }

  void _checkValues(){

    setState(() {

      if(accountController.text.isEmpty){
        _accountValidate = true;
        _passwordValidate = false;

      }else if(passwordController.text.isEmpty){
        _accountValidate = false;
        _passwordValidate = true;
      }else{
        _save();
      }

    });
  }

  void _toggle(){
    setState(() {
      _obscureText = !_obscureText;
      _iconPassword = _iconPassword == Icons.lock_outline ? Icons.lock_open : Icons.lock_outline;
    });
  }

  void moveToLastScreen(){
    Navigator.pop(context,true);
  }

  void updateAccount(){
    note.account = accountController.text;
  }

  void updatePassword(){
    note.password = passwordController.text;
  }

  void updateDescription(){
    note.description = descriptionController.text;
  }

  void _save() async{
    _accountValidate = false;
    _passwordValidate = false;

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if(note.id != null) { //update
      result = await helper.updateNote(note);

      if(result != 0) //Success
        _showAlert('Saved', 'Card saved successfully');
      else //Fail
        _showAlert('Error', 'Problem saving Card');
    }
    else { //Insert
      result = await helper.addNote(note);

      if(result != 0) //Success
        _showAlert('Saved', 'Card saved successfully');
      else //Fail
        _showAlert('Error', 'Problem saving Card');
    }


  }

  void _delete() async{

    moveToLastScreen();

    //Case I: If user is trying to delete the NEW Card i.e. he has come to
    //the detail page by pressing the FAB of CardList page.
    if(note.id == null){
      _showAlert('Error', 'No Card was deleted');
      return;
    }

    //Case II: User is trying to delete a existing card that already  has a valid ID.
    int result = await helper.removeNote(note.id);
    if(result != 0)
      _showAlert('Deleted', 'Note Deleted successfully.');
    else
      _showAlert('Error','Error ocurred while deleting note');

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
        }
    );
  }

  void _fireAndThud(){
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
                  new Text(' The day after you stole my heart,\nEverything I touched told me it would be better shared with you', textAlign: TextAlign.justify,),
                  new Divider(),
                ],
              )
          );
        });
  }

  _showModalGeneratePassword(BuildContext context) async {

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    await showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext context){
          return Container(
              color: Color.fromRGBO(117,117, 117, 1.0),
              child: new Container(
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(15.0),
                      topRight:  const Radius.circular(15.0)),),
                child: new MyBottomSheetDialog(length: length,),
              )

          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.title;

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    accountController.text = note.account;
    passwordController.text = note.password;
    descriptionController.text = note.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: color,
        actions: <Widget>[
          new IconButton(
              icon: Icon(Icons.check),
              onPressed: (){
                  _checkValues();
              })
        ],
      ),
      body:
          new Container(
            color: Colors.white,
            child: Padding(padding: EdgeInsets.only(top: 20.0,left: 20.0, right: 20.0),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: <Widget>[
                    new Column(
                      children: <Widget>[
                        new Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                          child: new Image.asset("assets/notes.jpg",alignment: Alignment.topCenter,repeat: ImageRepeat.noRepeat,width: width,),
                        ),
                        new Padding(
                          padding: EdgeInsets.only(top: 0.0),
                          child: TextField(
                            controller: accountController,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w300,
                            ),
                            maxLength: 13,
                            onChanged: (value){
                              updateAccount();
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.grey[150],
                              prefixIcon: Icon(Icons.account_balance_wallet,color: Colors.black,),
                              filled: true,
                              labelText: 'Account',
                              labelStyle: textStyle,
                              errorText: _accountValidate ? 'Value Can\'t Be Empty' : null,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red,style: BorderStyle.none),borderRadius: BorderRadius.circular(6.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent,),borderRadius: BorderRadius.circular(15.0)
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 0.0),
                          child: TextField(
                            controller: descriptionController,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w300
                            ),
                            maxLines: 3,
                            maxLength: 25,
                            onChanged: (value){
                              updateDescription();
                            },
                            decoration: InputDecoration(
                                fillColor: Colors.grey[150],
                                filled: true,
                                prefixIcon: Icon(Icons.description,color: Colors.black,),

                                labelText: 'Description',
                                labelStyle: textStyle,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent,),borderRadius: BorderRadius.circular(6.0)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent,),borderRadius: BorderRadius.circular(15.0)
                                )

                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 0.0),
                          child: TextField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w300
                            ),
                            onChanged: (value){
                              updatePassword();
                            },
                            decoration: InputDecoration(
                                fillColor: Colors.grey[150],
                                filled: true,
                                prefixIcon: IconButton(icon: Icon(_iconPassword),color: Colors.blue[700],onPressed: (){_toggle(); },),
                                suffixIcon: IconButton(icon: Icon(Icons.threesixty),color: Colors.black,onPressed: (){ _showModalGeneratePassword(context); },),   //vxvbvcnbcbnjhghjgjgjgjghjhgjghjvxvbvcnbcbnjhghjgjgjgjghjhgjghjvxvbvcnbcbnjhghjgjgjgjghjhgjghjvxvbvcnbcbnjhghjgjgjgjghjhgjghj
                                labelText: 'Password',
                                labelStyle: textStyle,
                                errorText: _passwordValidate ? 'Value Can\'t Be Empty' : null,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent,),borderRadius: BorderRadius.circular(6.0)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent,),borderRadius: BorderRadius.circular(15.0)
                                )
                            ),
                          ),
                        ),


                      ],
                    )
                  ],
                ),
            ),
          ),
    );
  }

}

class MyBottomSheetDialog extends StatefulWidget{
  MyBottomSheetDialog({
    Key key,
    this.length,
    this.letters,
    this.number,
    this.special
}):super(key:key);

  final int length;
  final int letters;
  final bool number;
  final bool special;

  @override
  _MyBottomSheetDialogState createState() => new _MyBottomSheetDialogState();



}

class _MyBottomSheetDialogState extends State<MyBottomSheetDialog>{
  int _selectLength = 4;
  int _selectLetters = 1;
  bool _checkBoxNumbers = true;
  bool _checkBoxSpecial = true;

  @override
  void initState() {
    super.initState();
  }

  void _fireAndThud(){
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
                  new Text(' The day after you stole my heart,\nEverything I touched told me it would be better shared with you', textAlign: TextAlign.justify,),
                  new Divider(),
                ],
              )
          );
        });
  }

  _generatePassword(bool numbers,bool specials, int length, int letters) async {

    var _letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    var _numbers = "0123456789";
    var _special = "!#%&'()*+,-./:;<=>?@[]^_`{|}~";
    var _chars = "";
    var _text ="";
    final key = new GlobalKey<ScaffoldState>();


    final _random = new Random();

    _chars += _letters.toLowerCase();

    if (numbers)
      _chars += _numbers;
    if (specials)
      _chars += _special;

    int startIndex(int min, int max) => min + _random.nextInt(max - min);

    // _chars += letters == 1 ? _letters : letters == 2 ? _letters.toLowerCase() : _letters + _letters.toLowerCase();


    for (var i = 0; i < length; i++)
      _text += _chars.substring(startIndex(1,_chars.length))[1];



    return
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              key: key,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9.0)
                ),
                title: new Text('My new Password :)',textAlign: TextAlign.center,),
                content: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new GestureDetector(
                      child: new Text(_text, textAlign: TextAlign.justify,),
                        onLongPress:() => _showtoast(context, _text),
                    ),

                    new Divider(),
                  ],
                )
            );
          });


    Navigator.of(context).pop();

  }

  _showtoast(BuildContext contex, String password){

    Clipboard.setData(new ClipboardData(text: password));

    Fluttertoast.showToast(
        msg: "Copied to Clipboard",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1
    );
  }

  _getContent(BuildContext context){

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

      return new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
        new GestureDetector(
          onLongPress: (){
            _fireAndThud();
          },
          child:
          new Image.asset("assets/password.jpg",alignment: Alignment.topCenter,repeat: ImageRepeat.noRepeat,width: width/2,height: height/6,),
        ),

        // new Image.network("https://cdn.dribbble.com/users/1748539/screenshots/4857111/dribbble_shot_hd.jpg",alignment: Alignment.topCenter,repeat: ImageRepeat.noRepeat,width: width/2,height: height/6,),

        Padding(
            padding: new EdgeInsets.all(0.0),
            child: new Column(
              children: <Widget>[
                //new Text("Options",style: TextStyle(color: Color.fromRGBO(23, 23, 23, 1.0)),textAlign: TextAlign.left,),
                new SwitchListTile(
                    value: _checkBoxNumbers,
                    title: new Text("Numbers"),
                    secondary: const Icon(Icons.filter_9_plus),
                    onChanged: (bool value) {
                      setState(() {
                        _checkBoxNumbers = value;
                      });
                    }
                ),
                new SwitchListTile(
                    value: _checkBoxSpecial,
                    title: new Text("Special Characters"),
                    secondary: const Icon(Icons.font_download),
                    onChanged: (bool value) {
                      setState(() {
                        _checkBoxSpecial = value;
                      });
                    }
                ),
                new SingleChildScrollView(
                  child: new Material(
                    child:
                    new Row(
                      children: <Widget>[
                        new Padding(padding: new EdgeInsets.symmetric(horizontal: 9)),
                        new Icon(Icons.settings_ethernet,color: Colors.grey[600],),
                        new Padding(padding: new EdgeInsets.symmetric(horizontal: 15)),
                        new Text('Length:     $_selectLength',style: TextStyle(fontSize: 16),),
                        new Padding(padding: new EdgeInsets.symmetric(horizontal: 15)),
                        new Slider(
                            value: _selectLength.toDouble(),
                            min: 4.0,
                            max: 20.0,
                            activeColor: Colors.blue,
                            inactiveColor: Colors.grey[300],

                            onChanged: (double value) {
                              setState(() {
                                _selectLength = value.round();
                              });
                            }),
                      ],
                    ),
                    // new MyDialogContent(length: _selectLength),
                  ),
                ),
                /*new SingleChildScrollView(
                  child: new Material(
                    child: new GeneratePassword(checkBoxNumbers: checkBoxNumbers,checkBoxSpecial: checkBoxSpecial,length: length,letters: letters),
                  ),
                ),*/
                  new CupertinoButton(
                  onPressed: (){
                    setState(() {
                    _generatePassword(_checkBoxNumbers,_checkBoxSpecial,_selectLength,_selectLetters);
                    });
                  },
                  child: new Text('Generate'))

              ],
            )

        ),
      ],
      );


  }

  @override
  Widget build(BuildContext context) {
    return _getContent(context);
  }
}
