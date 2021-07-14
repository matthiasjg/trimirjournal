/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

class Journal.Controller : Object {
    static Controller __instance;

    private Journal.LogModel[] ? _logs;

    private Journal.LogDao _log_dao;

    private Journal.LogReader _log_reader;
    private Journal.LogWriter _log_writer;

    public signal void updated_journal_logs (string tag_filter, LogModel[] logs);

    public static Controller shared_instance () {
        if (__instance == null) {
            __instance = new Journal.Controller ();
        }
        return __instance;
    }

    public void load_journal_logs (string tag_filter = "") {
        if (_logs == null) {
            if (_log_dao == null) {
                _log_dao = new Journal.LogDao ();
            }
            _logs = _log_dao.select_all_entities ();
        }
        debug ("Loaded Journal with %d logs", _logs.length);

        var filtered_logs = new Journal.LogModel[] {};
        if (tag_filter != "") {
            for (int i = 0; i < _logs.length; ++i) {
                if (_logs[i].log.contains (tag_filter)) {
                    filtered_logs += _logs[i];
                }
            }
            debug ("Filtered Journal for tag %s with %d logs", tag_filter, filtered_logs.length);
        } else {
            filtered_logs = _logs;
        }
        updated_journal_logs (tag_filter, filtered_logs);
    }

    private File ? choose_json_file (string label = "Choose JSON File", string json_file_name = "") {
        var json_filter = new Gtk.FileFilter ();
        json_filter.add_pattern ("*.json");
        json_filter.set_filter_name (_("JSON (*.json)"));

        var file_chooser = new Gtk.FileChooserNative (
            label,
            null,
            Gtk.FileChooserAction.SAVE,
            _("Save"),
            _("Cancel")
        );
        if (json_file_name != "") {
            file_chooser.do_overwrite_confirmation = true;
            file_chooser.set_current_name (json_file_name);
        }
        file_chooser.add_filter (json_filter);
        file_chooser.set_current_folder (Environment.get_home_dir ());

        string file = "";
        string name = "";
        string extension = "";
        if (file_chooser.run () == Gtk.ResponseType.ACCEPT) {
            file = file_chooser.get_filename ();
            extension = file.slice (file.last_index_of (".", 0), file.length);

            if (extension.length == 0 || extension[0] != '.') {
                extension = ".json";
                file += extension;
            }

            name = file.slice (file.last_index_of ("/", 0) + 1, file.last_index_of (".", 0));
            message ("name is %s extension is %s\n", name, extension);
        }

        file_chooser.destroy ();

        if (file != "") {
            var f = File.new_for_path (file);
            return f;
        }

        return null;
    }

    public void ? import_journal () {
        File ? file = choose_json_file ("Reset and Restore Journal");
        if (file != null) {
            if (_log_reader == null) {
                _log_reader = Journal.LogReader.shared_instance ();
            }
            var logs = _log_reader.load_journal_from_json_file (file.get_path ());

            if (_log_dao == null) {
                _log_dao = new Journal.LogDao ();
            }
            for (uint i = 0; i < logs.length; i++) {
                var log = (Journal.LogModel) logs[i];
                Journal.LogModel log_inserted = _log_dao.insert_entity (log);
                debug ("log_inserted: %s", log_inserted.to_string ());
            }
            debug ("Imported Journal with %d logs", logs.length);
            updated_journal_logs ("", logs);
        }
    }

    public void export_journal () {
        var json_file_name = "TrimirJournal_backup_%s.json".printf (
            new DateTime.now_local ().format ("%Y-%m-%d")
        );

        File ? file = choose_json_file ("Backup Journal", json_file_name);
        if (file != null) {
            if (_log_dao == null) {
                _log_dao = new Journal.LogDao ();
            }
            Journal.LogModel[] ? logs = _log_dao.select_all_entities ();

            if (_log_writer == null) {
                _log_writer = Journal.LogWriter.shared_instance ();
            }
            _log_writer.write_journal_to_json_file (logs, file.get_path ());
        }
    }
}
