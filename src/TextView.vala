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
public class Journal.TextView : Gtk.Grid {
    private Gtk.TextView _text_view;

    private Journal.LogReader _log_reader;
    private Journal.LogModel[]? _logs;

    public TextView () {
        var scrolledWindow = new Gtk.ScrolledWindow( null, null ) {
            expand = true
        };
        _text_view = new Gtk.TextView();
        _text_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        scrolledWindow.add( _text_view );

        add( scrolledWindow );
		updateText();
    }

    private void updateText() {
        if ( _logs == null ) {
            _log_reader = Journal.LogReader.sharedInstance();
            _logs = _log_reader.loadJournal();
        }
        Gtk.TextIter end_iter;
        for( int i = 0; i < _logs.length; ++i ) {
            var log = _logs[i].log;
            var created_at = _logs[i].created_at;
            var str = "%s:  %s\n\n".printf( created_at, log );
            _text_view.buffer.get_end_iter(out end_iter);
            _text_view.buffer.insert(ref end_iter, str, -1);
        }
        format_tags();
    }

    // https://github.com/GNOME/gitg/blob/master/libgitg/gitg-diff-view.vala
    // https://stackoverflow.com/questions/17109634/hyperlink-in-cellrenderertext-markup
	public void format_tags() {
	    Gtk.TextBuffer buffer;
	    buffer = _text_view.buffer;
		try {
    		var buffer_text = buffer.text;
			GLib.Regex regex = /(?:^|)#(\w+)/;
			GLib.MatchInfo matchInfo;
			regex.match (buffer_text, 0, out matchInfo);

			while (matchInfo.matches ()) {
			    //print ("text"+buffer_text);
				Gtk.TextIter start, end;
				int start_pos, end_pos;
				// string text = matchInfo.fetch(0);
				matchInfo.fetch_pos (0, out start_pos, out end_pos);
				buffer.get_iter_at_offset(out start, start_pos);
				buffer.get_iter_at_offset(out end, end_pos);

				var tag = buffer.create_tag(null, "underline", Pango.Underline.SINGLE);
				//text = regex.replace(text, text.length, 0, "mytag");
				//tag.set_data("type", "url");
				//tag.set_data("url", text);
				buffer.apply_tag(tag, start, end);

				matchInfo.next();
			}
		} catch(Error e) {
		    print ("Unable to format tags: %s\n", e.message);
		}
	}
}
