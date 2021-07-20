/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.LogModel : Object {
    private const string JSON_LOG = "log";
    private const string JSON_CREATED_AT = "createdAt";

    public int id { get; public set; }
    public string created_at { get; public set; }
    public string log { get; public set; }

    public LogModel (string log) {
        var date_time_utc = new DateTime.now_utc ();
        var date_time_utc_iso8601_zulu = date_time_utc.format ("%Y-%m-%dT%H:%M:%S.000Z");
        _log = log;
        _created_at = date_time_utc_iso8601_zulu;
        _id = get_id_from_created_at (created_at);
    }

    public LogModel.with_created_at (string log, string created_at) {
        _log = log;
        _created_at = created_at;
        _id = get_id_from_created_at (created_at);
    }

    public LogModel.with_id (int id, string log, string created_at) {
        _id = id;
        _log = log;
        _created_at = created_at;
    }

    public LogModel.from_json_object (Json.Object json) {
        _log = json.get_string_member (JSON_LOG);
        _created_at = json.get_string_member (JSON_CREATED_AT);
        _id = get_id_from_created_at (_created_at);
    }

    public string ? to_json_object () {
        Json.Builder builder = new Json.Builder ();
        builder.begin_object ();
        builder.set_member_name (JSON_LOG);
        builder.add_string_value (this.log);
        builder.set_member_name (JSON_CREATED_AT);
        builder.add_string_value (this.created_at);
        builder.end_object ();

        Json.Generator generator = new Json.Generator ();
        generator.set_root (builder.get_root ());
        return generator.to_data (null);
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
