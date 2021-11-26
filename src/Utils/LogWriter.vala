/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.LogWriter : Object {
    private static LogWriter __instance;

    public static LogWriter shared_instance () {
        if (__instance == null) {
            __instance = new Journal.LogWriter ();
        }

        return __instance;
    }

    public bool write_journal_to_json_file (Journal.LogModel[] logs, File journal_file, string format = "json") {
        if (journal_file == null) {
            return false;
        }

        // Json.Array res = new Json.Array.sized (logs.length);
        // res.add_object_element (owned Json.Object value);

        string journal_json = "";
        journal_json += "[";
        for (uint i = 0; i < logs.length; i++) {
            var log = (Journal.LogModel) logs[i];
            string json_log = log.to_json_object ();
            journal_json += json_log;
            if (i + 1 < logs.length) {
                journal_json += ",";
            }
        }
        journal_json += "]";
        debug ("journal_json: %s", journal_json);

        bool saved = false;
        try {
            var file_stream = journal_file.create (FileCreateFlags.NONE);
            var data_stream = new DataOutputStream (file_stream);
            data_stream.put_string (journal_json);
            saved = true;
        }
        catch (Error err) {
            warning ("Could not write Journal to JSON file %s: %s",
            journal_file.get_path (), err.message);
        }

        return saved;
    }

    public bool write_journal_to_zip_archive_file (Journal.LogModel[] logs, File archive_file) {
        if (archive_file == null) {
            return false;
        }
        bool saved = false;
        Journal.JournalArchiveModel journal_archive = new Journal.JournalArchiveModel (archive_file);

        // replace existing, i.e. delete before re-creating 
        /* if (archive_file.query_exists ()) {
            journal_archive.file_collector.mark_for_deletion (archive_file);
        } */

        journal_archive.prepare ();
        saved = journal_archive.write_journal (logs);
        journal_archive.close ();
        return saved;
    }
}
