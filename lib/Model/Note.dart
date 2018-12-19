class Note{
  int _id;
  String _account,_description,_password,_date;

  Note(this._account,this._password,this._date,[this._description]);

  Note.withId(this._id,this._account,this._password,this._date,[this._description]);

  int get id => _id;
  String get account => _account;
  String get description => _description;
  String get password => _password;
  String get date => _date;

  set account(String pAccount){
    if(pAccount.length <=13)
      this._account = pAccount;
  }

  set description(String pDescription){
    if(pDescription.length <=25)
      this._description = pDescription;
  }

  set password(String pPassword){
    if(pPassword.length >=4)
      this._password = pPassword;
  }

  set date(String pDate){
    this._date = pDate;
  }

  //Convert a Notes object into a map object
  //key    TypeValue
  Map<String, dynamic> toMap(){

    var map = Map<String,dynamic>();

    if(id != null)
      map['id'] = _id;

    map['account'] = _account;
    map['description'] = _description;
    map['password'] = _password;
    map['date'] = _date;

    return map;

  }

  //Extract a Notes object from  a Map object
  Note.fromMapObject(Map<String, dynamic> map){
    this._id = map['id'];
    this._account = map['account'];
    this._description = map['description'];
    this._password = map['password'];
    this._date = map['date'];
  }


}