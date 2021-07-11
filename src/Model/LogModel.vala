/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.LogModel : Object {
    public int id { get; public set; }
    public string created_at { get; public set; }
    public string log { get; public set; }

    public LogModel (string log, string created_at) {
        _log = log;
        _created_at = created_at;
        _id = get_id_from_created_at (created_at);
    }

    public LogModel.with_id (int id, string log, string created_at) {
        _id = id;
        _log = log;
        _created_at = created_at;
    }

    public LogModel.fromJsonObject (Json.Object json) {
        _log = json.get_string_member ("log");
        _created_at = json.get_string_member ("createdAt");
        _id = get_id_from_created_at (_created_at);
    }

    public string to_string () {
        var str = "created_at: %s, log: %s".printf (created_at, log);
        if (id == 0) {
            return str;
        } else {
            return "id: %s, %s".printf (id.to_string (), str);
        }
    }

    private int get_id_from_created_at (string created_at) {
        var created_at_date_time = new DateTime.from_iso8601 (created_at, new TimeZone.local ());
        return (int) created_at_date_time.to_unix ();
    }
}
