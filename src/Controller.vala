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

    public signal void updated_journal_logs (string log_filter, bool is_tag_filter, LogModel[] logs);

    public static Controller shared_instance () {
        if (__instance == null) {
            __instance = new Journal.Controller ();
        }
        return __instance;
    }

    public void add_journal_log_entry (string log_txt = "") {
        if (log_txt == "") {
            return;
        }

        if (_log_dao == null) {
            _log_dao = new Journal.LogDao ();
        }
        var log = new Journal.LogModel (log_txt);
        var log_inserted = _log_dao.insert_entity (log);
        debug ("log_inserted: %s", log_inserted.to_string ());
        load_journal_logs ();
    }

    public void load_journal_logs (string log_filter = "") {
        if (_log_dao == null) {
            _log_dao = new Journal.LogDao ();
        }

        if (log_filter == "") {
            _logs = _log_dao.select_all_entities ();
        } else {
            _logs = _log_dao.select_entities_where_column_like (
                Journal.LogDao.SQL_COLUMN_NAME_LOG,
                log_filter);
        }
        debug ("Loaded %d Journal logs filtered for %s", _logs.length, log_filter);

        Regex? tag_regex = null;
        try {
            tag_regex = new Regex ("^#\\w+$");
        } catch (Error err) {
            critical (err.message);
        }
        var is_tag_filter = tag_regex.match (log_filter);

        updated_journal_logs (log_filter, is_tag_filter, _logs);
    }

    private File ? choose_file (
        Gtk.FileChooserAction action,
        string label = "Choose JSON or ZIP File",
        string target_file_name = ""
    ) {
        var file_filter = new Gtk.FileFilter ();
        file_filter.add_pattern ("*.json");
        file_filter.add_pattern ("*.zip");
        file_filter.set_filter_name (_("JSON (*.json), ZIP (*.zip)"));

        var action_label = action == Gtk.FileChooserAction.SAVE ? _("Save") : _("Open");

        var file_chooser = new Gtk.FileChooserNative (
            label,
            null,
            action,
            action_label,
            _("Cancel")
        );
        if (target_file_name != "") {
            file_chooser.do_overwrite_confirmation = true;
            file_chooser.set_current_name (target_file_name);
        }
        file_chooser.add_filter (file_filter);
        file_chooser.set_current_folder (Environment.get_home_dir ());

        File file = null;
        if (file_chooser.run () == Gtk.ResponseType.ACCEPT) {
            file = File.new_for_path (file_chooser.get_filename ());
            string name = file_chooser.get_filename ();
            name = name.slice (name.last_index_of ("/", 0) + 1, name.last_index_of (".", 0));

            string ext = get_supported_file_extension (file);
            name += ext;
            message ("name is %s extension is %s\n", name, ext);
        }

        file_chooser.destroy ();

        return file;
    }

    public void import_journal () {
        File ? file = choose_file (Gtk.FileChooserAction.OPEN, _("Reset and Restore Journal"));
        if (file != null) {
            if (_log_reader == null) {
                _log_reader = Journal.LogReader.shared_instance ();
            }
            Journal.LogModel[] logs = null;

            string ext = get_supported_file_extension (file);
            if (ext == "json") {
                logs = _log_reader.load_journal_from_json_file (file);
            } else if (ext == "zip") {
                logs = _log_reader.load_journal_from_zip_archive_file (file);
            }

            // force re-create db, i.e. reset
            _log_dao = new Journal.LogDao (Journal.BaseDao.DB_FILE_NAME, true);

            for (uint i = 0; i < logs.length; i++) {
                var log = (Journal.LogModel) logs[i];
                Journal.LogModel log_inserted = _log_dao.insert_entity (log);
                debug ("log_inserted: %s", log_inserted.to_string ());
            }
            debug ("Imported Journal with %d logs", logs.length);
            updated_journal_logs ("", false, logs);
        }
    }

    public void export_journal () {
        var default_file_name = "TrimirJournal_backup_%s.json".printf (
            new DateTime.now_local ().format ("%Y-%m-%d")
        );

        File ? file = choose_file (Gtk.FileChooserAction.SAVE, _("Backup Journal"), default_file_name);
        if (file != null) {
            if (_log_dao == null) {
                _log_dao = new Journal.LogDao ();
            }
            Journal.LogModel[] ? logs = _log_dao.select_all_entities ();

            if (_log_writer == null) {
                _log_writer = Journal.LogWriter.shared_instance ();
            }

            string ext = get_supported_file_extension (file);
            if (ext == "json") {
                _log_writer.write_journal_to_json_file (logs, file);
            } else if (ext == "zip") {
                _log_writer.write_journal_to_zip_archive_file (logs, file);
            }
        }
    }

    private string get_supported_file_extension (File file) {
        string file_name = file.get_basename ();
        string ext = file_name.slice (file_name.last_index_of (".", 0) + 1, file_name.length);
        if (ext.length == 0 || ext == "." || (ext != "json" && ext != "zip")) {
            warning ("Unsupported file extension: %s", ext);
            ext = "json"; // sane default
        }
        return ext;
    }
}
