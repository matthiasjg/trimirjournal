/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.LogReader : Object {
    private static LogReader __instance;

    public static LogReader shared_instance () {
        if (__instance == null) {
            __instance = new Journal.LogReader ();
        }

        return __instance;
    }

    public Journal.LogModel[] ? load_journal_from_json_file (File journal_json_file) {
        if (journal_json_file == null) {
            return null;
        }
        Journal.LogModel[] logs = null;

        Json.Parser parser = new Json.Parser ();
        try {
            uint8[] contents;
            string etag_out;

            journal_json_file.load_contents (null, out contents, out etag_out);

            // parser.load_from_file ( journal_file_path );
            parser.load_from_data ((string) contents);
            Json.Node root_node = parser.get_root ();
            var array = root_node.get_array ();

            for (uint i = 0; i < array.get_length (); i++) {
                var object = array.get_object_element (i);
                var log = new LogModel.from_json_object (object);
                debug (log.to_string ());
                logs += log;
            }
        } catch (Error err) {
            error ("Unable to parse Journal JSON file %s: %s\n", journal_json_file.get_path (), err.message);
        }

        return logs;
    }

    public Journal.LogModel[] ? load_journal_from_zip_archive_file (File archive_file) {
        if (archive_file == null) {
            return null;
        }
        Journal.LogModel[] logs = null;

        Journal.JournalArchiveModel journal_archive = new Journal.JournalArchiveModel (archive_file);

        journal_archive.prepare ();
        logs = journal_archive.load_journal ();
        journal_archive.close ();

        return logs;
    }
}
