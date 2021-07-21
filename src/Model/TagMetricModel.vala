/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.TagMetricModel : Object {
    public string tag { get; public set; }
    public double value { get; public set; }
    public string unit { get; public set; }

    public TagMetricModel (string tag, double value, string unit) {
        _tag = tag;
        _value = value;
        _unit = unit;
    }

    public TagMetricModel.from_log (string log, string tag) {
        Regex? value_unit_regex = null;
        Regex? value_regex = null;
        try {
            value_unit_regex = new Regex ("%s\\s*(?P<value_unit>\\S+)".printf (tag));
            value_regex = new Regex ("\\s*(?P<value>\\d+(\\.\\d+)?)");
        } catch (Error err) {
            critical (err.message);
        }

        MatchInfo info;
        string value_unit = null;
        string value = null;
        double d_value;
        string unit = null;
        if (value_unit_regex.match (log, 0, out info)) {
            value_unit = info.fetch_named ("value_unit");
            if (value_unit != null && value_unit != "") {
                if (value_regex.match (value_unit, 0, out info)) {
                    value = info.fetch_named ("value");
                    if (value != null && value != "") {
                        unit = value_unit.replace (value, "");
                        if (unit == "") {
                            unit = "#"; // assume count
                        }
                        if (unit != null && unit != "") {
                            if (double.try_parse (value, out d_value)) {
                                debug ("value_unit, value, unit: %s %f %s", value_unit, d_value, unit);
                                _tag = tag;
                                _value = d_value;
                                _unit = unit;
                            }
                        }
                    }
                }
            }
        }
    }

    public string to_string () {
        var str = "tag: %s, value: %f, unit: %s".printf (tag, value, unit);
        return str;
    }
}
