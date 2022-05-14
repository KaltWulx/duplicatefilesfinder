public class DuplicateFiles.Resume: Gtk.Grid {


    private string view_name;
    private Gtk.Stack stack;
    private Gtk.Button btn_back;
    private Scanner scan;
    private Gtk.Label label_aux;
    private Gtk.Box box_viewer;



    public Resume( Gtk.Stack stack, Gtk.Button btn_back) {
        this.stack = stack;
        this.btn_back = btn_back;


        box_viewer = new Gtk.Box(Gtk.Orientation.VERTICAL, 0) {
		    expand = true,
		};

    }

    public async void fill_resume() {
        int i = 0;
        string map_size = scan.map_ocurrences_clean.size.to_string ();

        foreach(var entry in scan.map_ocurrences_clean.entries) {

                    var viewer = new DuplicateFiles.DuplicateViewer(entry.value.paths, i);
                    box_viewer.pack_start(viewer, true, true, 0);
                    i++;
                    string data_label = "Llenando vista: "+ i.to_string () +"/"+ map_size
                      + "...";
                    label_aux.label = data_label;
                    GLib.Idle.add(fill_resume.callback);
                    yield;
        }
    }

    public void set_data(Scanner scan) {
        this.scan = scan;
    }

    public void create_ui() {
        var lb_desc = new Gtk.Label("Exact Duplicates");
		lb_desc.justify = Gtk.Justification.LEFT;

		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 1) {
		    valign = Gtk.Align.START,
		    halign = Gtk.Align.START,
		    margin_start = 5
		};

		box.add(lb_desc);

		var panel = new Widget.Panel();

		string texto_chido = "<b>32.40 GB</b> in 3504 files found in total";

		label_aux = new Gtk.Label("") {
		    margin = 2,
		};

        label_aux.set_markup(texto_chido);

		var grid = new Gtk.Grid();
		grid.attach(box, 0, 0, 1, 1);
		grid.attach(panel, 0, 1, 1, 1);
		grid.attach(label_aux, 0, 2, 1, 1);

		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);

		grid.attach(separator, 1, 0, 1, 2);

        Gtk.ScrolledWindow scrolled = new Gtk.ScrolledWindow (null, null);

        scrolled.propagate_natural_height = true;
        scrolled.propagate_natural_width = true;
        scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled.add(box_viewer);

        grid.attach(scrolled, 2,0,1,2);
		add(grid);
		show_all();
    }

}
