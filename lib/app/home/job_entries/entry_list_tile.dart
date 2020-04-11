import 'package:flutter/material.dart';
import 'package:time_tracker_v2/app/home/models/entry.dart';

class EntryListTile extends StatelessWidget {
  const EntryListTile({Key key, @required this.entry, this.onTap}) : super(key: key);
  final Entry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entry.jobId),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
