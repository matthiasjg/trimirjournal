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

public class Journal.TagButton : Gtk.EventBox {
    public string tag_text { get; construct; }
    public int tag_count { get; construct; }

    private Gtk.Button tag_button;
    private static Gtk.CssProvider style_provider;

    public TagButton ( string tag_text, int tag_count ) {
        Object (
            tag_text: tag_text,
            tag_count: tag_count
        );
    }

    class construct {
        set_css_name ( "tag-button" );
    }

    static construct {
        style_provider = new Gtk.CssProvider ();
        style_provider.load_from_resource ("io/trimir/journal/TagButton.css");
    }

    construct {
        events |= Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK;

        var label = @"$_tag_text ($_tag_count)";
        tag_button = new Gtk.Button () {
            label = label,
            image = new Gtk.Image.from_icon_name ("folder-tag", Gtk.IconSize.BUTTON),
            always_show_image = true
        };

        unowned Gtk.StyleContext tag_button_context = tag_button.get_style_context ();
        tag_button_context.add_class (Gtk.STYLE_CLASS_FLAT);
        tag_button_context.add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var delete_button = new Gtk.Button.from_icon_name ("process-stop-symbolic", Gtk.IconSize.BUTTON) {
            tooltip_text = _("Remove")
        };

        unowned Gtk.StyleContext delete_button_context = delete_button.get_style_context ();
        delete_button_context.add_class (Gtk.STYLE_CLASS_FLAT);
        delete_button_context.add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var delete_button_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
            reveal_child = false
        };
        delete_button_revealer.add (delete_button);

        var button_box = new Gtk.Grid ();
        button_box.add (tag_button);
        button_box.add (delete_button_revealer);
        button_box.get_style_context ().add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        add ( button_box );

        delete_button.clicked.connect (() => {
            // TODO
        });

        tag_button.clicked.connect (() => {
            if (delete_button_revealer.reveal_child) {
                delete_button_revealer.reveal_child = false;
            }
        });

        enter_notify_event.connect (() => {
            delete_button_revealer.reveal_child = true;
        });

        leave_notify_event.connect (() => {
            if (delete_button_revealer.reveal_child) {
                delete_button_revealer.reveal_child = false;
            }
        });
    }
}

