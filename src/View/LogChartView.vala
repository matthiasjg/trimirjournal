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
            // Gdk.RGBA gdk_background_color = { 122.0, 54.0, 177.0, 1.0 };
            // Gdk.RGBA gdk_line_color = { 244.0, 233.0, 110.0, 1.0 };

            var gdk_background_color = Gdk.RGBA ();
            gdk_background_color.parse ("#7A36B1");

            var gdk_line_color = Gdk.RGBA ();
            gdk_line_color.parse ("#F4E96E");

            var gdk_axis_color = Gdk.RGBA ();
            gdk_axis_color.parse ("#F4E96E");

            var gdk_labels_color = Gdk.RGBA ();
            gdk_labels_color.parse ("#F4E96E");

            // var gdk_legend_color = Gdk.RGBA ();
            // gdk_legend_color.parse ("#F4E96E");

            serie = new LiveChart.Static.StaticSerie (log_filter);
            serie.line.color = gdk_line_color;

            chart = new LiveChart.Static.StaticChart ();

            /* chart.config.padding = LiveChart.Padding () {
                smart = LiveChart.AutoPadding.NONE,
                top = 0,
                right = 0,
                bottom = 0,
                left = 0
            }; */

            chart.background.color = gdk_background_color;
            chart.background.visible = true;
            chart.config.x_axis.visible = true;
            chart.config.x_axis.labels.visible = false;
            chart.config.x_axis.axis.color = gdk_line_color;
            chart.config.x_axis.axis.width = 2;

            chart.config.y_axis.labels.visible = true;
            chart.config.y_axis.labels.font.color = gdk_labels_color;
            chart.config.y_axis.lines.color = gdk_line_color;
            chart.config.y_axis.lines.dash = LiveChart.Dash () {dashes = {1}, offset = 2};
            chart.config.y_axis.axis.color = gdk_line_color;
            chart.config.y_axis.axis.width = 2;

            // chart.legend.main_color = gdk_legend_color;
            chart.legend.visible = false;

            chart.add_serie (serie);

            var categories = new Gee.ArrayList<string> ();
            var unit = "";
            var is_metric_valid = false;
            for (int i = logs.length - 1; i + 1 > 0; --i) {
                var log = logs[i];
                // var relative_created_at = log.get_relative_created_at ();
                // var created_at_formatted = log.get_created_at_datetime ().format ("%m.%d");
                var tag_metric = new Journal.TagMetricModel.from_log (log.log, log_filter);
                if (tag_metric.value.is_normal ()) {
                    if (unit == "" || unit == tag_metric.unit) {
                        unit = tag_metric.unit;
                    }
                    categories.add (log.created_at);
                    serie.add (log.created_at, tag_metric.value);
                    is_metric_valid = true;
                }
            }

            if (is_metric_valid && serie.get_values ().size > 1) {
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
