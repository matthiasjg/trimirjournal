/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.LogChartView : Gtk.Box {
    private Journal.Controller _controller;

    private LiveChart.Static.StaticSerie serie;
    private LiveChart.Static.StaticChart chart;

    private static Gtk.CssProvider style_provider;

    public LogChartView () {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 0,
            expand: false
        );
    }

    class construct {
        set_css_name ("log-chart");
    }

    static construct {
        style_provider = new Gtk.CssProvider ();
        style_provider.load_from_resource ("com/github/matthiasjg/trimirjournal/LogChart.css");
    }

    construct {
        unowned Gtk.StyleContext log_chart_context = this.get_style_context ();
        log_chart_context.add_class (Gtk.STYLE_CLASS_FLAT);
        log_chart_context.add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        _controller = Journal.Controller.shared_instance ();
        _controller.updated_journal_logs.connect (on_updated_journal_logs);
        _controller.load_journal_logs ();
    }

    private void on_updated_journal_logs (string log_filter, bool is_tag_filter, LogModel[] logs) {
        // remove prev chart, if any
        get_children ().foreach ( child => {
            if (child.get_type () == typeof (LiveChart.Static.StaticChart)) {
                remove (child);
            }
        });
        this.expand = false;

        Regex? value_unit_regex = null;
        try {
            value_unit_regex = new Regex ("%s\\s*(\\S+)".printf (log_filter));
        } catch (Error err) {
            critical (err.message);
        }

        if (is_tag_filter) {

            // get (accent) color from gtk css
            unowned Gtk.StyleContext log_chart_context = this.get_style_context ();

            /* var fg_color = Value (typeof (string));
            var bg_color = Value (typeof (string));
            // Gtk bug? widget class 'JournalLogChartView' has no style property named 'color'
            log_chart_context.get_style_property (Gtk.STYLE_PROPERTY_COLOR, ref fg_color);
            debug ("fg_color: %s", fg_color.get_string ());
            // Gtk bug? widget class 'JournalLogChartView' has no style property named 'background-color'
            log_chart_context.get_style_property (Gtk.STYLE_PROPERTY_BACKGROUND_COLOR, ref bg_color);
            debug ("bg_color: %s", bg_color.get_string ()); */

            // Gdk.RGBA color_white = { 1.0, 1.0, 1.0, 1.0 };
            var fg_color= log_chart_context.get_color (Gtk.StateFlags.NORMAL);
            debug ("fg_color: %s", fg_color.to_string ());

            // warning: `Gtk.StyleContext.get_background_color' has been deprecated since 3.16
            var bg_color = log_chart_context.get_background_color (Gtk.StateFlags.NORMAL);
            debug ("bg_color: %s", bg_color.to_string ());

            // var bg_color = gtk_settings.gtk_application_prefer_dark_theme ? gdk_white : gdk_black;

            var line_color = Gdk.RGBA ();
            line_color = Granite.contrasting_foreground_color (bg_color); // fg_color

            var axis_color = line_color;
            var labels_color =line_color;
            // var gdk_legend_color = line_color;

            var gdk_background_color = Gdk.RGBA ();
            gdk_background_color = bg_color;

            serie = new LiveChart.Static.StaticSerie (log_filter);
            serie.line.color = line_color;
            serie.line.width = 2;

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
            chart.config.x_axis.labels.font.color = labels_color;
            chart.config.x_axis.lines.color = line_color;
            chart.config.x_axis.lines.dash = LiveChart.Dash () {dashes = {1}, offset = 2};
            chart.config.x_axis.axis.color = axis_color;
            chart.config.x_axis.axis.width = 2;

            chart.config.y_axis.labels.visible = true;
            chart.config.y_axis.labels.font.color = labels_color;
            chart.config.y_axis.lines.color = line_color;
            chart.config.y_axis.lines.dash = LiveChart.Dash () {dashes = {1}, offset = 2};
            chart.config.y_axis.axis.color = axis_color;
            chart.config.y_axis.axis.width = 2;

            // chart.legend.main_color = gdk_legend_color;
            chart.legend.visible = false;
            chart.grid.visible = true;
            chart.add_serie (serie);

            var categories = new Gee.ArrayList<string> ();
            var unit = "";
            var is_metric_valid = false;
            for (int i = logs.length - 1; i + 1 > 0; --i) {
                var log = logs[i];
                // var created_at = log.created_at;
                // var created_at_relative = log.get_relative_created_at ();
                var created_at_formatted = log.get_created_at_datetime ().format (
                    Granite.DateTime.get_default_date_format (false, true, true)
                );
                var tag_metric = new Journal.TagMetricModel.from_log (log.log, log_filter);
                if (tag_metric.value.is_normal ()) {
                    if (unit == "" || unit == tag_metric.unit) {
                        unit = tag_metric.unit;
                    }
                    categories.add (created_at_formatted);
                    serie.add (created_at_formatted, tag_metric.value);
                    is_metric_valid = true;
                }
            }

            if (is_metric_valid && serie.get_values ().size > 1) {
                chart.set_categories (categories);
                chart.config.y_axis.unit = unit;

                var tooltip_txt = "%s (%i)\n%s %s\n%s %s".printf (
                    log_filter,
                    logs.length,
                    _ ("first"),
                    categories.first (),
                    _ ("last"),
                    categories.last ()
                );
                chart.set_tooltip_text (tooltip_txt);

                pack_start (chart, true, true, 0);

                this.expand = true;
            }
        }
        show_all ();
    }

}
