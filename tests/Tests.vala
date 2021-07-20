/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

const string SQL_DB_FILE_NAME = "io_trimir_journal_1_0_0_test";
const string TEST_DATA_FILE_JSON = "ZenJournal_backup.json";

void add_date_time_tests () {
    Test.add_func ("/DateTime/iso8601_with_zero_hour_offset", () => {
        /* "Zulu time" (UTC)
        SimpleDateFormat format = new SimpleDateFormat(
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US);
            format.setTimeZone(TimeZone.getTimeZone("UTC")); */
        var date_time_now = new DateTime.now_utc ();
        var date_time_now_utc = date_time_now.to_timezone (new TimeZone.utc ());
        var date_time_now_utc_iso8601 = date_time_now_utc.format_iso8601 ();
        var date_time_now_iso8601 = date_time_now.format_iso8601 ();
        var date_time_now_iso8601_zulu = date_time_now.format ("%Y-%m-%dT%H:%M:%S.000Z");
        debug ("date_time_now: %s", date_time_now.to_string () );
        debug ("date_time_now_utc: %s", date_time_now_utc.to_string () );
        debug ("date_time_now_utc_iso8601: %s", date_time_now_utc_iso8601.to_string () );
        debug ("date_time_now_iso8601: %s", date_time_now_iso8601 );
        debug ("date_time_now_iso8601_zulu: %s", date_time_now_iso8601_zulu );
    });
}

void add_json_serialization_tests () {
    Test.add_func ("/JSON/serialize", () => {
        var json_file_path = "%s/%s".printf (TEST_DATA_DIR, TEST_DATA_FILE_JSON);
        debug ("json_file: %s", json_file_path);

        Journal.LogReader log_reader = Journal.LogReader.shared_instance ();
        var logs = log_reader.load_journal_from_json_file (json_file_path);
        var log = logs[0];

        Json.Builder builder = new Json.Builder ();
        builder.begin_object ();
        builder.set_member_name ("log");
        builder.add_string_value (log.log);
        builder.set_member_name ("createdAt");
        builder.add_string_value (log.created_at);
        builder.end_object ();

        // Json.Node root = Json.gobject_serialize (log);
        Json.Node root = builder.get_root ();

        Json.Generator generator = new Json.Generator ();
        generator.set_root (root);
        debug ("json, %s", generator.to_data (null));
    });
}

void add_log_reader_tests () {
    Test.add_func ("/LogReader/load_journal_from_json_file", () => {
        var json_file_path = "%s/%s".printf (TEST_DATA_DIR, TEST_DATA_FILE_JSON);
        debug ("json_file: %s", json_file_path);

        Journal.LogReader log_reader = Journal.LogReader.shared_instance ();
        var logs = log_reader.load_journal_from_json_file (json_file_path);

        assert (logs != null && logs.length == 4);
    });
}

void add_log_writer_tests () {
    Test.add_func ("/LogWriter/write_journal_to_json_file", () => {
        var json_file_path_read = "%s/%s".printf (TEST_DATA_DIR, TEST_DATA_FILE_JSON);

        var json_file_name_write = TEST_DATA_FILE_JSON
            .replace (".json", "_%s.json").printf (
                new DateTime.now_local ().format ("%Y-%m-%d_%H-%M-%S")
            );
        var json_file_path_write = "%s/%s".printf (Environment.get_tmp_dir (), json_file_name_write);
        debug ("json_file_path_read: %s", json_file_path_read);
        debug ("json_file_path_write: %s", json_file_path_write);

        Journal.LogReader log_reader = Journal.LogReader.shared_instance ();
        var logs_read = log_reader.load_journal_from_json_file (json_file_path_read);

        assert (logs_read != null && logs_read.length == 4);

        Journal.LogWriter log_writer = Journal.LogWriter.shared_instance ();
        var is_logs_written = log_writer.write_journal_to_json_file (logs_read, json_file_path_write);

        assert (is_logs_written == true);

        var logs_written_read = log_reader.load_journal_from_json_file (json_file_path_write);

        assert (logs_written_read != null && logs_written_read.length == logs_read.length);
    });
}

void add_journal_reset_and_restore_tests () {
    Test.add_func ("/Journal/reset_and_restore", () => {
        var json_file_path = "%s/%s".printf (TEST_DATA_DIR, TEST_DATA_FILE_JSON);
        debug ("json_file: %s", json_file_path);

        Journal.LogReader log_reader = Journal.LogReader.shared_instance ();
        var logs_read = log_reader.load_journal_from_json_file (json_file_path);

        assert (logs_read != null && logs_read.length == 4);

        Journal.LogDao log_dao = new Journal.LogDao (SQL_DB_FILE_NAME, true);
        for (uint i = 0; i < logs_read.length; i++) {
            var log = (Journal.LogModel) logs_read[i];
            log_dao.insert_entity (log);
        }

        Journal.LogModel[] ? logs_selected = log_dao.select_all_entities ();
        assert (logs_selected != null || logs_selected.length == logs_read.length);
        assert (logs_selected[0].id == logs_read[0].id);
    });
}

