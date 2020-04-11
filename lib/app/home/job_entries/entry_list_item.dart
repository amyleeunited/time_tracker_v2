import 'package:flutter/material.dart';
import 'package:time_tracker_v2/app/home/job_entries/format.dart';
import 'package:time_tracker_v2/app/home/models/entry.dart';
import 'package:time_tracker_v2/app/home/models/job.dart';

class EntryListItem extends StatelessWidget {
  const EntryListItem({Key key, this.entry, this.job, this.onTap})
      : super(key: key);

  final Entry entry;
  final Job job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _buildContents(context)),
            Icon(
              Icons.chevron_right,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final dayOfWeek = Format.dayOfWeek(entry.start);
    final startDate = Format.date(entry.start);
    final startTime = TimeOfDay.fromDateTime(entry.start).format(context);
    final endTime = TimeOfDay.fromDateTime(entry.end).format(context);
    final formattedDuration = Format.hours(entry.durationInHours);

    final pay = job.ratePerHour * entry.durationInHours;
    final payFormatted = Format.currency(pay);

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              dayOfWeek,
              style: TextStyle(fontSize: 18.0, color: Colors.grey),
            ),
            SizedBox(
              width: 15.0,
            ),
            Text(
              startDate,
              style: TextStyle(fontSize: 18.0),
            ),
            if (job.ratePerHour > 0.0) ...<Widget>[
              Expanded(
                child: Container(),
              ),
              Text(
                payFormatted,
                style: TextStyle(fontSize: 16.0, color: Colors.green[700]),
              ),
            ]
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              '$startTime - $endTime',
              style: TextStyle(fontSize: 16.0),
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              formattedDuration,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
        if (entry.comment.isNotEmpty)
          Text(
            entry.comment,
            style: TextStyle(fontSize: 12.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
      ],
    );
  }
}

class DismissibleEntryListItem extends StatelessWidget {
  const DismissibleEntryListItem(
      {this.key, this.entry, this.job, this.onTap, this.onDismissed});

  final Key key;
  final Entry entry;
  final Job job;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key,
      background: Container(color: Colors.red),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDismissed,
      child: EntryListItem(
        entry: entry,
        job: job,
        onTap: onTap,
      ),
    );
  }
}
