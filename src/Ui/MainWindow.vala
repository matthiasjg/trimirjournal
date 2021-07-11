/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.MainWindow : Hdy.ApplicationWindow {

    private uint configure_id;

    private Gtk.Entry log_entry;
    private Gtk.ListBox listbox;
    private Gtk.ButtonBox sidebar_menu_buttonbox;
    // private Gtk.ActionBar sidebar_actionbar;
    private Gtk.ActionBar log_view_actionbar;
    private Journal.TagButton tag_filter_button;

    private Journal.Controller _controller;

    public const string ACTION_PREFIX = "win.";
    public const string ACTION_IMPORT = "action_import";

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "io.trimir.journal",
            title: _("Trimir Journal")
        );
    }

    static construct {
        Hdy.init ();
    }

    construct {
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

        var import_menuitem = new Gtk.MenuItem.with_label (_("Import to Journal…"));
        import_menuitem.action_name = ACTION_PREFIX + ACTION_IMPORT;

        var menu = new Gtk.Menu ();
        menu.append (import_menuitem);
        // menu.append (new Gtk.SeparatorMenuItem ());
        menu.show_all ();

        var menu_button = new Gtk.MenuButton ();
        menu_button.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        menu_button.popup = menu;
        menu_button.valign = Gtk.Align.CENTER;

        var log_view_header = new Hdy.HeaderBar () {
            show_close_button = true,
            has_subtitle = false,
            decoration_layout = ":maximize"
        };
        log_view_header.pack_end (menu_button);
        log_view_header.pack_end (mode_switch);
        log_view_header.set_title (_("Trimir Journal"));
        log_view_header.show_all ();

        unowned Gtk.StyleContext log_view_header_context = log_view_header.get_style_context ();
        log_view_header_context.add_class ("default-decoration");
        log_view_header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        listbox = new Gtk.ListBox ();

        var journal_row = new Journal.JournalRow ();
        var tags_row = new Journal.TagsRow () {
            sensitive = false,
            tooltip_text = _("Not implemented yet")
        };
        var saved_searches_row = new Journal.SavedSearchesRow () {
            sensitive = false,
            tooltip_text = _("Not implemented yet")
        };
        listbox.add (journal_row);
        listbox.add (tags_row);
        listbox.add (saved_searches_row);

        var scrolledwindow = new Gtk.ScrolledWindow (null, null) {
            expand = true,
            hscrollbar_policy = Gtk.PolicyType.NEVER
        };
        scrolledwindow.add (listbox);

        sidebar_menu_buttonbox = new Gtk.ButtonBox (Gtk.Orientation.VERTICAL);

        var add_tasklist_popover = new Gtk.Popover (null);
        add_tasklist_popover.add (sidebar_menu_buttonbox);

        /*
        var sidebar_menu_button = new Gtk.MenuButton () {
            label = _("Add Chart"),
            tooltip_text = _("Not implemented yet"),
            image = new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR),
            always_show_image = true,
            popover = add_tasklist_popover,
            sensitive = false
        };

        sidebar_actionbar = new Gtk.ActionBar ();
        sidebar_actionbar.add (sidebar_menu_button);

        unowned Gtk.StyleContext sidebar_actionbar_style_context = sidebar_actionbar.get_style_context ();
        sidebar_actionbar_style_context.add_class (Gtk.STYLE_CLASS_FLAT);
        */

        var sidebar = new Gtk.Grid ();
        sidebar.get_style_context ().add_class (Gtk.STYLE_CLASS_SIDEBAR);
        sidebar.attach (sidebar_header, 0, 0);
        sidebar.attach (scrolledwindow, 0, 1);
        // sidebar.attach (sidebar_actionbar, 0, 2);

        unowned Gtk.StyleContext sidebar_style_context = sidebar.get_style_context ();
        sidebar_style_context.add_class (Gtk.STYLE_CLASS_SIDEBAR);

        Journal.LogView log_view = new Journal.LogView ();

        log_entry = new Gtk.Entry () {
            hexpand = true,
            placeholder_text = _("Start logging or type ? to search your Journal…"),
            tooltip_text = _("Not implemented yet"),
            valign = Gtk.Align.CENTER,
            sensitive = false,
        };
        log_entry.set_icon_from_icon_name (0, "edit-find-replace-symbolic");

        log_view_actionbar = new Gtk.ActionBar ();
        log_view_actionbar.add (log_entry);

        unowned Gtk.StyleContext log_view_actionbar_style_context = log_view_actionbar.get_style_context ();
        log_view_actionbar_style_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var log_view_grid = new Gtk.Grid ();
        log_view_grid.attach (log_view_header, 0, 0);
        log_view_grid.attach (log_view, 0, 1);
        log_view_grid.attach (log_view_actionbar, 0, 2);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.pack1 (sidebar, false, false);
        paned.pack2 (log_view_grid, true, false);

        add (paned);

        Journal.Application.settings.bind ("pane-position", paned, "position", GLib.SettingsBindFlags.DEFAULT);
    }

    private void on_updated_journal_logs (string tag_filter, LogModel[] filtered_logs) {
        if (log_view_actionbar != null) {
            log_view_actionbar.get_children ().foreach ( child => (log_view_actionbar.remove (child)));
            if (tag_filter != "") {
                tag_filter_button = new Journal.TagButton (tag_filter, filtered_logs.length);
                log_view_actionbar.add (tag_filter_button);
            } else {
                log_view_actionbar.add (log_entry);
            }
            log_view_actionbar.show_all ();
        }
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
