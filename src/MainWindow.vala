/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.MainWindow : Hdy.ApplicationWindow {

    private uint configure_id;

    private Gtk.ListBox listbox;
    private Gtk.ButtonBox bookmark_tag_filter_buttonbox;
    private Gtk.Grid tag_filter_grid;

    private Journal.Controller _controller;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "io.trimir.journal",
            title: _("Trimir Journal")
        );
    }

    construct {
        Hdy.init ();

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

        tag_filter_grid = new Gtk.Grid () {
            margin_top = 20,
            margin_bottom = 20,
            margin_left = 20,
            margin_right = 20
        };

        var log_view_header = new Hdy.HeaderBar () {
            has_subtitle = false,
            decoration_layout = ":maximize",
            show_close_button = true
        };
        log_view_header.pack_end (mode_switch);

        unowned Gtk.StyleContext log_view_header_context = log_view_header.get_style_context ();
        log_view_header_context.add_class ("default-decoration");
        log_view_header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        listbox = new Gtk.ListBox ();

        var journal_row = new Journal.JournalRow ();
        listbox.add (journal_row);

        var scrolledwindow = new Gtk.ScrolledWindow (null, null) {
            expand = true,
            hscrollbar_policy = Gtk.PolicyType.NEVER
        };
        scrolledwindow.add (listbox);

        bookmark_tag_filter_buttonbox = new Gtk.ButtonBox (Gtk.Orientation.VERTICAL);

        var add_tasklist_popover = new Gtk.Popover (null);
        add_tasklist_popover.add (bookmark_tag_filter_buttonbox);

        var bookmark_tag_filter_button = new Gtk.MenuButton () {
            label = ("Bookmark Tag Filter…"),
            image = new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR),
            always_show_image = true,
            popover = add_tasklist_popover,
            sensitive = false
        };

        var actionbar = new Gtk.ActionBar ();
        actionbar.add (bookmark_tag_filter_button);

        unowned Gtk.StyleContext actionbar_style_context = actionbar.get_style_context ();
        actionbar_style_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var sidebar = new Gtk.Grid ();
        sidebar.attach (sidebar_header, 0, 0);
        sidebar.attach (scrolledwindow, 0, 1);
        sidebar.attach (actionbar, 0, 2);

        unowned Gtk.StyleContext sidebar_style_context = sidebar.get_style_context ();
        sidebar_style_context.add_class (Gtk.STYLE_CLASS_SIDEBAR);

        Journal.LogView log_view = new Journal.LogView ();

        Gtk.Label log_view_title = new Gtk.Label (_("Journal")) {
            ellipsize = Pango.EllipsizeMode.END,
            margin_start = 24,
            xalign = 0
        };

        unowned Gtk.StyleContext log_view_title_context = log_view_title.get_style_context ();
        log_view_title_context.add_class (Granite.STYLE_CLASS_H1_LABEL);
        log_view_title_context.add_class (Granite.STYLE_CLASS_ACCENT);

        var log_view_grid = new Gtk.Grid ();
        log_view_grid.attach (log_view_header, 0, 0);
        log_view_grid.attach (log_view_title, 0, 1);
        log_view_grid.attach (tag_filter_grid, 0, 2);
        log_view_grid.attach (log_view, 0, 3);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.pack1 (sidebar, false, false);
        paned.pack2 (log_view_grid, true, false);

        add (paned);

        Journal.Application.settings.bind ("pane-position", paned, "position", GLib.SettingsBindFlags.DEFAULT);
    }

    private void on_updated_journal_logs (string tag_filter, LogModel[] filtered_logs) {
        if (tag_filter != "") {
            var tag_filter_button = new Journal.TagButton (tag_filter, filtered_logs.length);
            tag_filter_grid.attach (tag_filter_button, 0, 0);
        } else {
            tag_filter_grid.remove_row (0);
        }
        tag_filter_grid.show_all ();
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
