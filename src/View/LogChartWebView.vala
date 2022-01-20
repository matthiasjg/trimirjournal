/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.LogChartWebView : Gtk.Box {
    private Journal.Controller _controller;

    private static Gtk.CssProvider style_provider;

    private WebKit.WebView web_view;

    public LogChartWebView () {
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
        style_provider.load_from_resource ("com/github/matthiasjg/trimirjournal/css/LogChart.css");
    }

    construct {
        unowned Gtk.StyleContext log_chart_context = this.get_style_context ();
        log_chart_context.add_class (Gtk.STYLE_CLASS_FLAT);
        log_chart_context.add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        _controller = Journal.Controller.shared_instance ();
        _controller.updated_journal_logs.connect (on_updated_journal_logs);
        _controller.load_journal_logs ();

        web_view = new WebKit.WebView ();
        web_view.get_settings ().set_property ("enable-developer-extras", true);
    }

    private async void inject_data (string accent_color, string log_filter, string logs_json) {
        try {
            yield web_view.run_javascript ("handleData('%s', '%s', '%s');"
                .printf (accent_color, log_filter, logs_json));
        } catch (Error e) {
            critical ("Unable to inject data: %s\n", e.message);
        }
    }


    private void on_updated_journal_logs (string log_filter, bool is_tag_filter, LogModel[] logs) {
        // remove prev chart, if any
        get_children ().foreach ( child => {
            if (child.get_type () == typeof (WebKit.WebView)) {
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

            //do we actually have at least one valid metric tag for given filter_tag?
            var unit = "";
            var is_metric_valid = false;
            for (int i = logs.length - 1; i + 1 > 0; --i) {
                var log = logs[i];
                var tag_metric = new Journal.TagMetricModel.from_log (log.log, log_filter);
                if (tag_metric.value.is_normal ()) {
                    if (unit == "" || unit == tag_metric.unit) {
                        unit = tag_metric.unit;
                    }
                    is_metric_valid = unit != "" ? true : false;
                }
            }

            if (is_metric_valid) {
                // get (accent) color from gtk css
                unowned Gtk.StyleContext log_chart_context = this.get_style_context ();
                var fg_color= log_chart_context.get_color (Gtk.StateFlags.NORMAL);
                // critical ("fg_color: %s", fg_color.to_string ());

                // string accent_color = fg_color.to_string ();
                string accent_color = "#%02x%02x%02x"
                    .printf (
                        (uint) Math.round (fg_color.red * 255),
                        (uint) Math.round (fg_color.green * 255),
                        (uint) Math.round (fg_color.blue * 255)
                    ).up ();
                // critical ("accent_color: %s", accent_color);

                // string url = "javascript:alert('error');";
                // url = "file://" + Path.get_dirname(FileUtils.read_link("/proc/self/exe")) + "/html/test.html";

                string html = "";
                File file = File.new_for_uri ("resource://com/github/matthiasjg/trimirjournal/logChartWebView.html");

                try {
                    var dis = new DataInputStream (file.read ());
                    string line;
                    while ((line = dis.read_line (null)) != null) {
                        html += line + "\n";
                    }
                } catch (Error e) {
                    error ("%s", e.message);
                }

                // replace placeholder/ vars
                html = html.replace ("[ACCENT_COLOR]", accent_color);

                pack_start (web_view, true, true, 0);

                this.expand = true;

                string logs_json = Journal.LogModel.logs_to_json (logs);
                web_view.load_changed.connect ((load_event) => {
                    inject_data.begin (accent_color, log_filter, logs_json);
                });

                // web_view.load_uri (url);
                web_view.load_html (html, null);
                /*
                web_view.run_javascript_from_gresource.begin ("/com/github/matthiasjg/trimirjournal/js/luxon.min.js", null, (resource, luxon_result) => {
                    try {
                        WebKit.JavascriptResult js_result = web_view.run_javascript_from_gresource.end (luxon_result);
                        critical ("%s", js_result.get_js_value ().to_string ());
                        string js = "window.luxon = luxon;";
                        web_view.rulogChartWebViewWithJs.htmln_javascript.begin (js);
                        web_view.run_javascript_from_gresource.begin ("/com/github/matthiasjg/trimirjournal/js/chart.min.js", null, (finsh2) => {
                            web_view.run_javascript_from_gresource.begin ("/com/github/matthiasjg/trimirjournal/js/chartjs-adapter-luxon.min.js", null, (finish3) => {
                                web_view.run_javascript_from_gresource.begin ("/com/github/matthiasjg/trimirjournal/js/logChartWebView.js");
                            });
                        });
                    } catch (Error err) {
                        critical ("Could not SELECT all logs: %s", err.message);
                    }
                });
                */
                show_all ();
            }
        }
    }

}
