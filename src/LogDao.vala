/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

 public class Journal.LogDao : Journal.BaseDao<Journal.LogModel> {
    private const string SQL_TABLE_NAME = "logs";

    private const string SQL_COLUMN_NAME_ID = "id";
    private const string SQL_COLUMN_NAME_CREATED_AT = "created_at";
    private const string SQL_COLUMN_NAME_LOG = "log";

    public LogDao (string db_file_name = DB_FILE_NAME, bool db_force_create = false ) {
        db_connection = init_db (
            db_file_name,
            db_force_create,
            SQL_TABLE_NAME,
            get_create_table_sql_statement ()
        );
    }

    private string get_create_table_sql_statement () {
        return """
            CREATE TABLE IF NOT EXISTS %s (
                %s INTEGER PRIMARY KEY,
                %s TEXT NOT NULL,
                %s TEXT NOT NULL
            );
        """.printf (
                SQL_TABLE_NAME,
                SQL_COLUMN_NAME_ID,
                SQL_COLUMN_NAME_CREATED_AT,
                SQL_COLUMN_NAME_LOG
            );
    }

    private Journal.LogModel get_log_from_data_model (Gda.DataModelIter iter) {
        debug ("iter %d", iter.current_row);
        Journal.LogModel log = new Journal.LogModel.with_id (
            iter.get_value_for_field (SQL_COLUMN_NAME_ID).get_int (),
            iter.get_value_for_field (SQL_COLUMN_NAME_CREATED_AT).get_string (),
            iter.get_value_for_field (SQL_COLUMN_NAME_LOG).get_string ()
        );
        return log;
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
                    Journal.LogModel log = get_log_from_data_model (iter);
                    debug (log.to_string ());
                    logs+= log;
                } while (iter.move_next ());
                debug ("Number of logs retrieved: %d", logs.length);
            }
        } catch (Error e) {
            critical ("Could not SELECT all logs: %s", e.message);
        }
        return logs;
    }

    public override Journal.LogModel select_entity (int id) requires (db_connection.is_opened ()) {
        var builder = new Gda.SqlBuilder (Gda.SqlStatementType.SELECT);
        builder.select_add_field ("*", null, null);
        builder.select_add_target (SQL_TABLE_NAME, null);
        var id_val = Value (typeof (int));
        id_val.set_int (id);
        var id_field = builder.add_id (SQL_COLUMN_NAME_ID);
        var id_param = builder.add_expr_value (null, id_val);
        var id_cond = builder.add_cond (Gda.SqlOperatorType.EQ, id_field, id_param, 0);
        builder.set_where (id_cond);

        Journal.LogModel log = null;
        try {
            Gda.Statement stmt = builder.get_statement ();
            debug (stmt.to_sql_extended (db_connection, null, Gda.StatementSqlFlag.PARAMS_AS_VALUES, null));
            Gda.DataModel data_model = db_connection.statement_execute_select (stmt, null);
            int row_count = data_model.get_n_rows ();
            debug ("Row count: %d", row_count);
            var iter = data_model.create_iter ();
            iter.move_to_row (0);
            do {
                log = get_log_from_data_model (iter);
            } while (iter.move_next ());
        } catch (Error e) {
            critical ("Could not SELECT log %s: %s", id.to_string (), e.message);
        }
        return log;
    }

    public override Journal.LogModel insert_entity (Journal.LogModel log) requires (db_connection.is_opened ()) {
        var builder = new Gda.SqlBuilder (Gda.SqlStatementType.INSERT);
        var id_val = Value (typeof (int));
        var created_at_val = Value (typeof (string));
        var log_val = Value (typeof (string));
        id_val.set_int (log.id);
        created_at_val.set_string (log.created_at);
        log_val.set_string (log.log);
        builder.set_table (SQL_TABLE_NAME);
        builder.add_field_value_as_gvalue (SQL_COLUMN_NAME_ID, id_val);
        builder.add_field_value_as_gvalue (SQL_COLUMN_NAME_CREATED_AT, created_at_val);
        builder.add_field_value_as_gvalue (SQL_COLUMN_NAME_LOG, log_val);
        try {
            Gda.Set inserted_row;
            Gda.Statement stmt = builder.get_statement ();
            debug (stmt.to_sql_extended (db_connection, null, Gda.StatementSqlFlag.PARAMS_AS_VALUES, null));
            db_connection.statement_execute_non_select (stmt, null , out inserted_row);
            log.id = (int) inserted_row.get_holder_value ("+0").get_int ();
        } catch (Error e) {
            critical ("Could not INSERT log '%s': %s", log.to_string (), e.message);
        }
        return log;
    }

    public override Journal.LogModel update_entity (Journal.LogModel log) requires (db_connection.is_opened ()) {
        critical ("Not implemented yet");
        return log;
    }

    public override bool delete_entity (int id) requires (db_connection.is_opened ()) {
        critical ("Not implemented yet");
        return false;
    }
}
