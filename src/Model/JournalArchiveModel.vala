/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

 public class Journal.JournalArchiveModel : Journal.ZipArchiveHandler {

    public File assets_folder { get; private set; }

    private File journal_file { get; set; }

    public JournalArchiveModel (File _journal_zip_archive_file) {
        Object (opened_file: _journal_zip_archive_file.dup ());
    }

    public Journal.LogModel[] ? load_journal () {
        Journal.LogModel[] logs = null;
        try {
            open_archive ();

            var journal_json = get_content_as_json (journal_file);

            for (uint i = 0; i < journal_json.get_length (); i++) {
                var log_json = journal_json.get_object_element (i);
                var log = new LogModel.from_asset_json_object (log_json);
                logs += log;
            }

        } catch (Error err) {
            error ("Unable to load and parse Journal JSON from archive %s: %s\n", opened_file.get_path (), err.message);
        }
        return logs;
    }

    public bool write_journal (Journal.LogModel[] logs) {
        bool saved = false;
        try {
            string journal_json = "";
            journal_json += "[";
            for (uint i = 0; i < logs.length; i++) {
                var log = (Journal.LogModel) logs[i];
                string json_log = log.to_asset_json_object ();
                journal_json += json_log;
                if (i + 1 < logs.length) {
                    journal_json += ",";
                }
            }
            journal_json += "]";

            write_content_to_file (journal_file, journal_json);

            write_to_archive ();

            saved = true;
        } catch (Error err) {
            error ("Unable to write Journal JSON to archive %s: %s\n", opened_file.get_path (), err.message);
        }
        return saved;
    }

    public void close () {
        try {
            clean ();
        } catch (Error err) {
            warning ("Unable to clean Journal Archive: %s\n", err.message);
        }
    }

    public override void prepare () {
        base.prepare ();

        var base_path = unarchived_location.get_path ();
        assets_folder = File.new_for_path (Path.build_filename (base_path, "assets"));

        make_dir (assets_folder);

        journal_file = File.new_for_path (Path.build_filename (assets_folder.get_path (), "logs.json"));

        make_file (journal_file);
    }
}
