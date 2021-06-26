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
}
