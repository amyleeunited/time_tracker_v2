import 'package:flutter/foundation.dart';

class Entry {
  Entry(
      {@required this.id,
      @required this.jobId,
      @required this.start,
      @required this.end,
      @required this.comment});
  String id;
  String jobId;
  String comment;
  DateTime start;
  DateTime end;

  double get durationInHours => end.difference(start).inMinutes.toDouble()/60;

  factory Entry.fromMap(Map<dynamic, dynamic> value, String id){
    final startMilliseconds = value['start'];
    final endMilliseconds = value['end'];
    return Entry(
      id: id,
      jobId: value['jobId'],
      start: DateTime.fromMillisecondsSinceEpoch(startMilliseconds),
      end: DateTime.fromMillisecondsSinceEpoch(endMilliseconds),
      comment: value['comment'], 
    );
  }

  Map<String, dynamic> toMap(){
    return <String, dynamic>{
      'jobId': jobId,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'comment': comment,
    };
  }




}
