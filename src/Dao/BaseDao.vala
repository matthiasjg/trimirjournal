/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

 public abstract class Journal.BaseDao<TModel> : Object {
    protected Gda.Connection db_connection;

    protected const string DB_FILE_NAME = "io_trimir_journal_1_0_0";

    public abstract TModel[] ? select_all_entities ();

    public abstract TModel[] ? select_entities_where_column_like (string column, string like);

    public abstract TModel ? select_entity (int id);

    public abstract TModel ? insert_entity (TModel t_model);

    public abstract TModel ? update_entity (TModel t_model);

    public abstract bool delete_entity (int id);

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
    protected Gda.Connection ? init_db (
        string db_file_name = DB_FILE_NAME,
        bool db_force_create = false,
        string sql_table_name = "",
        string sql_stmt_create_table = ""
    ) {
        debug ("db_file_name: %s", db_file_name);
        var database_dir = Journal.Utils.get_data_directory ();
        try {
            database_dir.make_directory_with_parents (null);
        } catch (Error err) {
            if (err is IOError.EXISTS == false)
                error ("Could not create data directory: %s", err.message);
        }

        var db_file = database_dir.get_child (db_file_name + ".db");
        bool new_db = !db_file.query_exists ();
        if (!new_db && db_force_create) {
            try {
                db_file.delete ();
            } catch (Error err) {
                print ("Error: %s", err.message);
            }
        }
        if (new_db) {
            try {
                db_file.create (FileCreateFlags.PRIVATE);
            } catch (Error err) {
                critical ("Error: %s", err.message);
            }
        }

        try {
            db_connection = new Gda.Connection.from_string (
                "SQLite",
                "DB_DIR=%s;DB_NAME=%s".printf (database_dir.get_path (), db_file_name),
                null,
                Gda.ConnectionOptions.NONE);
            db_connection.open ();
            create_table (sql_table_name, sql_stmt_create_table);
        } catch (Error err) {
            error (err.message);
        }
        return db_connection;
    }

    private void create_table (
        string sql_table_name = "",
        string sql_stmt_create_table = ""
    ) requires (db_connection.is_opened ()) {
        debug ("sql_table_name: %s", sql_table_name);
        debug ("sql_stmt_create_table: %s", sql_stmt_create_table);
        if (sql_table_name == "") {
            critical ("Missing SQL table name: %s", sql_table_name);
        } else if (sql_stmt_create_table == "") {
            critical ("Missing SQL create table statement: %s", sql_table_name);
        } else {
            try {
                var result = db_connection.execute_non_select_command (sql_stmt_create_table);
                debug ("Table %s created: %s", sql_table_name, result.to_string ());
            } catch (Error err) {
                critical ("Could not CREATE TABLE %s: %s", sql_table_name, err.message);
            }
        }
    }
}
