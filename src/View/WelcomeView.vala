/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.WelcomeView : Gtk.Grid {
    private Journal.Controller _controller;

    construct {
        var welcome = new Granite.Widgets.Welcome (
            _("Trimir Journal"),
            _("Journaling, Logging and Activity Tracking.")
        );

        welcome.append ("document-import", _("Reset and Restore Journal"),
            _("Import Journal from a JSON (*.json) file."));

        welcome.append ("document-export", _("Backup Journal"),
            _("Export Journal to a JSON (*.json) file."));

        add (welcome);

        _controller = Journal.Controller.shared_instance ();

        welcome.activated.connect ((index) => {
            switch (index) {
                case 0:
                    _controller.import_journal ();
                    /* try {
                        AppInfo.launch_default_for_uri ("http://trimir.io", null);
                    } catch (Error err) {
                        warning (err.message);
                    } */
                    break;

                case 1:
                    _controller.export_journal ();
                break;
            }
        });
    }
}
