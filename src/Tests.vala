/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

void add_log_dao_tests () {
    Test.add_func ("/LogDao/get_all", () => {
        Journal.LogDao log_dao = new Journal.LogDao ();
        assert ("foo" + "bar" == "foobar");
    });
}


int main (string[] args) {
    Test.init (ref args);
    add_log_dao_tests ();
    return Test.run ();
}
