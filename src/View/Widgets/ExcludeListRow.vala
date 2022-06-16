public class DuplicateFiles.ExcludeListRow : Gtk.ListBoxRow {

	public string icon_name {get; set;}
	public string text {get; set;}


	public ExcludeListRow (string icon_name, string text) {
		this.icon_name = icon_name;
		this.text = text;
		init_components();
	}

	public void init_components () {

		var icon = new Gtk.Image () {
		    icon_name = this.icon_name,
		    pixel_size = 16
		};

		var lb_text = new Gtk.Label (text);
		lb_text.width_chars = 10;
		//lb_text.max_width_chars = 1;
        lb_text.set_ellipsize (Pango.EllipsizeMode.MIDDLE);


		var grid = new Gtk.Grid () {
		    column_spacing = 0,
		    margin = 5,
		    margin_start = 5,
		    margin_end = 5
		};
        grid.set_column_homogeneous(false);

		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5) {
		    halign = Gtk.Align.START,
		    valign = Gtk.Align.BASELINE,
		};
        box.set_center_widget(lb_text);
        box.pack_start(icon, true, true, 0);

		var box_lb = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0) {
		    halign = Gtk.Align.END,
		    valign = Gtk.Align.BASELINE,
		};

		grid.attach(box, 0,0,1,1);
		grid.attach(box_lb, 1,0,1,1);
		add(grid);
		show_all ();
 	}
}
