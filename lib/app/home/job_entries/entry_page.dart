import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_tracker_v2/app/home/job_entries/date_time_picker.dart';
import 'package:time_tracker_v2/app/home/job_entries/format.dart';
import 'package:time_tracker_v2/app/home/models/entry.dart';
import 'package:time_tracker_v2/app/home/models/job.dart';
import 'package:time_tracker_v2/common_widgets/platform_exception_alert_dialog.dart';
import 'package:time_tracker_v2/services/database.dart';

class EntryPage extends StatefulWidget {
  const EntryPage(
      {Key key,
      @required this.database,
      @required this.job,
      @required this.entry})
      : super(key: key);

  final Database database;
  final Job job;
  final Entry entry;

  static Future<void> show(
      {BuildContext context, Database database, Job job, Entry entry}) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          EntryPage(database: database, job: job, entry: entry),
      fullscreenDialog: true,
    ));
  }

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  DateTime _startDate;
  TimeOfDay _startTime;
  DateTime _endDate;
  TimeOfDay _endTime;
  String _comment;

  @override
  void initState() {
    super.initState();
    final start = widget.entry?.start ?? DateTime.now();
    _startDate = DateTime(start.year, start.month, start.day);
    _startTime = TimeOfDay.fromDateTime(start);

    final end = widget.entry?.end ?? DateTime.now();
    _endDate = DateTime(end.year, end.month, end.day);
    _endTime = TimeOfDay.fromDateTime(end);

    _comment = widget.entry?.comment ?? '';
  }

  Entry _entryFromState() {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day,
        _startTime.hour, _startTime.minute);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day,
        _endTime.hour, _endTime.minute);
    final id = widget.entry?.id ?? documentIdFromCurrentDate();
    return Entry(
      start: start,
      end: end,
      id: id,
      jobId: widget.job.id,
      comment: _comment,
    );
  }

  Future<void> _setEntryAndDismiss(BuildContext context) async {
    try {
      final entry = _entryFromState();
      await widget.database.setEntry(entry);
      Navigator.of(context).pop();
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.job.name),
          centerTitle: true,
          elevation: 2.0,
          backgroundColor: Colors.indigo,
          actions: <Widget>[
            FlatButton(
              child: Text(
                widget.entry == null ? 'Create' : 'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
              onPressed: () => _setEntryAndDismiss(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildStartDate(),
                _buildEndDate(),
                SizedBox(height: 10.0),
                _buildDuration(),
                SizedBox(height: 10.0),
                _buildComment(),
              ],
            ),
          ),
        ));
  }

  Widget _buildStartDate() {
    return DateTimePicker(
      labelText: 'Start',
      selectedDate: _startDate,
      selectedTime: _startTime,
      selectDate: (date) => setState(() => _startDate = date),
      selectTime: (time) => setState(() => _startTime = time),
    );
  }

  Widget _buildEndDate() {
    return DateTimePicker(
      labelText: 'End',
      selectedDate: _endDate,
      selectedTime: _endTime,
      selectDate: (date) => setState(() => _endDate = date),
      selectTime: (time) => setState(() => _endTime = time),
    );
  }

  Widget _buildDuration() {
    final currentEntry = _entryFromState();
    final durationFormatted = Format.hours(currentEntry.durationInHours);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          'Duration: $durationFormatted',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }

  Widget _buildComment() {
    return TextField(
      keyboardType: TextInputType.text,
      maxLength: 50,
      controller: TextEditingController(text: _comment),
      maxLines: null,
      decoration: InputDecoration(
        labelText: 'Comment',
        labelStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      ),
      style: TextStyle(fontSize: 20.0, color: Colors.black),
      onChanged: (comment) => _comment = comment,
    );
  }
}
