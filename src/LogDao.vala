/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

 public class Journal.LogDao : Object {
    protected Gda.Connection __conn;

    protected string conn_str = "SQLite://DB_DIR=.;DB_NAME=io.trimir.journal";

    private const string SQL_TABLE_NAME_LOGS = "logs";
    private const string SQL_COLUMN_NAME_CREATED_AT = "created_at";
    private const string SQL_COLUMN_NAME_LOG = "log";
    private const string SQL_STATEMENT_CREATE_TABLE_LOGS = """
        CREATE TABLE IF NOT EXISTS %s (
            created_at DATE PRIMARY KEY,
            log TEXT NOT NULL
        );
    """;

    public Journal.LogModel[] ? get_all ()
        requires (__conn.is_opened ()) {
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

    public Journal.LogModel get_log (string created_at)
        requires (__conn.is_opened ()) {
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

    public void create_log (Journal.LogModel log)
        requires (__conn.is_opened ()) {
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

    public void update_log (Journal.LogModel log) {
        debug ("TODO not implemented yet");
    }

    public void destroy_log (string createt_at) {
        debug ("TODO not implemented yet");
    }

    protected void create_table () {
        try {
            var result = __conn.execute_non_select_command (SQL_STATEMENT_CREATE_TABLE_LOGS);
            debug ("Table %s created: %s", SQL_TABLE_NAME_LOGS, result.to_string ());
        } catch (Error e) {
            critical ("Could not CREATE TABLE %s", SQL_TABLE_NAME_LOGS);
        }
    }
}
