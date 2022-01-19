/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.MainWindow : Hdy.ApplicationWindow {

    private uint configure_id;

    private Gtk.ListBox sidebar_listbox;
    private Gtk.Entry log_entry;
    private Gtk.SearchEntry search_entry;
    private Hdy.HeaderBar main_header;
    private Gtk.ActionBar log_view_actionbar;

    private Journal.Controller _controller;

    private const string WELCOME_VIEW_UID = "welcome_view";
    private const string JOURNAL_VIEW_UID = "journal_view";

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "com.github.matthiasjg.trimirjournal",
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

        var restore_menuitem = new Gtk.MenuItem.with_label (_("Reset and Restore…"));
        restore_menuitem.activate.connect (() => {
            if (_controller == null) {
                _controller = Journal.Controller.shared_instance ();
            }
            _controller.import_journal ();
        });

        var backup_menuitem = new Gtk.MenuItem.with_label (_("Backup…"));
        backup_menuitem.activate.connect (() => {
            if (_controller == null) {
                _controller = Journal.Controller.shared_instance ();
            }
            _controller.export_journal ();
        });

        var menu = new Gtk.Menu ();
        menu.append (restore_menuitem);
        menu.append (backup_menuitem);
        // menu.append (new Gtk.SeparatorMenuItem ());
        menu.show_all ();

        var menu_button = new Gtk.MenuButton ();
        menu_button.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        menu_button.popup = menu;
        menu_button.valign = Gtk.Align.CENTER;

        search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search Journal"),
            tooltip_text = _("Not implemented yet"),
            valign = Gtk.Align.CENTER
        };

        search_entry.activate.connect (() => {
            if (search_entry.text != null && search_entry.text.strip ().length > 0) {
                debug ("search_entry: %s", search_entry.text);
                var log_filter = search_entry.text.strip ();
                debug ("log_filter: %s", log_filter);
                if (_controller == null) {
                    _controller = Journal.Controller.shared_instance ();
                }
                _controller.load_journal_logs (log_filter);
            }
        });

        search_entry.changed.connect (() => {
            if (search_entry.text == null || search_entry.text.strip ().length == 0) {
                _controller.load_journal_logs ();
            }
        });

        main_header = new Hdy.HeaderBar () {
            show_close_button = true,
            has_subtitle = false,
            decoration_layout = ":maximize"
        };
        main_header.pack_end (menu_button);
        main_header.pack_end (mode_switch);
        main_header.pack_end (search_entry);
        main_header.set_title (_("Trimir Journal"));
        main_header.show_all ();

        unowned Gtk.StyleContext main_header_context = main_header.get_style_context ();
        main_header_context.add_class ("default-decoration");
        main_header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        sidebar_listbox = new Gtk.ListBox ();

        var welcome_row = new Journal.WelcomeRow ();
        var journal_row = new Journal.JournalRow ();

        sidebar_listbox.add (welcome_row);
        sidebar_listbox.add (journal_row);

        /*
        var tags_row = new Journal.TagsRow () {
            sensitive = false,
            tooltip_text = _("Not implemented yet")
        };
        var saved_searches_row = new Journal.SavedSearchesRow () {
            sensitive = false,
            tooltip_text = _("Not implemented yet")
        };
        sidebar_listbox.add (tags_row);
        sidebar_listbox.add (saved_searches_row);
        */

        var scrolledwindow = new Gtk.ScrolledWindow (null, null) {
            expand = true,
            hscrollbar_policy = Gtk.PolicyType.NEVER
        };
        scrolledwindow.add (sidebar_listbox);

        /*
        var sidebar_menu_buttonbox = new Gtk.ButtonBox (Gtk.Orientation.VERTICAL);

        var add_tasklist_popover = new Gtk.Popover (null);
        add_tasklist_popover.add (sidebar_menu_buttonbox);

        var sidebar_menu_button = new Gtk.MenuButton () {
            label = _("Add Chart"),
            tooltip_text = _("Not implemented yet"),
            image = new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR),
            always_show_image = true,
            popover = add_tasklist_popover,
            sensitive = false
        };

        var sidebar_actionbar = new Gtk.ActionBar ();
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

        Regex? search_regex = null;
        try {
            search_regex = new Regex ("^\\?.+$");
        } catch (Error err) {
            critical (err.message);
        }

        log_entry = new Gtk.Entry () {
            hexpand = true,
            placeholder_text = _("Start logging or type ? to search your Journal…"),
            tooltip_text = _("Not implemented yet"),
            valign = Gtk.Align.CENTER
        };
        log_entry.set_icon_from_icon_name (0, "edit-find-replace-symbolic");

        log_entry.changed.connect (() => {
            if (log_entry.text != null && log_entry.text.strip ().length > 0) {
                var is_search = search_regex.match (log_entry.text);
                if (is_search) {
                    log_entry.set_icon_from_icon_name (0, "edit-find-symbolic");
                } else {
                    log_entry.set_icon_from_icon_name (0, "edit-symbolic");
                }
            }
        });

        log_entry.activate.connect (() => {
            if (log_entry.text != null && log_entry.text.strip ().length > 1) {
                debug ("log_entry: %s", log_entry.text);
                var is_search = search_regex.match (log_entry.text);
                if (is_search) {
                    var log_filter = log_entry.text.strip ().replace ("?", "");
                    search_entry.text = log_filter;
                    debug ("log_filter: %s", log_filter);
                    if (_controller == null) {
                        _controller = Journal.Controller.shared_instance ();
                    }
                    _controller.load_journal_logs (log_filter);
                } else {
                    var log_txt = log_entry.text.strip ();
                    _controller.add_journal_log_entry (log_txt);
                }
                log_entry.text = "";
                log_entry.set_icon_from_icon_name (0, "edit-find-replace-symbolic");
            }
        });

        var welcome_view = new Journal.WelcomeView ();

        log_view_actionbar = new Gtk.ActionBar ();
        log_view_actionbar.add (log_entry);

        unowned Gtk.StyleContext log_view_actionbar_style_context = log_view_actionbar.get_style_context ();
        log_view_actionbar_style_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var log_view = new Journal.LogView ();
        var log_chart_view = new Journal.LogChartWebView ();

        var log_view_grid = new Gtk.Grid ();
        log_view_grid.attach (log_view, 0, 1);
        log_view_grid.attach (log_view_actionbar, 0, 2);
        log_view_grid.attach (log_chart_view, 0, 3);

        var main_view_stack = new Gtk.Stack ();
        main_view_stack.add_named (welcome_view, WELCOME_VIEW_UID);
        main_view_stack.add_named (log_view_grid, JOURNAL_VIEW_UID);

        var main_view_grid = new Gtk.Grid ();
        main_view_grid.attach (main_header, 0, 0);
        main_view_grid.attach (main_view_stack, 0, 1);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.pack1 (sidebar, false, false);
        paned.pack2 (main_view_grid, true, false);

        sidebar_listbox.row_selected.connect ((row) => {
            if (row != null) {
                if (row is Journal.WelcomeRow) {
                    main_view_stack.set_visible_child_name (WELCOME_VIEW_UID);
                }
                if (row is Journal.JournalRow) {
                    main_view_stack.set_visible_child_name (JOURNAL_VIEW_UID);
                }
            }
        });
        /* var first_row = sidebar_listbox.get_row_at_index (0);
        if (first_row != null) {
            sidebar_listbox.select_row (first_row);
        } */

        add (paned);

        Journal.Application.settings.bind ("pane-position", paned, "position", GLib.SettingsBindFlags.DEFAULT);
    }

    private void on_updated_journal_logs (string log_filter, bool is_tag_filter, LogModel[] filtered_logs) {
        debug ("on_updated_journal_logs: %s %s", log_filter, is_tag_filter.to_string ());
        // remove tag btn from header bar, if any
        main_header.get_children ().foreach ( child => {
            if (child.get_type () == typeof (Journal.TagButton)) {
                main_header.remove (child);
            }
        });
        if (is_tag_filter && log_filter != null && log_filter != "") {
            // add tag btn to header bar
            var tag_filter_button = new Journal.TagButton (log_filter, filtered_logs.length);
            main_header.pack_end (tag_filter_button);
        }
        if (filtered_logs != null && filtered_logs.length >= 0) {
            // force journal view visible
            sidebar_listbox.select_row (sidebar_listbox.get_row_at_index (1));
        } else {
            // fallback show welcome view
            sidebar_listbox.select_row (sidebar_listbox.get_row_at_index (0));
        }
        main_header.show_all ();
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
