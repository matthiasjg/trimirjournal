/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

const string SQL_DB_FILE_NAME = "io_trimir_journal_1_0_0_test";
const string TEST_DATA_FILE_JSON = "ZenJournal_backup.json";

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
        Journal.LogModel[] logs_read = log_reader.load_journal (json_file);
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
        Journal.LogModel[] logs_read = log_reader.load_journal (json_file);
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
}


int main (string[] args) {
    Test.init (ref args);
    add_log_dao_tests ();
    return Test.run ();
}
