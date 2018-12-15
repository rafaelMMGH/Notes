import 'package:flutter/material.dart';

class CardItemModel{

  String cardTitle;
  IconData icon;
  int tasksRemaning;
  double taskCompletion;

  CardItemModel(this.cardTitle, this.icon, this.tasksRemaning, this.taskCompletion);
}