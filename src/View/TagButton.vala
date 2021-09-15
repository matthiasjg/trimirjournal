/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.TagButton : Gtk.EventBox {

    private Journal.Controller _controller;

    public string tag_text { get; construct; }
    public int tag_count { get; construct; }

    private Gtk.Button tag_button;
    private static Gtk.CssProvider style_provider;

    public TagButton (string tag_text, int tag_count) {
        Object (
            tag_text: tag_text,
            tag_count: tag_count
        );
    }

    class construct {
        set_css_name ("tag-button");
    }

    static construct {
        style_provider = new Gtk.CssProvider ();
        style_provider.load_from_resource ("com/github/matthiasjg/trimirjournal/TagButton.css");
    }

    construct {
        events |= Gdk.EventMask.ENTER_NOTIFY_MASK
                  | Gdk.EventMask.LEAVE_NOTIFY_MASK;

        var label = "%s (%d)".printf (_tag_text, _tag_count);
        tag_button = new Gtk.Button.with_label (label) {
            tooltip_text = _("Active tag filter %s").printf (_tag_text)
        };

        unowned Gtk.StyleContext tag_button_context = tag_button.get_style_context ();
        tag_button_context.add_class (Gtk.STYLE_CLASS_FLAT);
        tag_button_context.add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        /* var bg_color = Value (typeof (string));
        // Gtk bug? widget class 'TagButton' has no style property named 'background-color'
        tag_button_context.get_style_property (Gtk.STYLE_PROPERTY_BACKGROUND_COLOR, ref bg_color); */

        // warning: `Gtk.StyleContext.get_background_color' has been deprecated since 3.16
        var bg_color = tag_button_context.get_background_color (Gtk.StateFlags.NORMAL);
        Journal.Utils.apply_contrasting_foreground_color (bg_color, tag_button_context);

        var delete_button = new Gtk.Button.from_icon_name ("process-stop-symbolic", Gtk.IconSize.BUTTON) {
            tooltip_text = _("Remove filter for tag %s").printf (_tag_text)
        };

        unowned Gtk.StyleContext delete_button_context = delete_button.get_style_context ();
        delete_button_context.add_class (Gtk.STYLE_CLASS_FLAT);
        delete_button_context.add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        Journal.Utils.apply_contrasting_foreground_color (bg_color, delete_button_context);

        var delete_button_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
            reveal_child = false
        };
        delete_button_revealer.add (delete_button);

        var button_box = new Gtk.Grid () {
            valign = Gtk.Align.CENTER
        };
        button_box.add (tag_button);
        button_box.add (delete_button_revealer);
        button_box.get_style_context ().add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        add (button_box);

        _controller = Journal.Controller.shared_instance ();

        delete_button.clicked.connect (() => {
            if (_controller == null) {
                _controller = Journal.Controller.shared_instance ();
            }
            _controller.load_journal_logs ();
        });

        tag_button.clicked.connect (() => {
            if (delete_button_revealer.reveal_child) {
                delete_button_revealer.reveal_child = false;
            }
        });

        enter_notify_event.connect (() => {
            delete_button_revealer.reveal_child = true;
        });

        tag_button.enter_notify_event.connect (() => {
            delete_button_revealer.reveal_child = true;
        });

        leave_notify_event.connect (() => {
            if (delete_button_revealer.reveal_child) {
                delete_button_revealer.reveal_child = false;
            }
        });
    }
}
