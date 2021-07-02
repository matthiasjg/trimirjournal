/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.LogView : Gtk.Grid {
    private Gtk.ListBox log_list;
    private string active_tag_filter;

    private Journal.Controller _controller;

    public signal void filtered_logs (string tag_filter, LogModel[] filtered_logs);

    public LogView () {}

    construct {
        var scrolled_window = new Gtk.ScrolledWindow (null, null) {
            expand = true
        };
        log_list = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.NONE
        };
        log_list.get_style_context ().add_class (Gtk.STYLE_CLASS_BACKGROUND);
        log_list.set_filter_func (filter_function);
        scrolled_window.add (log_list);
        add (scrolled_window);

        _controller = Journal.Controller.shared_instance ();
        _controller.updated_journal_logs.connect (on_updated_journal_logs);
        _controller.load_journal_logs ();
    }

    private bool filter_function (Gtk.ListBoxRow row) {
        if (active_tag_filter != null && active_tag_filter != "") {
            if (active_tag_filter in ((Journal.LogRow) row).tags) {
                return true;
            }
            return false;
        }
        return true;
    }

    private void on_updated_journal_logs (string tag_filter, LogModel[] logs) {
        active_tag_filter = tag_filter;
        log_list.foreach ((log) => log_list.remove (log));

        for (int i = 0; i < logs.length; ++i) {
            var log = logs[i].log;
            var created_at = logs[i].created_at;
            var created_at_date_time = new DateTime.from_iso8601 (created_at, new TimeZone.local ());
            var relative_created_at = Granite.DateTime.get_relative_datetime (created_at_date_time);
            var str = "%s:  %s\n".printf (relative_created_at, log);
            Gtk.TextView text_view = new Gtk.TextView () {};
            text_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
            text_view.buffer.text = str;
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
            Journal.LogRow log_row = new Journal.LogRow (text_view, tags);
            log_list.insert (log_row, -1);
        }
        filtered_logs (tag_filter, logs);
        log_list.show_all ();
    }

    private bool tag_clicked_handler (Gtk.TextTag text_tag,
                                      Object object, Gdk.Event event, Gtk.TextIter iter) {

        if (event.type == Gdk.EventType.BUTTON_PRESS) {
            string tag_text = text_tag.get_data ("tag");
            _controller.load_journal_logs (tag_text);
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
        } catch (Error e) {
            print ("Unable to format tags: %s\n", e.message);
        }
        return buffer;
    }
}
