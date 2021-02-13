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

public class Journal.ListView : Gtk.Grid {
    private Gtk.TreeView _treeView;

    private Journal.LogReader _logReader;
    private Journal.LogModel[]? _logs;

    public ListView () {

        var scrolledWindow = new Gtk.ScrolledWindow( null, null ) {
            expand = true
        };
        _treeView = new Gtk.TreeView();
        scrolledWindow.add( _treeView );

        _treeView.set_grid_lines( Gtk.TreeViewGridLines.HORIZONTAL );
		var cell = new Gtk.CellRendererText();
        cell.set_padding( 4, 10 );
		_treeView.insert_column_with_attributes( -1, null, cell, "markup", 0 );

        add( scrolledWindow );
		updateList();
    }

    private void updateList()
    {
        var listmodel = new Gtk.ListStore( 1, typeof(string) );
		_treeView.set_model( listmodel );

        Gtk.TreeIter iter;

        if ( _logs == null ) {
            _logReader = Journal.LogReader.sharedInstance();
            _logs = _logReader.loadJournal();
        }
        for( int i = 0; i < _logs.length; ++i ) {
            listmodel.append( out iter );
            var log = _logs[i].log;
            var created_at = _logs[i].created_at;
            var str = "<big><b>%s</b></big>\n\n%s".printf( log, created_at );
            listmodel.set( iter, 0, str );
        }
    }

}
