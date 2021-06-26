/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

const string JOURNAL_FILE_PATH = "/home/matthias/Tresors/matthias tresor/ZenJournal_backup_Fri_Jun_25_2021.json";

public class Journal.LogReader : Object {
    private static LogReader __instance;

    public static LogReader shared_instance () {
        if (__instance == null) {
            __instance = new Journal.LogReader ();
        }

        return __instance;
    }

    public Journal.LogModel[] ? load_journal () {
        Journal.LogModel[] result = null;

        Json.Parser parser = new Json.Parser ();
        try {
            uint8[] contents;
            string etag_out;

            File file = File.new_for_path (JOURNAL_FILE_PATH);
            file.load_contents (null, out contents, out etag_out);

            // parser.load_from_file ( JOURNAL_FILE_PATH );
            parser.load_from_data ((string) contents);
            Json.Node root_node = parser.get_root ();
            var array = root_node.get_array ();

            var logs = new Journal.LogModel[] {};
            for (uint i = array.get_length () - 1; i > 0; --i) {
                var object = array.get_object_element (i);
                var log = new LogModel.fromJsonObject (object);
                logs += log;
            }
            result = logs;
        } catch (Error e) {
            print ("Unable to parse '%s': %s\n", JOURNAL_FILE_PATH, e.message);
        }

        return result;
    }
}
