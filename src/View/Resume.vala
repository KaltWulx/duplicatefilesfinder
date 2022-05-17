public class DuplicateFiles.Resume: Gtk.Grid {
    private string view_name;
    private Gtk.Stack stack;
    private Gtk.Button btn_back;
    private Scanner scanner;
    private Gtk.Label label_aux;
    private Gtk.Box box_viewer;
    private Gtk.InfoBar info_bar;
    private	Gtk.Spinner spinner;
    private Gtk.Grid grid;

    private DuplicateFiles.Panel panel;


    private Categories categories;
    private CategorySizeSum size_sum;

    private Gee.ArrayList<DuplicateFiles.DuplicateViewer> list_viewer;

    public Resume( Gtk.Stack stack, Gtk.Button btn_back) {
        this.stack = stack;
        this.btn_back = btn_back;
        box_viewer = new Gtk.Box(Gtk.Orientation.VERTICAL, 0) {
		    vexpand = false,
            valign = Gtk.Align.START,
            halign = Gtk.Align.START,
		};
		list_viewer = new Gee.ArrayList<DuplicateFiles.DuplicateViewer> ();
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

		categories = new Categories();
		size_sum = new CategorySizeSum ();

		panel = new DuplicateFiles.Panel(categories, size_sum);

		panel.list_box.row_selected.connect( ()=> {
		    var row = (CategoryListRow) panel.list_box.get_selected_row ();
            switch(row.text) {
                case "Applications":
                    GLib.debug("Click en: %s\n", row.text);
                    show_category(row.text);
                break;

                case "Audio":
                    GLib.debug("Click en: %s\n", row.text);
                    show_category(row.text);
                break;

                case "Documents":
                    GLib.debug("Click en: %s\n", row.text);
                    show_category(row.text);
                break;

                case "Folders":
                    GLib.debug("Click en: %s\n", row.text);
                    show_category(row.text);
                break;

                case "Images":
                    GLib.debug("Click en: %s\n", row.text);
                    show_category(row.text);
                break;

                case "Video":
                    GLib.debug("Click en: %s\n", row.text);
                    show_category(row.text);
                break;

                default:
                    GLib.debug("Click en: %s\n", row.text);
                    show_category(row.text);
                break;
            }
		});

		string texto_chido = "<b>32.40 GB</b> in 3504 files found in total";
		label_aux = new Gtk.Label("") {
		    margin = 2,
		};


		info_bar = new Gtk.InfoBar();
		info_bar.set_message_type(Gtk.MessageType.WARNING);
		spinner = new Gtk.Spinner();
		spinner.active = true;

		var container = info_bar.get_content_area ();
		container.add(new Gtk.Label("Loading data, wait a moment..."));
		container.add(spinner);

		info_bar.revealed = true;

        label_aux.set_markup(texto_chido);

		grid = new Gtk.Grid();
		grid.attach(box, 0, 0, 1, 1);
		grid.attach(panel, 0, 1, 1, 1);
//		grid.attach(info_bar, 0, 2, 1, 1);

		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
		grid.attach(separator, 1, 0, 1, 2);
        Gtk.ScrolledWindow scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.propagate_natural_height = true;
        scrolled.propagate_natural_width = true;
        scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled.add(box_viewer);

        grid.attach(scrolled, 2,0,1,2);
		//add(grid);
		this.attach(grid, 0, 1, 1,1);
		this.attach(info_bar, 0, 0, 1,1);
		show_all();
    }

    public void disable_ui() {
        grid.sensitive = false;
    }

    public void hide_info_bar() {
        spinner.active = false;
		info_bar.revealed = false;
		grid.sensitive = true;
    }

    public async bool fill_resume() {
        int i = 0;
        string map_size = scanner.map_ocurrences_clean.size.to_string ();

        foreach(var entry in scanner.map_ocurrences_clean.entries) {

                    var viewer = new DuplicateFiles.DuplicateViewer(entry.value.paths, i);
                    box_viewer.pack_start(viewer, true, true, 0);
                    list_viewer.add(viewer);
                    i++;
                    string data_label = "Llenando vista: "+ i.to_string () +"/"+ map_size
                      + "...";
                    label_aux.label = data_label;
                    GLib.Idle.add(fill_resume.callback);
                    yield;
        }
        return true;
    }

    public void fill_panel_categories() {
        check_categories.begin( (obj, res) => {
                var result = check_categories.end(res);
                if(result) {
                    panel.update_ui();
                    hide_info_bar();
                }
        });

    }

    public async bool check_categories () {

        foreach(DuplicateViewer viewer in list_viewer) {

            if(viewer.content_type.has_prefix("application/")) {
                categories.application = true;
                size_sum.application += viewer.size_sum;
            }
            if(viewer.content_type.has_prefix("audio/")) {
                categories.audio = true;
                size_sum.audio += viewer.size_sum;
            }
            if(viewer.content_type.has_prefix("video/")) {
                categories.video = true;
                size_sum.video += viewer.size_sum;
            }
            if(viewer.content_type.has_prefix("image/")) {
                categories.image = true;
                size_sum.image += viewer.size_sum;
            }
            if(viewer.content_type.has_prefix("text/")) {
                categories.document = true;
                size_sum.document += viewer.size_sum;
            }
            GLib.Idle.add(check_categories.callback);
            yield;
        }
       return true;
    }


    private void show_category (string row_category) {
        //show all categories...
        foreach(DuplicateViewer viewer in list_viewer) {
            viewer.visible = true;
        }

        foreach(DuplicateViewer viewer in list_viewer) {

            if(row_category =="Applications" && !viewer.content_type.has_prefix("application/")) {
                viewer.visible = false;
            }
            if(row_category =="Images" && !viewer.content_type.has_prefix("image/")) {
                viewer.visible = false;
            }
            if(row_category =="Video" && !viewer.content_type.has_prefix("video/")) {
               viewer.visible = false;
            }

            if(row_category == "Documents" && !viewer.content_type.has_prefix("text/")) {
                viewer.visible = false;
            }
            if(row_category == "Audio" && !viewer.content_type.has_prefix("audio/")) {
                viewer.visible = false;
            }
        }
    }

    public void set_data(Scanner scanner) {
        this.scanner = scanner;
    }
}

public class CategorySizeSum {
            public int64 application;
            public int64 audio;
            public int64 video;
            public int64 image;
            public int64 document;
}

public class Categories {
            public bool application;
            public bool audio;
            public bool video;
            public bool image;
            public bool document;
}
