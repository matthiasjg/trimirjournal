/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

const string SQL_DB_FILE_NAME = "io_trimir_journal_1_0_0_test";

const string TEST_DATA_FILE_JSON = "ZenJournal_backup.json";

void add_log_dao_tests () {
    Test.add_func ("/LogDao/select_all_entities", () => {
        Journal.LogDao log_dao = new Journal.LogDao (SQL_DB_FILE_NAME);
        Journal.LogModel[] ? logs = log_dao.select_all_entities ();
        assert (logs == null || logs.length == 0);
    });

    Test.add_func ("/LogDao/create_entity", () => {
        debug ("TEST_DATA_DIR: %s", TEST_DATA_DIR);
        Journal.LogDao log_dao = new Journal.LogDao (SQL_DB_FILE_NAME);
        Journal.LogModel[] ? logs = log_dao.select_all_entities ();
        assert (logs == null || logs.length == 0);
    });
}


int main (string[] args) {
    Test.init (ref args);
    add_log_dao_tests ();
    return Test.run ();
}
