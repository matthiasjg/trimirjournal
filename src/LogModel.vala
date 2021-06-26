/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.LogModel : Object {
    public string log { get; private set; }
    public string created_at { get; private set; }

    public LogModel (string log = "", string created_at = "") {
        _log = log;
        _created_at = created_at;
    }

    public LogModel.fromJsonObject (Json.Object json) {
        _log = json.get_string_member ("log");
        _created_at = json.get_string_member ("createdAt");
    }
}

