/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.LogView : Gtk.Grid {
    private Gtk.ScrolledWindow scrolled_window;
    private Gtk.ListBox log_list;
    private bool is_tag_filter_active;
    private string active_tag_filter;

    private Journal.Controller _controller;

    private const string BG_COLOR_LIGHT = "rgba(255,255,255,0.05)";
    private const string BG_COLOR_DARK = "rgba(0,0,0,0.05)";

    public LogView () {}

    construct {
        scrolled_window = new Gtk.ScrolledWindow (null, null) {
            expand = true
        };

        log_list = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.NONE
        };
        log_list.set_css_name ("log-list");

        log_list.size_allocate.connect (() => {
            // auto-scroll to bottom/ last added log
            var scrolled_window_vadjustment = scrolled_window.get_vadjustment ();
            scrolled_window_vadjustment.set_value (
                scrolled_window_vadjustment.get_upper () - scrolled_window_vadjustment.get_page_size ());
        });

        unowned Gtk.StyleContext log_list_style_context = log_list.get_style_context ();
        log_list_style_context.add_class (Gtk.STYLE_CLASS_BACKGROUND);
        //log_list.set_filter_func (filter_function);

        scrolled_window.add (log_list);

        add (scrolled_window);

        _controller = Journal.Controller.shared_instance ();
        _controller.updated_journal_logs.connect (on_updated_journal_logs);
        _controller.load_journal_logs ();
    }

    /* private bool filter_function (Gtk.ListBoxRow row) {
        if (is_tag_filter_active && active_tag_filter != null && active_tag_filter != "" ) {
            if (active_tag_filter in ((Journal.LogRow) row).tags) {
                return true;
            }
            return false;
        }
        return true;
    } */

    private void on_updated_journal_logs (string log_filter, bool is_tag_filter, LogModel[] logs) {
        is_tag_filter_active = is_tag_filter;
        active_tag_filter = log_filter;
        log_list.foreach ((log) => log_list.remove (log));

        for (int i = logs.length - 1; i + 1 > 0; --i) {
            var log = logs[i];
            var log_log = log.log;
            var log_relative_created_at = logs[i].get_relative_created_at ();
            var log_txt = "%s:  %s".printf (log_relative_created_at, log_log);
            debug ("log_txt: %s", log_txt);
            Granite.HyperTextView text_view = new Granite.HyperTextView () {};
            text_view.get_style_context ().add_class (Granite.STYLE_CLASS_ACCENT);
            text_view.editable = false;
            text_view.left_margin = text_view.right_margin = 6;
            text_view.monospace = true;
            text_view.pixels_above_lines = text_view.pixels_below_lines = 3;
            text_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
            text_view.buffer.text = log_txt;
            text_view.buffer = format_tags (text_view.buffer);
            string[] tags = {};
            text_view.buffer
                .get_tag_table ()
                .foreach ((tag) => {
                    var data_tag = tag.get_data <string> ("tag");
                    if ( data_tag != null && data_tag != "") {
                        tags += data_tag;
                    }
                });
            var log_row = new Journal.LogRow (text_view, tags);
            log_list.insert (log_row, -1);
        }
        log_list.show_all ();
    }

    private bool tag_clicked_handler (Gtk.TextTag text_tag,
                                      Object object, Gdk.Event event, Gtk.TextIter iter) {

        if (event.type == Gdk.EventType.BUTTON_PRESS) {
            string tag_text = text_tag.get_data ("tag");
            _controller.load_journal_logs ("#" + tag_text);
        }
        return true;
    }

    private Gtk.TextBuffer format_tags (Gtk.TextBuffer buffer) {
        try {
            var buffer_text = buffer.text;
            GLib.Regex regex = new GLib.Regex ("(?:^|)#(\\w+)");
            GLib.MatchInfo match_info;
            regex.match (buffer_text, 0, out match_info);

            while (match_info.matches ()) {
                Gtk.TextIter start, end;
                int start_pos, end_pos;

                match_info.fetch_pos (0, out start_pos, out end_pos);
                buffer.get_iter_at_offset (out start, start_pos);
                buffer.get_iter_at_offset (out end, end_pos);

                string tag_text = match_info.fetch (0).replace ("#", "");
                // string text_tag_name = "%s_%i_%i".printf ( tag_text, start_pos, end_pos );

                var tag_ul = buffer.create_tag (null, "underline", Pango.Underline.SINGLE);
                var tag_b = buffer.create_tag (null, "weight", Pango.Weight.BOLD);

                tag_ul.set_data ("tag", tag_text);
                tag_ul.event.connect (tag_clicked_handler);

                buffer.apply_tag (tag_ul, start, end);
                buffer.apply_tag (tag_b, start, end);

                match_info.next ();
            }
        } catch (Error err) {
            print ("Unable to format tags: %s\n", err.message);
        }
        return buffer;
    }
}
