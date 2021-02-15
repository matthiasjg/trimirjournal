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

    private void loadJournalLogs() {
        if ( _logs == null ) {
            _log_reader = Journal.LogReader.sharedInstance();
            _logs = _log_reader.loadJournal();
        }
        for( int i = 0; i < _logs.length; ++i ) {
            Gtk.TextView text_view = new Gtk.TextView();
            text_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
            var log = _logs[i].log;
            var created_at = _logs[i].created_at;
            var str = "%s:  %s\n".printf( created_at, log );
            text_view.buffer.text = str;
            text_view.buffer = format_tags ( text_view.buffer );
            _list_box.insert( text_view, -1 );
        }
    }

	public Gtk.TextBuffer format_tags(Gtk.TextBuffer buffer) {
		try {
    		var buffer_text = buffer.text;
			GLib.Regex regex = /(?:^|)#(\w+)/;
			GLib.MatchInfo matchInfo;
			regex.match (buffer_text, 0, out matchInfo);

			while (matchInfo.matches ()) {
				Gtk.TextIter start, end;
				int start_pos, end_pos;
				string tag_text = matchInfo.fetch(0);
				matchInfo.fetch_pos (0, out start_pos, out end_pos);
				buffer.get_iter_at_offset(out start, start_pos);
				buffer.get_iter_at_offset(out end, end_pos);
				string text_tag_name = "%s_%i_%i".printf ( tag_text, start_pos, end_pos );

				var tag = buffer.create_tag(text_tag_name, "underline", Pango.Underline.SINGLE);
				//tag.set_data("type", "url");
				//tag.set_data("url", "https://example.com");
				buffer.apply_tag(tag, start, end);

				matchInfo.next();
			}
		} catch(Error e) {
		    print ("Unable to format tags: %s\n", e.message);
		}
		return buffer;
	}
}
