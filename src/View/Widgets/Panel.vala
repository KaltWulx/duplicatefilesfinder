

public class Widget.Panel: Gtk.Grid {

	public Panel () {

		orientation = Gtk.Orientation.HORIZONTAL;

		create_ui ();
	}

	private void create_ui () {

		var listbox = new Gtk.ListBox() {
		    vexpand = true,
		    activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.SINGLE
		};

		var row1 = new Widget.IconListRow ("application-octet-stream", "All Duplicates", "25 GB");
		var row2 = new Widget.IconListRow ("application-x-desktop", "Applications", "2 GB");
		var row3 = new Widget.IconListRow ("audio-x-generic", "Audio", "9.4 MB");
		var row4 = new Widget.IconListRow ("text-x-generic", "Documents", "4 GB");
		var row5 = new Widget.IconListRow ("folder", "Folders", "321.4 GB");
		var row6 = new Widget.IconListRow ("image-x-generic", "Images", "5.8 MB");
		var row7 = new Widget.IconListRow ("folder-videos", "Video", "12 GB");

		listbox.add (row1);
		listbox.add (row2);
		listbox.add (row3);
		listbox.add (row4);
		listbox.add (row5);
		listbox.add (row6);
		listbox.add (row7);


        //GLib.debug("Creando otra fila..\n");
		//var row_aux = new Test();
		//listbox.add(row_aux);

		add(listbox);
	}
}


public class Test : Gtk.ListBoxRow {

    public Test() {

        Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

		var lb = new Gtk.Label("AAAA");
		box.add(lb);
		add(box);
		//show_all();
    }

}
