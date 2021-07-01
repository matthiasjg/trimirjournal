/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.MainWindow : Hdy.ApplicationWindow {

    private uint configure_id;

    private Gtk.Grid _tag_filter_grid;

    private Journal.Controller _controller;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "io.trimir.journal",
            title: _("Trimir Journal")
        );
    }

    construct {
        var header_provider = new Gtk.CssProvider ();
        header_provider.load_from_resource ("io/trimir/journal/HeaderBar.css");

        var sidebar_header = new Hdy.HeaderBar () {
            decoration_layout = "close:",
            has_subtitle = false,
            show_close_button = true
        };

        unowned Gtk.StyleContext sidebar_header_context = sidebar_header.get_style_context ();
        sidebar_header_context.add_class ("default-decoration");
        sidebar_header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var gtk_settings = Gtk.Settings.get_default ();

        var mode_switch = new Granite.ModeSwitch.from_icon_name (
            "display-brightness-symbolic",
            "weather-clear-night-symbolic"
        );
        mode_switch.primary_icon_tooltip_text = ("Light background");
        mode_switch.secondary_icon_tooltip_text = ("Dark background");
        mode_switch.valign = Gtk.Align.CENTER;
        mode_switch.bind_property (
            "active", gtk_settings, "gtk-application-prefer-dark-theme", GLib.
                BindingFlags.BIDIRECTIONAL
        );

        _controller = Journal.Controller.shared_instance ();
        _controller.updated_journal_logs.connect (on_updated_journal_logs);

        _tag_filter_grid = new Gtk.Grid () {
            margin_top = 2,
            margin_bottom = 2
        };

        var headerbar = new Hdy.HeaderBar ();
        headerbar.get_style_context ().add_class ("default-decoration");
        headerbar.show_close_button = false;
        headerbar.pack_end (mode_switch);

        unowned Gtk.StyleContext headerbar_context = headerbar.get_style_context ();
        headerbar_context.add_class ("default-decoration");
        headerbar_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var sidebar = new Gtk.Grid ();
        sidebar.attach (sidebar_header, 0, 0);

        unowned Gtk.StyleContext sidebar_style_context = sidebar.get_style_context ();
        sidebar_style_context.add_class (Gtk.STYLE_CLASS_SIDEBAR);

        Journal.LogView journal_view = new Journal.LogView ();

        var journal_view_grid = new Gtk.Grid ();
        journal_view_grid.attach (headerbar, 0, 0);
        journal_view_grid.attach (_tag_filter_grid, 0, 1);
        journal_view_grid.attach (journal_view, 0, 2);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.pack1 (sidebar, false, false);
        paned.pack2 (journal_view_grid, true, false);

        add (paned);

        Journal.Application.settings.bind ("pane-position", paned, "position", GLib.SettingsBindFlags.DEFAULT);
    }

    private void on_updated_journal_logs (string tag_filter, LogModel[] filtered_logs) {
        if (tag_filter != "") {
            var tag_filter_button = new Journal.TagButton (tag_filter, filtered_logs.length);
            _tag_filter_grid.attach (tag_filter_button, 0, 0);
        } else {
            _tag_filter_grid.remove_row (0);
        }
        _tag_filter_grid.show_all ();
    }

    public override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id != 0) {
            GLib.Source.remove (configure_id);
        }

        configure_id = Timeout.add (100, () => {
            configure_id = 0;

            if (is_maximized) {
                Journal.Application.settings.set_boolean ("window-maximized", true);
            } else {
                Journal.Application.settings.set_boolean ("window-maximized", false);

                Gdk.Rectangle rect;
                get_allocation (out rect);
                Journal.Application.settings.set ("window-size", "(ii)", rect.width, rect.height);

                int root_x, root_y;
                get_position (out root_x, out root_y);
                Journal.Application.settings.set ("window-position", "(ii)", root_x, root_y);
            }

            return false;
        });

        return base.configure_event (event);
    }
}