void add_log_dao_tests () {
    Test.add_func ("/LogDao/select_all_entities", () => {
        Journal.LogDao log_dao = new Journal.LogDao (SQL_DB_FILE_NAME, true);
        Journal.LogModel[] ? logs = log_dao.select_all_entities ();

        assert (logs == null || logs.length == 0);
    });

    Test.add_func ("/LogDao/insert_entity", () => {
        var json_file = "%s/%s".printf (TEST_DATA_DIR, TEST_DATA_FILE_JSON);
        debug ("json_file: %s", json_file);

        Journal.LogReader log_reader = Journal.LogReader.shared_instance ();
        Journal.LogModel[] logs_read = log_reader.load_journal_from_json_file (json_file);
        var log_read = logs_read[0];

        Journal.LogDao log_dao = new Journal.LogDao (SQL_DB_FILE_NAME, true);
        Journal.LogModel log_inserted = log_dao.insert_entity (log_read);
        debug ("log_inserted: %s", log_inserted.to_string ());

        Journal.LogModel log_selected = log_dao.select_entity (log_read.id);
        debug ("log_selected: %s", log_selected.to_string ());

        assert (log_inserted.id == log_selected.id);
    });

    Test.add_func ("/LogDao/update_entity", () => {
        var json_file = "%s/%s".printf (TEST_DATA_DIR, TEST_DATA_FILE_JSON);
        debug ("json_file: %s", json_file);

        Journal.LogReader log_reader = Journal.LogReader.shared_instance ();
        Journal.LogModel[] logs_read = log_reader.load_journal_from_json_file (json_file);
        var log_read = logs_read[0];

        Journal.LogDao log_dao = new Journal.LogDao (SQL_DB_FILE_NAME, true);
        Journal.LogModel log_inserted = log_dao.insert_entity (log_read);
        debug ("log_inserted: %s", log_inserted.to_string ());
        var log_to_update = log_inserted;
        string log_update_txt = "I changed my mind #yolo";
        log_to_update.log = log_update_txt;

        Journal.LogModel log_updated = log_dao.update_entity (log_to_update);
        debug ("log_updated: %s", log_updated.to_string ());

        assert (log_updated.log == log_update_txt);
    });

    Test.add_func ("/LogDao/delete_entity", () => {
        var json_file = "%s/%s".printf (TEST_DATA_DIR, TEST_DATA_FILE_JSON);
        debug ("json_file: %s", json_file);

        Journal.LogReader log_reader = Journal.LogReader.shared_instance ();
        Journal.LogModel[] logs_read = log_reader.load_journal_from_json_file (json_file);
        var log_read = logs_read[0];

        Journal.LogDao log_dao = new Journal.LogDao (SQL_DB_FILE_NAME, true);
        Journal.LogModel log_inserted = log_dao.insert_entity (log_read);
        debug ("log_inserted: %s", log_inserted.to_string ());

        bool is_log_deleted = log_dao.delete_entity (log_inserted.id);

        assert (is_log_deleted == true);
    });

    Test.add_func ("/LogDao/select_entities_where_column_like", () => {
        var json_file_path = "%s/%s".printf (TEST_DATA_DIR, TEST_DATA_FILE_JSON);
        debug ("json_file: %s", json_file_path);

        Journal.LogReader log_reader = Journal.LogReader.shared_instance ();
        var logs_read = log_reader.load_journal_from_json_file (json_file_path);

        assert (logs_read != null && logs_read.length == 4);

        Journal.LogDao log_dao = new Journal.LogDao (SQL_DB_FILE_NAME, true);
        for (uint i = 0; i < logs_read.length; i++) {
            var log = (Journal.LogModel) logs_read[i];
            log_dao.insert_entity (log);
        }

        Journal.LogModel[] ? logs_selected = log_dao.select_entities_where_column_like (
            Journal.LogDao.SQL_COLUMN_NAME_LOG,
            "#c64"
        );
        assert (logs_selected != null || logs_selected.length == 1);
    });
}

int main (string[] args) {
    Test.init (ref args);
    add_date_time_tests ();
    add_json_serialization_tests ();
    add_log_reader_tests ();
    add_log_writer_tests ();
    add_log_dao_tests ();
    add_journal_reset_and_restore_tests ();
    return Test.run ();
}
