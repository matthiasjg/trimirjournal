/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.LogRow : Gtk.ListBoxRow {

    public Gtk.TextView log_view { get; construct; }
    public string[] tags { get; construct; }

    private static Gtk.CssProvider logrow_provider;

    public LogRow (Gtk.TextView log_view, string[] tags) {
        Object (log_view: log_view, tags: tags);
    }

    class construct {
        set_css_name ("log-row");
    }

    static construct {
        logrow_provider = new Gtk.CssProvider ();
        logrow_provider.load_from_resource ("com/github/matthiasjg/trimirjournal/LogRow.css");
    }

    construct {
        add (log_view);
    }

}
