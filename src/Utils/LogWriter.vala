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

    public bool write_journal_to_json_file (Journal.LogModel[] logs, string journal_file_path) {
        if (journal_file_path == null || journal_file_path == "") {
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
        File dest = GLib.File.new_for_path (journal_file_path);
        try {
            var file_stream = dest.create (FileCreateFlags.NONE);
            var data_stream = new DataOutputStream (file_stream);
            data_stream.put_string (journal_json);
            saved = true;
        }
        catch (Error err) {
            warning ("Could not write Journal to JSON file %s: %s",
            journal_file_path, err.message);
        }

        return saved;
    }
}
