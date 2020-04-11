import 'dart:async';

import 'package:meta/meta.dart';
import 'package:time_tracker_v2/app/home/models/entry.dart';
import 'package:time_tracker_v2/app/home/models/job.dart';
import 'package:time_tracker_v2/services/api_path.dart';
import 'package:time_tracker_v2/services/firestore_service.dart';

abstract class Database {
  Future<void> setJob(Job job);
  Future<void> deleteJob(Job job);
  Stream<List<Job>> jobsStream();
  Stream<Job> jobStream({@required String jobId});

  Future<void> setEntry(Entry entry);
  Future<void> deleteEntry(Entry entry);
  Stream<List<Entry>> entriesStream({Job job});
  Stream<List<Entry>> entryStream();
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;

  final _service = FirestoreService.instance;

  @override
  Future<void> setJob(Job job) async => await _service.setData(
        path: APIPath.job(uid, job.id),
        data: job.toMap(),
      );

  @override
  Future<void> deleteJob(Job job) async => await _service.deleteData(
        path: APIPath.job(uid, job.id),
      );

  @override
  Stream<List<Job>> jobsStream() => _service.collectionStream(
        path: APIPath.jobs(uid),
        builder: (data, documentId) => Job.fromMap(data, documentId),
      );

  @override
  Stream<Job> jobStream({@required String jobId}) => _service.documentStream(
      path: APIPath.job(uid, jobId),
      builder: (data, documentId) => Job.fromMap(data, documentId));

  @override
  Future<void> setEntry(Entry entry) async => await _service.setData(
        path: APIPath.entry(uid, entry.id),
        data: entry.toMap(),
      );

  @override
  Future<void> deleteEntry(Entry entry) async => await _service.deleteData(
        path: APIPath.entry(uid, entry.id),
      );

  @override
  Stream<List<Entry>> entriesStream({Job job}) =>
      _service.collectionStream<Entry>(
        path: APIPath.entries(uid),
        queryBuilder: job != null
            ? (query) => query.where('jobId', isEqualTo: job.id)
            : null,
        builder: (data, documentID) => Entry.fromMap(data, documentID),
        sort: (lhs, rhs) => rhs.start.compareTo(lhs.start),
      );

  Stream<List<Entry>> entryStream() => _service.collectionStream(
      path: APIPath.entries(uid),
      builder: (value, documentID) => Entry.fromMap(value, documentID));
}
