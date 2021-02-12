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

    private Journal.ListView listview;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "io.trimir.journal",
            title: _("Trimir Journal")
        );
    }

    construct {
        var log_row = new Journal.LogRow ("finally fixed my #c64 setup", "2019-12-26T16:25:44.502Z");

        var header_provider = new Gtk.CssProvider ();
        header_provider.load_from_resource ("io/trimir/journal/HeaderBar.css");

        var sidebar_header = new Gtk.HeaderBar () {
            decoration_layout = "close:",
            has_subtitle = false,
            show_close_button = true
        };

        unowned Gtk.StyleContext sidebar_header_context = sidebar_header.get_style_context ();
        sidebar_header_context.add_class ("sidebar-header");
        sidebar_header_context.add_class ("default-decoration");
        sidebar_header_context.add_class (Gtk.STYLE_CLASS_FLAT);
        sidebar_header_context.add_provider (header_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var listview_header = new Gtk.HeaderBar () {
            has_subtitle = false,
            decoration_layout = ":maximize",
            show_close_button = true
        };

        unowned Gtk.StyleContext listview_header_context = listview_header.get_style_context ();
        listview_header_context.add_class ("default-decoration");
        listview_header_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var sidebar = new Gtk.Grid ();
        sidebar.attach (sidebar_header, 0, 0);

        listview = new Journal.ListView ();

        var listview_grid = new Gtk.Grid ();
        listview_grid.attach (listview_header, 0, 0);
        listview_grid.attach (listview, 0, 1);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.pack1 (sidebar, false, false);
        paned.pack2 (listview_grid, true, false);

        add (paned);
    }

}
