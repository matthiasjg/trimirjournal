/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.LogModel : Object {
    private const string JSON_LOG = "log";
    private const string JSON_ASSET_TEXT = "text";
    private const string JSON_CREATED_AT = "createdAt";

    public int id { get; public set; }
    public string created_at { get; public set; }
    public string log { get; public set; }

    public LogModel (string log) {
        var date_time_utc = new DateTime.now_utc ();
        var date_time_utc_iso8601_zulu = date_time_utc.format ("%Y-%m-%dT%H:%M:%S.000Z");
        _log = log;
        _created_at = date_time_utc_iso8601_zulu;
        _id = (int) get_unix_from_local_iso8601 (created_at);
    }

    public LogModel.with_created_at (string log, string created_at) {
        _log = log;
        _created_at = created_at;
        _id = (int) get_unix_from_local_iso8601 (created_at);
    }

    public LogModel.with_id (int id, string log, string created_at) {
        _id = id;
        _log = log;
        _created_at = created_at;
    }

    public LogModel.from_json_object (Json.Object json) {
        _log = json.get_string_member (JSON_LOG);
        _created_at = json.get_string_member (JSON_CREATED_AT);
        _id = (int) get_unix_from_local_iso8601 (_created_at);
    }

    public LogModel.from_asset_json_object (Json.Object json) {
        _log = json.get_string_member (JSON_ASSET_TEXT);
        int64 created_at_unix = json.get_int_member (JSON_CREATED_AT);
        _created_at = format_date_time_from_unix (created_at_unix);
        _id = (int) get_unix_from_local_iso8601 (_created_at);
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

    public string ? to_asset_json_object () {
        Json.Builder builder = new Json.Builder ();
        builder.begin_object ();
        builder.set_member_name (JSON_ASSET_TEXT);
        builder.add_string_value (this.log);
        builder.set_member_name (JSON_CREATED_AT);
        builder.add_int_value (get_unix_from_local_iso8601 (this.created_at));
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

    public DateTime get_created_at_datetime () {
        var created_at_date_time = new DateTime.from_iso8601 (
            this.created_at,
            new TimeZone.utc ()
        );
        return created_at_date_time;
    }

    public string get_relative_created_at () {
        var created_at_date_time = new DateTime.from_iso8601 (
            this.created_at,
            new TimeZone.utc ()
        );
        return Granite.DateTime.get_relative_datetime (created_at_date_time);
    }

    private int64 get_unix_from_local_iso8601 (string created_at) {
        var created_at_date_time = new DateTime.from_iso8601 (created_at, new TimeZone.local ());
        return created_at_date_time.to_unix ();
    }

    private string format_date_time_from_unix (int64 created_at) {
        if (created_at.to_string ().length > 10) {
            // THIS feels strange, maybe even stupid(?) BUT required—or maybe not?
            // Anyways, a straight DateTime.from_unix_utc() on a unix timestamp w/ zero hour offset is null,
            // e.g. "2021-07-17T04:49:05.875Z" —› 1626497345875 —› DateTime.from_unix_utc(1626497345875) = null.
            // But when truncating zero hour offset ("875") —› 1626497345 —› DateTime.from_unix_utc(1626497345).to_unix() = 1626497345
            string created_at_timestamp_utc = created_at.to_string ().substring (0, 10);
            string created_at_zero_hour_offset = created_at.to_string ().substring (10, -1);
            DateTime created_at_date_time = new DateTime.from_unix_utc ( (int64) int.parse (created_at_timestamp_utc));
            return created_at_date_time.format ("%Y-%m-%dT%H:%M:%S." + created_at_zero_hour_offset + "Z");
        } else {
            DateTime created_at_date_time = new DateTime.from_unix_utc (created_at);
            if (created_at_date_time == null) {
                created_at_date_time = new DateTime.now_utc ().to_timezone (new TimeZone.local ());
            }
            return created_at_date_time.format ("%Y-%m-%dT%H:%M:%S.000Z");
        }
    }
}
