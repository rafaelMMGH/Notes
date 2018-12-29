import 'package:flutter/material.dart';

class BottomSheetModal{


  mainBottomSheet(BuildContext context, Note note){
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
        });
  }

}