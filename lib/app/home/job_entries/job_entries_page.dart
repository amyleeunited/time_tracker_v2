import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_v2/app/home/job_entries/entry_list_item.dart';
import 'package:time_tracker_v2/app/home/job_entries/entry_list_tile.dart';
import 'package:time_tracker_v2/app/home/job_entries/entry_page.dart';
import 'package:time_tracker_v2/app/home/jobs/edit_job_page.dart';
import 'package:time_tracker_v2/app/home/jobs/job_list_tile.dart';
import 'package:time_tracker_v2/app/home/jobs/list_item_builder2.dart';
import 'package:time_tracker_v2/app/home/jobs/list_items_builder.dart';
import 'package:time_tracker_v2/app/home/models/entry.dart';
import 'package:time_tracker_v2/app/home/models/job.dart';
import 'package:time_tracker_v2/common_widgets/platform_exception_alert_dialog.dart';
import 'package:time_tracker_v2/services/database.dart';
import 'package:flutter/services.dart';

class JobEntriesPage extends StatelessWidget {
  const JobEntriesPage({Key key, @required this.database, @required this.job})
      : super(key: key);
  final Database database;
  final Job job;

  static Future<void> show({BuildContext context, Job job}) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => JobEntriesPage(
        database: database,
        job: job,
      ),
    ));
  }

  Future<void> _deleteEntry(BuildContext context, Entry entry) async {
    try {
      await database.deleteEntry(entry);
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Job>(
        stream: database.jobStream(jobId: job.id),
        builder: (context, snapshot) {
          final job = snapshot.data;
          final jobName = job?.name ?? '';
          return Scaffold(
            appBar: AppBar(
              elevation: 2.0,
              backgroundColor: Colors.indigo,
              title: Text(jobName),
              centerTitle: true,
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                  onPressed: () => EditJobPage.show(
                    database: database,
                    context: context,
                    job: job,
                  ),
                )
              ],
            ),
            body: _buildContent(context, job),
            floatingActionButton: FloatingActionButton(
              onPressed: () => EntryPage.show(
                context: context,
                database: database,
                job: job,
              ),
              elevation: 2.0,
              child: Icon(Icons.add),
            ),
          );
        }
      );
  }

  Widget _buildContent(BuildContext context, Job job) {
    return StreamBuilder<List<Entry>>(
      stream: database.entriesStream(job: job),
      builder: (context, snapshot) {
        return ListItemsBuilder<Entry>(
            snapshot: snapshot,
            itemBuilder: (context, entry) {
              return DismissibleEntryListItem(
                key: Key('entry-${entry.id}'),
                entry: entry,
                job: job,
                onTap: () => EntryPage.show(
                    database: database,
                    context: context,
                    job: job,
                    entry: entry),
                onDismissed: () => _deleteEntry(context, entry),
              );
            });
      },
    );
  }
}
