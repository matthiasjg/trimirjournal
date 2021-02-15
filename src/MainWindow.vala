/*
* Copyright 2021 Matthias Joachim Geisler, openwebcraft (https://trimir.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/

public class Journal.MainWindow : Gtk.ApplicationWindow {

    private uint configure_id;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "io.trimir.journal",
            title: _("Trimir Journal")
        );
    }

    construct {
        var header_provider = new Gtk.CssProvider ();
        header_provider.load_from_resource ( "io/trimir/journal/HeaderBar.css" );

        var sidebar_header = new Gtk.HeaderBar () {
            decoration_layout = "close:",
            has_subtitle = false,
            show_close_button = false
        };

        unowned Gtk.StyleContext sidebar_header_context = sidebar_header.get_style_context ();
        sidebar_header_context.add_class ( "sidebar-header" );
        sidebar_header_context.add_class ( "default-decoration" );
        sidebar_header_context.add_class (Gtk.STYLE_CLASS_FLAT);
        sidebar_header_context.add_provider (header_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var journal_view_header = new Gtk.HeaderBar () {
            has_subtitle = false,
            decoration_layout = ":maximize",
            show_close_button = false
        };

        unowned Gtk.StyleContext journal_view_header_context = journal_view_header.get_style_context ();
        journal_view_header_context.add_class ("default-decoration");
        journal_view_header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var sidebar = new Gtk.Grid ();
        sidebar.attach ( sidebar_header, 0, 0 );

        unowned Gtk.StyleContext sidebar_style_context = sidebar.get_style_context ();
        sidebar_style_context.add_class ( Gtk.STYLE_CLASS_SIDEBAR );

        Journal.JournalView journal_view = new Journal.JournalView ();

        var journal_view_grid = new Gtk.Grid ();
        journal_view_grid.attach ( journal_view_header, 0, 0 );
        journal_view_grid.attach ( journal_view, 0, 1 );

        var paned = new Gtk.Paned ( Gtk.Orientation.HORIZONTAL );
        paned.pack1 ( sidebar, false, false );
        paned.pack2 ( journal_view_grid, true, false );


        add ( paned );

        Journal.Application.settings.bind ( "pane-position", paned, "position", GLib.SettingsBindFlags.DEFAULT );
    }

    public override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id != 0) {
            GLib.Source.remove (configure_id);
        }

        configure_id = Timeout.add (100, () => {
            configure_id = 0;

            if (is_maximized) {
                Journal.Application.settings.set_boolean ( "window-maximized", true );
            } else {
                Journal.Application.settings.set_boolean ( "window-maximized", false );

                Gdk.Rectangle rect;
                get_allocation ( out rect );
                Journal.Application.settings.set ( "window-size", "(ii)", rect.width, rect.height );

                int root_x, root_y;
                get_position ( out root_x, out root_y );
                Journal.Application.settings.set ( "window-position", "(ii)", root_x, root_y );
            }

            return false;
        });

        return base.configure_event (  event );
    }
}
