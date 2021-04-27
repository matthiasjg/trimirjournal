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
public class Journal.JournalView : Gtk.Grid {
    private Gtk.ListBox _list_box;

    private Journal.LogReader _log_reader;
    private Journal.LogModel[]? _logs;

    public JournalView () {
        Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow( null, null ) {
            expand = true
        };
        _list_box = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.NONE
        };
        scrolled_window.add( _list_box );
        add( scrolled_window );
		loadJournalLogs();
    }

    private void loadJournalLogs(string tag_filter = "") {
        if ( _logs == null ) {
            _log_reader = Journal.LogReader.sharedInstance();
            _logs = _log_reader.loadJournal();
        }

        _list_box.foreach ((log) => _list_box.remove ( log ) );

        for( int i = 0; i < _logs.length; ++i ) {
            var log = _logs[i].log;
            var created_at = _logs[i].created_at;
            var created_at_date_time = new DateTime.from_iso8601 ( created_at, new TimeZone.local () );
            var relative_created_at = Granite.DateTime.get_relative_datetime ( created_at_date_time );
            var str = "%s:  %s\n".printf( relative_created_at, log );
            bool add_log = true;
            if ( tag_filter != "" ) {
                add_log = log.contains( tag_filter );
            }
            if ( add_log ) {
                Gtk.TextView text_view = new Gtk.TextView();
                text_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
                text_view.buffer.text = str;
                text_view.buffer = format_tags ( text_view.buffer );
                _list_box.insert( text_view, -1 );
            }
        }
        _list_box.show_all();
    }

    private bool handleTagEvent( Gtk.TextTag text_tag,
        Object object, Gdk.Event event, Gtk.TextIter iter) {

        if ( event.type == Gdk.EventType.BUTTON_PRESS ) {
            string tag_text = text_tag.get_data( "tag" );
            loadJournalLogs( tag_text );
        }
        return true;
    }

	public Gtk.TextBuffer format_tags(Gtk.TextBuffer buffer) {
		try {
    		var buffer_text = buffer.text;
			GLib.Regex regex = /(?:^|)#(\w+)/;
			GLib.MatchInfo matchInfo;
			regex.match ( buffer_text, 0, out matchInfo );

			while (matchInfo.matches ()) {
				Gtk.TextIter start, end;
				int start_pos, end_pos;

				matchInfo.fetch_pos ( 0, out start_pos, out end_pos );
				buffer.get_iter_at_offset( out start, start_pos );
				buffer.get_iter_at_offset( out end, end_pos );

				string tag_text = matchInfo.fetch(0);
				// string text_tag_name = "%s_%i_%i".printf ( tag_text, start_pos, end_pos );

				var tag_ul = buffer.create_tag (null, "underline", Pango.Underline.SINGLE );
				var tag_b = buffer.create_tag( null, "weight", Pango.Weight.BOLD );

                tag_ul.set_data( "tag", tag_text );
				tag_ul.event.connect( handleTagEvent );

				buffer.apply_tag( tag_ul, start, end );
				buffer.apply_tag( tag_b, start, end );

				matchInfo.next();
			}
		} catch(Error e) {
		    print ( "Unable to format tags: %s\n", e.message );
		}
		return buffer;
	}
}
