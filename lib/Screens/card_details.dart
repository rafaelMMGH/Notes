import 'dart:async';
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
                setState(() {
                  _save();
                })
              ;})
        ],
      ),
      body: Padding(padding: EdgeInsets.only(top: 15.0,left: 20.0, right: 20.0),
        child: ListView(
          children: <Widget>[

            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: 0.0),
              child: TextField(
                controller: accountController,
                style: textStyle,
                onChanged: (value){
                  updateAccount();
                },
                decoration: InputDecoration(
                  labelText: 'Account',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0,horizontal: 0.0),
              child: TextField(
                controller: descriptionController,
                style: textStyle,
                onChanged: (value){
                  updateDescription();
                },
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0,horizontal: 0.0),
              child: TextField(
                controller: passwordController,
                style: textStyle,
                onChanged: (value){
                  updatePassword();
                },
                decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),



          ],
        ),
      ),
    );
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
        });
  }
}
