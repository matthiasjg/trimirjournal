/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.LogChartView : Gtk.Box {
    private Journal.Controller _controller;

    private LiveChart.Static.StaticSerie serie;
    private LiveChart.Static.StaticChart chart;

    public LogChartView () {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 0,
            expand: false
        );
    }

    construct {
        _controller = Journal.Controller.shared_instance ();
        _controller.updated_journal_logs.connect (on_updated_journal_logs);
        _controller.load_journal_logs ();
    }

    private void on_updated_journal_logs (string log_filter, bool is_tag_filter, LogModel[] logs) {
        Regex? value_unit_regex = null;
        try {
            value_unit_regex = new Regex ("%s\\s*(\\S+)".printf (log_filter));
        } catch (Error err) {
            critical (err.message);
        }

        if (is_tag_filter) {
            // colors
            Gdk.RGBA gdk_white = { 1.0, 1.0, 1.0, 1.0 };
            Gdk.RGBA gdk_black = { 0.0, 0.0, 0.0, 1.0 };
            var gtk_settings = Gtk.Settings.get_default ();
            var bg_color = gtk_settings.gtk_application_prefer_dark_theme ? gdk_white : gdk_black;

            serie = new LiveChart.Static.StaticSerie (log_filter);
            serie.line.color = Granite.contrasting_foreground_color (bg_color);

            chart = new LiveChart.Static.StaticChart ();
            chart.background.color = bg_color;
            chart.legend.visible = false;
            chart.add_serie (serie);

            var categories = new Gee.ArrayList<string> ();
            var unit = "";
            var is_metric_valid = false;
            for (int i = logs.length - 1; i + 1 > 0; --i) {
                var log = logs[i];
                var relative_created_at = log.get_relative_created_at ();
                var tag_metric = new Journal.TagMetricModel.from_log (log.log, log_filter);
                if (tag_metric.value.is_normal ()) {
                    if (unit == "" || unit == tag_metric.unit) {
                        unit = tag_metric.unit;
                    }
                    categories.add (relative_created_at);
                    serie.add (relative_created_at, tag_metric.value);
                    is_metric_valid = true;
                }
            }

            if (is_metric_valid) {
                chart.set_categories (categories);
                chart.config.y_axis.unit = unit;

                pack_start (chart, true, true, 0);

                this.expand = true;
            }
        } else {
            if (chart != null) {
                remove (chart);
            }
            this.expand = false;
        }
        show_all ();
    }

}
