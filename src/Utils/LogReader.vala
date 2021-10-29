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

    public void extract_journal_from_gzip_file (File journal_gzip_file, File journal_unzip_location) {
        Archive.ExtractFlags flags;
        flags = Archive.ExtractFlags.TIME;
        flags |= Archive.ExtractFlags.PERM;
        flags |= Archive.ExtractFlags.ACL;
        flags |= Archive.ExtractFlags.FFLAGS;

        Archive.Read archive = new Archive.Read ();
        archive.support_format_all ();
        archive.support_filter_all ();

        Archive.WriteDisk extractor = new Archive.WriteDisk ();
        extractor.set_options (flags);
        extractor.set_standard_lookup ();

        if (archive.open_filename (journal_gzip_file.get_path (), 10240) != Archive.Result.OK) {
            critical ("Error opening %s: %s (%d)", journal_gzip_file.get_path (), archive.error_string (), archive.errno ());
        }

        unowned Archive.Entry entry;
        Archive.Result last_result;
        while ((last_result = archive.next_header (out entry)) == Archive.Result.OK) {
            entry.set_perm (0644);
            entry.set_pathname (Path.build_filename (journal_unzip_location.get_path (), entry.pathname ()));

            if (extractor.write_header (entry) != Archive.Result.OK) {
                continue;
            }

            uint8[] buffer;
            Posix.off_t offset;
            while (archive.read_data_block (out buffer, out offset) == Archive.Result.OK) {
                if (extractor.write_data_block (buffer, offset) != Archive.Result.OK) {
                    break;
                }
            }
        }

        if (last_result != Archive.Result.EOF) {
            critical ("Error: %s (%d)", archive.error_string (), archive.errno ());
        }
    }
}
