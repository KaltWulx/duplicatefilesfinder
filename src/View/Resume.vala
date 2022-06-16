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

    private DuplicateFiles.PanelCategory panel;
    private Categories categories;
    private CategorySizeSum size_sum;
    private PreviewContentFile preview_content;
    private ItemDuplicateViewer tree_item_duplicate;

    public Resume( Gtk.Stack stack, Gtk.Button btn_back) {
        this.stack = stack;
        this.btn_back = btn_back;
		tree_item_duplicate = new ItemDuplicateViewer ();
		preview_content = new PreviewContentFile();
    }

    public void create_ui() {
        var lb_desc = new Granite.HeaderLabel ("Exact Duplicates");
		lb_desc.justify = Gtk.Justification.LEFT;

		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 1) {
		    valign = Gtk.Align.START,
		    halign = Gtk.Align.START,
		    margin_start = 5
		};

		box.add(lb_desc);

		categories = new Categories();
		size_sum = new CategorySizeSum ();
		panel = new DuplicateFiles.PanelCategory(categories, size_sum);
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

		Gtk.Separator separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
		grid.attach(separator, 1, 0, 1, 2);

        Gtk.ScrolledWindow scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.propagate_natural_height = true;
        scrolled.propagate_natural_width = true;
        scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled.add(tree_item_duplicate);

        grid.attach(scrolled, 2,0,1,2);
		this.attach(grid, 0, 1, 1,1);
		this.attach(preview_content, 3, 0, 2, 2);
		this.attach(info_bar, 0, 0, 1,1);
		this.add(label_aux);
		show_all();

		tree_item_duplicate.row_activated.connect(on_row_activated);
		panel.list_box.row_activated.connect(on_category_activated);
    }

    public void on_category_activated(Gtk.ListBoxRow row) {
        var row_cat = (CategoryListRow) row;
        switch( row_cat.text ) {

            case "Applications":
                GLib.debug("Applications!\n");
                tree_item_duplicate.show_applications ();

            break;

            case "Documents":
                GLib.debug("Documents!\n");
                tree_item_duplicate.show_documents ();

            break;

            case "Images":
                GLib.debug("Images!\n");
                tree_item_duplicate.show_images ();
            break;

            case "Audio":
            GLib.debug("Audio!\n");
            break;

            case "Video":
                GLib.debug("Video!\n");
                tree_item_duplicate.show_videos ();
            break;

            default:
                GLib.debug("Default!\n");
                tree_item_duplicate.show_all_categories ();
            break;
        }
    }

    public void on_row_activated(Gtk.TreeView tree, Gtk.TreePath path, Gtk.TreeViewColumn col) {

        Gtk.TreeIter iter;
        tree.model.get_iter(out iter, path);
        string file_path;
        tree.model.get(iter, 2, out file_path);
        GLib.debug("Data: %s\n", file_path);
        preview_content.load_content_media.begin(file_path);
        GLib.debug("on_row_activated!\n");
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
        int position = 0;
        string map_size = scanner.map_ocurrences_clean.size.to_string ();
        tree_item_duplicate.disconnect_model();

        foreach(var entry in scanner.map_ocurrences_clean.entries) {
            new Thread<void> (null, () => {
                tree_item_duplicate.add.begin(entry.value.paths);
            });
            position++;
            string data_label = "Llenando vista: "+ position.to_string () +"/"+ map_size + "...";
            label_aux.label = data_label;
            GLib.Idle.add(fill_resume.callback);
            yield;
        }
        tree_item_duplicate.connect_model();
        return true;
    }

    public async bool fill_panel_categories() {
        iterate_treeview ();
        panel.update_ui ();
        return true;
    }


    private void iterate_treeview() {
        tree_item_duplicate.model.foreach(get_categories_and_size);
    }

    public bool get_categories_and_size (Gtk.TreeModel model, Gtk.TreePath path, Gtk.TreeIter iter) {
        string file_path;

        if(path.get_depth() == 2) {
            model.get(iter, 2, out file_path);
            var mime_type = ContentType.guess(file_path, new uchar[0], null);

            if(mime_type.has_prefix("image/")) {
                categories.image = true;
            } else if(mime_type.has_prefix("video/")){
                categories.video = true;
            } else if(mime_type.has_prefix("text/")){
                categories.document = true;
            } else if(mime_type.has_prefix("application/")){
                categories.application = true;
            } else if(mime_type.has_prefix("audio/")){
                categories.audio = true;
            }
        }

         if(path.get_depth() > 1) {
            model.get(iter, 2, out file_path);
            var mime_type = ContentType.guess(file_path, new uchar[0], null);

            var f = File.new_for_path(file_path);
            FileInfo info = f.query_info("standard::*", 0);

            if(mime_type.has_prefix("image/")) {
                size_sum.image += info.get_size();
            } else if(mime_type.has_prefix("video/")){
                 size_sum.video += info.get_size();
            } else if(mime_type.has_prefix("text/")){
                 size_sum.document += info.get_size();
            } else if(mime_type.has_prefix("application/")){
                 size_sum.application += info.get_size();
            } else if(mime_type.has_prefix("audio/")){
                 size_sum.audio += info.get_size();
            }

            GLib.debug("Function: get_categories_and_size => %s\n", file_path);
        }
        return false;
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
