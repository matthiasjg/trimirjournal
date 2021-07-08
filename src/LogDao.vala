/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

 public class Journal.LogDao : Journal.BaseDao<Journal.LogModel> {
    private Gda.Connection db_connection;

    private const string SQL_TABLE_NAME = "logs";
    private const string SQL_STATEMENT_CREATE_TABLE = """
        CREATE TABLE IF NOT EXISTS logs (
            created_at TEXT PRIMARY KEY,
            log TEXT NOT NULL
        );
    """;

    private const string SQL_COLUMN_NAME_CREATED_AT = "created_at";
    private const string SQL_COLUMN_NAME_LOG = "log";

    public LogDao (string db_file_name = DB_FILE_NAME ) {
        db_connection = init_db (db_file_name, SQL_TABLE_NAME, SQL_STATEMENT_CREATE_TABLE);
    }

    public override Journal.LogModel[] ? select_all_entities () requires (db_connection.is_opened ()) {
        var builder = new Gda.SqlBuilder (Gda.SqlStatementType.SELECT);
        builder.select_add_field ("*", null, null);
        builder.select_add_target (SQL_TABLE_NAME, null);

        Journal.LogModel[] logs = null;
        try {
            Gda.Statement stmt = builder.get_statement ();
            debug (stmt.to_sql_extended (db_connection, null, Gda.StatementSqlFlag.PARAMS_AS_VALUES, null));
            Gda.DataModel data_model = db_connection.statement_execute_select (stmt, null);
            int row_count = data_model.get_n_rows ();
            debug ("Row count: %d", row_count);
            if (row_count > 0) {
                var iter = data_model.create_iter ();
                do {
                    Journal.LogModel log = new Journal.LogModel (
                        iter.get_value_for_field (SQL_COLUMN_NAME_CREATED_AT).get_string (),
                        iter.get_value_for_field (SQL_COLUMN_NAME_LOG).get_string ()
                    );
                    debug (log.to_string ());
                    logs+= log;
                } while (iter.move_next ());
                debug ("Number of logs retrieved: %d", logs.length);
            }
        } catch (Error e) {
            critical ("Could not SELECT all logs");
        }
        return logs;
    }

    public override Journal.LogModel select_entity (string created_at) requires (db_connection.is_opened ()) {
        var builder = new Gda.SqlBuilder (Gda.SqlStatementType.SELECT);
        builder.set_where ((Gda.SqlBuilderId) created_at);
        builder.select_add_target (SQL_TABLE_NAME, null);

        Journal.LogModel log = null;
        try {
            Gda.Statement stmt = builder.get_statement ();
            debug (stmt.to_sql_extended (db_connection, null, Gda.StatementSqlFlag.PARAMS_AS_VALUES, null));
            Gda.DataModel data_model = db_connection.statement_execute_select (stmt, null);

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

    public override bool insert_entity (Journal.LogModel log) requires (db_connection.is_opened ()) {
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
            debug (stmt.to_sql_extended (db_connection, null, Gda.StatementSqlFlag.PARAMS_AS_VALUES, null));
            db_connection.statement_execute_non_select (stmt, null , out inserted_row);

            var id = inserted_row.get_holder_value ("id").get_uint ();
            stdout.printf (@"inserted id: $id");
            return true;
        } catch (Error e) {
            critical ("Could not INSERT log: %s %s", log.created_at, log.log);
            return false;
        }
    }

    public override bool update_entity (Journal.LogModel log) requires (db_connection.is_opened ()) {
        debug ("TODO not implemented yet");
        return false;
    }

    public override bool delete_entity (string created_at) requires (db_connection.is_opened ()) {
        debug ("TODO not implemented yet");
        return false;
    }
}
