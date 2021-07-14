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

    public Journal.LogModel[] ? load_journal_from_json_file (string journal_file_path) {
        if (journal_file_path == null || journal_file_path == "") {
            return null;
        }
        Journal.LogModel[] logs = null;

        Json.Parser parser = new Json.Parser ();
        try {
            uint8[] contents;
            string etag_out;

            File file = File.new_for_path (journal_file_path);
            file.load_contents (null, out contents, out etag_out);

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
            error ("Unable to parse Journal JSON file %s: %s\n", journal_file_path, err.message);
        }

        return logs;
    }
}
