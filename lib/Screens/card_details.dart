import 'package:flutter/material.dart';
import 'package:notes/Model/Note.dart';
import 'package:notes/Database/DBHelper.dart';
import 'package:intl/intl.dart';

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
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.title;

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
      padding: EdgeInsets.only(top: 15.0),
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

}
