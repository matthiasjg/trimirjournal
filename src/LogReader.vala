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

const string LogFilePath = "/home/matthias/Tresors/matthias tresor/ZenJournal_backup_Sun_Jan_03_2021.json";

public class Journal.LogReader : Object {
    private static LogReader __instance;

    public static LogReader sharedInstance() {
        if ( __instance == null ) {
            __instance = new LogReader();
        }

        return __instance;
    }

    public LogModel[]? loadJournal() {
        LogModel[] result = null;

        Json.Parser parser = new Json.Parser();
	    try {
		    parser.load_from_file (LogFilePath);
	        Json.Node root_node = parser.get_root();
	        var array = root_node.get_array();

            var logs = new LogModel[] {};
            for ( uint i = 0; i < array.get_length(); ++i ) {
                var object = array.get_object_element(i);
                var log = new LogModel.fromJsonObject(object);
                logs += log;
            }
            result = logs;
	    } catch (Error e) {
		    print ("Unable to parse '%s': %s\n", LogFilePath, e.message);
	    }

        return result;
    }
}
