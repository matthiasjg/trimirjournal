/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

class Journal.Controller : Object {
    static Controller __instance;

    private Journal.LogReader _log_reader;
    private Journal.LogModel[]? _logs;

    public signal void updated_journal_logs( string tag_filter, LogModel[] logs );

    public static Controller sharedInstance() {
        if ( __instance == null ) {
            __instance = new Journal.Controller();
        }
        return __instance;
    }

    public void load_journal_logs( string tag_filter = "" ) {
        if ( _logs == null ) {
            _log_reader = Journal.LogReader.sharedInstance();
            _logs = _log_reader.loadJournal();
        }
        print( @"Loaded Journal with $(_logs.length) logs\n" );

        var filtered_logs = new Journal.LogModel[] {};
        if ( tag_filter != "" ) {
            for( int i = 0; i < _logs.length; ++i ) {
                if ( _logs[i].log.contains( tag_filter ) ) {
                    filtered_logs += _logs[i];
                }
            }
            print( @"Filtered Journal for tag $(tag_filter) with $(filtered_logs.length) logs\n" );
        } else {
            filtered_logs = _logs;
        }
        updated_journal_logs( tag_filter, filtered_logs );
    }
}

