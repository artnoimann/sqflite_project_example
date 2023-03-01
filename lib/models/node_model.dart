import 'dart:convert';

class NoteModel {
  String title;
  String content;
  int? id;
  NoteModel({
    required this.title,
    required this.content,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
    };
  }
}
