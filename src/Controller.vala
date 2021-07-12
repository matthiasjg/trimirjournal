/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

class Journal.Controller : Object {
    static Controller __instance;

    private Journal.LogReader _log_reader;
    private Journal.LogModel[] ? _logs;

    public signal void updated_journal_logs (string tag_filter, LogModel[] logs);

    public static Controller shared_instance () {
        if (__instance == null) {
            __instance = new Journal.Controller ();
        }
        return __instance;
    }

    public void load_journal_logs (string tag_filter = "") {
        if (_logs == null) {
            _log_reader = Journal.LogReader.shared_instance ();
            _logs = _log_reader.load_journal ();
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

    public void export_journal () {

        var json_file_name = "TrimirJournal_backup_%s.json".printf (
            new DateTime.now_local ().format ("%Y-%m-%d")
        );
        var json_filter = new Gtk.FileFilter ();
        json_filter.add_pattern ("*.json");
        json_filter.set_filter_name (_("JSON (*.json)"));

        var file_chooser = new Gtk.FileChooserNative (
            _("Backup Journal"),
            null,
            Gtk.FileChooserAction.SAVE,
            _("Save"),
            _("Cancel")
        );
        file_chooser.do_overwrite_confirmation = true;
        file_chooser.set_current_name (json_file_name);
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

            string folder = f.get_parent ().get_uri ();
            save_journal_export (f.get_basename (), folder);
        }
    }

    private bool save_journal_export (string json_file_name, string folder_uri) {
        bool saved = false;
        string to_save = "[]";

        File dest = GLib.File.new_for_uri (folder_uri + "/" + json_file_name.replace ("/", "_"));
        try {
            var file_stream = dest.create (FileCreateFlags.NONE);
            var data_stream = new DataOutputStream (file_stream);
            data_stream.put_string (to_save);
            saved = true;
        }
        catch (Error err) {
            warning ("Could not save Journal export to file %s at %s: %s",
                json_file_name, dest.get_path (), err.message);
        }

        return saved;
    }
}
