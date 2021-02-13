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

public class Journal.LogModel : Object {
    public string log { get; private set; }
    public string created_at { get; private set; }

    public LogModel( string log = "", string created_at = "" ) {
        _log = log;
        _created_at = created_at;
    }

    public LogModel.fromJsonObject( Json.Object json ) {
        _log = json.get_string_member( "log" );
        _created_at = json.get_string_member( "createdAt" );
    }
}

