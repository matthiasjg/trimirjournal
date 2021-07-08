/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

 public class Journal.LogDao : Object {
    protected Gda.Connection __conn;

    private const string SQL_DB_FILE = "io_trimir_journal_1_0_0";
    private const string SQL_TABLE_NAME_LOGS = "logs";
    private const string SQL_COLUMN_NAME_CREATED_AT = "created_at";
    private const string SQL_COLUMN_NAME_LOG = "log";
    private const string SQL_STATEMENT_CREATE_TABLE_LOGS = """
        CREATE TABLE IF NOT EXISTS logs (
            created_at DATE PRIMARY KEY,
            log TEXT NOT NULL
        );
    """;

    public LogDao () {
        init_db ();
    }

    public Journal.LogModel[] ? get_all () requires (__conn.is_opened ()) {
        var builder = new Gda.SqlBuilder (Gda.SqlStatementType.SELECT);
        builder.select_add_field ("*", null, null);
        builder.select_add_target (SQL_TABLE_NAME_LOGS, null);

        Journal.LogModel[] logs = null;
        try {
            Gda.Statement stmt = builder.get_statement ();
            debug (stmt.to_sql_extended (__conn, null, Gda.StatementSqlFlag.PARAMS_AS_VALUES, null));
            Gda.DataModel data_model = __conn.statement_execute_select (stmt, null);
            var iter = data_model.create_iter ();
            do {
                Journal.LogModel log = new Journal.LogModel (
                    iter.get_value_for_field (SQL_COLUMN_NAME_CREATED_AT).get_string (),
                    iter.get_value_for_field (SQL_COLUMN_NAME_LOG).get_string ()
                );
                debug (log.to_string ());
                logs+= log;
            } while (iter.move_next ());
            debug ("%d", logs.length);
        } catch (Error e) {
            critical ("Could not SELECT all logs");
            return null;
        }
        return logs;
    }

    public Journal.LogModel get_log (string created_at) requires (__conn.is_opened ()) {
        var builder = new Gda.SqlBuilder (Gda.SqlStatementType.SELECT);
        builder.set_where ((Gda.SqlBuilderId) created_at);
        builder.select_add_target (SQL_TABLE_NAME_LOGS, null);

        Journal.LogModel log = null;
        try {
            Gda.Statement stmt = builder.get_statement ();
            debug (stmt.to_sql_extended (__conn, null, Gda.StatementSqlFlag.PARAMS_AS_VALUES, null));
            Gda.DataModel data_model = __conn.statement_execute_select (stmt, null);

            var iter = data_model.create_iter ();
            log = new Journal.LogModel (
                iter.get_value_for_field (SQL_COLUMN_NAME_CREATED_AT).get_string (),
                iter.get_value_for_field (SQL_COLUMN_NAME_LOG).get_string ()
            );
        } catch (Error e) {
            critical ("Could not SELECT all logs");
        }

        return log;
    }

    public void create_log (Journal.LogModel log) requires (__conn.is_opened ()) {
        var builder = new Gda.SqlBuilder (Gda.SqlStatementType.INSERT);
        var created_at_val = Value (typeof (string));
        var log_val = Value (typeof (string));
        created_at_val.set_string (log.created_at);
        log_val.set_string (log.log);
        builder.add_field_value_as_gvalue (SQL_COLUMN_NAME_CREATED_AT, created_at_val);
        builder.add_field_value_as_gvalue (SQL_COLUMN_NAME_LOG, log_val);
        try {
            Gda.Set inserted_row;
            Gda.Statement stmt = builder.get_statement ();
            debug (stmt.to_sql_extended (__conn, null, Gda.StatementSqlFlag.PARAMS_AS_VALUES, null));
            __conn.statement_execute_non_select (stmt, null , out inserted_row);

            var id = inserted_row.get_holder_value ("id").get_uint ();
            stdout.printf (@"inserted id: $id");
        } catch (Error e) {
            critical ("Could not INSERT log: %s %s", log.created_at, log.log);
        }
    }

    public void update_log (Journal.LogModel log) requires (__conn.is_opened ()) {
        debug ("TODO not implemented yet");
    }

    public void destroy_log (string createt_at) requires (__conn.is_opened ()) {
        debug ("TODO not implemented yet");
    }

    /*-
    * Copyright (c) 2012-2018 elementary LLC. (https://elementary.io)
    *
    * This program is free software: you can redistribute it and/or modify
    * it under the terms of the GNU Lesser General Public License as published by
    * the Free Software Foundation, either version 2 of the License, or
    * (at your option) any later version.
    *
    * This program is distributed in the hope that it will be useful,
    * but WITHOUT ANY WARRANTY; without even the implied warranty of
    * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    * GNU Lesser General Public License for more details.
    *
    * You should have received a copy of the GNU Lesser General Public License
    * along with this program.  If not, see <http://www.gnu.org/licenses/>.
    *
    * The Music authors hereby grant permission for non-GPL compatible
    * GStreamer plugins to be used and distributed together with GStreamer
    * and Music. This permission is above and beyond the permissions granted
    * by the GPL license by which Music is covered. If you modify this code
    * you may extend this exception to your version of the code, but you are not
    * obligated to do so. If you do not wish to do so, delete this exception
    * statement from your version.
    *
    * Authored by: Scott Ringwelski <sgringwe@mtu.edu>
    *              Victor Eduardo <victoreduardm@gmail.com>
    *              Corentin Noël <corentin@elementary.io>
    */
    // https://github.com/elementary/music/blob/master/src/LocalBackend/LocalLibrary.vala
    private void init_db () {
        var database_dir = Journal.Utils.get_data_directory ();
        try {
            database_dir.make_directory_with_parents (null);
        } catch (Error err) {
            if (err is IOError.EXISTS == false)
                error ("Could not create data directory: %s", err.message);
        }

        var db_file = database_dir.get_child (SQL_DB_FILE + ".db");
        bool new_db = !db_file.query_exists ();
        if (new_db) {
            try {
                db_file.create (FileCreateFlags.PRIVATE);
            } catch (Error e) {
                critical ("Error: %s", e.message);
            }
        }

        try {
            __conn = new Gda.Connection.from_string (
                "SQLite",
                "DB_DIR=%s;DB_NAME=%s".printf (database_dir.get_path (), SQL_DB_FILE),
                null,
                Gda.ConnectionOptions.NONE);
            __conn.open ();
        } catch (Error e) {
            error (e.message);
        }

        create_table ();
    }

    private void create_table () requires (__conn.is_opened ()) {
        try {
            var result = __conn.execute_non_select_command (SQL_STATEMENT_CREATE_TABLE_LOGS);
            debug ("Table %s created: %s", SQL_TABLE_NAME_LOGS, result.to_string ());
        } catch (Error e) {
            critical ("Could not CREATE TABLE %s", SQL_TABLE_NAME_LOGS);
        }
    }

}
