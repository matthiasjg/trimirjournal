/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.TagsRow : Gtk.ListBoxRow {

    construct {
        var icon = new Gtk.Image.from_icon_name ("tag-symbolic", Gtk.IconSize.MENU);

        var display_name_label = new Gtk.Label (_("Tags")) {
            ellipsize = Pango.EllipsizeMode.MIDDLE,
            halign = Gtk.Align.START,
            hexpand = true,
            margin_end = 9
        };

        var grid = new Gtk.Grid () {
            column_spacing = 6,
            margin_start = 12,
            margin_end = 6
        };
        grid.add (icon);
        grid.add (display_name_label);

        add (grid);
    }
}
