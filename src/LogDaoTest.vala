/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

void add_foo_tests () {
    GLib.Test.add_func ("/vala/test", () => {
        assert ("foo" + "bar" == "foobar");
    });
}


int main (string[] args) {
    Test.init (ref args);
    add_foo_tests ();
    return Test.run ();
}
