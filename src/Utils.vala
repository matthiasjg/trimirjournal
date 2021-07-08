/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

namespace Journal.Utils {
    private const string APP_NAME = "journal";

    /*-
    * Copyright (c) 2012-2018 elementary LLC. (https://elementary.io)
    *
    * This program is free software: you can redistribute it and/or modify
    * it under the terms of the GNU Lesser General Public License as published by
    * the Free Software Foundation, either version 2 of the License, or
    * (at your option) any later version.
    *
    * This program is distributed in the hope that it will be useful,
    * but WITHOUT ANY WARRANTY; without even the implied warranty of
    * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    * GNU Lesser General Public License for more details.
    *
    * You should have received a copy of the GNU Lesser General Public License
    * along with this program.  If not, see <http://www.gnu.org/licenses/>.
    *
    * The Music authors hereby grant permission for non-GPL compatible
    * GStreamer plugins to be used and distributed together with GStreamer
    * and Music. This permission is above and beyond the permissions granted
    * by the GPL license by which Music is covered. If you modify this code
    * you may extend this exception to your version of the code, but you are not
    * obligated to do so. If you do not wish to do so, delete this exception
    * statement from your version.
    *
    * Authored by: Victor Eduardo <victoreduardm@gmail.com>
    *              Scott Ringwelski <sgringwe@mtu.edu>
    */
    // https://github.com/elementary/music/blob/master/core/Utils/FileUtils.vala
    public File get_data_directory () {
        string data_dir = Environment.get_user_data_dir ();
        string dir_path = Path.build_path (Path.DIR_SEPARATOR_S, data_dir, APP_NAME);
        return File.new_for_path (dir_path);
    }
}
